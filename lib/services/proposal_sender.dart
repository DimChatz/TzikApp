import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config.dart';

/// Sends question proposals to Formspree, which forwards them by email.
class ProposalSender {
  ProposalSender({this.client, this.formId = formspreeFormId});

  /// Defaults to a new client per send; tests pass a mock.
  final http.Client? client;
  final String formId;

  bool get isConfigured => formId.isNotEmpty;

  /// Throws an [Exception] if the proposal could not be delivered.
  Future<void> send({required String question, String name = ''}) async {
    assert(isConfigured, 'Set formspreeFormId in lib/config.dart');
    final client = this.client ?? http.Client();
    try {
      final response = await client
          .post(
            Uri.https('formspree.io', '/f/$formId'),
            headers: {
              'Accept': 'application/json',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              '_subject': '$appName question proposal',
              'question': question,
              if (name.isNotEmpty) 'name': name,
            }),
          )
          .timeout(const Duration(seconds: 15));
      if (response.statusCode ~/ 100 != 2) {
        throw ProposalException(response.statusCode, response.body);
      }
    } finally {
      if (this.client == null) client.close();
    }
  }
}

class ProposalException implements Exception {
  const ProposalException(this.statusCode, this.body);

  final int statusCode;
  final String body;

  @override
  String toString() => 'Formspree returned $statusCode: $body';
}
