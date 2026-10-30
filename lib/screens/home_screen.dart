import 'package:flutter/material.dart';

import '../config.dart';
import '../l10n/app_localizations.dart';
import '../models/question.dart';
import '../services/favourites_store.dart';
import '../services/language_store.dart';
import '../services/teams_store.dart';
import '../theme.dart';
import '../widgets/gradient_background.dart';
import '../widgets/language_button.dart';
import '../widgets/logo.dart';
import '../widgets/team_dialogs.dart';
import 'favourites_screen.dart';
import 'propose_screen.dart';
import 'question_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.questions,
    required this.favourites,
    required this.teams,
    required this.language,
  });

  final List<Question> questions;
  final FavouritesStore favourites;
  final TeamsStore teams;
  final LanguageStore language;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  /// Playing needs a team, so without one START asks for it first.
  Future<void> _start() async {
    final team =
        widget.teams.selected ??
        await showCreateTeamDialog(context, widget.teams);
    if (team == null || !mounted) return;
    await Navigator.of(context).push(
      PageRouteBuilder<void>(
        transitionDuration: const Duration(milliseconds: 450),
        pageBuilder: (_, _, _) => QuestionScreen(
          questions: widget.questions,
          favourites: widget.favourites,
          teams: widget.teams,
          team: team,
          language: widget.language,
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
  }

  void _open(Widget screen) =>
      Navigator.of(context)
          .push(MaterialPageRoute<void>(builder: (_) => screen));

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context);
    final actionStyle = OutlinedButton.styleFrom(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
    );

    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          // The language button floats in the corner so it doesn't push the
          // rest down.
          child: Stack(
            children: [
              LayoutBuilder(
                builder: (context, constraints) => SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: IntrinsicHeight(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [
                            const Spacer(flex: 2),
                            const AporiaLogo(size: 72),
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
                              l10n.homeTagline,
                              textAlign: TextAlign.center,
                              style: textTheme.titleMedium?.copyWith(
                                color: brandNavy.withValues(alpha: 0.7),
                              ),
                            ),
                            const Spacer(flex: 2),
                            _TeamPicker(
                              teams: widget.teams,
                              questionCount: widget.questions.length,
                            ),
                            const SizedBox(height: 28),
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
                                    final count =
                                        widget.favourites.items.length;
                                    return OutlinedButton.icon(
                                      style: actionStyle,
                                      onPressed: () => _open(
                                        FavouritesScreen(
                                          favourites: widget.favourites,
                                          questions: widget.questions,
                                        ),
                                      ),
                                      icon: Badge(
                                        isLabelVisible: count > 0,
                                        label: Text('$count'),
                                        child: const Icon(Icons.favorite),
                                      ),
                                      label: Text(l10n.favourites),
                                    );
                                  },
                                ),
                                OutlinedButton.icon(
                                  style: actionStyle,
                                  onPressed: () => _open(const ProposeScreen()),
                                  icon: const Icon(Icons.lightbulb_outline),
                                  label: Text(l10n.proposeQuestion),
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
              Positioned(
                top: 8,
                right: 8,
                child: LanguageButton(language: widget.language),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Buttons to create a team and to pick which one is playing.
class _TeamPicker extends StatelessWidget {
  const _TeamPicker({required this.teams, required this.questionCount});

  final TeamsStore teams;
  final int questionCount;

  @override
  Widget build(BuildContext context) {
    final style = OutlinedButton.styleFrom(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      backgroundColor: Colors.white.withValues(alpha: 0.4),
    );
    final l10n = AppLocalizations.of(context);
    return ListenableBuilder(
      listenable: teams,
      builder: (context, _) {
        final selected = teams.selected;
        return Column(
          children: [
            Text(
              selected == null
                  ? l10n.createTeamToStart
                  : l10n.playingAs(selected.name),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium
                  ?.copyWith(color: brandNavy, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 12,
              runSpacing: 12,
              children: [
                OutlinedButton.icon(
                  style: style,
                  onPressed: () => showCreateTeamDialog(context, teams),
                  icon: const Icon(Icons.group_add_outlined),
                  label: Text(l10n.createTeam),
                ),
                OutlinedButton.icon(
                  style: style,
                  onPressed: selected == null
                      ? null
                      : () => showSelectTeamDialog(
                          context,
                          teams,
                          questionCount: questionCount,
                        ),
                  icon: const Icon(Icons.groups_outlined),
                  label: Text(l10n.selectTeam),
                ),
              ],
            ),
          ],
        );
      },
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
          child: Text(AppLocalizations.of(context).start),
        ),
      ),
    );
  }
}
