// Phase 12 — PDF source service.
//
// Responsibilities:
//   1. Build the absolute URL of the PDF that backs a given `Sources` row,
//      using the topic's subject + chapter codes to namespace the file on
//      the VPS (matches the layout used by `vps/socdaily-pdfs/`).
//   2. Cache downloaded bytes on disk under
//      `<docDir>/socdaily/pdf_cache/<sha1(url)>.pdf` with a 30-day TTL.
//
// We deliberately keep this independent from `flutter_cache_manager` to keep
// the dependency list small (Dio for transport + the platform's documents
// directory is enough).

import 'dart:async';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../data/db/app_database.dart';
import '../data/db/content_repository.dart';
import 'pdf_source_config.dart';

@immutable
class PdfSourceLocation {
  const PdfSourceLocation({
    required this.subjectCode,
    required this.chapterCode,
    required this.pdfPath,
    this.page,
  });

  /// Subject `code` (e.g. `soc-fundamentals`).
  final String subjectCode;

  /// Chapter `code` (e.g. `siem`).
  final String chapterCode;

  /// Value of `sources.pdf_path`. Either a bare filename like
  /// `"SOC Analyst Guide.pdf"` or a relative path like
  /// `"blue-team/phishing/phishing-indicators.pdf"`.
  final String pdfPath;

  /// 1-indexed source page (matches `flashcards.source_page` semantics).
  final int? page;
}

@immutable
class PdfSourceContext {
  const PdfSourceContext({
    required this.source,
    required this.subjectCode,
    required this.subjectTitle,
    required this.chapterCode,
    required this.chapterTitle,
    required this.topicTitle,
  });

  final Source source;
  final String subjectCode;
  final String subjectTitle;
  final String chapterCode;
  final String chapterTitle;
  final String topicTitle;

  PdfSourceLocation locationFor({int? page}) => PdfSourceLocation(
        subjectCode: subjectCode,
        chapterCode: chapterCode,
        pdfPath: source.pdfPath,
        page: page,
      );
}

/// Pluggable lookup so tests can stub the DB+filesystem out.
typedef PdfCacheDirResolver = Future<Directory> Function();

class PdfSourceService {
  PdfSourceService({
    required PdfSourceConfig config,
    required Dio dio,
    required PdfCacheDirResolver cacheDir,
    Duration cacheTtl = const Duration(days: 30),
  })  : _config = config,
        _dio = dio,
        _cacheDir = cacheDir,
        _ttl = cacheTtl;

  final PdfSourceConfig _config;
  final Dio _dio;
  final PdfCacheDirResolver _cacheDir;
  final Duration _ttl;

  PdfSourceConfig get config => _config;

  /// Builds the absolute URL for [loc]. Pure — no I/O, safe to unit-test.
  String buildUrl(PdfSourceLocation loc) {
    final base = _stripTrailingSlashes(_config.baseUrl);
    final rel = buildRelativePath(loc);
    return '$base/$rel';
  }

  /// Builds the path portion (without the base URL) — exposed for tests.
  static String buildRelativePath(PdfSourceLocation loc) {
    final raw = loc.pdfPath.trim();
    if (raw.isEmpty) {
      // Fall back to topic-coded path so the caller still produces *something*
      // rather than a malformed URL.
      return '${loc.subjectCode}/${loc.chapterCode}/source.pdf';
    }
    final hasSlash = raw.contains('/') || raw.contains(r'\');
    if (hasSlash) {
      final normalized = raw.replaceAll(r'\', '/');
      final segments = normalized
          .split('/')
          .where((s) => s.isNotEmpty)
          .toList(growable: false);
      final slugged = <String>[];
      for (var i = 0; i < segments.length; i++) {
        final isLast = i == segments.length - 1;
        slugged.add(isLast
            ? slugifyPdfFilename(segments[i])
            : slugifyPathSegment(segments[i]));
      }
      return slugged.join('/');
    }
    final slug = slugifyPdfFilename(raw);
    return '${loc.subjectCode}/${loc.chapterCode}/$slug';
  }

  /// Stable cache key — sha1 of the absolute URL. Exposed for tests.
  static String cacheKeyFor(String url) {
    return sha1.convert(url.codeUnits).toString();
  }

  static String slugifyPathSegment(String seg) {
    final lower = seg.toLowerCase().trim();
    final replaced = lower.replaceAll(RegExp(r'[^a-z0-9]+'), '-');
    return _trimDashes(replaced);
  }

  /// Slugifies a PDF filename. Strips the `.pdf` (case-insensitive) suffix,
  /// lowercases, replaces any non-alphanumeric run with a single dash, trims
  /// leading/trailing dashes, then re-appends `.pdf`.
  static String slugifyPdfFilename(String name) {
    final trimmed = name.trim();
    final lower = trimmed.toLowerCase();
    final withoutExt =
        lower.endsWith('.pdf') ? lower.substring(0, lower.length - 4) : lower;
    final slug = _trimDashes(
      withoutExt.replaceAll(RegExp(r'[^a-z0-9]+'), '-'),
    );
    return slug.isEmpty ? 'source.pdf' : '$slug.pdf';
  }

  static String _trimDashes(String s) {
    var out = s;
    while (out.startsWith('-')) {
      out = out.substring(1);
    }
    while (out.endsWith('-')) {
      out = out.substring(0, out.length - 1);
    }
    return out;
  }

  static String _stripTrailingSlashes(String s) {
    var out = s;
    while (out.endsWith('/')) {
      out = out.substring(0, out.length - 1);
    }
    return out;
  }

  /// Returns the cached file path for [loc], downloading first when needed
  /// or when the on-disk copy is older than [_ttl].
  Future<File> fetchPdf(PdfSourceLocation loc) async {
    if (!_config.isConfigured) {
      throw const PdfSourceException('PDF host is not configured.');
    }
    final url = buildUrl(loc);
    return fetchUrl(url);
  }

  Future<File> fetchUrl(String url) async {
    final dir = await _cacheDir();
    await dir.create(recursive: true);
    final file = File(p.join(dir.path, '${cacheKeyFor(url)}.pdf'));

    if (await file.exists()) {
      final stat = await file.stat();
      final age = DateTime.now().difference(stat.modified);
      if (age < _ttl) return file;
    }

    try {
      final response = await _dio.get<List<int>>(
        url,
        options: Options(
          responseType: ResponseType.bytes,
          followRedirects: true,
          headers: const {'Accept': 'application/pdf'},
        ),
      );
      final bytes = response.data;
      if (bytes == null || bytes.isEmpty) {
        throw const PdfSourceException('Empty response from PDF host.');
      }
      await file.writeAsBytes(bytes, flush: true);
      return file;
    } on DioException catch (e) {
      throw PdfSourceException(
        e.response != null
            ? 'PDF host returned ${e.response!.statusCode}.'
            : 'Could not reach PDF host (${e.message ?? "network error"}).',
      );
    }
  }

  /// Convenience: returns the raw bytes (handy for `printing.PdfPreview`).
  Future<Uint8List> fetchPdfBytes(PdfSourceLocation loc) async {
    final file = await fetchPdf(loc);
    return file.readAsBytes();
  }
}

class PdfSourceException implements Exception {
  const PdfSourceException(this.message);
  final String message;

  @override
  String toString() => 'PdfSourceException: $message';
}

/// Riverpod wiring -----------------------------------------------------------

final _pdfDioProvider = Provider<Dio>((ref) {
  final dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(minutes: 2),
    sendTimeout: const Duration(seconds: 15),
  ));
  ref.onDispose(dio.close);
  return dio;
});

