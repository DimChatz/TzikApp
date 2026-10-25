import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tzikapp/models/question.dart';
import 'package:tzikapp/screens/home_screen.dart';
import 'package:tzikapp/screens/question_screen.dart';
import 'package:tzikapp/services/favourites_store.dart';

const _questions = [
  Question(index: 1, text: 'Cats or dogs?'),
  Question(index: 2, text: 'Mountains or sea?'),
  Question(index: 5, text: 'Tea or coffee?'),
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

  Future<void> tapAndAnimate(WidgetTester tester, Finder finder) async {
    await tester.tap(finder);
    await _animate(tester);
  }

  testWidgets('START opens the questions at number 1', (tester) async {
    await pumpHome(tester);
    expect(find.byType(QuestionScreen), findsNothing);

    await tapAndAnimate(tester, find.text('START'));
    expect(find.byType(QuestionScreen), findsOneWidget);
    expect(find.text('Question 1'), findsOneWidget);
    expect(find.text('Cats or dogs?'), findsOneWidget);
  });

  testWidgets('Next and Previous step through in index order', (tester) async {
    await pumpHome(tester);
    await tapAndAnimate(tester, find.text('START'));

    Finder button(String label) => find.ancestor(
      of: find.text(label),
      matching: find.bySubtype<ButtonStyleButton>(),
    );
    bool enabled(String label) =>
        tester.widget<ButtonStyleButton>(button(label)).enabled;

    expect(enabled('Previous'), isFalse);

    await tapAndAnimate(tester, find.text('Next'));
    expect(find.text('Question 2'), findsOneWidget);
    expect(find.text('Mountains or sea?'), findsOneWidget);

    await tapAndAnimate(tester, find.text('Next'));
    expect(find.text('Question 5'), findsOneWidget);
    expect(enabled('Next'), isFalse);

    await tapAndAnimate(tester, find.text('Previous'));
    expect(find.text('Question 2'), findsOneWidget);
  });

  testWidgets('jumps straight to a question by its number', (tester) async {
    await pumpHome(tester);
    await tapAndAnimate(tester, find.text('START'));

    await tapAndAnimate(tester, find.text('Question 1'));
    await tester.enterText(find.byType(TextField), '3');
    await tapAndAnimate(tester, find.text('Go'));
    expect(find.text("There's no question 3."), findsOneWidget);

    await tester.enterText(find.byType(TextField), '5');
    await tapAndAnimate(tester, find.text('Go'));
    expect(find.text('Question 5'), findsOneWidget);
    expect(find.text('Tea or coffee?'), findsOneWidget);
  });

  testWidgets('reopening carries on where you left off', (tester) async {
    await pumpHome(tester);
    await tapAndAnimate(tester, find.text('START'));
    await tapAndAnimate(tester, find.text('Next'));

    await tapAndAnimate(tester, find.byType(BackButton));
    await tapAndAnimate(tester, find.text('START'));
    expect(find.text('Question 2'), findsOneWidget);
  });

  testWidgets('heart saves the question to favourites', (tester) async {
    await pumpHome(tester);
    await tapAndAnimate(tester, find.text('START'));

    await tapAndAnimate(tester, find.byTooltip('Save to favourites'));
    expect(favourites.items, ['Cats or dogs?']);
    expect(find.byTooltip('Remove from favourites'), findsOneWidget);

    // Go back and open the favourites list.
    await tapAndAnimate(tester, find.byType(BackButton));
    await tapAndAnimate(tester, find.text('Favourites'));
    expect(find.text('Cats or dogs?'), findsOneWidget);
  });

  testWidgets('propose screen validates before sending', (tester) async {
    await pumpHome(tester);
    await tapAndAnimate(tester, find.text('Propose a question'));

    await tapAndAnimate(tester, find.text('Send'));
    expect(find.textContaining('at least 10 characters'), findsOneWidget);
  });
}
