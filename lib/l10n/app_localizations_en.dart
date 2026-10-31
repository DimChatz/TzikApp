// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get languageCode => 'EN';

  @override
  String get switchLanguage => 'Αλλαγή σε Ελληνικά';

  @override
  String get splashTagline => 'Questions for constructive boredom';

  @override
  String loadFailed(String error) {
    return 'Couldn\'t load the questions:\n$error';
  }

  @override
  String get homeTagline =>
      'Questions & dilemmas to argue about\nwith your friends';

  @override
  String get start => 'START';

  @override
  String get createTeamToStart => 'Create a team to start';

  @override
  String playingAs(String team) {
    return 'Playing as $team';
  }

  @override
  String get createTeam => 'Create team';

  @override
  String get selectTeam => 'Select team';

  @override
  String get favourites => 'Favourites';

  @override
  String get proposeQuestion => 'Propose a question';

  @override
  String get question => 'Question';

  @override
  String noSuchQuestion(String number) {
    return 'There\'s no question $number.';
  }

  @override
  String playedCount(int played, int total) {
    return '$played of $total played';
  }

  @override
  String get previous => 'Previous';

  @override
  String get next => 'Next';

  @override
  String get markPlayed => 'Mark as played';

  @override
  String get markNotPlayed => 'Mark as not played';

  @override
  String get saveToFavourites => 'Save to favourites';

  @override
  String get removeFromFavourites => 'Remove from favourites';

  @override
  String get noFavourites =>
      'No favourites yet.\nTap the heart on a question to save it here.';

  @override
  String get removedFromFavourites => 'Removed from favourites';

  @override
  String get undo => 'Undo';

  @override
  String get proposeIntro =>
      'Got a great question or dilemma? Send it over and it might make it into the app.';

  @override
  String get yourQuestion => 'Your question';

  @override
  String get questionHint => 'Would you rather...';

  @override
  String get questionTooShort => 'Please write at least 10 characters.';

  @override
  String get yourName => 'Your name (optional)';

  @override
  String get send => 'Send';

  @override
  String get sending => 'Sending...';

  @override
  String get proposalSent => 'Thanks! Your question was sent.';

  @override
  String get sendingNotSetUp =>
      'Sending isn\'t set up yet: put your Formspree form ID in config.json and rebuild the app.';

  @override
  String sendingRejected(int code) {
    return 'Couldn\'t send your question (error $code). Please try again later.';
  }

  @override
  String get sendingOffline =>
      'Couldn\'t send your question. Check your internet connection and try again.';

  @override
  String get newTeam => 'New team';

  @override
  String get teamName => 'Team name';

  @override
  String get teamNameHint => 'Friday night crew';

  @override
  String get teamNameMissing => 'Give your team a name.';

  @override
  String teamNameTaken(String team) {
    return 'There is already a team called $team.';
  }

  @override
  String get cancel => 'Cancel';

  @override
  String get create => 'Create';

  @override
  String get teams => 'Teams';

  @override
  String get noTeams => 'No teams yet.';

  @override
  String deleteTeam(String team) {
    return 'Delete $team';
  }

  @override
  String deleteTeamQuestion(String team) {
    return 'Delete $team?';
  }

  @override
  String get deleteTeamWarning =>
      'The questions this team played will be forgotten.';

  @override
  String get delete => 'Delete';

  @override
  String get close => 'Close';
}
