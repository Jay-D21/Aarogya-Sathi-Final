import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../services/api_service.dart';
import '../services/location_service.dart';

class ChatMessage {
  final String id;
  final String userMessage;
  final String aiResponse;
  final DateTime timestamp;
  final bool isEmergency;

  ChatMessage({
    required this.id,
    required this.userMessage,
    required this.aiResponse,
    required this.timestamp,
    this.isEmergency = false,
  });
}

class ChatProvider extends ChangeNotifier {
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;
  bool _isTyping = false;

  List<ChatMessage> get messages => List.unmodifiable(_messages);
  bool get isLoading => _isLoading;
  bool get isTyping => _isTyping;

  Future<void> loadHistory() async {
    _isLoading = true;
    notifyListeners();
    try {
      final resp = await ApiService.get('/chat/history?limit=50');
      final data = resp['data'] as Map<String, dynamic>?;
      if (data != null && data['messages'] != null) {
        _messages.clear();
        for (final m in (data['messages'] as List).reversed) {
          _messages.add(ChatMessage(
            id: m['chat_id'] ?? '',
            userMessage: m['user_message'] ?? '',
            aiResponse: m['ai_response'] ?? '',
            timestamp:
                DateTime.tryParse(m['timestamp'] ?? '') ?? DateTime.now(),
            isEmergency:
                (m['safety_flags']?['emergency'] ?? false) == true,
          ));
        }
      }
    } catch (_) {
      // Offline or backend down — just show empty history
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> sendMessage(
    String text, {
    String language = 'en',
    Map<String, dynamic>? profile,
    Map<String, dynamic>? wearable,
    double? lat,
    double? lon,
  }) async {
    final tempMsg = ChatMessage(
      id: 'temp',
      userMessage: text,
      aiResponse: '',
      timestamp: DateTime.now(),
    );
    _messages.add(tempMsg);
    _isTyping = true;
    notifyListeners();

    String reply = '';
    bool isEmergency = _detectEmergency(text);

    try {
      // Fetch location if not provided
      if (lat == null || lon == null) {
        final pos = await LocationService.getCurrentPosition();
        if (pos != null) {
          lat = pos.latitude;
          lon = pos.longitude;
        }
      }

      // 1. First try our deployed FastAPI backend with SSE streaming
      final client = http.Client();
      final request = http.Request('POST', Uri.parse(ApiConfig.chatEndpoint));
      request.headers['Content-Type'] = 'application/json';
      
      final chatHistory = <Map<String, dynamic>>[];
      final pastMessages = _messages.where((m) => m.id != 'temp').toList();
      final last5 = pastMessages.reversed.take(5).toList().reversed;
      for (final m in last5) {
        if (m.userMessage.isNotEmpty) {
          chatHistory.add({'role': 'user', 'content': m.userMessage});
        }
        if (m.aiResponse.isNotEmpty) {
          chatHistory.add({'role': 'assistant', 'content': m.aiResponse});
        }
      }

      request.body = jsonEncode({
        'query': text,
        'language': language,
        if (profile != null) 'profile': profile,
        if (wearable != null) 'wearable': wearable,
        if (lat != null) 'lat': lat,
        if (lon != null) 'lon': lon,
        'chat_history': chatHistory,
      });

      final streamedResponse = await client.send(request).timeout(const Duration(seconds: 25));
      if (streamedResponse.statusCode == 200) {
        final lines = streamedResponse.stream
            .transform(utf8.decoder)
            .transform(const LineSplitter());

        final buffer = StringBuffer();
        await for (final line in lines) {
          if (line.startsWith('data: ')) {
            final jsonStr = line.substring(6).trim();
            if (jsonStr.isNotEmpty) {
              try {
                final tokenObj = jsonDecode(jsonStr);
                final token = tokenObj['token'] as String? ?? '';
                buffer.write(token);
              } catch (_) {}
            }
          }
        }
        if (buffer.isNotEmpty) {
          reply = buffer.toString().trim();
        }
      }
    } catch (_) {
      // Backend request failed or timed out
    }

    // 2. If backend response is empty or failed, fallback to Groq Cloud API directly
    if (reply.isEmpty) {
      try {
        final groqReply = await _callGroqDirectly(text);
        if (groqReply != null && groqReply.isNotEmpty) {
          reply = groqReply.trim();
        }
      } catch (_) {}
    }

    // 3. Last resort fallback
    if (reply.isEmpty) {
      reply = 'I am unable to connect to the server right now. '
          'Please check your internet connection.\n\n'
          'If this is a medical emergency, please call 108 immediately.';
    }

    _messages.removeLast();
    _messages.add(ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userMessage: text,
      aiResponse: reply,
      timestamp: DateTime.now(),
      isEmergency: isEmergency,
    ));
    _isTyping = false;
    notifyListeners();
  }

  static bool _detectEmergency(String text) {
    final lower = text.toLowerCase();
    const emergencyKeywords = [
      'chest pain', 'heart attack', 'cannot breathe', 'shortness of breath',
      'stroke', 'unconscious', 'severe bleeding', 'poison', 'ambulance',
      'emergency', 'fainted', 'seizure', 'convulsion', 'choking'
    ];
    for (final kw in emergencyKeywords) {
      if (lower.contains(kw)) return true;
    }
    return false;
  }

  /// Calls the Groq Cloud API directly when our backend is unreachable.
  /// Uses llama-3.1-8b-instant which is fast and free-tier friendly.
  static Future<String?> _callGroqDirectly(String userMessage) async {
    try {
      const apiKey = String.fromEnvironment('GROQ_API_KEY', defaultValue: '');
      if (apiKey.isEmpty) return null;
      const url = 'https://api.groq.com/openai/v1/chat/completions';

      final resp = await http
          .post(
            Uri.parse(url),
            headers: {
              'Authorization': 'Bearer $apiKey',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'model': 'llama-3.1-8b-instant',
              'messages': [
                {
                  'role': 'system',
                  'content': 'You are Aarogya Sathi, a caring AI health '
                      'companion for India. Provide helpful, accurate guidance '
                      'based on ICMR and WHO guidelines. Always recommend '
                      'consulting a qualified doctor for diagnosis or treatment. '
                      'For emergencies, always advise the user to call 108. '
                      'Keep responses concise, practical, and empathetic. '
                      'Use simple language that non-medical users can understand.',
                },
                {'role': 'user', 'content': userMessage},
              ],
              'temperature': 0.7,
              'max_tokens': 600,
            }),
          )
          .timeout(const Duration(seconds: 20));

      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body) as Map<String, dynamic>;
        return data['choices']?[0]?['message']?['content'] as String?;
      }
    } catch (_) {}
    return null;
  }

  void clearMessages() {
    _messages.clear();
    notifyListeners();
  }
}
