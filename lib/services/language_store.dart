import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The language the app is shown in, English or Greek, saved on the device.
///
/// Until it is switched with the language button, it follows the phone:
/// Greek on a phone set to Greek, English otherwise.
class LanguageStore extends ChangeNotifier {
  LanguageStore._(this._prefs, this._code);

  static const _key = 'language';
  static const _english = 'en';
  static const _greek = 'el';

  final SharedPreferences _prefs;
  String _code;

  /// [phoneLocale] defaults to the phone's language; tests pass their own.
  static Future<LanguageStore> load({Locale? phoneLocale}) async {
    final prefs = await SharedPreferences.getInstance();
    final phone = phoneLocale ?? PlatformDispatcher.instance.locale;
    final saved = prefs.getString(_key);
    return LanguageStore._(
      prefs,
      saved ?? (phone.languageCode == _greek ? _greek : _english),
    );
  }

  Locale get locale => Locale(_code);

  bool get isGreek => _code == _greek;

  /// Switches between English and Greek.
  Future<void> toggle() async {
    _code = isGreek ? _english : _greek;
    notifyListeners();
    await _prefs.setString(_key, _code);
  }
}
