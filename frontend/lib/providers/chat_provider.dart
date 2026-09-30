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
  // Demo fallback responses — hardcoded ICMR-based answers that protect the
  // presentation if both the backend AND Groq direct APIs are unreachable.
  // Matched by keyword against the user's query before showing the generic error.
  static const Map<String, String> _demoFallbacks = {
    'diabetes': '⚕️ **Diabetes Management (ICMR Guidelines)**\n\n'
        '• **Diet:** Follow the Indian Plate Method — ½ plate vegetables, '
        '¼ plate whole grains (roti/brown rice), ¼ plate protein (dal/paneer/fish).\n'
        '• **Blood Sugar Targets:** Fasting 80–130 mg/dL, Post-meal <180 mg/dL, HbA1c <7%.\n'
        '• **Lifestyle:** Walk 30 minutes daily, reduce refined sugar and maida.\n'
        '• **Medication:** Continue prescribed medications (e.g., Metformin) as directed.\n\n'
        '🏥 *Please consult your doctor for personalized treatment. '
        'If blood sugar exceeds 300 mg/dL or you feel dizzy/confused, call 108 immediately.*',

    'blood pressure': '⚕️ **Blood Pressure Control (ICMR Guidelines)**\n\n'
        '• **Target:** Below 140/90 mmHg (below 130/80 if diabetic).\n'
        '• **DASH Diet:** Increase fruits, vegetables, low-fat dairy. '
        'Limit salt to <5g/day (about 1 teaspoon).\n'
        '• **Lifestyle:** 150 minutes moderate exercise/week, reduce alcohol, quit smoking.\n'
        '• **Medication:** Take antihypertensives at the same time daily.\n\n'
        '🏥 *Consult your doctor before changing medications. '
        'If BP exceeds 180/120, seek emergency care immediately.*',

    'fever': '⚕️ **Fever Management (ICMR Guidelines)**\n\n'
        '• **Hydration:** Drink 2–3 liters of fluids daily — water, ORS, coconut water, buttermilk.\n'
        '• **Paracetamol:** 500mg every 6 hours (max 4 doses/day). Avoid aspirin in dengue-prone areas.\n'
        '• **Rest:** Complete bed rest. Use light cotton clothing.\n'
        '• **When to worry:** Fever >103°F for 3+ days, rash, severe headache, or confusion.\n\n'
        '🏥 *Visit a doctor if fever persists beyond 3 days or is accompanied by '
        'difficulty breathing. Call 108 for emergencies.*',

    'air quality': '⚕️ **Air Quality Precautions (ICMR + CPCB Guidelines)**\n\n'
        '• **N95 Masks:** Wear when AQI exceeds 200 (Poor/Very Poor category).\n'
        '• **Avoid Outdoor Exercise:** Switch to indoor workouts when AQI >150.\n'
        '• **Indoor Air:** Use air purifiers with HEPA filters. Keep windows closed during peak pollution.\n'
        '• **Hydration:** Drink warm water with tulsi or ginger to soothe airways.\n'
        '• **Vulnerable Groups:** Children, elderly, and asthma patients should stay indoors when AQI >100.\n\n'
        '🏥 *If you experience persistent cough, chest tightness, or difficulty breathing, '
        'consult a pulmonologist immediately.*',

    'diet': '⚕️ **Healthy Indian Diet (ICMR & NIN Guidelines)**\n\n'
        '• **Indian Plate Method:** ½ plate vegetables/salad, ¼ plate whole grains, ¼ plate protein.\n'
        '• **Daily Targets:** 400g fruits & vegetables, 30g fiber, <5g salt, <25g added sugar.\n'
        '• **Good Sources:** Dal, rajma, chole (protein), ragi, jowar, bajra (millets), '
        'seasonal fruits, curd, green leafy vegetables.\n'
        '• **Avoid:** Excessive oil (>20ml/meal), packaged snacks, sugary drinks, maida-based foods.\n'
        '• **Hydration:** 8–10 glasses of water daily.\n\n'
        '🏥 *For personalized diet plans, especially for diabetes, heart disease, or kidney issues, '
        'please consult a registered dietitian.*',
  };

  /// Checks the user's query against demo fallback keywords.
  /// Returns a matching fallback response, or null if no keyword matches.
  static String? _findDemoFallback(String query) {
    final lower = query.toLowerCase();
    // Check each keyword — return the first match
    for (final entry in _demoFallbacks.entries) {
      if (lower.contains(entry.key)) return entry.value;
    }
    // Also match common synonyms that map to the same fallback
    if (lower.contains('sugar') || lower.contains('glucose') || lower.contains('hba1c')) {
      return _demoFallbacks['diabetes'];
    }
    if (lower.contains('bp') || lower.contains('hypertension')) {
      return _demoFallbacks['blood pressure'];
    }
    if (lower.contains('aqi') || lower.contains('pollution') || lower.contains('smog')) {
      return _demoFallbacks['air quality'];
    }
    if (lower.contains('nutrition') || lower.contains('food') || lower.contains('eating')) {
      return _demoFallbacks['diet'];
    }
    return null;
  }

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

      // Read persistent user ID and preferred language from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final effectiveLang = prefs.getString('user_language') ?? language;
      var userId = prefs.getString('user_id');
      if (userId == null || userId.isEmpty) {
        userId = prefs.getString('device_user_id');
        if (userId == null || userId.isEmpty) {
          userId = 'user_${DateTime.now().millisecondsSinceEpoch}';
          await prefs.setString('device_user_id', userId);
        }
      }

      request.body = jsonEncode({
        'user_id': userId,
        'query': text,
        'language': effectiveLang,
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

    // 3. If both APIs failed, try demo fallback responses for common health queries
    // This protects the presentation if LLM providers are down or keys are missing
    if (reply.isEmpty) {
      final fallback = _findDemoFallback(text);
      if (fallback != null) {
        reply = fallback;
      }
    }

    // 4. Last resort — generic error with emergency helpline
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
