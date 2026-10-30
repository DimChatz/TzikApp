import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tzikapp/l10n/app_localizations.dart';
import 'package:tzikapp/screens/favourites_screen.dart';
import 'package:tzikapp/services/favourites_store.dart';

const _removed = 'Removed from favourites';

void main() {
  late FavouritesStore favourites;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    favourites = await FavouritesStore.load();
    await favourites.add('Cats or dogs?');
  });

  /// Opens the favourites from another screen and removes the only one.
  Future<void> openAndRemove(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => FavouritesScreen(
                    favourites: favourites,
                    questions: const [],
                  ),
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
    await tester.tap(find.byTooltip('Remove from favourites'));
    await tester.pumpAndSettle();
    expect(find.text(_removed), findsOneWidget);
  }

  testWidgets('the Undo message goes away by itself', (tester) async {
    await openAndRemove(tester);

    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
    expect(find.text(_removed), findsNothing);
    expect(favourites.items, isEmpty);
  });

  testWidgets('Undo puts the favourite back', (tester) async {
    await openAndRemove(tester);

    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();
    expect(favourites.items, ['Cats or dogs?']);
    expect(find.text(_removed), findsNothing);
  });

  testWidgets('the Undo message closes when leaving the screen', (
    tester,
  ) async {
    await openAndRemove(tester);

    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(find.byType(FavouritesScreen), findsNothing);
    expect(find.text(_removed), findsNothing);
  });
}
