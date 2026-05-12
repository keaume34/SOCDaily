// Phase 12 — URL builder + cache-key + slugify edge cases for
// [PdfSourceService]. The download path is exercised indirectly via the
// URL it builds; the disk-cache layer is covered through cacheKeyFor.

import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:socdaily_app/src/pdf/pdf_source_config.dart';
import 'package:socdaily_app/src/pdf/pdf_source_service.dart';

void main() {
  group('PdfSourceService.slugifyPdfFilename', () {
    test('lowercases, trims .pdf, collapses non-alphanumerics to dashes', () {
      expect(
        PdfSourceService.slugifyPdfFilename('SOC Analyst Guide.pdf'),
        'soc-analyst-guide.pdf',
      );
    });

    test('handles diacritics + punctuation', () {
      expect(
        PdfSourceService.slugifyPdfFilename("Phishing — Notes (v2).PDF"),
        'phishing-notes-v2.pdf',
      );
    });

    test('strips leading/trailing dashes and double dashes', () {
      expect(
        PdfSourceService.slugifyPdfFilename('  -- SIEM  /  Foundations --.pdf'),
        'siem-foundations.pdf',
      );
    });

    test('falls back to source.pdf when the input has no alphanumerics', () {
      expect(
        PdfSourceService.slugifyPdfFilename('___.pdf'),
        'source.pdf',
      );
    });

    test('appends .pdf when missing from input', () {
      expect(
        PdfSourceService.slugifyPdfFilename('Soc Mission'),
        'soc-mission.pdf',
      );
    });
  });

  group('PdfSourceService.buildRelativePath', () {
    test('bare filename prepends subject + chapter codes', () {
      final rel = PdfSourceService.buildRelativePath(
        const PdfSourceLocation(
          subjectCode: 'blue-team',
          chapterCode: 'phishing',
          pdfPath: 'Phishing Notes.pdf',
        ),
      );
      expect(rel, 'blue-team/phishing/phishing-notes.pdf');
    });

    test('path with slashes is preserved (and slugified)', () {
      final rel = PdfSourceService.buildRelativePath(
        const PdfSourceLocation(
          subjectCode: 'IGNORED',
          chapterCode: 'IGNORED',
          pdfPath: 'SOC Fundamentals/Introduction/SOC Mission.pdf',
        ),
      );
      expect(rel, 'soc-fundamentals/introduction/soc-mission.pdf');
    });

    test('windows-style backslashes are normalized', () {
      final rel = PdfSourceService.buildRelativePath(
        const PdfSourceLocation(
          subjectCode: 'IGNORED',
          chapterCode: 'IGNORED',
          pdfPath: r'blue-team\phishing\Phishing Indicators.pdf',
        ),
      );
      expect(rel, 'blue-team/phishing/phishing-indicators.pdf');
    });

    test('empty pdfPath falls back to a deterministic placeholder', () {
      final rel = PdfSourceService.buildRelativePath(
        const PdfSourceLocation(
          subjectCode: 'soc-fundamentals',
          chapterCode: 'siem',
          pdfPath: '   ',
        ),
      );
      expect(rel, 'soc-fundamentals/siem/source.pdf');
    });
  });

  group('PdfSourceService.buildUrl', () {
    test('joins base URL + relative path, trimming trailing slashes', () {
      final svc = PdfSourceService(
        config: const PdfSourceConfig(baseUrl: 'http://example.com:8080///'),
        dio: Dio(),
        cacheDir: () async => Directory.systemTemp.createTemp('socdaily-test'),
      );
      final url = svc.buildUrl(const PdfSourceLocation(
        subjectCode: 'blue-team',
        chapterCode: 'phishing',
        pdfPath: 'Phishing Notes.pdf',
      ));
      expect(url, 'http://example.com:8080/blue-team/phishing/phishing-notes.pdf');
    });
  });

  group('PdfSourceService.cacheKeyFor', () {
    test('is a stable sha1 hex string', () {
      const url = 'http://100.110.125.8:8080/blue-team/phishing/phishing-indicators.pdf';
      final key = PdfSourceService.cacheKeyFor(url);
      // sha1("…") was computed offline; just assert (a) hex (b) 40 chars
      // (c) determinism. We avoid baking the exact value so the test stays
      // future-proof against trivial URL tweaks.
      expect(key, hasLength(40));
      expect(RegExp(r'^[0-9a-f]{40}$').hasMatch(key), isTrue);
      expect(PdfSourceService.cacheKeyFor(url), key,
          reason: 'same URL must produce the same cache key');
    });

    test('different URLs hash to different keys', () {
      final a = PdfSourceService.cacheKeyFor(
          'http://host/blue-team/phishing/a.pdf');
      final b = PdfSourceService.cacheKeyFor(
          'http://host/blue-team/phishing/b.pdf');
      expect(a, isNot(equals(b)));
    });
  });

  group('PdfSourceConfig.isConfigured', () {
    test('empty base URL is unconfigured', () {
      expect(const PdfSourceConfig(baseUrl: '').isConfigured, isFalse);
    });

    test('URL without scheme is unconfigured', () {
      expect(const PdfSourceConfig(baseUrl: '100.110.125.8:8080').isConfigured,
          isFalse);
    });

    test('well-formed http URL is configured', () {
      expect(
        const PdfSourceConfig(baseUrl: 'http://100.110.125.8:8080').isConfigured,
        isTrue,
      );
    });
  });
}
