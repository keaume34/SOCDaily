// Phase 11 — Sync configuration. Reads Supabase URL + anon key from
// dart-define so secrets stay out of the repo. If either value is empty
// the sync features render in "disabled" mode in the UI.

import 'package:flutter/foundation.dart';

@immutable
class SyncConfig {
  const SyncConfig({required this.url, required this.anonKey});

  factory SyncConfig.fromEnvironment() {
    const url = String.fromEnvironment('SUPABASE_URL');
    const anon = String.fromEnvironment('SUPABASE_ANON_KEY');
    return const SyncConfig(url: url, anonKey: anon);
  }

  final String url;
  final String anonKey;

  bool get isConfigured =>
      url.isNotEmpty && anonKey.isNotEmpty && Uri.tryParse(url) != null;
}
