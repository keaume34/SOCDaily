// Phase 14.B — On-demand content generator screen.
//
// Lets the user pick a server-hosted PDF, a page range, counts, and an
// optional hint, then POSTs to the FastAPI generator (P14.A) and imports
// the returned `TopicSeed` JSON into the local SQLite via `SeedImporter`.
//
// On success the new flashcards + MCQs land in the same place as bundled
// content — Browse / Study / Daily Challenge all see them immediately.
// If the user is paired (P11) the seed is best-effort pushed to the
// remote so the partner device gets the same content on next sync.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../ai/content_generator.dart';
import '../../ai/generator_settings.dart';
import '../../data/db/content_repository.dart';
import '../../data/seed/seed_importer.dart';
import '../../sync/sync_controller.dart';
import '../../theme/gradient_background.dart';
import '../settings/settings_controller.dart';

/// Pre-fill values from the calling screen (Browse / Topic study).
class GeneratePrefill {
  const GeneratePrefill({
    this.subjectCode,
    this.subjectTitle,
    this.chapterCode,
    this.chapterTitle,
    this.topicCode,
    this.topicTitle,
    this.lockTopic = false,
    this.nQuestions,
  });

  final String? subjectCode;
  final String? subjectTitle;
  final String? chapterCode;
  final String? chapterTitle;
  final String? topicCode;
  final String? topicTitle;

  /// When true the user can't edit the topic fields. Used by P14.C
  /// "Practice weak areas" to lock generation onto a known weakness.
  final bool lockTopic;

  /// When non-null overrides the default count (P14.C boosts MCQs).
  final int? nQuestions;
}

class GenerateScreen extends ConsumerStatefulWidget {
  const GenerateScreen({super.key, this.prefill});

  final GeneratePrefill? prefill;

  @override
  ConsumerState<GenerateScreen> createState() => _GenerateScreenState();
}

class _GenerateScreenState extends ConsumerState<GenerateScreen> {
  final _subjectCodeCtl = TextEditingController();
  final _subjectTitleCtl = TextEditingController();
  final _chapterCodeCtl = TextEditingController();
  final _chapterTitleCtl = TextEditingController();
  final _topicCodeCtl = TextEditingController();
  final _topicTitleCtl = TextEditingController();
  final _hintCtl = TextEditingController();
  final _pageStartCtl = TextEditingController(text: '1');
  final _pageEndCtl = TextEditingController(text: '4');

  String? _selectedPdf;
  int _nFlashcards = 6;
  int _nQuestions = 4;
  String? _contentLang; // null = server default

  bool _generating = false;
  String? _error;
  TopicSeedImportResult? _result;
  AsyncValue<List<PdfListing>>? _pdfList;

  @override
  void initState() {
    super.initState();
    final p = widget.prefill;
    if (p != null) {
      _subjectCodeCtl.text = p.subjectCode ?? '';
      _subjectTitleCtl.text = p.subjectTitle ?? '';
      _chapterCodeCtl.text = p.chapterCode ?? '';
      _chapterTitleCtl.text = p.chapterTitle ?? '';
      _topicCodeCtl.text = p.topicCode ?? '';
      _topicTitleCtl.text = p.topicTitle ?? '';
      if (p.nQuestions != null) _nQuestions = p.nQuestions!;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => _refreshPdfs());
  }

  @override
  void dispose() {
    _subjectCodeCtl.dispose();
    _subjectTitleCtl.dispose();
    _chapterCodeCtl.dispose();
    _chapterTitleCtl.dispose();
    _topicCodeCtl.dispose();
    _topicTitleCtl.dispose();
    _hintCtl.dispose();
    _pageStartCtl.dispose();
    _pageEndCtl.dispose();
    super.dispose();
  }

  Future<void> _refreshPdfs() async {
    final svc = ref.read(contentGeneratorServiceProvider);
    if (!svc.isConfigured) {
      setState(() => _pdfList = null);
      return;
    }
    setState(() => _pdfList = const AsyncValue.loading());
    try {
      final list = await svc.listPdfs();
      if (!mounted) return;
      setState(() {
        _pdfList = AsyncValue.data(list);
        if (list.isNotEmpty &&
            (_selectedPdf == null ||
                !list.any((e) => e.name == _selectedPdf))) {
          _selectedPdf = list.first.name;
        }
      });
    } catch (e, st) {
      if (!mounted) return;
      setState(() => _pdfList = AsyncValue.error(e, st));
    }
  }