Future<Directory> _defaultPdfCacheDir() async {
  final docs = await getApplicationDocumentsDirectory();
  return Directory(p.join(docs.path, 'socdaily', 'pdf_cache'));
}

final pdfSourceServiceProvider = Provider<PdfSourceService>((ref) {
  return PdfSourceService(
    config: ref.watch(pdfSourceConfigProvider),
    dio: ref.watch(_pdfDioProvider),
    cacheDir: _defaultPdfCacheDir,
  );
});

/// Resolves a `sources.id` to a rich [PdfSourceContext] that has the
/// surrounding subject + chapter + topic metadata — needed both by the
/// URL builder and the viewer screen's AppBar/banner.
class PdfSourceLookup {
  PdfSourceLookup(this._db);

  final AppDatabase _db;

  Future<PdfSourceContext?> contextFor({
    required int sourceId,
    int? topicId,
  }) async {
    final source = await (_db.select(_db.sources)
          ..where((s) => s.id.equals(sourceId)))
        .getSingleOrNull();
    if (source == null) return null;

    Topic? topic;
    if (topicId != null) {
      topic = await (_db.select(_db.topics)
            ..where((t) => t.id.equals(topicId)))
          .getSingleOrNull();
    }
    final resolvedTopic = topic ?? await _pickTopicForSource(sourceId);
    if (resolvedTopic == null) {
      // No flashcard / question references this source yet — fall back to a
      // synthetic context so the URL builder still has *some* scoping.
      return PdfSourceContext(
        source: source,
        subjectCode: 'uncategorized',
        subjectTitle: 'Uncategorized',
        chapterCode: 'misc',
        chapterTitle: 'Misc',
        topicTitle: source.title ?? source.pdfPath,
      );
    }
    final chapter = await (_db.select(_db.chapters)
          ..where((c) => c.id.equals(resolvedTopic.chapterId)))
        .getSingleOrNull();
    if (chapter == null) return null;
    final subject = await (_db.select(_db.subjects)
          ..where((s) => s.id.equals(chapter.subjectId)))
        .getSingleOrNull();
    if (subject == null) return null;

    return PdfSourceContext(
      source: source,
      subjectCode: subject.code,
      subjectTitle: subject.title,
      chapterCode: chapter.code,
      chapterTitle: chapter.title,
      topicTitle: resolvedTopic.title,
    );
  }

  Future<Topic?> _pickTopicForSource(int sourceId) async {
    // Any flashcard pointing at this source is fine — they all live in the
    // same topic-coded folder per the seed convention.
    final fc = await (_db.select(_db.flashcards)
          ..where((f) => f.sourceId.equals(sourceId))
          ..limit(1))
        .getSingleOrNull();
    if (fc != null) {
      return (_db.select(_db.topics)..where((t) => t.id.equals(fc.topicId)))
          .getSingleOrNull();
    }
    final q = await (_db.select(_db.questions)
          ..where((qq) => qq.sourceId.equals(sourceId))
          ..limit(1))
        .getSingleOrNull();
    if (q != null) {
      return (_db.select(_db.topics)..where((t) => t.id.equals(q.topicId)))
          .getSingleOrNull();
    }
    return null;
  }
}

final pdfSourceLookupProvider = Provider<PdfSourceLookup>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return PdfSourceLookup(db);
});

