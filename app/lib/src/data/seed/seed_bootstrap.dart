// Bootstrap provider: runs once on cold start, ensures the bundled JSON
// seeds are imported into the local SQLite DB.

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../db/content_repository.dart';
import 'seed_importer.dart';
import '../../features/settings/settings_controller.dart';

const _kSeedImportedKey = 'seed.imported_version';

final seedBootstrapProvider = FutureProvider<SeedBootstrapResult>((ref) async {
  ref.keepAlive();
  final prefs = ref.watch(sharedPreferencesProvider);
  final db = ref.watch(appDatabaseProvider);
  final lastImported = prefs.getInt(_kSeedImportedKey);

  // Skip the full import if the bundled version hasn't changed.
  if (lastImported == SeedImporter.bundledVersion) {
    return SeedBootstrapResult(
      importedVersion: SeedImporter.bundledVersion,
      flashcards: 0,
      questions: 0,
    );
  }

  final importer = SeedImporter(db);
  final result = await importer.ensureImported();
  await prefs.setInt(_kSeedImportedKey, result.bundledVersion);
  return SeedBootstrapResult(
    importedVersion: result.bundledVersion,
    flashcards: result.flashcardsAdded,
    questions: result.questionsAdded,
  );
});

class SeedBootstrapResult {
  const SeedBootstrapResult({
    required this.importedVersion,
    required this.flashcards,
    required this.questions,
  });

  final int importedVersion;
  final int flashcards;
  final int questions;
}

/// Force the bootstrap provider to run before screens that depend on content.
/// Convenient one-liner for [HomeScreen], [BrowseScreen] etc.
Future<void> ensureSeedReady(Ref ref) =>
    ref.read(seedBootstrapProvider.future);

/// Convenience alias for widgets that already have a [WidgetRef].
Future<void> ensureSeedReadyFromWidget(WidgetRef ref) =>
    ref.read(seedBootstrapProvider.future);
