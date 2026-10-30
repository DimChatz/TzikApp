import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'config.dart';
import 'l10n/app_localizations.dart';
import 'screens/splash_screen.dart';
import 'services/language_store.dart';
import 'theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  // Loaded first so that even the splash screen is in the right language.
  final language = await LanguageStore.load();
  runApp(AporiaApp(language: language));
}

class AporiaApp extends StatelessWidget {
  const AporiaApp({super.key, required this.language, this.home});

  final LanguageStore language;

  /// Defaults to the splash screen; tests pass their own.
  final Widget? home;

  @override
  Widget build(BuildContext context) {
    // Switching language rebuilds every screen in it, keeping your place.
    return ListenableBuilder(
      listenable: language,
      builder: (context, _) => MaterialApp(
        title: appName,
        debugShowCheckedModeBanner: false,
        theme: buildTheme(),
        locale: language.locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: home ?? SplashScreen(language: language),
      ),
    );
  }
}
