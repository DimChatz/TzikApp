import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:tzikapp/services/proposal_sender.dart';

void main() {
  test('posts the proposal as JSON to the Formspree form', () async {
    late http.Request sent;
    final sender = ProposalSender(
      formId: 'abc123',
      client: MockClient((request) async {
        sent = request;
        return http.Response('{"ok":true}', 200);
      }),
    );

    await sender.send(question: 'Cats or dogs?', name: 'Maria');

    expect(sent.method, 'POST');
    expect(sent.url.toString(), 'https://formspree.io/f/abc123');
    expect(sent.headers['Accept'], 'application/json');
    expect(jsonDecode(sent.body), {
      '_subject': 'TzikApp question proposal',
      'question': 'Cats or dogs?',
      'name': 'Maria',
    });
  });

  test('leaves out the name when none is given', () async {
    late http.Request sent;
    final sender = ProposalSender(
      formId: 'abc123',
      client: MockClient((request) async {
        sent = request;
        return http.Response('{"ok":true}', 200);
      }),
    );

    await sender.send(question: 'Cats or dogs?');

    expect(jsonDecode(sent.body), isNot(contains('name')));
  });

  test('throws when Formspree rejects the submission', () async {
    final sender = ProposalSender(
      formId: 'missing',
      client: MockClient(
        (_) async => http.Response('{"error":"Form not found"}', 404),
      ),
    );

    expect(
      sender.send(question: 'Cats or dogs?'),
      throwsA(
        isA<ProposalException>().having((e) => e.statusCode, 'status', 404),
      ),
    );
  });

  test('is not configured without a form ID', () {
    expect(ProposalSender(formId: '').isConfigured, isFalse);
    expect(ProposalSender(formId: 'abc123').isConfigured, isTrue);
  });
}
