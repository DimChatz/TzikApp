import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tzikapp/main.dart';
import 'package:tzikapp/models/question.dart';
import 'package:tzikapp/screens/home_screen.dart';
import 'package:tzikapp/screens/question_screen.dart';
import 'package:tzikapp/services/favourites_store.dart';
import 'package:tzikapp/services/language_store.dart';
import 'package:tzikapp/services/teams_store.dart';

const _questions = [
  Question(index: 1, text: 'Cats or dogs?', greekText: 'Γάτες ή σκύλοι;'),
  Question(index: 2, text: 'Mountains or sea?'),
  Question(index: 5, text: 'Tea or coffee?', greekText: 'Τσάι ή καφές;'),
];

// The START button pulses forever, so pumpAndSettle would never settle.
Future<void> _animate(WidgetTester tester) async {
  for (var i = 0; i < 10; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

void main() {
  late FavouritesStore favourites;
  late TeamsStore teams;
  late LanguageStore language;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    favourites = await FavouritesStore.load();
    teams = await TeamsStore.load();
    language = await LanguageStore.load(phoneLocale: const Locale('en'));
  });

  /// Starts with a team called Friends unless [withTeam] is false.
  Future<void> pumpHome(WidgetTester tester, {bool withTeam = true}) async {
    if (withTeam) await teams.create('Friends');
    await tester.pumpWidget(
      AporiaApp(
        language: language,
        home: HomeScreen(
          questions: _questions,
          favourites: favourites,
          teams: teams,
          language: language,
        ),
      ),
    );
  }

  Future<void> tapAndAnimate(WidgetTester tester, Finder finder) async {
    await tester.tap(finder);
    await _animate(tester);
  }

  /// The number in the "Question N" title.
  String shownNumber(WidgetTester tester) =>
      tester.widget<TextField>(find.byType(TextField)).controller!.text;

  Future<void> typeNumber(WidgetTester tester, String number) async {
    await tester.enterText(find.byType(TextField), number);
    await tester.testTextInput.receiveAction(TextInputAction.go);
    await _animate(tester);
  }

  testWidgets('START opens the questions at number 1', (tester) async {
    await pumpHome(tester);
    expect(find.byType(QuestionScreen), findsNothing);

    await tapAndAnimate(tester, find.text('START'));
    expect(find.byType(QuestionScreen), findsOneWidget);
    expect(find.text('Question '), findsOneWidget);
    expect(shownNumber(tester), '1');
    expect(find.text('Cats or dogs?'), findsOneWidget);
  });

  testWidgets('START without a team asks to create one first', (tester) async {
    await pumpHome(tester, withTeam: false);
    expect(find.text('Create a team to start'), findsOneWidget);

    await tapAndAnimate(tester, find.text('START'));
    expect(find.byType(QuestionScreen), findsNothing);
    await tapAndAnimate(tester, find.text('Create'));
    expect(find.text('Give your team a name.'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'Book club');
    await tapAndAnimate(tester, find.text('Create'));
    expect(teams.selected?.name, 'Book club');
    expect(find.byType(QuestionScreen), findsOneWidget);
  });

  testWidgets('team names must be unique', (tester) async {
    await pumpHome(tester);
    await tapAndAnimate(tester, find.text('Create team'));
    await tester.enterText(find.byType(TextField), 'friends');
    await tapAndAnimate(tester, find.text('Create'));
    expect(
      find.text('There is already a team called friends.'),
      findsOneWidget,
    );
    expect(teams.teams, hasLength(1));
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
    expect(shownNumber(tester), '2');
    expect(find.text('Mountains or sea?'), findsOneWidget);

    await tapAndAnimate(tester, find.text('Next'));
    expect(shownNumber(tester), '5');
    expect(enabled('Next'), isFalse);

    await tapAndAnimate(tester, find.text('Previous'));
    expect(shownNumber(tester), '2');
  });

  testWidgets('typing a number in the title jumps to it', (tester) async {
    await pumpHome(tester);
    await tapAndAnimate(tester, find.text('START'));

    await typeNumber(tester, '3');
    expect(find.text("There's no question 3."), findsOneWidget);
    expect(shownNumber(tester), '1');
    expect(find.byType(Dialog), findsNothing);

    await typeNumber(tester, '5');
    expect(shownNumber(tester), '5');
    expect(find.text('Tea or coffee?'), findsOneWidget);
  });

  testWidgets('reopening carries on where you left off', (tester) async {
    await pumpHome(tester);
    await tapAndAnimate(tester, find.text('START'));
    await tapAndAnimate(tester, find.text('Next'));

    await tapAndAnimate(tester, find.byType(BackButton));
    await tapAndAnimate(tester, find.text('START'));
    expect(shownNumber(tester), '2');
  });

  testWidgets('each team has its own place and played questions', (
    tester,
  ) async {
    await pumpHome(tester);
    await tapAndAnimate(tester, find.text('START'));
    await tapAndAnimate(tester, find.byTooltip('Mark as played'));
    expect(find.text('Played'), findsOneWidget);
    expect(find.text('Friends · 1 of 3 played'), findsOneWidget);
    await tapAndAnimate(tester, find.text('Next'));
    await tapAndAnimate(tester, find.byType(BackButton));

    // A new team starts from the beginning with nothing played.
    await tapAndAnimate(tester, find.text('Create team'));
    await tester.enterText(find.byType(TextField), 'Family');
    await tapAndAnimate(tester, find.text('Create'));
    expect(find.text('Playing as Family'), findsOneWidget);
    await tapAndAnimate(tester, find.text('START'));
    expect(shownNumber(tester), '1');
    expect(find.text('Played'), findsNothing);
    await tapAndAnimate(tester, find.byType(BackButton));

    // Switching back carries on where Friends left off.
    await tapAndAnimate(tester, find.text('Select team'));
    expect(find.text('1 of 3 played'), findsOneWidget);
    await tapAndAnimate(tester, find.text('Friends'));
    expect(find.text('Playing as Friends'), findsOneWidget);
    await tapAndAnimate(tester, find.text('START'));
    expect(shownNumber(tester), '2');
    await tapAndAnimate(tester, find.text('Previous'));
    expect(find.text('Played'), findsOneWidget);
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

  testWidgets('the globe switches the app and the questions to Greek', (
    tester,
  ) async {
    await pumpHome(tester);
    await tapAndAnimate(tester, find.byIcon(Icons.language));
    expect(find.text('ΠΑΜΕ'), findsOneWidget);
    expect(find.text('Παίζει η ομάδα Friends'), findsOneWidget);

    await tapAndAnimate(tester, find.text('ΠΑΜΕ'));
    expect(find.text('Ερώτηση '), findsOneWidget);
    expect(find.text('Γάτες ή σκύλοι;'), findsOneWidget);
    expect(find.text('Friends · Παίχτηκαν 0 από 3'), findsOneWidget);

    // A question without a Greek version is shown in English.
    await tapAndAnimate(tester, find.text('Επόμενη'));
    expect(find.text('Mountains or sea?'), findsOneWidget);

    // Switching back on the questions screen keeps your place.
    await tapAndAnimate(tester, find.byIcon(Icons.language));
    expect(find.text('Question '), findsOneWidget);
    expect(shownNumber(tester), '2');
    expect(language.isGreek, isFalse);
  });

  testWidgets('a favourite saved in Greek shows in Greek', (tester) async {
    await pumpHome(tester);
    await tapAndAnimate(tester, find.byIcon(Icons.language));
    await tapAndAnimate(tester, find.text('ΠΑΜΕ'));
    await tapAndAnimate(tester, find.byTooltip('Αποθήκευση στα αγαπημένα'));

    // Saved by its English text, so the heart works in both languages.
    expect(favourites.items, ['Cats or dogs?']);

    await tapAndAnimate(tester, find.byType(BackButton));
    await tapAndAnimate(tester, find.text('Αγαπημένα'));
    expect(find.text('Γάτες ή σκύλοι;'), findsOneWidget);
  });

  testWidgets('propose screen validates before sending', (tester) async {
    await pumpHome(tester);
    await tapAndAnimate(tester, find.text('Propose a question'));

    await tapAndAnimate(tester, find.text('Send'));
    expect(find.textContaining('at least 10 characters'), findsOneWidget);
  });
}
