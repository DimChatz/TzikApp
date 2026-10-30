import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:tzikapp/l10n/app_localizations.dart';
import 'package:tzikapp/screens/propose_screen.dart';
import 'package:tzikapp/services/proposal_sender.dart';

const _proposal = 'Would you rather fly or be invisible?';

ProposalSender _formspreeReplying(int status, List<String> sentBodies) =>
    ProposalSender(
      formId: 'xyzabcde',
      client: MockClient((request) async {
        sentBodies.add(request.body);
        return http.Response('{}', status);
      }),
    );

Future<void> _openAndSubmit(WidgetTester tester, ProposalSender sender) async {
  await tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Builder(
        builder: (context) => Scaffold(
          body: TextButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => ProposeScreen(sender: sender),
              ),
            ),
            child: const Text('Open'),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('Open'));
  await tester.pumpAndSettle();

  await tester.enterText(
    find.widgetWithText(TextFormField, 'Your question'),
    _proposal,
  );
  await tester.tap(find.text('Send'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('sends the question and goes back', (tester) async {
    final sent = <String>[];
    await _openAndSubmit(tester, _formspreeReplying(200, sent));

    expect(sent.single, contains(_proposal));
    expect(find.text('Thanks! Your question was sent.'), findsOneWidget);
    expect(find.byType(ProposeScreen), findsNothing);
  });

  testWidgets('keeps the question when sending fails', (tester) async {
    final sent = <String>[];
    await _openAndSubmit(tester, _formspreeReplying(500, sent));

    expect(sent, hasLength(1));
    expect(find.textContaining("Couldn't send"), findsOneWidget);
    expect(find.byType(ProposeScreen), findsOneWidget);
    expect(find.text(_proposal), findsOneWidget);
    expect(find.text('Send'), findsOneWidget);
  });

  testWidgets('blames Formspree, not the internet, when it says no', (
    tester,
  ) async {
    await _openAndSubmit(tester, _formspreeReplying(404, []));

    expect(find.textContaining('(error 404)'), findsOneWidget);
    expect(find.textContaining('internet'), findsNothing);
  });

  testWidgets('blames the internet when Formspree can\'t be reached', (
    tester,
  ) async {
    final offline = ProposalSender(
      formId: 'xyzabcde',
      client: MockClient(
        (_) async => throw http.ClientException('Failed host lookup'),
      ),
    );
    await _openAndSubmit(tester, offline);

    expect(find.textContaining('internet connection'), findsOneWidget);
    expect(find.byType(ProposeScreen), findsOneWidget);
  });

  testWidgets('explains when sending is not set up', (tester) async {
    await _openAndSubmit(tester, ProposalSender(formId: 'your-form-id'));

    expect(find.textContaining("isn't set up"), findsOneWidget);
    expect(find.byType(ProposeScreen), findsOneWidget);
  });
}
