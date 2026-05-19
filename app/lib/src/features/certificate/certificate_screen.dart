// Phase 9 — Certificate preview screen. Generates the PDF on demand from
// the user's current stats, shows the standard PDF preview UI (share / save
// / print), and lets the user edit the name on the certificate.

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:printing/printing.dart';

import '../../data/db/content_repository.dart';
import '../../data/db/user_state_repository.dart';
import '../../services/certificate_service.dart';
import '../../theme/gradient_background.dart';
import '../settings/settings_controller.dart';

final _certificateServiceProvider =
    Provider<CertificateService>((_) => CertificateService());

class CertificateScreen extends ConsumerStatefulWidget {
  const CertificateScreen({super.key});

  @override
  ConsumerState<CertificateScreen> createState() =>
      _CertificateScreenState();
}

class _CertificateScreenState extends ConsumerState<CertificateScreen> {
  final _nameController = TextEditingController(text: 'SOC Analyst');

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsControllerProvider);
    final theme = Theme.of(context);

    return Scaffold(
      body: GradientBackground(
        accent: settings.accent,
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    const SizedBox(width: 4),
                    Text('Study certificate',
                        style: theme.textTheme.titleLarge),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Your name (printed on the certificate)',
                    border: OutlineInputBorder(),
                  ),
                  onSubmitted: (_) => setState(() {}),
                ),
              ),
              Expanded(
                child: PdfPreview(
                  build: (format) => _buildPdf(),
                  allowSharing: true,
                  allowPrinting: true,
                  canChangePageFormat: false,
                  canChangeOrientation: false,
                  canDebug: false,
                  pdfFileName: 'socdaily-certificate.pdf',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<Uint8List> _buildPdf() async {
    final userRepo = ref.read(userStateRepositoryProvider);
    final contentRepo = ref.read(contentRepositoryProvider);
    final svc = ref.read(_certificateServiceProvider);
    final totals = await userRepo.totals();
    final streak = await userRepo.streakStats();
    final subjects = await contentRepo.listSubjects();
    return svc.buildPdf(CertificateData(
      holderName:
          _nameController.text.trim().isEmpty ? 'SOC Analyst' : _nameController.text,
      issuedOn: DateTime.now(),
      totals: totals,
      streak: streak,
      subjectsCovered: subjects.length,
    ));
  }
}
