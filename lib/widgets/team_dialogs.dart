import 'package:flutter/material.dart';

import '../models/team.dart';
import '../services/teams_store.dart';
import '../theme.dart';
import 'brand_dialog.dart';

/// Asks for a name and creates the team. Returns it, or null if cancelled.
Future<Team?> showCreateTeamDialog(BuildContext context, TeamsStore teams) =>
    showDialog<Team>(
      context: context,
      builder: (_) => _CreateTeamDialog(teams: teams),
    );

/// Lists the teams to pick the one playing, or delete one.
Future<void> showSelectTeamDialog(
  BuildContext context,
  TeamsStore teams, {
  required int questionCount,
}) => showDialog<void>(
  context: context,
  builder: (_) => _SelectTeamDialog(teams: teams, questionCount: questionCount),
);

class _CreateTeamDialog extends StatefulWidget {
  const _CreateTeamDialog({required this.teams});

  final TeamsStore teams;

  @override
  State<_CreateTeamDialog> createState() => _CreateTeamDialogState();
}

class _CreateTeamDialogState extends State<_CreateTeamDialog> {
  final _name = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final name = _name.text.trim();
    final error = name.isEmpty
        ? 'Give your team a name.'
        : widget.teams.hasName(name)
        ? 'There is already a team called $name.'
        : null;
    if (error != null) {
      setState(() => _error = error);
      return;
    }
    final team = await widget.teams.create(name);
    if (mounted) Navigator.of(context).pop(team);
  }

  @override
  Widget build(BuildContext context) {
    return BrandDialog(
      title: 'New team',
      content: TextField(
        controller: _name,
        autofocus: true,
        maxLength: 30,
        textCapitalization: TextCapitalization.words,
        textInputAction: TextInputAction.done,
        onSubmitted: (_) => _submit(),
        decoration: InputDecoration(
          labelText: 'Team name',
          hintText: 'Friday night crew',
          errorText: _error,
          border: const OutlineInputBorder(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(onPressed: _submit, child: const Text('Create')),
      ],
    );
  }
}

class _SelectTeamDialog extends StatelessWidget {
  const _SelectTeamDialog({required this.teams, required this.questionCount});

  final TeamsStore teams;
  final int questionCount;

  Future<void> _delete(BuildContext context, Team team) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => BrandDialog(
        title: 'Delete ${team.name}?',
        content: const Text(
          'The questions this team played will be forgotten.',
          style: TextStyle(color: brandNavy, fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed ?? false) await teams.delete(team);
  }

  @override
  Widget build(BuildContext context) {
    return BrandDialog(
      title: 'Teams',
      content: ListenableBuilder(
        listenable: teams,
        builder: (context, _) {
          final all = teams.teams;
          final selected = teams.selected;
          if (all.isEmpty) {
            return const Text(
              'No teams yet.',
              style: TextStyle(color: brandNavy, fontSize: 16),
            );
          }
          return ListView.separated(
            shrinkWrap: true,
            itemCount: all.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, i) {
              final team = all[i];
              final isSelected = team.id == selected?.id;
              return Card(
                margin: EdgeInsets.zero,
                color: Colors.white.withValues(alpha: isSelected ? 0.85 : 0.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: isSelected
                      ? const BorderSide(color: brandNavy, width: 2)
                      : BorderSide.none,
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.only(left: 12, right: 4),
                  leading: Icon(
                    isSelected
                        ? Icons.radio_button_checked
                        : Icons.radio_button_unchecked,
                    color: brandNavy,
                  ),
                  title: Text(
                    team.name,
                    style: const TextStyle(
                      color: brandNavy,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    '${team.played.length} of $questionCount played',
                  ),
                  trailing: IconButton(
                    tooltip: 'Delete ${team.name}',
                    onPressed: () => _delete(context, team),
                    icon: const Icon(Icons.delete_outline),
                  ),
                  onTap: () {
                    teams.select(team);
                    Navigator.of(context).pop();
                  },
                ),
              );
            },
          );
        },
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }
}
