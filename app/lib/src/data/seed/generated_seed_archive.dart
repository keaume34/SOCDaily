// Phase 14.C — Persist on-demand-generated seeds to disk.
//
// After `SeedImporter.importTopicSeed` lands a generated TopicSeed in the
// local DB, we ALSO archive the raw JSON under
//
//   <getApplicationDocumentsDirectory>/socdaily/generated/<yyyy-mm-dd>/<topic>.json
//
// so the user can review / roll back / re-import a previous generation.
// Best-effort: if the write fails (no permission, disk full, etc.) we
// surface the error to logs but don't break the in-app flow because the
// seed already lives in SQLite.

import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class GeneratedSeedArchive {
  GeneratedSeedArchive({Directory? rootOverride}) : _rootOverride = rootOverride;

  /// Test hook — when set, [_root] returns this directory instead of
  /// `getApplicationDocumentsDirectory`.
  final Directory? _rootOverride;

  Future<Directory> _root() async {
    final override = _rootOverride;
    if (override != null) return override;
    return getApplicationDocumentsDirectory();
  }

  /// Writes [seed] to `<docs>/socdaily/generated/<yyyy-mm-dd>/<topic>.json`.
  /// Returns the absolute path on success, `null` on failure (best-effort).
  Future<String?> archive(
    Map<String, dynamic> seed, {
    DateTime? now,
  }) async {
    try {
      final ts = (now ?? DateTime.now()).toUtc();
      final day =
          '${ts.year.toString().padLeft(4, '0')}-${ts.month.toString().padLeft(2, '0')}-${ts.day.toString().padLeft(2, '0')}';
      final topicCode = (seed['topic_code'] as String?) ?? 'topic';
      final safe = _safe(topicCode);

      final root = await _root();
      final dir = Directory(p.join(root.path, 'socdaily', 'generated', day));
      await dir.create(recursive: true);
      final file = File(p.join(dir.path, '$safe.json'));
      await file.writeAsString(
        const JsonEncoder.withIndent('  ').convert(seed),
        flush: true,
      );
      return file.path;
    } catch (_) {
      return null;
    }
  }

  /// Lists archived seeds. Returns `(file, day)` tuples sorted newest first.
  Future<List<ArchivedSeed>> list() async {
    final out = <ArchivedSeed>[];
    try {
      final root = await _root();
      final base = Directory(p.join(root.path, 'socdaily', 'generated'));
      if (!await base.exists()) return out;
      await for (final dayDir in base.list()) {
        if (dayDir is! Directory) continue;
        final day = p.basename(dayDir.path);
        await for (final entry in dayDir.list()) {
          if (entry is! File) continue;
          if (!entry.path.endsWith('.json')) continue;
          out.add(ArchivedSeed(file: entry, day: day));
        }
      }
    } catch (_) {
      // Best-effort: tolerate filesystem errors.
    }
    out.sort((a, b) => b.day.compareTo(a.day));
    return out;
  }

  static String _safe(String code) {
    final cleaned = code
        .replaceAll(RegExp(r'[^A-Za-z0-9._-]+'), '-')
        .replaceAll(RegExp(r'^[-.]+|[-.]+$'), '');
    return cleaned.isEmpty ? 'topic' : cleaned;
  }
}

class ArchivedSeed {
  const ArchivedSeed({required this.file, required this.day});
  final File file;
  final String day;
}

final generatedSeedArchiveProvider = Provider<GeneratedSeedArchive>(
  (ref) => GeneratedSeedArchive(),
);
