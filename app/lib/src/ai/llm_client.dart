// Provider-agnostic LLM client interface used by the in-app AI tutor.
// Two implementations (OpenAI-compatible + Anthropic native) mirror the
// Python pipeline so we can share prompts.

import 'package:dio/dio.dart';

class TutorPrompt {
  const TutorPrompt({required this.system, required this.user});
  final String system;
  final String user;
}

abstract class LlmClient {
  Future<String> complete(TutorPrompt prompt, {Duration? timeout});
}

class LlmException implements Exception {
  LlmException(this.message, {this.statusCode});
  final String message;
  final int? statusCode;
  @override
  String toString() =>
      statusCode == null ? message : '$message (status=$statusCode)';
}

class OpenAICompatClient implements LlmClient {
  OpenAICompatClient({
    required this.baseUrl,
    required this.apiKey,
    required this.model,
    this.temperature = 0.2,
    this.maxTokens = 600,
    Dio? dio,
  }) : _dio = dio ?? Dio();

  final String baseUrl;
  final String apiKey;
  final String model;
  final double temperature;
  final int maxTokens;
  final Dio _dio;

  @override
  Future<String> complete(TutorPrompt prompt, {Duration? timeout}) async {
    if (apiKey.isEmpty) {
      throw LlmException('API key is empty');
    }
    final url = '${_normalize(baseUrl)}/chat/completions';
    final res = await _dio.post<Map<String, dynamic>>(
      url,
      data: {
        'model': model,
        'temperature': temperature,
        'max_tokens': maxTokens,
        'messages': [
          {'role': 'system', 'content': prompt.system},
          {'role': 'user', 'content': prompt.user},
        ],
      },
      options: Options(
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
        sendTimeout: timeout ?? const Duration(seconds: 30),
        receiveTimeout: timeout ?? const Duration(seconds: 60),
      ),
    );
    final data = res.data;
    if (data == null) {
      throw LlmException('Empty response', statusCode: res.statusCode);
    }
    final choices = data['choices'] as List?;
    if (choices == null || choices.isEmpty) {
      throw LlmException('No choices in response',
          statusCode: res.statusCode);
    }
    final msg = (choices.first as Map)['message'] as Map?;
    final content = msg?['content'] as String?;
    if (content == null || content.isEmpty) {
      throw LlmException('Empty content',
          statusCode: res.statusCode);
    }
    return content.trim();
  }

  static String _normalize(String url) {
    final stripped = url.trim();
    return stripped.endsWith('/')
        ? stripped.substring(0, stripped.length - 1)
        : stripped;
  }
}

class AnthropicClient implements LlmClient {
  AnthropicClient({
    required this.apiKey,
    required this.model,
    this.maxTokens = 600,
    this.temperature = 0.2,
    Dio? dio,
  }) : _dio = dio ?? Dio();

  final String apiKey;
  final String model;
  final int maxTokens;
  final double temperature;
  final Dio _dio;

  static const _endpoint = 'https://api.anthropic.com/v1/messages';
  static const _apiVersion = '2023-06-01';

  @override
  Future<String> complete(TutorPrompt prompt, {Duration? timeout}) async {
    if (apiKey.isEmpty) {
      throw LlmException('API key is empty');
    }
    final res = await _dio.post<Map<String, dynamic>>(
      _endpoint,
      data: {
        'model': model,
        'system': prompt.system,
        'max_tokens': maxTokens,
        'temperature': temperature,
        'messages': [
          {'role': 'user', 'content': prompt.user},
        ],
      },
      options: Options(
        headers: {
          'x-api-key': apiKey,
          'anthropic-version': _apiVersion,
          'Content-Type': 'application/json',
        },
        sendTimeout: timeout ?? const Duration(seconds: 30),
        receiveTimeout: timeout ?? const Duration(seconds: 60),
      ),
    );
    final data = res.data;
    if (data == null) {
      throw LlmException('Empty response', statusCode: res.statusCode);
    }
    final content = data['content'] as List?;
    if (content == null || content.isEmpty) {
      throw LlmException('Empty content',
          statusCode: res.statusCode);
    }
    final first = content.first as Map;
    final text = first['text'] as String?;
    if (text == null || text.isEmpty) {
      throw LlmException('Empty text',
          statusCode: res.statusCode);
    }
    return text.trim();
  }
}
