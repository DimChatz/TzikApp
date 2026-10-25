import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/question.dart';
import '../models/team.dart';
import '../services/favourites_store.dart';
import '../services/teams_store.dart';
import '../theme.dart';
import '../widgets/gradient_background.dart';

/// Shows the questions one at a time, in index order, for one team. Swipe or
/// use Previous/Next to move through them, or type a number in the title to
/// jump to it.
class QuestionScreen extends StatefulWidget {
  const QuestionScreen({
    super.key,
    required this.questions,
    required this.favourites,
    required this.teams,
    required this.team,
  });

  /// Sorted by index, as [parseQuestions] returns them.
  final List<Question> questions;
  final FavouritesStore favourites;
  final TeamsStore teams;

  /// The team playing. The screen opens where it left off and remembers
  /// where it gets to and which questions it played.
  final Team team;

  @override
  State<QuestionScreen> createState() => _QuestionScreenState();
}

class _QuestionScreenState extends State<QuestionScreen> {
  late int _page = widget.team.page.clamp(0, widget.questions.length - 1);
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
    widget.teams.setPage(widget.team, page);
  }

  void _step(int by) => _pages.animateToPage(
    _page + by,
    duration: const Duration(milliseconds: 350),
    curve: Curves.easeOutCubic,
  );

  /// Returns false if no question has [index].
  bool _goTo(int index) {
    final page = widget.questions.indexWhere((q) => q.index == index);
    if (page < 0) return false;
    if (page != _page) _pages.jumpToPage(page);
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final outlined = IconButton.styleFrom(
      side: BorderSide(color: brandNavy.withValues(alpha: 0.35)),
    );

    return GradientScaffold(
      appBar: AppBar(
        centerTitle: true,
        title: _QuestionNumber(index: _question.index, onSubmitted: _goTo),
      ),
      body: SafeArea(
        top: false,
        child: ListenableBuilder(
          listenable: widget.teams,
          builder: (context, _) {
            final played = widget.team.played;
            return Column(
              children: [
                Text(
                  '${widget.team.name} · ${played.length} of '
                  '${widget.questions.length} played',
                  style: textTheme.titleSmall?.copyWith(
                    color: brandNavy.withValues(alpha: 0.7),
                  ),
                ),
                Expanded(
                  child: PageView.builder(
                    controller: _pages,
                    itemCount: widget.questions.length,
                    onPageChanged: _onPageChanged,
                    itemBuilder: (context, page) {
                      final question = widget.questions[page];
                      return Center(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(32),
                          child: Column(
                            children: [
                              Text(
                                question.text,
                                textAlign: TextAlign.center,
                                style: textTheme.headlineMedium?.copyWith(
                                  color: brandNavy,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              if (played.contains(question.index)) ...[
                                const SizedBox(height: 20),
                                const Chip(
                                  avatar: Icon(Icons.check, color: brandNavy),
                                  label: Text('Played'),
                                  backgroundColor: Colors.white54,
                                  side: BorderSide.none,
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
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
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                          ),
                          icon: const Icon(Icons.arrow_back),
                          label: const _OneLine('Previous'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      _playedButton(played.contains(_question.index), outlined),
                      const SizedBox(width: 8),
                      _favouriteButton(outlined),
                      const SizedBox(width: 8),
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: _isLast ? null : () => _step(1),
                          style: FilledButton.styleFrom(
                            minimumSize: const Size.fromHeight(52),
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                          ),
                          icon: const Icon(Icons.arrow_forward),
                          iconAlignment: IconAlignment.end,
                          label: const _OneLine('Next'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _playedButton(bool played, ButtonStyle style) => IconButton.outlined(
    tooltip: played ? 'Mark as not played' : 'Mark as played',
    iconSize: 28,
    style: style,
    onPressed: () => widget.teams.togglePlayed(widget.team, _question.index),
    icon: _AnimatedIcon(
      icon: played ? Icons.check_circle : Icons.check_circle_outline,
      color: brandNavy,
    ),
  );

  Widget _favouriteButton(ButtonStyle style) => ListenableBuilder(
    listenable: widget.favourites,
    builder: (context, _) {
      final saved = widget.favourites.contains(_question.text);
      return IconButton.outlined(
        tooltip: saved ? 'Remove from favourites' : 'Save to favourites',
        iconSize: 28,
        style: style,
        onPressed: () => widget.favourites.toggle(_question.text),
        icon: _AnimatedIcon(
          icon: saved ? Icons.favorite : Icons.favorite_border,
          color: saved ? Colors.pink : brandNavy,
        ),
      );
    },
  );
}

/// Shrinks the text rather than wrapping it on narrow phones.
class _OneLine extends StatelessWidget {
  const _OneLine(this.text);

  final String text;

  @override
  Widget build(BuildContext context) =>
      FittedBox(fit: BoxFit.scaleDown, child: Text(text, maxLines: 1));
}

/// Pops in when the icon changes.
class _AnimatedIcon extends StatelessWidget {
  const _AnimatedIcon({required this.icon, required this.color});

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) => AnimatedSwitcher(
    duration: const Duration(milliseconds: 250),
    transitionBuilder: (child, animation) =>
        ScaleTransition(scale: animation, child: child),
    child: Icon(icon, key: ValueKey(icon), color: color),
  );
}

/// "Question [12]": the number is a field you can tap and overwrite to jump
/// to another question.
class _QuestionNumber extends StatefulWidget {
  const _QuestionNumber({required this.index, required this.onSubmitted});

  final int index;

  /// Returns false if there is no question with that number.
  final bool Function(int index) onSubmitted;

  @override
  State<_QuestionNumber> createState() => _QuestionNumberState();
}

class _QuestionNumberState extends State<_QuestionNumber> {
  late final _number = TextEditingController(text: '${widget.index}');
  final _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    _focus.addListener(_onFocusChanged);
  }

  @override
  void didUpdateWidget(_QuestionNumber oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_focus.hasFocus) _number.text = '${widget.index}';
  }

  @override
  void dispose() {
    _focus.dispose();
    _number.dispose();
    super.dispose();
  }

  void _onFocusChanged() {
    if (_focus.hasFocus) {
      // Typing replaces the number instead of adding to it.
      _number.selection = TextSelection(
        baseOffset: 0,
        extentOffset: _number.text.length,
      );
    } else {
      _submit();
    }
  }

  void _submit() {
    final typed = _number.text;
    final index = int.tryParse(typed);
    if (index != null && widget.onSubmitted(index)) {
      _number.text = '$index';
    } else {
      _number.text = '${widget.index}';
      if (typed.isNotEmpty) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(content: Text("There's no question $typed.")),
          );
      }
    }
    _focus.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.titleLarge
        ?.copyWith(color: brandNavy, fontWeight: FontWeight.bold);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('Question ', style: style),
        GestureDetector(
          onTap: _focus.requestFocus,
          child: Container(
            padding: const EdgeInsets.only(left: 10, right: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: brandNavy.withValues(alpha: 0.35)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ConstrainedBox(
                  constraints: const BoxConstraints(minWidth: 20),
                  child: IntrinsicWidth(
                    child: TextField(
                      controller: _number,
                      focusNode: _focus,
                      style: style,
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(5),
                      ],
                      textInputAction: TextInputAction.go,
                      onSubmitted: (_) => _submit(),
                      cursorColor: brandNavy,
                      decoration: const InputDecoration(
                        isDense: true,
                        filled: false,
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 6),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.edit,
                  size: 16,
                  color: brandNavy.withValues(alpha: 0.6),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
