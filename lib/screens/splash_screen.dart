import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../config.dart';
import '../services/favourites_store.dart';
import '../services/question_repository.dart';
import '../services/teams_store.dart';
import '../theme.dart';
import '../widgets/gradient_background.dart';
import '../widgets/logo.dart';
import 'home_screen.dart';

const _minSplashTime = Duration(milliseconds: 1600);

/// Shows the logo while questions, favourites and teams load, then moves on to
/// [HomeScreen].
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Object? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final minDelay = Future<void>.delayed(_minSplashTime);
      final questions = await loadQuestions(rootBundle);
      final favourites = await FavouritesStore.load();
      final teams = await TeamsStore.load();
      await minDelay;
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        PageRouteBuilder<void>(
          transitionDuration: const Duration(milliseconds: 600),
          pageBuilder: (_, _, _) => HomeScreen(
            questions: questions,
            favourites: favourites,
            teams: teams,
          ),
          transitionsBuilder: (_, animation, _, child) =>
              FadeTransition(opacity: animation, child: child),
        ),
      );
    } catch (e) {
      if (mounted) setState(() => _error = e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      body: GradientBackground(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: const Duration(milliseconds: 900),
              curve: Curves.easeOutBack,
              builder: (context, t, child) => Opacity(
                opacity: t.clamp(0, 1),
                child: Transform.scale(scale: 0.6 + 0.4 * t, child: child),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const AporiaLogo(size: 140),
                  const SizedBox(height: 24),
                  Text(
                    appName,
                    style: textTheme.displayMedium?.copyWith(
                      color: brandNavy,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Questions for constructive boredom',
                    textAlign: TextAlign.center,
                    style: textTheme.titleMedium?.copyWith(
                      color: brandNavy.withValues(alpha: 0.7),
                    ),
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 32),
                    Text(
                      "Couldn't load the questions:\n$_error",
                      textAlign: TextAlign.center,
                      style: textTheme.bodyMedium?.copyWith(color: brandNavy),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
