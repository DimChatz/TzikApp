import 'package:flutter/material.dart';

import '../config.dart';
import '../models/question.dart';
import '../services/favourites_store.dart';
import '../services/question_repository.dart';
import '../widgets/gradient_background.dart';
import 'favourites_screen.dart';
import 'propose_screen.dart';
import 'question_dialog.dart';

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
  // Lives as long as the home screen, so closing and reopening the question
  // popup carries on through the deck instead of starting over.
  late final _deck = QuestionDeck(widget.questions);

  void _start() =>
      showQuestionDialog(context, deck: _deck, favourites: widget.favourites);

  void _open(Widget screen) =>
      Navigator.of(context)
          .push(MaterialPageRoute<void>(builder: (_) => screen));

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final actionStyle = OutlinedButton.styleFrom(
      foregroundColor: Colors.white,
      side: const BorderSide(color: Colors.white54),
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
                        Text(
                          appName,
                          style: textTheme.displaySmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Questions & dilemmas to argue about\nwith your friends',
                          textAlign: TextAlign.center,
                          style: textTheme.titleMedium?.copyWith(
                            color: Colors.white70,
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
            backgroundColor: Colors.white,
            foregroundColor: const Color(0xFF4527A0),
            elevation: 12,
            shadowColor: Colors.black54,
            textStyle: Theme.of(context).textTheme.headlineMedium
                ?.copyWith(fontWeight: FontWeight.w800, letterSpacing: 3),
          ),
          child: const Text('START'),
        ),
      ),
    );
  }
}
