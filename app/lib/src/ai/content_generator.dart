// HTTP client for the SOCDaily content-generator service (P14.A FastAPI).
//
// Endpoints:
//   GET  /pdfs       — list PDFs available on the server.
//   POST /generate   — request a fresh TopicSeed for a (subject, chapter,
//                      topic, page-range) tuple.
//
// Returns the raw `TopicSeed` JSON map (matches the bundled seed schema)
// so it can be fed straight to [SeedImporter.importTopicSeed].

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'generator_settings.dart';

class GeneratorException implements Exception {
  GeneratorException(this.message, {this.statusCode});
  final String message;
  final int? statusCode;
  @override
  String toString() =>
      statusCode == null ? message : '$message (status=$statusCode)';
}

class PdfListing {
  const PdfListing({required this.name, required this.sizeBytes});
  final String name;
  final int sizeBytes;
}

class GenerateRequest {
  const GenerateRequest({
    required this.subjectCode,
    required this.subjectTitle,
    required this.chapterCode,
    required this.chapterTitle,
    required this.topicCode,
    required this.topicTitle,
    required this.pdfFilename,
    required this.pageStart,
    required this.pageEnd,
    this.hint,
    this.nFlashcards = 6,
    this.nQuestions = 4,
    this.contentLang,
  });

  final String subjectCode;
  final String subjectTitle;
  final String chapterCode;
  final String chapterTitle;
  final String topicCode;
  final String topicTitle;
  final String pdfFilename;
  final int pageStart;
  final int pageEnd;
  final String? hint;
  final int nFlashcards;
  final int nQuestions;

  /// `'vi'`, `'en'`, or `'bilingual'`. `null` = use server default.
  final String? contentLang;

  Map<String, dynamic> toJson() => {
        'subject_code': subjectCode,
        'subject_title': subjectTitle,
        'chapter_code': chapterCode,
        'chapter_title': chapterTitle,
        'topic_code': topicCode,
        'topic_title': topicTitle,
        'pdf_filename': pdfFilename,
        'page_start': pageStart,
        'page_end': pageEnd,
        'n_flashcards': nFlashcards,
        'n_questions': nQuestions,
        if (hint != null && hint!.isNotEmpty) 'hint': hint,
        if (contentLang != null) 'content_lang': contentLang,
      };
}

class ContentGeneratorService {
  ContentGeneratorService({
    required this.baseUrl,
    required this.token,
    Dio? dio,
  }) : _dio = dio ?? Dio();

  final String baseUrl;
  final String token;
  final Dio _dio;

  bool get isConfigured =>
      baseUrl.trim().isNotEmpty && token.trim().isNotEmpty;

  Map<String, String> get _headers => {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      };

  Future<List<PdfListing>> listPdfs({Duration? timeout}) async {
    if (!isConfigured) {
      throw GeneratorException('Generator is not configured.');
    }
    final res = await _dio.get<List<dynamic>>(
      '${_normalize(baseUrl)}/pdfs',
      options: Options(
        headers: _headers,
        sendTimeout: timeout ?? const Duration(seconds: 15),
        receiveTimeout: timeout ?? const Duration(seconds: 30),
      ),
    );
    final data = res.data;
    if (data == null) {
      throw GeneratorException('Empty PDF list response.',
          statusCode: res.statusCode);
    }
    return data
        .cast<Map<String, dynamic>>()
        .map((m) => PdfListing(
              name: m['name'] as String,
              sizeBytes: (m['size_bytes'] as num?)?.toInt() ?? 0,
            ))
        .toList();
  }

  /// POSTs `/generate` and returns the raw `TopicSeed` JSON.
  ///
  /// The returned map matches the bundled seed schema in
  /// `app/assets/seed/<topic>.json` so it can be fed directly to
  /// [SeedImporter.importTopicSeed].
  Future<Map<String, dynamic>> generate(
    GenerateRequest req, {
    Duration? timeout,
  }) async {
    if (!isConfigured) {
      throw GeneratorException('Generator is not configured.');
    }
    try {
      final res = await _dio.post<Map<String, dynamic>>(
        '${_normalize(baseUrl)}/generate',
        data: req.toJson(),
        options: Options(
          headers: _headers,
          sendTimeout: timeout ?? const Duration(seconds: 30),
          // Generation can take 30-60s for a long page range; mirror the
          // 5-minute nginx proxy_read_timeout from P14.A.
          receiveTimeout: timeout ?? const Duration(minutes: 5),
        ),
      );
      final data = res.data;
      if (data == null) {
        throw GeneratorException('Empty response from /generate.',
            statusCode: res.statusCode);
      }
      return data;
    } on DioException catch (e) {
      final code = e.response?.statusCode;
      final detail = _extractDetail(e.response?.data) ?? e.message ?? 'unknown';
      throw GeneratorException(detail, statusCode: code);
    }
  }

  static String? _extractDetail(Object? body) {
    if (body is Map) {
      final d = body['detail'];
      if (d is String) return d;
    }
    return null;
  }

  static String _normalize(String url) {
    final stripped = url.trim();
    return stripped.endsWith('/')
        ? stripped.substring(0, stripped.length - 1)
        : stripped;
  }
}

/// Resolves a [ContentGeneratorService] from current [GeneratorSettings].
final contentGeneratorServiceProvider = Provider<ContentGeneratorService>(
  (ref) {
    final s = ref.watch(generatorSettingsControllerProvider);
    return ContentGeneratorService(baseUrl: s.baseUrl, token: s.token);
  },
);
