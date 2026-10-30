import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_el.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('el'),
    Locale('en'),
  ];

  /// Short name of this language, shown on the language button.
  ///
  /// In en, this message translates to:
  /// **'EN'**
  String get languageCode;

  /// Tooltip of the language button, written in the language it switches to.
  ///
  /// In en, this message translates to:
  /// **'Αλλαγή σε Ελληνικά'**
  String get switchLanguage;

  /// No description provided for @splashTagline.
  ///
  /// In en, this message translates to:
  /// **'Questions for constructive boredom'**
  String get splashTagline;

  /// No description provided for @loadFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load the questions:\n{error}'**
  String loadFailed(String error);

  /// No description provided for @homeTagline.
  ///
  /// In en, this message translates to:
  /// **'Questions & dilemmas to argue about\nwith your friends'**
  String get homeTagline;

  /// No description provided for @start.
  ///
  /// In en, this message translates to:
  /// **'START'**
  String get start;

  /// No description provided for @createTeamToStart.
  ///
  /// In en, this message translates to:
  /// **'Create a team to start'**
  String get createTeamToStart;

  /// No description provided for @playingAs.
  ///
  /// In en, this message translates to:
  /// **'Playing as {team}'**
  String playingAs(String team);

  /// No description provided for @createTeam.
  ///
  /// In en, this message translates to:
  /// **'Create team'**
  String get createTeam;

  /// No description provided for @selectTeam.
  ///
  /// In en, this message translates to:
  /// **'Select team'**
  String get selectTeam;

  /// No description provided for @favourites.
  ///
  /// In en, this message translates to:
  /// **'Favourites'**
  String get favourites;

  /// No description provided for @proposeQuestion.
  ///
  /// In en, this message translates to:
  /// **'Propose a question'**
  String get proposeQuestion;

  /// Title of the questions screen, followed by the question's number.
  ///
  /// In en, this message translates to:
  /// **'Question'**
  String get question;

  /// No description provided for @noSuchQuestion.
  ///
  /// In en, this message translates to:
  /// **'There\'s no question {number}.'**
  String noSuchQuestion(String number);

  /// No description provided for @playedCount.
  ///
  /// In en, this message translates to:
  /// **'{played} of {total} played'**
  String playedCount(int played, int total);

  /// No description provided for @played.
  ///
  /// In en, this message translates to:
  /// **'Played'**
  String get played;

  /// No description provided for @previous.
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get previous;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @markPlayed.
  ///
  /// In en, this message translates to:
  /// **'Mark as played'**
  String get markPlayed;

  /// No description provided for @markNotPlayed.
  ///
  /// In en, this message translates to:
  /// **'Mark as not played'**
  String get markNotPlayed;

  /// No description provided for @saveToFavourites.
  ///
  /// In en, this message translates to:
  /// **'Save to favourites'**
  String get saveToFavourites;

  /// No description provided for @removeFromFavourites.
  ///
  /// In en, this message translates to:
  /// **'Remove from favourites'**
  String get removeFromFavourites;

  /// No description provided for @noFavourites.
  ///
  /// In en, this message translates to:
  /// **'No favourites yet.\nTap the heart on a question to save it here.'**
  String get noFavourites;

  /// No description provided for @removedFromFavourites.
  ///
  /// In en, this message translates to:
  /// **'Removed from favourites'**
  String get removedFromFavourites;

  /// No description provided for @undo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undo;

  /// No description provided for @proposeIntro.
  ///
  /// In en, this message translates to:
  /// **'Got a great question or dilemma? Send it over and it might make it into the app.'**
  String get proposeIntro;

  /// No description provided for @yourQuestion.
  ///
  /// In en, this message translates to:
  /// **'Your question'**
  String get yourQuestion;

  /// No description provided for @questionHint.
  ///
  /// In en, this message translates to:
  /// **'Would you rather...'**
  String get questionHint;

  /// No description provided for @questionTooShort.
  ///
  /// In en, this message translates to:
  /// **'Please write at least 10 characters.'**
  String get questionTooShort;

  /// No description provided for @yourName.
  ///
  /// In en, this message translates to:
  /// **'Your name (optional)'**
  String get yourName;

  /// No description provided for @send.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get send;

  /// No description provided for @sending.
  ///
  /// In en, this message translates to:
  /// **'Sending...'**
  String get sending;

  /// No description provided for @proposalSent.
  ///
  /// In en, this message translates to:
  /// **'Thanks! Your question was sent.'**
  String get proposalSent;

  /// No description provided for @sendingNotSetUp.
  ///
  /// In en, this message translates to:
  /// **'Sending isn\'t set up yet: put your Formspree form ID in config.json and rebuild the app.'**
  String get sendingNotSetUp;

  /// No description provided for @sendingRejected.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t send your question (error {code}). Please try again later.'**
  String sendingRejected(int code);

  /// No description provided for @sendingOffline.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t send your question. Check your internet connection and try again.'**
  String get sendingOffline;

  /// No description provided for @newTeam.
  ///
  /// In en, this message translates to:
  /// **'New team'**
  String get newTeam;

  /// No description provided for @teamName.
  ///
  /// In en, this message translates to:
  /// **'Team name'**
  String get teamName;

  /// No description provided for @teamNameHint.
  ///
  /// In en, this message translates to:
  /// **'Friday night crew'**
  String get teamNameHint;

  /// No description provided for @teamNameMissing.
  ///
  /// In en, this message translates to:
  /// **'Give your team a name.'**
  String get teamNameMissing;

  /// No description provided for @teamNameTaken.
  ///
  /// In en, this message translates to:
  /// **'There is already a team called {team}.'**
  String teamNameTaken(String team);

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @create.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get create;

  /// No description provided for @teams.
  ///
  /// In en, this message translates to:
  /// **'Teams'**
  String get teams;

  /// No description provided for @noTeams.
  ///
  /// In en, this message translates to:
  /// **'No teams yet.'**
  String get noTeams;

  /// No description provided for @deleteTeam.
  ///
  /// In en, this message translates to:
  /// **'Delete {team}'**
  String deleteTeam(String team);

  /// No description provided for @deleteTeamQuestion.
  ///
  /// In en, this message translates to:
  /// **'Delete {team}?'**
  String deleteTeamQuestion(String team);

  /// No description provided for @deleteTeamWarning.
  ///
  /// In en, this message translates to:
  /// **'The questions this team played will be forgotten.'**
  String get deleteTeamWarning;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['el', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'el':
      return AppLocalizationsEl();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
