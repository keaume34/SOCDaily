// Phase 12 — PDF source viewer configuration. Reads the VPS base URL
// from `--dart-define=PDF_BASE_URL=…` so the location of the PDF host
// stays out of the repo. When the value is empty the PDF source button
// hides itself in the UI (mirrors `SyncConfig` from P11).

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

@immutable
class PdfSourceConfig {
  const PdfSourceConfig({required this.baseUrl});

  factory PdfSourceConfig.fromEnvironment() {
    const url = String.fromEnvironment('PDF_BASE_URL');
    return const PdfSourceConfig(baseUrl: url);
  }

  final String baseUrl;

  bool get isConfigured {
    if (baseUrl.isEmpty) return false;
    final uri = Uri.tryParse(baseUrl);
    return uri != null && uri.hasScheme && uri.host.isNotEmpty;
  }
}

final pdfSourceConfigProvider = Provider<PdfSourceConfig>((ref) {
  return PdfSourceConfig.fromEnvironment();
});
