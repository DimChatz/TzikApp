import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config.dart';

/// Sends question proposals to Formspree, which forwards them by email.
class ProposalSender {
  ProposalSender({this.client, this.formId = formspreeFormId});

  /// Defaults to a new client per send; tests pass a mock.
  final http.Client? client;
  final String formId;

  /// Formspree form IDs are letters and digits only, so placeholders like
  /// `your-form-id` count as not set up rather than failing to send.
  bool get isConfigured => RegExp(r'^[A-Za-z0-9]+$').hasMatch(formId);

  /// Throws a [ProposalException] if Formspree turns the proposal down, or
  /// another [Exception] if it can't be reached.
  Future<void> send({required String question, String name = ''}) async {
    assert(isConfigured, 'Set FORMSPREE_FORM_ID in config.json');
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
