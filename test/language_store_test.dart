import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tzikapp/services/language_store.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('follows the phone until switched', () async {
    final onGreekPhone = await LanguageStore.load(
      phoneLocale: const Locale('el', 'GR'),
    );
    expect(onGreekPhone.locale, const Locale('el'));

    final onFrenchPhone = await LanguageStore.load(
      phoneLocale: const Locale('fr'),
    );
    expect(onFrenchPhone.locale, const Locale('en'));
  });

  test('remembers the language picked, whatever the phone says', () async {
    final language = await LanguageStore.load(phoneLocale: const Locale('en'));
    await language.toggle();
    expect(language.isGreek, isTrue);

    final reloaded = await LanguageStore.load(phoneLocale: const Locale('en'));
    expect(reloaded.isGreek, isTrue);
  });

  test('switches back and forth, telling listeners', () async {
    final language = await LanguageStore.load(phoneLocale: const Locale('en'));
    var notified = 0;
    language.addListener(() => notified++);

    await language.toggle();
    await language.toggle();
    expect(language.isGreek, isFalse);
    expect(notified, 2);
  });
}
