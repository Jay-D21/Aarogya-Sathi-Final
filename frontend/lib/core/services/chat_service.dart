import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/config/api_config.dart';
import 'package:frontend/features/chat/data/chat_request_model.dart';

final chatServiceProvider = Provider<ChatService>((ref) {
  return ChatService(Dio());
});

class ChatToken {
  final String token;
  final bool done;
  final bool? translated;

  const ChatToken({
    required this.token,
    required this.done,
    this.translated,
  });

  factory ChatToken.fromJson(Map<String, dynamic> json) {
    return ChatToken(
      token: json['token'] as String? ?? '',
      done: json['done'] as bool? ?? false,
      translated: json['translated'] as bool?,
    );
  }
}

class ChatService {
  final Dio _dio;

  ChatService(this._dio) {
    _dio.options.baseUrl = ApiConfig.baseUrl;
  }

  Stream<ChatToken> streamChat(ChatRequestModel request) async* {
    try {
      final response = await _dio.post(
        ApiConfig.chatEndpoint,
        data: request.toJson(),
        options: Options(
          responseType: ResponseType.stream,
          headers: {
            'Accept': 'text/event-stream',
          },
        ),
      );

      final stream = response.data.stream as Stream<Uint8List>;
      String buffer = '';

      await for (final chunk in stream) {
        final text = utf8.decode(chunk, allowMalformed: true);
        buffer += text;

        final lines = buffer.split('\n');
        buffer = lines.removeLast();

        for (final line in lines) {
          final trimmed = line.trim();
          if (trimmed.startsWith('data:')) {
            final dataStr = trimmed.substring(5).trim();
            if (dataStr.isNotEmpty) {
              try {
                final json = jsonDecode(dataStr);
                final token = ChatToken.fromJson(json);
                yield token;
                if (token.done) {
                  return;
                }
              } catch (e) {
                debugPrint('Error parsing SSE data line: $e');
              }
            }
          }
        }
      }
    } catch (e) {
      throw Exception('Failed to stream chat: $e');
    }
  }
}
