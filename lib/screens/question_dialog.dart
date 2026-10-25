import 'package:flutter/material.dart';

import '../models/question.dart';
import '../services/favourites_store.dart';
import '../services/question_repository.dart';

/// Pops a question up over the current screen.
Future<void> showQuestionDialog(
  BuildContext context, {
  required QuestionDeck deck,
  required FavouritesStore favourites,
}) {
  return showGeneralDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Close question',
    barrierColor: Colors.black54,
    transitionDuration: const Duration(milliseconds: 350),
    pageBuilder: (_, _, _) =>
        QuestionDialog(deck: deck, favourites: favourites),
    transitionBuilder: (_, animation, _, child) => FadeTransition(
      opacity: animation,
      child: ScaleTransition(
        scale: Tween<double>(begin: 0.7, end: 1).animate(
          CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutBack,
            reverseCurve: Curves.easeIn,
          ),
        ),
        child: child,
      ),
    ),
  );
}

class QuestionDialog extends StatefulWidget {
  const QuestionDialog({
    super.key,
    required this.deck,
    required this.favourites,
  });

  final QuestionDeck deck;
  final FavouritesStore favourites;

  @override
  State<QuestionDialog> createState() => _QuestionDialogState();
}

class _QuestionDialogState extends State<QuestionDialog> {
  late Question _question = widget.deck.next();

  void _next() => setState(() => _question = widget.deck.next());

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 8, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  tooltip: 'Close',
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ),
              Flexible(
                child: Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder: (child, animation) => FadeTransition(
                      opacity: animation,
                      child: ScaleTransition(
                        scale: Tween<double>(
                          begin: 0.85,
                          end: 1,
                        ).animate(animation),
                        child: child,
                      ),
                    ),
                    child: SingleChildScrollView(
                      key: ObjectKey(_question),
                      child: Text(
                        _question.text,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.headlineSmall,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Row(
                  children: [
                    ListenableBuilder(
                      listenable: widget.favourites,
                      builder: (context, _) {
                        final saved = widget.favourites.contains(
                          _question.text,
                        );
                        return IconButton.filledTonal(
                          tooltip: saved
                              ? 'Remove from favourites'
                              : 'Save to favourites',
                          iconSize: 28,
                          onPressed: () =>
                              widget.favourites.toggle(_question.text),
                          icon: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 250),
                            transitionBuilder: (child, animation) =>
                                ScaleTransition(scale: animation, child: child),
                            child: Icon(
                              saved ? Icons.favorite : Icons.favorite_border,
                              key: ValueKey(saved),
                              color: saved ? Colors.pink : null,
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: _next,
                        style: FilledButton.styleFrom(
                          minimumSize: const Size.fromHeight(52),
                        ),
                        icon: const Icon(Icons.arrow_forward),
                        label: const Text('Next'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
