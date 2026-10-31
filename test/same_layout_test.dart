import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tzikapp/main.dart';
import 'package:tzikapp/models/question.dart';
import 'package:tzikapp/screens/favourites_screen.dart';
import 'package:tzikapp/screens/home_screen.dart';
import 'package:tzikapp/screens/propose_screen.dart';
import 'package:tzikapp/services/favourites_store.dart';
import 'package:tzikapp/services/language_store.dart';
import 'package:tzikapp/services/teams_store.dart';
import 'package:tzikapp/widgets/logo.dart';

const _questions = [
  Question(index: 1, text: 'Cats or dogs?', greekText: 'Γάτες ή σκύλοι;'),
  Question(index: 2, text: 'Mountains or sea?'),
];

/// A narrow and a wide phone.
const _phones = [Size(360, 780), Size(412, 915)];

// The START button pulses forever, so pumpAndSettle would never settle.
Future<void> _animate(WidgetTester tester) async {
  for (var i = 0; i < 10; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

/// Where every button, icon, text field and the logo is, and how big. By
/// their centre, which stays put while the START button pulses.
List<(Type, Offset, Size)> _layout(WidgetTester tester) => [
  for (final finder in [
    find.bySubtype<ButtonStyleButton>(),
    find.byType(Icon),
    find.byType(TextField),
    find.byType(AporiaLogo),
  ])
    for (var i = 0; i < finder.evaluate().length; i++)
      (
        finder.at(i).evaluate().single.widget.runtimeType,
        tester.getCenter(finder.at(i)),
        tester.getSize(finder.at(i)),
      ),
];

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

  Future<void> pumpApp(WidgetTester tester, Size phone, Widget home) async {
    tester.view.physicalSize = phone * 3;
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(AporiaApp(language: language, home: home));
    await _animate(tester);
  }

  Widget homeScreen() => HomeScreen(
    questions: _questions,
    favourites: favourites,
    teams: teams,
    language: language,
  );

  /// Switches to Greek and checks nothing moved or changed size.
  Future<void> expectSameInGreek(WidgetTester tester) async {
    final english = _layout(tester);
    expect(english, isNotEmpty);
    await language.toggle();
    await _animate(tester);
    expect(language.isGreek, isTrue);
    expect(_layout(tester), english);
  }

  for (final phone in _phones) {
    final size = '${phone.width.round()}x${phone.height.round()}';

    testWidgets('home screen without a team, $size', (tester) async {
      await pumpApp(tester, phone, homeScreen());
      await expectSameInGreek(tester);
    });

    testWidgets('home screen with a team, $size', (tester) async {
      await teams.create('Friends');
      await pumpApp(tester, phone, homeScreen());
      await expectSameInGreek(tester);
    });

    testWidgets('questions screen, $size', (tester) async {
      await teams.create('Friends');
      await pumpApp(tester, phone, homeScreen());
      await tester.tap(find.text('START'));
      await _animate(tester);
      await expectSameInGreek(tester);
    });

    testWidgets('new team pop-up, $size', (tester) async {
      await pumpApp(tester, phone, homeScreen());
      await tester.tap(find.text('Create team'));
      await _animate(tester);
      await expectSameInGreek(tester);
    });

    testWidgets('propose screen, $size', (tester) async {
      await pumpApp(tester, phone, const ProposeScreen());
      await expectSameInGreek(tester);
    });

    testWidgets('empty favourites, $size', (tester) async {
      await pumpApp(
        tester,
        phone,
        FavouritesScreen(favourites: favourites, questions: _questions),
      );
      await expectSameInGreek(tester);
    });
  }
}
