// Phase 9 — Generates a "completion" certificate PDF from the user's
// current learning stats. The PDF is rendered server-side (in-app) using
// the `pdf` package and previewed/shared via `printing`.

import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../data/db/user_state_repository.dart';

class CertificateData {
  const CertificateData({
    required this.holderName,
    required this.issuedOn,
    required this.totals,
    required this.streak,
    required this.subjectsCovered,
  });

  final String holderName;
  final DateTime issuedOn;
  final TotalsSnapshot totals;
  final ({int current, int longest, int? milestoneHit}) streak;
  final int subjectsCovered;
}

class CertificateService {
  Future<Uint8List> buildPdf(CertificateData data) async {
    final doc = pw.Document(title: 'SOCDaily Study Certificate');
    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4.landscape,
        build: (context) => _buildCertificate(data),
      ),
    );
    return doc.save();
  }

  pw.Widget _buildCertificate(CertificateData data) {
    const navy = PdfColor.fromInt(0xff0d1b2a);
    const accent = PdfColor.fromInt(0xff4361ee);
    const muted = PdfColor.fromInt(0xff5c6b80);

    final accuracy = (data.totals.accuracy * 100).toStringAsFixed(0);
    final issued =
        '${data.issuedOn.year}-${data.issuedOn.month.toString().padLeft(2, '0')}-${data.issuedOn.day.toString().padLeft(2, '0')}';

    return pw.Container(
      decoration: pw.BoxDecoration(
        gradient: const pw.LinearGradient(
          colors: [PdfColors.white, PdfColor.fromInt(0xffeef2ff)],
          begin: pw.Alignment.topLeft,
          end: pw.Alignment.bottomRight,
        ),
        border: pw.Border.all(color: navy, width: 4),
      ),
      padding: const pw.EdgeInsets.all(36),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('SOCDaily',
                  style: pw.TextStyle(
                    fontSize: 22,
                    fontWeight: pw.FontWeight.bold,
                    color: navy,
                  )),
              pw.Text(
                'CERTIFICATE OF STUDY',
                style: const pw.TextStyle(
                  letterSpacing: 4,
                  fontSize: 12,
                  color: muted,
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 28),
          pw.Text(
            'This certifies that',
            style: const pw.TextStyle(fontSize: 14, color: muted),
          ),
          pw.SizedBox(height: 6),
          pw.Text(
            data.holderName,
            style: pw.TextStyle(
              fontSize: 38,
              fontWeight: pw.FontWeight.bold,
              color: navy,
            ),
          ),
          pw.SizedBox(height: 6),
          pw.Container(width: 220, height: 2, color: accent),
          pw.SizedBox(height: 18),
          pw.Text(
            'has completed self-paced study on the SOCDaily learning platform.',
            style: const pw.TextStyle(fontSize: 13, color: muted),
          ),
          pw.SizedBox(height: 26),
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _stat('Cards mastered', '${data.totals.cardsKnown}',
                  '${data.totals.cardsReviewed} reviews'),
              _stat('Questions answered', '${data.totals.mcqAttempts}',
                  '$accuracy% accuracy'),
              _stat('Longest streak', '${data.streak.longest}',
                  'consecutive days'),
              _stat('Subjects studied', '${data.subjectsCovered}',
                  'across the library'),
            ],
          ),
          pw.Spacer(),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Container(
                      width: 180, height: 1, color: PdfColors.grey600),
                  pw.SizedBox(height: 4),
                  pw.Text('SOCDaily — issued $issued',
                      style: const pw.TextStyle(
                          fontSize: 10, color: PdfColors.grey700)),
                ],
              ),
              pw.Container(
                padding:
                    const pw.EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: pw.BoxDecoration(
                  color: accent,
                  borderRadius: pw.BorderRadius.circular(999),
                ),
                child: pw.Text(
                  'SELF-PACED',
                  style: pw.TextStyle(
                    color: PdfColors.white,
                    fontSize: 11,
                    letterSpacing: 2,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  pw.Widget _stat(String label, String value, String subtitle) {
    const navy = PdfColor.fromInt(0xff0d1b2a);
    const muted = PdfColor.fromInt(0xff5c6b80);
    return pw.Expanded(
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            label.toUpperCase(),
            style: const pw.TextStyle(
              fontSize: 9,
              letterSpacing: 2,
              color: muted,
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: 26,
              fontWeight: pw.FontWeight.bold,
              color: navy,
            ),
          ),
          pw.SizedBox(height: 2),
          pw.Text(
            subtitle,
            style: const pw.TextStyle(fontSize: 10, color: muted),
          ),
        ],
      ),
    );
  }
}
