import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:frontend/core/services/chat_service.dart';
import 'package:frontend/core/services/profile_service.dart';
import 'package:frontend/features/chat/data/chat_request_model.dart';
import 'package:frontend/features/dashboard/presentation/providers/dashboard_providers.dart';

enum MessageSender { user, ai }

class ChatMessage {
  final String id;
  final String text;
  final MessageSender sender;
  final bool isStreaming;

  ChatMessage({
    required this.id,
    required this.text,
    required this.sender,
    this.isStreaming = false,
  });

  ChatMessage copyWith({
    String? id,
    String? text,
    MessageSender? sender,
    bool? isStreaming,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      text: text ?? this.text,
      sender: sender ?? this.sender,
      isStreaming: isStreaming ?? this.isStreaming,
    );
  }
}

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final List<ChatMessage> _messages = [];
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final stt.SpeechToText _speech = stt.SpeechToText();
  
  bool _isListening = false;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _initSpeech();
    _messages.add(
      ChatMessage(
        id: DateTime.now().toString(),
        text: 'Hello! I am Aarogya Sathi, your AI health assistant. How can I help you today?',
        sender: MessageSender.ai,
      )
    );
  }

  void _initSpeech() async {
    await _speech.initialize();
    if (mounted) setState(() {});
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty) return;
    
    final query = text.trim();
    _textController.clear();
    
    setState(() {
      _messages.add(
        ChatMessage(
          id: DateTime.now().toString(),
          text: query,
          sender: MessageSender.user,
        )
      );
      _isProcessing = true;
    });
    
    Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);

    final aiMessageId = DateTime.now().toString();
    setState(() {
      _messages.add(
        ChatMessage(
          id: aiMessageId,
          text: '',
          sender: MessageSender.ai,
          isStreaming: true,
        )
      );
    });
    
    Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);

    try {
      final chatService = ref.read(chatServiceProvider);
      final sensorService = ref.read(sensorServiceProvider);

      // Load real profile from SharedPreferences
      final profileService = ProfileService();
      final savedProfile = await profileService.loadProfile();
      UserProfileData? profileData;
      if (savedProfile != null) {
        profileData = UserProfileData(
          age: savedProfile.age,
          gender: savedProfile.gender,
          conditions: savedProfile.conditions,
          medications: savedProfile.medications,
        );
      }

      // Fetch live wearable data from Health Connect (Fitbit/Google Fit)
      final wearableData = await sensorService.getWearableData();
      WearableDataModel? wearableForChat;
      if (wearableData.todaySteps != null || wearableData.heartRateBpm != null) {
        wearableForChat = WearableDataModel(
          todaySteps: wearableData.todaySteps,
          caloriesBurned: wearableData.caloriesBurned,
          heartRateBpm: wearableData.heartRateBpm,
          restingHeartRate: wearableData.restingHeartRate,
          spo2Percent: wearableData.spo2Percent,
          bloodGlucoseMgDl: wearableData.bloodGlucoseMgDl,
          bpSystolic: wearableData.bpSystolic,
          bpDiastolic: wearableData.bpDiastolic,
          bodyTempCelsius: wearableData.bodyTempCelsius,
          sleepTotalHours: wearableData.sleepTotalHours,
          sleepRemHours: wearableData.sleepRemHours,
          sleepDeepHours: wearableData.sleepDeepHours,
          sleepLightHours: wearableData.sleepLightHours,
          weightKg: wearableData.weightKg,
        );
      }

      // Get GPS location for AQI context
      final position = await sensorService.getCurrentLocation();

      final request = ChatRequestModel(
        query: query,
        language: 'en',
        profile: profileData,
        wearable: wearableForChat,
        lat: position?.latitude,
        lon: position?.longitude,
      );

      String accumulatedText = '';
      
      await for (final token in chatService.streamChat(request)) {
        accumulatedText += token.token;
        
        if (mounted) {
          setState(() {
            final index = _messages.indexWhere((m) => m.id == aiMessageId);
            if (index != -1) {
              _messages[index] = _messages[index].copyWith(
                text: accumulatedText,
                isStreaming: !token.done,
              );
            }
          });
          _scrollToBottom();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Connection error: $e')),
        );
        setState(() {
          final index = _messages.indexWhere((m) => m.id == aiMessageId);
          if (index != -1 && _messages[index].text.isEmpty) {
            _messages.removeAt(index);
          } else if (index != -1) {
            _messages[index] = _messages[index].copyWith(isStreaming: false);
          }
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
        _scrollToBottom();
      }
    }
  }

  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (val) {
          if (val == 'done' && mounted) {
            setState(() => _isListening = false);
          }
        },
        onError: (val) {
          if (mounted) {
            setState(() => _isListening = false);
          }
        },
      );
      if (available && mounted) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (val) {
            if (mounted) {
              setState(() {
                _textController.text = val.recognizedWords;
              });
            }
          },
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
      if (_textController.text.isNotEmpty) {
        _sendMessage(_textController.text);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Aarogya Sathi'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16.0),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final isUser = message.sender == MessageSender.user;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Column(
                    crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          if (!isUser) ...[
                            CircleAvatar(
                              backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                              child: Icon(Icons.health_and_safety, color: theme.colorScheme.primary),
                            ),
                            const SizedBox(width: 8),
                          ],
                          Flexible(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                              decoration: BoxDecoration(
                                color: isUser ? theme.colorScheme.primary : theme.colorScheme.surfaceContainerHighest,
                                borderRadius: BorderRadius.only(
                                  topLeft: const Radius.circular(16),
                                  topRight: const Radius.circular(16),
                                  bottomLeft: Radius.circular(isUser ? 16 : 0),
                                  bottomRight: Radius.circular(isUser ? 0 : 16),
                                ),
                              ),
                              child: Text(
                                message.text.isEmpty && message.isStreaming ? '...' : message.text,
                                style: TextStyle(
                                  color: isUser ? theme.colorScheme.onPrimary : theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                          ),
                          if (isUser) ...[
                            const SizedBox(width: 8),
                            CircleAvatar(
                              backgroundColor: theme.colorScheme.secondary.withOpacity(0.1),
                              child: Icon(Icons.person, color: theme.colorScheme.secondary),
                            ),
                          ],
                        ],
                      ),
                      if (!isUser && message.text.isNotEmpty && !message.isStreaming)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0, left: 48.0),
                          child: Text(
                            'Disclaimer: This is AI-generated advice and not a substitute for professional medical guidance.',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(0.5),
                              fontSize: 10,
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
          if (_isProcessing && _messages.isNotEmpty && _messages.last.sender == MessageSender.user)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  const SizedBox(width: 16),
                  const SizedBox(
                    height: 16,
                    width: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  const SizedBox(width: 8),
                  Text('Aarogya Sathi is typing...', style: theme.textTheme.bodySmall),
                ],
              ),
            ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(_isListening ? Icons.mic : Icons.mic_none),
                    color: _isListening ? theme.colorScheme.primary : null,
                    onPressed: _listen,
                  ),
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      decoration: InputDecoration(
                        hintText: 'Ask Aarogya Sathi...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      ),
                      onSubmitted: _sendMessage,
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.send),
                    color: theme.colorScheme.primary,
                    onPressed: () => _sendMessage(_textController.text),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
