// Phase 9 — Certificate PDF generation tests. Smoke-checks that the
// service produces a valid non-empty PDF byte stream containing the
// expected header.

import 'package:flutter_test/flutter_test.dart';

import 'package:socdaily_app/src/data/db/user_state_repository.dart';
import 'package:socdaily_app/src/services/certificate_service.dart';

void main() {
  test('CertificateService.buildPdf produces a valid PDF', () async {
    final svc = CertificateService();
    final bytes = await svc.buildPdf(CertificateData(
      holderName: 'Test Analyst',
      issuedOn: DateTime(2025, 5, 12),
      totals: const TotalsSnapshot(
        cardsKnown: 12,
        cardsReviewed: 30,
        mcqAttempts: 50,
        mcqCorrect: 40,
      ),
      streak: (current: 3, longest: 7),
      subjectsCovered: 5,
    ));

    expect(bytes, isNotEmpty);
    expect(bytes.length, greaterThan(500));
    // PDF files start with the magic bytes "%PDF-".
    expect(String.fromCharCodes(bytes.take(5)), '%PDF-');
  });

  test('CertificateService handles zero attempts (0% accuracy)', () async {
    final svc = CertificateService();
    final bytes = await svc.buildPdf(CertificateData(
      holderName: 'Zero User',
      issuedOn: DateTime(2025, 1, 1),
      totals: const TotalsSnapshot(
        cardsKnown: 0,
        cardsReviewed: 0,
        mcqAttempts: 0,
        mcqCorrect: 0,
      ),
      streak: (current: 0, longest: 0),
      subjectsCovered: 0,
    ));
    expect(bytes, isNotEmpty);
    expect(String.fromCharCodes(bytes.take(5)), '%PDF-');
  });
}