  String? _validate() {
    if (_subjectCodeCtl.text.trim().isEmpty) return 'Subject code is required.';
    if (_subjectTitleCtl.text.trim().isEmpty) return 'Subject title is required.';
    if (_chapterCodeCtl.text.trim().isEmpty) return 'Chapter code is required.';
    if (_chapterTitleCtl.text.trim().isEmpty) return 'Chapter title is required.';
    if (_topicCodeCtl.text.trim().isEmpty) return 'Topic code is required.';
    if (_topicTitleCtl.text.trim().isEmpty) return 'Topic title is required.';
    final pdf = _selectedPdf;
    if (pdf == null || pdf.isEmpty) return 'Pick a server-side PDF.';
    final start = int.tryParse(_pageStartCtl.text.trim());
    final end = int.tryParse(_pageEndCtl.text.trim());
    if (start == null || start < 1) return 'page_start must be ≥ 1.';
    if (end == null || end < start) return 'page_end must be ≥ page_start.';
    return null;
  }

  Future<void> _generate() async {
    final problem = _validate();
    if (problem != null) {
      setState(() => _error = problem);
      return;
    }
    final svc = ref.read(contentGeneratorServiceProvider);
    final db = ref.read(appDatabaseProvider);

    setState(() {
      _generating = true;
      _error = null;
      _result = null;
    });
    try {
      final req = GenerateRequest(
        subjectCode: _subjectCodeCtl.text.trim(),
        subjectTitle: _subjectTitleCtl.text.trim(),
        chapterCode: _chapterCodeCtl.text.trim(),
        chapterTitle: _chapterTitleCtl.text.trim(),
        topicCode: _topicCodeCtl.text.trim(),
        topicTitle: _topicTitleCtl.text.trim(),
        pdfFilename: _selectedPdf!,
        pageStart: int.parse(_pageStartCtl.text.trim()),
        pageEnd: int.parse(_pageEndCtl.text.trim()),
        hint: _hintCtl.text.trim().isEmpty ? null : _hintCtl.text.trim(),
        nFlashcards: _nFlashcards,
        nQuestions: _nQuestions,
        contentLang: _contentLang,
      );
      final seed = await svc.generate(req);
      final result = await SeedImporter(db).importTopicSeed(seed);
      // Best-effort: notify the partner device.
      await ref.read(syncControllerProvider.notifier).pushGeneratedSeed(
            topicCode: req.topicCode,
            seed: seed,
          );
      // Make sure subjects/topics widgets re-fetch after we mutated the DB.
      ref.invalidate(subjectsProvider);
      if (!mounted) return;
      setState(() => _result = result);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = '$e');
    } finally {
      if (mounted) setState(() => _generating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsControllerProvider);
    final genSettings = ref.watch(generatorSettingsControllerProvider);
    final theme = Theme.of(context);

    return Scaffold(
      body: GradientBackground(
        accent: settings.accent,
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverAppBar.medium(
                title: const Text('Generate more'),
                pinned: true,
                backgroundColor: Colors.transparent,
                actions: [
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    tooltip: 'Refresh PDF list',
                    onPressed: _generating ? null : _refreshPdfs,
                  ),
                  const SizedBox(width: 4),
                ],
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                sliver: SliverList.list(
                  children: [
                    if (!genSettings.isConfigured) _NotConfiguredCard(theme: theme),
                    if (genSettings.isConfigured) ...[
                      _PdfPickerCard(
                        pdfList: _pdfList,
                        selected: _selectedPdf,
                        enabled: !_generating,
                        onChanged: (v) => setState(() => _selectedPdf = v),
                      ),
                      const SizedBox(height: 16),
                      _TaxonomyCard(
                        subjectCode: _subjectCodeCtl,
                        subjectTitle: _subjectTitleCtl,
                        chapterCode: _chapterCodeCtl,
                        chapterTitle: _chapterTitleCtl,
                        topicCode: _topicCodeCtl,
                        topicTitle: _topicTitleCtl,
                        locked: widget.prefill?.lockTopic == true,
                      ),
                      const SizedBox(height: 16),
                      _PageRangeCard(
                        pageStart: _pageStartCtl,
                        pageEnd: _pageEndCtl,
                      ),
                      const SizedBox(height: 16),
                      _CountsCard(
                        nFlashcards: _nFlashcards,
                        nQuestions: _nQuestions,
                        contentLang: _contentLang,
                        onFlashcards: (v) => setState(() => _nFlashcards = v),
                        onQuestions: (v) => setState(() => _nQuestions = v),
                        onLang: (v) => setState(() => _contentLang = v),
                      ),
                      const SizedBox(height: 16),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: TextField(
                            controller: _hintCtl,
                            maxLines: 3,
                            decoration: const InputDecoration(
                              labelText: 'Hint (optional)',
                              hintText:
                                  'e.g. focus on Splunk SPL examples; emphasise '
                                  'practical detection use-cases',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (_error != null)
                        Card(
                          color: theme.colorScheme.errorContainer,
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Text(
                              _error!,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onErrorContainer,
                              ),
                            ),
                          ),
                        ),
                      if (_result != null)
                        _SuccessCard(result: _result!, theme: theme),
                      const SizedBox(height: 8),
                      FilledButton.icon(
                        icon: _generating
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.auto_awesome),
                        label: Text(_generating ? 'Generating…' : 'Generate'),
                        onPressed: _generating ? null : _generate,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NotConfiguredCard extends StatelessWidget {
  const _NotConfiguredCard({required this.theme});
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Generator not configured', style: theme.textTheme.titleMedium),
            const SizedBox(height: 6),
            Text(
              'Set the generator base URL and bearer token in Settings → '
              'Content generator before requesting new flashcards or MCQs.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerLeft,
              child: FilledButton.tonalIcon(
                icon: const Icon(Icons.settings_outlined),
                label: const Text('Open Settings'),
                onPressed: () => context.go('/settings'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PdfPickerCard extends StatelessWidget {
  const _PdfPickerCard({
    required this.pdfList,
    required this.selected,
    required this.enabled,
    required this.onChanged,
  });
  final AsyncValue<List<PdfListing>>? pdfList;
  final String? selected;
  final bool enabled;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final list = pdfList;
    Widget body;
    if (list == null) {
      body = Text('Loading…', style: theme.textTheme.bodyMedium);
    } else {
      body = list.when(
        loading: () => const Padding(
          padding: EdgeInsets.symmetric(vertical: 12),
          child: LinearProgressIndicator(),
        ),
        error: (e, _) => Text(
          '$e',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.error,
          ),
        ),
        data: (rows) {
          if (rows.isEmpty) {
            return Text(
              'No PDFs on the server. Upload one with `POST /pdfs` or '
              'drop it under SOCDAILY_PDF_DIR on the VPS.',
              style: theme.textTheme.bodyMedium,
            );
          }
          return DropdownButtonFormField<String>(
            initialValue: selected,
            isExpanded: true,
            decoration: const InputDecoration(
              labelText: 'Server PDF',
              border: OutlineInputBorder(),
            ),
            items: [
              for (final p in rows)
                DropdownMenuItem(
                  value: p.name,
                  child: Text(
                    '${p.name}  ·  ${(p.sizeBytes / 1024).toStringAsFixed(0)} KB',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
            ],
            onChanged: enabled ? onChanged : null,
          );
        },
      );
    }
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Source PDF', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            body,
          ],
        ),
      ),
    );
  }
}

class _TaxonomyCard extends StatelessWidget {
  const _TaxonomyCard({
    required this.subjectCode,
    required this.subjectTitle,
    required this.chapterCode,
    required this.chapterTitle,
    required this.topicCode,
    required this.topicTitle,
    required this.locked,
  });
  final TextEditingController subjectCode;
  final TextEditingController subjectTitle;
  final TextEditingController chapterCode;
  final TextEditingController chapterTitle;
  final TextEditingController topicCode;
  final TextEditingController topicTitle;
  final bool locked;

  @override
  Widget build(BuildContext context) {
    InputDecoration deco(String label) => InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        );
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Where to file it', style: theme.textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(
              'Subject + chapter + topic codes decide where the new content '
              'lands in Browse. Re-using existing codes appends to that topic.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(
                  child: TextField(
                      controller: subjectCode,
                      enabled: !locked,
                      decoration: deco('Subject code'))),
              const SizedBox(width: 8),
              Expanded(
                  child: TextField(
                      controller: subjectTitle,
                      enabled: !locked,
                      decoration: deco('Subject title'))),
            ]),
            const SizedBox(height: 8),
            Row(children: [
              Expanded(
                  child: TextField(
                      controller: chapterCode,
                      enabled: !locked,
                      decoration: deco('Chapter code'))),
              const SizedBox(width: 8),
              Expanded(
                  child: TextField(
                      controller: chapterTitle,
                      enabled: !locked,
                      decoration: deco('Chapter title'))),
            ]),
            const SizedBox(height: 8),
            Row(children: [
              Expanded(
                  child: TextField(
                      controller: topicCode,
                      enabled: !locked,
                      decoration: deco('Topic code'))),
              const SizedBox(width: 8),
              Expanded(
                  child: TextField(
                      controller: topicTitle,
                      enabled: !locked,
                      decoration: deco('Topic title'))),
            ]),
          ],
        ),
      ),
    );
  }
}

