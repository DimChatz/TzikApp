// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Modern Greek (`el`).
class AppLocalizationsEl extends AppLocalizations {
  AppLocalizationsEl([String locale = 'el']) : super(locale);

  @override
  String get languageCode => 'ΕΛ';

  @override
  String get switchLanguage => 'Switch to English';

  @override
  String get splashTagline => 'Ερωτήσεις για δημιουργική βαρεμάρα';

  @override
  String loadFailed(String error) {
    return 'Δεν φορτώθηκαν οι ερωτήσεις:\n$error';
  }

  @override
  String get homeTagline =>
      'Ερωτήσεις & διλήμματα για συζήτηση\nμε την παρέα σου';

  @override
  String get start => 'ΠΑΜΕ';

  @override
  String get createTeamToStart => 'Φτιάξε μια ομάδα για να ξεκινήσεις';

  @override
  String playingAs(String team) {
    return 'Παίζει η ομάδα $team';
  }

  @override
  String get createTeam => 'Νέα ομάδα';

  @override
  String get selectTeam => 'Επιλογή ομάδας';

  @override
  String get favourites => 'Αγαπημένα';

  @override
  String get proposeQuestion => 'Πρότεινε μια ερώτηση';

  @override
  String get question => 'Ερώτηση';

  @override
  String noSuchQuestion(String number) {
    return 'Δεν υπάρχει ερώτηση $number.';
  }

  @override
  String playedCount(int played, int total) {
    String _temp0 = intl.Intl.pluralLogic(
      played,
      locale: localeName,
      other: 'Παίχτηκαν $played από $total',
      one: 'Παίχτηκε 1 από $total',
    );
    return '$_temp0';
  }

  @override
  String get played => 'Παίχτηκε';

  @override
  String get previous => 'Προηγούμενη';

  @override
  String get next => 'Επόμενη';

  @override
  String get markPlayed => 'Σήμανση ως παιγμένη';

  @override
  String get markNotPlayed => 'Σήμανση ως μη παιγμένη';

  @override
  String get saveToFavourites => 'Αποθήκευση στα αγαπημένα';

  @override
  String get removeFromFavourites => 'Αφαίρεση από τα αγαπημένα';

  @override
  String get noFavourites =>
      'Δεν έχεις αγαπημένα ακόμα.\nΠάτα την καρδιά σε μια ερώτηση για να την αποθηκεύσεις εδώ.';

  @override
  String get removedFromFavourites => 'Αφαιρέθηκε από τα αγαπημένα';

  @override
  String get undo => 'Αναίρεση';

  @override
  String get proposeIntro =>
      'Έχεις μια καλή ερώτηση ή ένα δίλημμα; Στείλ\' το και ίσως μπει στην εφαρμογή.';

  @override
  String get yourQuestion => 'Η ερώτησή σου';

  @override
  String get questionHint => 'Τι θα προτιμούσες...';

  @override
  String get questionTooShort => 'Γράψε τουλάχιστον 10 χαρακτήρες.';

  @override
  String get yourName => 'Το όνομά σου (προαιρετικό)';

  @override
  String get send => 'Αποστολή';

  @override
  String get sending => 'Αποστολή...';

  @override
  String get proposalSent => 'Ευχαριστούμε! Η ερώτησή σου στάλθηκε.';

  @override
  String get sendingNotSetUp =>
      'Η αποστολή δεν έχει ρυθμιστεί ακόμα: βάλε το Formspree form ID στο config.json και ξαναχτίσε την εφαρμογή.';

  @override
  String sendingRejected(int code) {
    return 'Η ερώτησή σου δεν στάλθηκε (σφάλμα $code). Δοκίμασε ξανά αργότερα.';
  }

  @override
  String get sendingOffline =>
      'Η ερώτησή σου δεν στάλθηκε. Έλεγξε τη σύνδεσή σου στο διαδίκτυο και δοκίμασε ξανά.';

  @override
  String get newTeam => 'Νέα ομάδα';

  @override
  String get teamName => 'Όνομα ομάδας';

  @override
  String get teamNameHint => 'Η παρέα της Παρασκευής';

  @override
  String get teamNameMissing => 'Δώσε ένα όνομα στην ομάδα σου.';

  @override
  String teamNameTaken(String team) {
    return 'Υπάρχει ήδη ομάδα με το όνομα $team.';
  }

  @override
  String get cancel => 'Άκυρο';

  @override
  String get create => 'Δημιουργία';

  @override
  String get teams => 'Ομάδες';

  @override
  String get noTeams => 'Δεν υπάρχουν ομάδες ακόμα.';

  @override
  String deleteTeam(String team) {
    return 'Διαγραφή: $team';
  }

  @override
  String deleteTeamQuestion(String team) {
    return 'Διαγραφή της ομάδας $team;';
  }

  @override
  String get deleteTeamWarning =>
      'Οι ερωτήσεις που έπαιξε αυτή η ομάδα θα ξεχαστούν.';

  @override
  String get delete => 'Διαγραφή';

  @override
  String get close => 'Κλείσιμο';
}
