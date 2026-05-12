// Phase 12 — PDF source viewer.
//
// Route: `/source/:sourceId?page=N&topicId=T`.
//
// Fetches `sources.id` (joined to the surrounding subject/chapter via the
// topicId hint when present), builds a VPS URL through `PdfSourceService`,
// downloads + caches the file once, then renders it through the existing
// `printing.PdfPreview` widget (already shipped for P9 — no extra deps).
//
// By default we render only the source page so the user lands on the exact
// citation; a toggle in the AppBar lets them load every page.

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:printing/printing.dart';

import '../../pdf/pdf_source_config.dart';
import '../../pdf/pdf_source_service.dart';
import '../../theme/gradient_background.dart';
import '../settings/settings_controller.dart';

class PdfSourceLoadArgs {
  const PdfSourceLoadArgs({
    required this.sourceId,
    this.topicId,
    this.page,
  });
  final int sourceId;
  final int? topicId;
  final int? page;
}

class _LoadedPdf {
  const _LoadedPdf({
    required this.bytes,
    required this.context,
    required this.url,
    required this.totalPages,
  });
  final List<int> bytes;
  final PdfSourceContext context;
  final String url;
  final int? totalPages;
}

final pdfSourceLoadProvider =
    FutureProvider.family<_LoadedPdf, PdfSourceLoadArgs>((ref, args) async {
  final lookup = ref.watch(pdfSourceLookupProvider);
  final ctx = await lookup.contextFor(
    sourceId: args.sourceId,
    topicId: args.topicId,
  );
  if (ctx == null) {
    throw const PdfSourceException('Source not found.');
  }
  final service = ref.watch(pdfSourceServiceProvider);
  final loc = ctx.locationFor(page: args.page);
  final url = service.buildUrl(loc);
  final file = await service.fetchPdf(loc);
  final bytes = await file.readAsBytes();
  return _LoadedPdf(
    bytes: bytes,
    context: ctx,
    url: url,
    totalPages: ctx.source.pageCount,
  );
});

class PdfViewerScreen extends ConsumerStatefulWidget {
  const PdfViewerScreen({
    required this.sourceId,
    this.topicId,
    this.page,
    super.key,
  });

  final int sourceId;
  final int? topicId;
  final int? page;

  @override
  ConsumerState<PdfViewerScreen> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends ConsumerState<PdfViewerScreen> {
  bool _showAllPages = false;

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsControllerProvider);
    final config = ref.watch(pdfSourceConfigProvider);

    if (!config.isConfigured) {
      return _UnconfiguredView(accent: settings.accent);
    }

    final args = PdfSourceLoadArgs(
      sourceId: widget.sourceId,
      topicId: widget.topicId,
      page: widget.page,
    );
    final async = ref.watch(pdfSourceLoadProvider(args));

    return Scaffold(
      body: GradientBackground(
        accent: settings.accent,
        child: SafeArea(
          child: async.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => _ErrorView(
              message: e is PdfSourceException ? e.message : e.toString(),
              onRetry: () => ref.invalidate(pdfSourceLoadProvider(args)),
            ),
            data: (loaded) => _PreviewBody(
              loaded: loaded,
              requestedPage: widget.page,
              showAllPages: _showAllPages,
              onToggleAll: () =>
                  setState(() => _showAllPages = !_showAllPages),
            ),
          ),
        ),
      ),
    );
  }
}

class _PreviewBody extends StatelessWidget {
  const _PreviewBody({
    required this.loaded,
    required this.requestedPage,
    required this.showAllPages,
    required this.onToggleAll,
  });

  final _LoadedPdf loaded;
  final int? requestedPage;
  final bool showAllPages;
  final VoidCallback onToggleAll;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pages = (!showAllPages && requestedPage != null && requestedPage! > 0)
        ? <int>[requestedPage! - 1]
        : null;
    final headline = loaded.context.source.title ??
        loaded.context.source.pdfPath;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 4, 12, 0),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.close),
                tooltip: 'Close source',
                onPressed: () => context.pop(),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      headline,
                      style: theme.textTheme.titleSmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '${loaded.context.subjectTitle} • '
                      '${loaded.context.chapterTitle} • '
                      '${loaded.context.topicTitle}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (requestedPage != null)
                TextButton.icon(
                  icon: Icon(
                    showAllPages ? Icons.crop_square : Icons.menu_book,
                    size: 18,
                  ),
                  label: Text(showAllPages
                      ? 'Source page only'
                      : 'Show all pages'),
                  onPressed: onToggleAll,
                ),
            ],
          ),
        ),
        if (requestedPage != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.bookmark_outline,
                    size: 16,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Source page $requestedPage',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
        Expanded(
          child: PdfPreview(
            build: (_) async => Uint8List.fromList(loaded.bytes),
            allowPrinting: false,
            allowSharing: true,
            canChangePageFormat: false,
            canChangeOrientation: false,
            canDebug: false,
            useActions: true,
            pages: pages,
            loadingWidget: const Center(child: CircularProgressIndicator()),
          ),
        ),
      ],
    );
  }
}

class _UnconfiguredView extends StatelessWidget {
  const _UnconfiguredView({required this.accent});
  final dynamic accent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Source PDF')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.cloud_off_outlined,
                size: 48,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: 16),
              Text(
                'PDF host is not configured.',
                style: theme.textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Build the app with `--dart-define=PDF_BASE_URL=…` pointing '
                'at your VPS to enable source citations.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => Navigator.of(context).maybePop(),
                child: const Text('Close'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              "Couldn't load source PDF",
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                FilledButton.tonal(
                  onPressed: () => Navigator.of(context).maybePop(),
                  child: const Text('Close'),
                ),
                const SizedBox(width: 12),
                FilledButton(
                  onPressed: onRetry,
                  child: const Text('Retry'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
