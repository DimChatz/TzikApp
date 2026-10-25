import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tzikapp/services/question_repository.dart';

const _url = 'https://example.com/questions.json';

class _BuiltInQuestions extends CachingAssetBundle {
  @override
  Future<ByteData> load(String key) async =>
      ByteData.sublistView(utf8.encode('[{"index": 1, "text": "Built-in?"}]'));
}

MockClient _serving(String body, {int status = 200}) =>
    MockClient((_) async => http.Response.bytes(utf8.encode(body), status));

final _offline = MockClient(
  (_) async => throw http.ClientException('No internet'),
);

Future<List<String>> _load(http.Client client, {String url = _url}) async {
  final questions = await loadQuestions(
    _BuiltInQuestions(),
    url: url,
    client: client,
  );
  return [for (final q in questions) q.text];
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('uses the downloaded questions when online', () async {
    expect(await _load(_serving('[{"index": 1, "text": "Online for €5?"}]')), [
      'Online for €5?',
    ]);
  });

  test('uses the last download when offline', () async {
    await _load(_serving('[{"index": 1, "text": "Online?"}]'));
    expect(await _load(_offline), ['Online?']);
  });

  test('uses the built-in questions when offline on first launch', () async {
    expect(await _load(_offline), ['Built-in?']);
  });

  test('ignores a broken download and keeps the last good one', () async {
    await _load(_serving('[{"index": 1, "text": "Online?"}]'));
    expect(await _load(_serving('[{"index": 1, "text": "Missing quote}]')), [
      'Online?',
    ]);
  });

  test('ignores error pages', () async {
    expect(await _load(_serving('Not Found', status: 404)), ['Built-in?']);
  });

  test('only uses the built-in questions when no URL is set', () async {
    expect(
      await _load(_serving('[{"index": 1, "text": "Online?"}]'), url: ''),
      ['Built-in?'],
    );
  });
}