class _PageRangeCard extends StatelessWidget {
  const _PageRangeCard({required this.pageStart, required this.pageEnd});
  final TextEditingController pageStart;
  final TextEditingController pageEnd;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Pages to use', style: theme.textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(
              'A 4-page slice gives the best signal-to-noise. Larger ranges '
              'cost more tokens and dilute focus.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(
                child: TextField(
                  controller: pageStart,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Page start',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: pageEnd,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Page end',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ]),
          ],
        ),
      ),
    );
  }
}

class _CountsCard extends StatelessWidget {
  const _CountsCard({
    required this.nFlashcards,
    required this.nQuestions,
    required this.contentLang,
    required this.onFlashcards,
    required this.onQuestions,
    required this.onLang,
  });
  final int nFlashcards;
  final int nQuestions;
  final String? contentLang;
  final ValueChanged<int> onFlashcards;
  final ValueChanged<int> onQuestions;
  final ValueChanged<String?> onLang;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Counts', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            _CountRow(
              label: 'Flashcards',
              value: nFlashcards,
              min: 1,
              max: 20,
              onChanged: onFlashcards,
            ),
            const SizedBox(height: 8),
            _CountRow(
              label: 'MCQs',
              value: nQuestions,
              min: 0,
              max: 12,
              onChanged: onQuestions,
            ),
            const SizedBox(height: 12),
            Text('Language', style: theme.textTheme.titleSmall),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              children: [
                ChoiceChip(
                  label: const Text('Server default'),
                  selected: contentLang == null,
                  onSelected: (_) => onLang(null),
                ),
                ChoiceChip(
                  label: const Text('Tiếng Việt'),
                  selected: contentLang == 'vi',
                  onSelected: (_) => onLang('vi'),
                ),
                ChoiceChip(
                  label: const Text('English'),
                  selected: contentLang == 'en',
                  onSelected: (_) => onLang('en'),
                ),
                ChoiceChip(
                  label: const Text('Bilingual'),
                  selected: contentLang == 'bilingual',
                  onSelected: (_) => onLang('bilingual'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CountRow extends StatelessWidget {
  const _CountRow({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });
  final String label;
  final int value;
  final int min;
  final int max;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        SizedBox(width: 90, child: Text(label, style: theme.textTheme.bodyMedium)),
        IconButton(
          icon: const Icon(Icons.remove_circle_outline),
          onPressed: value > min ? () => onChanged(value - 1) : null,
        ),
        SizedBox(
          width: 28,
          child: Text(
            '$value',
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.add_circle_outline),
          onPressed: value < max ? () => onChanged(value + 1) : null,
        ),
      ],
    );
  }
}

class _SuccessCard extends StatelessWidget {
  const _SuccessCard({required this.result, required this.theme});
  final TopicSeedImportResult result;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: theme.colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Icon(Icons.check_circle, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                result.topicCreated ? 'Topic created' : 'Topic refreshed',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
            ]),
            const SizedBox(height: 8),
            Text(
              '${result.flashcardsAdded} flashcards · '
              '${result.questionsAdded} MCQs imported.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                icon: const Icon(Icons.school_outlined),
                label: const Text('Open in Study'),
                onPressed: () =>
                    context.push('/study/topic/${result.topicId}'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
