import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/team.dart';

/// The teams, saved on the device, and which one is playing.
class TeamsStore extends ChangeNotifier {
  TeamsStore._(this._prefs, this._teams, this._selectedId);

  static const _teamsKey = 'teams';
  static const _selectedKey = 'selected_team';

  final SharedPreferences _prefs;
  final List<Team> _teams;
  String? _selectedId;

  static Future<TeamsStore> load() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_teamsKey);
    final teams = saved == null
        ? <Team>[]
        : [
            for (final json in jsonDecode(saved) as List)
              Team.fromJson(json as Map<String, dynamic>),
          ];
    return TeamsStore._(prefs, teams, prefs.getString(_selectedKey));
  }

  /// In the order they were created.
  List<Team> get teams => List.unmodifiable(_teams);

  /// The team playing now. Null only when there are no teams.
  Team? get selected {
    for (final team in _teams) {
      if (team.id == _selectedId) return team;
    }
    return _teams.isEmpty ? null : _teams.last;
  }

  /// Whether [name] is already taken, ignoring case and outer spaces.
  bool hasName(String name) {
    final wanted = name.trim().toLowerCase();
    return _teams.any((t) => t.name.toLowerCase() == wanted);
  }

  /// Adds a team, starting from the first question, and selects it.
  Future<Team> create(String name) async {
    // The clock can repeat for teams created in quick succession.
    var id = DateTime.now().microsecondsSinceEpoch;
    while (_teams.any((t) => t.id == '$id')) {
      id++;
    }
    final team = Team(id: '$id', name: name.trim());
    _teams.add(team);
    _selectedId = team.id;
    notifyListeners();
    await _save();
    return team;
  }

  Future<void> select(Team team) async {
    _selectedId = team.id;
    notifyListeners();
    await _save();
  }

  Future<void> delete(Team team) async {
    _teams.removeWhere((t) => t.id == team.id);
    if (_selectedId == team.id) _selectedId = null;
    notifyListeners();
    await _save();
  }

  /// Remembers where [team] is in the question list.
  Future<void> setPage(Team team, int page) async {
    if (team.page == page) return;
    team.page = page;
    await _save();
  }

  Future<void> togglePlayed(Team team, int questionIndex) async {
    if (!team.played.remove(questionIndex)) team.played.add(questionIndex);
    notifyListeners();
    await _save();
  }

  Future<void> _save() async {
    await _prefs.setString(
      _teamsKey,
      jsonEncode([for (final team in _teams) team.toJson()]),
    );
    final id = selected?.id;
    if (id == null) {
      await _prefs.remove(_selectedKey);
    } else {
      await _prefs.setString(_selectedKey, id);
    }
  }
}
