# TzikApp
An App with interesting questions to ask with your friend group for some constructive interesting boredom.

Built with Flutter for Android and iOS.

## How it works

1. A splash screen loads the questions, downloading the latest list from this repo
   (see [Editing the questions](#editing-the-questions)).
2. The home screen has a big **START** button. Tap it and the questions screen opens.
3. Questions go in order of their number. Use **Previous** and **Next** (or swipe) to move
   between them, or tap **Question N** at the top to jump straight to a number. Tap ♥ to
   save a question to **Favourites**. Going back and pressing START again carries on where
   you left off.
4. **Propose a question** sends the proposal straight from the app. It arrives in your
   inbox through [Formspree](https://formspree.io) (see [Setting up proposals](#setting-up-proposals)).

## Editing the questions

All questions live in [`assets/questions.json`](assets/questions.json), one per line:

```json
[
  { "index": 1, "text": "Would you rather explore deep space or the deep ocean?" },
  { "index": 2, "text": "Is free will real, or are we just very complicated dominoes?" }
]
```

- Every question needs an `index`: its number in the app, a whole number counting from 1.
  Each number can only be used once. The app shows questions in order of their index,
  whatever their order in the file. Gaps are allowed, so removing a question doesn't
  mean renumbering the rest; give a new question the next unused number.
- Every entry except the last needs a comma after it. If a question contains a
  double quote, write it as `\"`.
- Commit the change to `main` on GitHub, either by editing the file in the browser
  (pencil icon) or by pushing from your computer. **No app update is needed**: phones
  download the file from `main` every time the app opens. GitHub can take up to about
  5 minutes to serve the new version.
- If a phone is offline, it uses the last list it downloaded. A phone that has never
  been online uses the copy built into the app, which is refreshed whenever you build
  a new version.
- If an edit breaks the file, phones ignore it and keep the last good list. To check
  your edit, run `flutter test`: it verifies the file is valid JSON with no duplicate questions or indexes.
- The download address is `questionsUrl` in `lib/config.dart`.

Favourites are stored on the device by question text, so a favourite stays even if
you later edit or remove that question.

## Setting up proposals

The app can't safely hold your email password, so proposals go through Formspree, a free
service that emails you every submission (free plan: 50 per month).

1. Sign up at [formspree.io](https://formspree.io) with the email address you want proposals sent to.
2. Create a new form. Its endpoint looks like `https://formspree.io/f/xyzabcde`.
3. Copy `config.example.json` to `config.json` and put the ID (`xyzabcde`) in it.
   `config.json` is git-ignored, so the ID stays out of this public repo.
4. Always run and build with `--dart-define-from-file=config.json` (see below).
   The included VS Code launch settings already do this.

The ID still ends up inside the built app, which needs it to send proposals. Keeping it
out of the repo just means it isn't published here. If the form ever gets spammed,
create a new form in Formspree, delete the old one, and update `config.json`.

Each email has the subject "TzikApp question proposal" and contains the question and,
if given, the sender's name. If the app was built without the ID, tapping Send shows a
"not set up" message.

## Running and building

You need the [Flutter SDK](https://docs.flutter.dev/get-started/install). For Android you
also need Android Studio (or the Android SDK). For iOS you need a Mac with Xcode.

```sh
flutter pub get
flutter test                 # unit and widget tests, including the questions file check
flutter run --dart-define-from-file=config.json         # on a connected phone or emulator
flutter build apk --dart-define-from-file=config.json   # Android
flutter build ipa --dart-define-from-file=config.json   # iOS (on a Mac)
```

## Logo and app icon

The logo is drawn in code in `lib/widgets/logo.dart`, with its colours in `lib/theme.dart`,
so the app screens, the app icons and the exported files always match. `branding/` holds
the exports: `logo.svg` (editable), `logo-1024.png` (for app stores), and the layers Android
uses to fit the icon into different shapes. After changing the logo or its colours, run:

```sh
flutter test tool/render_logo_test.dart           # re-export branding/
dart run flutter_launcher_icons                   # regenerate the Android and iOS icons
git checkout ios/Runner.xcodeproj/project.pbxproj # undo an unwanted edit the previous step makes
```

## Keeping personal data out of this repo

This repo is public, so three safeguards stop personal data and secrets from being published:

- **Commit and push checks.** The hooks in `.githooks/` run `tool/check_for_leaks.sh`, which
  blocks a commit or push that contains a real email address (in files, commit messages or
  the commit's author details), passwords, keys or tokens, a Formspree form ID, or files such
  as `.env`, `config.json` or signing keys. The push check also catches commits made with
  `--no-verify`. Turn the hooks on once in every copy of the repo:
  ```sh
  git config core.hooksPath .githooks
  ```
  If something harmless gets blocked, add it to `ALLOWED` at the top of the script.
- **`.gitignore`** keeps secret files (`config.json`, `.env`, signing keys) out of commits.
- **GitHub push protection** (enabled in the repo settings) rejects pushes containing known
  kinds of keys and tokens. It also covers edits made on the GitHub website, which don't run
  the local hooks.

## Project layout

```
assets/questions.json         the questions
lib/config.dart               app name, questions download URL
lib/widgets/logo.dart         the logo, drawn in code
branding/                     exported logo files and icon layers
tool/render_logo_test.dart    re-exports branding/ from the code
config.example.json           template for the git-ignored config.json (Formspree form ID)
lib/screens/                  splash, home, questions, favourites, propose
lib/services/                 loading questions, favourites, sending proposals
tool/check_for_leaks.sh       blocks commits and pushes that would publish personal data
.githooks/                    git hooks that run it
test/                         tests
```
