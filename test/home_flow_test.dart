import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tzikapp/models/question.dart';
import 'package:tzikapp/screens/home_screen.dart';
import 'package:tzikapp/services/favourites_store.dart';

const _questions = [
  Question(text: 'Cats or dogs?'),
  Question(text: 'Mountains or sea?'),
];

// The START button pulses forever, so pumpAndSettle would never settle.
Future<void> _animate(WidgetTester tester) async {
  for (var i = 0; i < 10; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

void main() {
  late FavouritesStore favourites;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    favourites = await FavouritesStore.load();
  });

  Future<void> pumpHome(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: HomeScreen(questions: _questions, favourites: favourites),
      ),
    );
  }

  Text questionText(WidgetTester tester) => tester.widget<Text>(
    find.byWidgetPredicate(
      (w) => w is Text && _questions.any((q) => q.text == w.data),
    ),
  );

  testWidgets('START pops up a question, Next shows another', (tester) async {
    await pumpHome(tester);
    expect(find.byType(Dialog), findsNothing);

    await tester.tap(find.text('START'));
    await _animate(tester);
    expect(find.byType(Dialog), findsOneWidget);
    final first = questionText(tester).data;

    await tester.tap(find.text('Next'));
    await _animate(tester);
    expect(questionText(tester).data, isNot(first));
  });

  testWidgets('heart saves the question to favourites', (tester) async {
    await pumpHome(tester);
    await tester.tap(find.text('START'));
    await _animate(tester);
    final shown = questionText(tester).data!;

    await tester.tap(find.byTooltip('Save to favourites'));
    await _animate(tester);
    expect(favourites.items, [shown]);
    expect(find.byTooltip('Remove from favourites'), findsOneWidget);

    // Close the popup and open the favourites list.
    await tester.tap(find.byTooltip('Close'));
    await _animate(tester);
    await tester.tap(find.text('Favourites'));
    await _animate(tester);
    expect(find.text(shown), findsOneWidget);
  });

  testWidgets('propose screen validates before sending', (tester) async {
    await pumpHome(tester);
    await tester.tap(find.text('Propose a question'));
    await _animate(tester);

    await tester.tap(find.text('Send'));
    await _animate(tester);
    expect(find.textContaining('at least 10 characters'), findsOneWidget);
  });
}
