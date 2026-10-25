import 'package:flutter/material.dart';

import '../config.dart';
import '../models/question.dart';
import '../services/favourites_store.dart';
import '../theme.dart';
import '../widgets/gradient_background.dart';
import '../widgets/logo.dart';
import 'favourites_screen.dart';
import 'propose_screen.dart';
import 'question_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.questions,
    required this.favourites,
  });

  final List<Question> questions;
  final FavouritesStore favourites;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Lives as long as the home screen, so leaving and reopening the questions
  // carries on where you left off instead of starting over.
  var _page = 0;

  void _start() => Navigator.of(context).push(
    PageRouteBuilder<void>(
      transitionDuration: const Duration(milliseconds: 450),
      pageBuilder: (_, _, _) => QuestionScreen(
        questions: widget.questions,
        favourites: widget.favourites,
        initialPage: _page,
        onPageChanged: (page) => _page = page,
      ),
      transitionsBuilder: (_, animation, _, child) => FadeTransition(
        opacity: animation,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.9, end: 1).animate(
            CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
          ),
          child: child,
        ),
      ),
    ),
  );

  void _open(Widget screen) =>
      Navigator.of(context)
          .push(MaterialPageRoute<void>(builder: (_) => screen));

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final actionStyle = OutlinedButton.styleFrom(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
    );

    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) => SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        const Spacer(flex: 2),
                        const TzikLogo(size: 72),
                        const SizedBox(height: 16),
                        Text(
                          appName,
                          style: textTheme.displaySmall?.copyWith(
                            color: brandNavy,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Questions & dilemmas to argue about\nwith your friends',
                          textAlign: TextAlign.center,
                          style: textTheme.titleMedium?.copyWith(
                            color: brandNavy.withValues(alpha: 0.7),
                          ),
                        ),
                        const Spacer(flex: 2),
                        _StartButton(onPressed: _start),
                        const SizedBox(height: 24),
                        const Spacer(flex: 3),
                        Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 12,
                          runSpacing: 12,
                          children: [
                            ListenableBuilder(
                              listenable: widget.favourites,
                              builder: (context, _) {
                                final count = widget.favourites.items.length;
                                return OutlinedButton.icon(
                                  style: actionStyle,
                                  onPressed: () => _open(
                                    FavouritesScreen(
                                      favourites: widget.favourites,
                                    ),
                                  ),
                                  icon: Badge(
                                    isLabelVisible: count > 0,
                                    label: Text('$count'),
                                    child: const Icon(Icons.favorite),
                                  ),
                                  label: const Text('Favourites'),
                                );
                              },
                            ),
                            OutlinedButton.icon(
                              style: actionStyle,
                              onPressed: () => _open(const ProposeScreen()),
                              icon: const Icon(Icons.lightbulb_outline),
                              label: const Text('Propose a question'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Big round button that gently pulses to invite a tap.
class _StartButton extends StatefulWidget {
  const _StartButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  State<_StartButton> createState() => _StartButtonState();
}

class _StartButtonState extends State<_StartButton>
    with SingleTickerProviderStateMixin {
  late final _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: Tween<double>(
        begin: 1,
        end: 1.06,
      ).animate(CurvedAnimation(parent: _pulse, curve: Curves.easeInOut)),
      child: SizedBox.square(
        dimension: 180,
        child: FilledButton(
          onPressed: widget.onPressed,
          style: FilledButton.styleFrom(
            shape: const CircleBorder(),
            backgroundColor: brandNavy,
            foregroundColor: Colors.white,
            elevation: 12,
            shadowColor: brandNavy,
            textStyle: Theme.of(context).textTheme.headlineMedium
                ?.copyWith(fontWeight: FontWeight.w800, letterSpacing: 3),
          ),
          child: const Text('START'),
        ),
      ),
    );
  }
}
