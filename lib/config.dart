const appName = 'TzikApp';

/// Formspree form that "Propose a question" submissions are sent to.
/// Formspree emails each submission to the address the form belongs to.
///
/// Read at build time from the git-ignored `config.json`, so it stays out of
/// the public repo. Build with `--dart-define-from-file=config.json`; without
/// it, Send shows a "not set up" message.
const formspreeFormId = String.fromEnvironment('FORMSPREE_FORM_ID');

/// Where the app downloads the latest questions from each time it opens.
/// Edit the file there and phones pick up the change on their next launch,
/// without an app update. Leave empty to only use `assets/questions.json`.
const questionsUrl =
    'https://raw.githubusercontent.com/DimChatz/TzikApp/main/assets/questions.json';
