// Phase 14.B — ContentGeneratorService tests.
// Stub the Dio HTTP layer so we can verify request shape (headers,
// payload, URL) and response parsing without hitting a real server.

import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:socdaily_app/src/ai/content_generator.dart';

class _StubAdapter implements HttpClientAdapter {
  _StubAdapter(this.handler);
  final Future<ResponseBody> Function(RequestOptions opts) handler;

  RequestOptions? lastRequest;
  Object? lastBody;

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    lastRequest = options;
    lastBody = options.data;
    return handler(options);
  }
}

ResponseBody _json(Map<String, dynamic> body, {int status = 200}) {
  return ResponseBody.fromString(
    jsonEncode(body),
    status,
    headers: {
      'content-type': ['application/json'],
    },
  );
}

ResponseBody _jsonList(List<dynamic> body, {int status = 200}) {
  return ResponseBody.fromString(
    jsonEncode(body),
    status,
    headers: {
      'content-type': ['application/json'],
    },
  );
}

void main() {
  test('isConfigured requires both base URL and token', () {
    expect(
      ContentGeneratorService(baseUrl: '', token: '').isConfigured,
      isFalse,
    );
    expect(
      ContentGeneratorService(baseUrl: 'https://x', token: '').isConfigured,
      isFalse,
    );
    expect(
      ContentGeneratorService(baseUrl: '', token: 't').isConfigured,
      isFalse,
    );
    expect(
      ContentGeneratorService(baseUrl: 'https://x', token: 't').isConfigured,
      isTrue,
    );
  });

  test('listPdfs throws when not configured', () async {
    final svc = ContentGeneratorService(baseUrl: '', token: '');
    expect(svc.listPdfs(), throwsA(isA<GeneratorException>()));
  });

  test('listPdfs hits GET /pdfs with bearer auth and parses results',
      () async {
    final dio = Dio();
    final adapter = _StubAdapter((opts) async => _jsonList([
          {'name': 'a.pdf', 'size_bytes': 1024},
          {'name': 'b.pdf', 'size_bytes': 2048},
        ]));
    dio.httpClientAdapter = adapter;
    final svc = ContentGeneratorService(
      baseUrl: 'https://api.example/',
      token: 'tok',
      dio: dio,
    );
    final list = await svc.listPdfs();
    expect(list.length, 2);
    expect(list.first.name, 'a.pdf');
    expect(list.first.sizeBytes, 1024);
    final req = adapter.lastRequest!;
    expect(req.method, 'GET');
    expect(req.uri.toString(), 'https://api.example/pdfs');
    expect(req.headers['Authorization'], 'Bearer tok');
  });

  test('generate POSTs full request body and returns the seed map', () async {
    final dio = Dio();
    final fakeSeed = {
      'subject_code': 'soc',
      'subject_title': 'SOC',
      'chapter_code': 'siem',
      'chapter_title': 'SIEM',
      'topic_code': 'siem-core',
      'topic_title': 'SIEM Core',
      'source_pdf': 'guide.pdf',
      'flashcards': [
        {'front': 'q', 'back': 'a'},
      ],
      'questions': [
        {
          'stem': 's',
          'qtype': 'single',
          'options': [
            {'label': 'A', 'content': 'c', 'is_correct': true},
            {'label': 'B', 'content': 'd', 'is_correct': false},
          ],
        }
      ],
    };
    final adapter = _StubAdapter((opts) async => _json(fakeSeed));
    dio.httpClientAdapter = adapter;
    final svc = ContentGeneratorService(
      baseUrl: 'https://api.example',
      token: 'tok',
      dio: dio,
    );
    final res = await svc.generate(const GenerateRequest(
      subjectCode: 'soc',
      subjectTitle: 'SOC',
      chapterCode: 'siem',
      chapterTitle: 'SIEM',
      topicCode: 'siem-core',
      topicTitle: 'SIEM Core',
      pdfFilename: 'guide.pdf',
      pageStart: 1,
      pageEnd: 4,
      hint: 'Splunk',
      contentLang: 'vi',
      nFlashcards: 6,
      nQuestions: 4,
    ));
    expect(res['topic_code'], 'siem-core');
    expect((res['flashcards'] as List).length, 1);

    final req = adapter.lastRequest!;
    expect(req.method, 'POST');
    expect(req.uri.toString(), 'https://api.example/generate');
    expect(req.headers['Authorization'], 'Bearer tok');
    expect(req.headers['Content-Type'], 'application/json');
    final body = adapter.lastBody as Map;
    expect(body['subject_code'], 'soc');
    expect(body['page_start'], 1);
    expect(body['page_end'], 4);
    expect(body['hint'], 'Splunk');
    expect(body['content_lang'], 'vi');
    expect(body['n_flashcards'], 6);
    expect(body['n_questions'], 4);
  });

  test('generate omits hint and content_lang when not set', () async {
    final dio = Dio();
    final adapter = _StubAdapter((opts) async => _json({'topic_code': 't'}));
    dio.httpClientAdapter = adapter;
    final svc = ContentGeneratorService(
      baseUrl: 'https://api.example',
      token: 'tok',
      dio: dio,
    );
    await svc.generate(const GenerateRequest(
      subjectCode: 's',
      subjectTitle: 'S',
      chapterCode: 'c',
      chapterTitle: 'C',
      topicCode: 't',
      topicTitle: 'T',
      pdfFilename: 'g.pdf',
      pageStart: 2,
      pageEnd: 3,
    ));
    final body = adapter.lastBody as Map;
    expect(body.containsKey('hint'), isFalse);
    expect(body.containsKey('content_lang'), isFalse);
  });

  test('generate surfaces server detail message on 4xx', () async {
    final dio = Dio();
    final adapter = _StubAdapter(
      (opts) async => _json({'detail': 'PDF not found.'}, status: 404),
    );
    dio.httpClientAdapter = adapter;
    final svc = ContentGeneratorService(
      baseUrl: 'https://api.example',
      token: 'tok',
      dio: dio,
    );
    try {
      await svc.generate(const GenerateRequest(
        subjectCode: 's',
        subjectTitle: 'S',
        chapterCode: 'c',
        chapterTitle: 'C',
        topicCode: 't',
        topicTitle: 'T',
        pdfFilename: 'missing.pdf',
        pageStart: 1,
        pageEnd: 2,
      ));
      fail('should have thrown');
    } catch (e) {
      expect(e, isA<GeneratorException>());
      expect((e as GeneratorException).message, contains('PDF not found'));
      expect(e.statusCode, 404);
    }
  });
}
