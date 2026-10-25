import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/question.dart';
import '../services/favourites_store.dart';
import '../theme.dart';
import '../widgets/gradient_background.dart';

/// Shows the questions one at a time, in index order. Swipe or use
/// Previous/Next to move through them, or tap the title to jump to a number.
class QuestionScreen extends StatefulWidget {
  const QuestionScreen({
    super.key,
    required this.questions,
    required this.favourites,
    this.initialPage = 0,
    this.onPageChanged,
  });

  /// Sorted by index, as [parseQuestions] returns them.
  final List<Question> questions;
  final FavouritesStore favourites;

  /// Position in [questions] to start at (not a question index).
  final int initialPage;
  final ValueChanged<int>? onPageChanged;

  @override
  State<QuestionScreen> createState() => _QuestionScreenState();
}

class _QuestionScreenState extends State<QuestionScreen> {
  late int _page = widget.initialPage.clamp(0, widget.questions.length - 1);
  late final _pages = PageController(initialPage: _page);

  Question get _question => widget.questions[_page];
  bool get _isFirst => _page == 0;
  bool get _isLast => _page == widget.questions.length - 1;

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() => _page = page);
    widget.onPageChanged?.call(page);
  }

  void _step(int by) => _pages.animateToPage(
    _page + by,
    duration: const Duration(milliseconds: 350),
    curve: Curves.easeOutCubic,
  );

  Future<void> _goTo() async {
    final index = await showDialog<int>(
      context: context,
      builder: (_) => _GoToDialog(questions: widget.questions),
    );
    if (index == null) return;
    _pages.jumpToPage(widget.questions.indexWhere((q) => q.index == index));
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return GradientScaffold(
      appBar: AppBar(
        centerTitle: true,
        title: TextButton.icon(
          onPressed: _goTo,
          style: TextButton.styleFrom(
            foregroundColor: brandNavy,
            textStyle: textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          icon: const Icon(Icons.arrow_drop_down),
          iconAlignment: IconAlignment.end,
          label: Text('Question ${_question.index}'),
        ),
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pages,
                itemCount: widget.questions.length,
                onPageChanged: _onPageChanged,
                itemBuilder: (context, page) => Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(32),
                    child: Text(
                      widget.questions[page].text,
                      textAlign: TextAlign.center,
                      style: textTheme.headlineMedium?.copyWith(
                        color: brandNavy,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _isFirst ? null : () => _step(-1),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(52),
                      ),
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Previous'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ListenableBuilder(
                    listenable: widget.favourites,
                    builder: (context, _) {
                      final saved = widget.favourites.contains(_question.text);
                      return IconButton.outlined(
                        tooltip: saved
                            ? 'Remove from favourites'
                            : 'Save to favourites',
                        iconSize: 28,
                        style: IconButton.styleFrom(
                          side: BorderSide(
                            color: brandNavy.withValues(alpha: 0.35),
                          ),
                        ),
                        onPressed: () =>
                            widget.favourites.toggle(_question.text),
                        icon: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 250),
                          transitionBuilder: (child, animation) =>
                              ScaleTransition(scale: animation, child: child),
                          child: Icon(
                            saved ? Icons.favorite : Icons.favorite_border,
                            key: ValueKey(saved),
                            color: saved ? Colors.pink : brandNavy,
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: _isLast ? null : () => _step(1),
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(52),
                      ),
                      icon: const Icon(Icons.arrow_forward),
                      iconAlignment: IconAlignment.end,
                      label: const Text('Next'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Asks for a question number and returns it, if a question has it.
class _GoToDialog extends StatefulWidget {
  const _GoToDialog({required this.questions});

  final List<Question> questions;

  @override
  State<_GoToDialog> createState() => _GoToDialogState();
}

class _GoToDialogState extends State<_GoToDialog> {
  final _number = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _number.dispose();
    super.dispose();
  }

  void _submit() {
    final index = int.tryParse(_number.text);
    if (index != null && widget.questions.any((q) => q.index == index)) {
      Navigator.of(context).pop(index);
    } else {
      setState(() => _error = "There's no question ${_number.text}.");
    }
  }

  @override
  Widget build(BuildContext context) {
    final first = widget.questions.first.index;
    final last = widget.questions.last.index;
    return AlertDialog(
      title: const Text('Go to question'),
      content: TextField(
        controller: _number,
        autofocus: true,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        textInputAction: TextInputAction.go,
        onSubmitted: (_) => _submit(),
        decoration: InputDecoration(
          labelText: 'Number ($first–$last)',
          errorText: _error,
          border: const OutlineInputBorder(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(onPressed: _submit, child: const Text('Go')),
      ],
    );
  }
}
