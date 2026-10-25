// Renders the logo files in branding/ from lib/widgets/logo.dart.
//
// After changing the logo or its colours, run:
//   flutter test tool/render_logo_test.dart
//   dart run flutter_launcher_icons
//   git checkout ios/Runner.xcodeproj/project.pbxproj
// (flutter_launcher_icons wrongly rewrites an unrelated Xcode setting.)
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tzikapp/theme.dart';
import 'package:tzikapp/widgets/logo.dart';

// Android shows the middle 72 of an adaptive icon's 108 units, cropped to the
// phone's icon shape. Shrinking the T and stretching the gradient by this
// factor makes the visible part look like the full logo.
const _androidVisible = 72 / 108;

const _androidBackground = LinearGradient(
  begin: Alignment(-_androidVisible, -_androidVisible),
  end: Alignment(_androidVisible, _androidVisible),
  colors: [brandGreen, brandBlue],
);

Future<void> _savePng(String name, LogoPainter painter) async {
  final recorder = ui.PictureRecorder();
  painter.paint(Canvas(recorder), const Size.square(1024));
  final image = await recorder.endRecording().toImage(1024, 1024);
  final png = await image.toByteData(format: ui.ImageByteFormat.png);
  File('branding/$name').writeAsBytesSync(png!.buffer.asUint8List());
}

String _hex(Color c) =>
    '#${(c.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase()}';

void main() {
  test('render logo files', () async {
    File('branding/logo.svg').writeAsStringSync('''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1024 1024" width="1024" height="1024">
  <defs>
    <linearGradient id="background" x1="0" y1="0" x2="1" y2="1">
      <stop offset="0" stop-color="${_hex(brandGreen)}"/>
      <stop offset="1" stop-color="${_hex(brandBlue)}"/>
    </linearGradient>
  </defs>
  <rect width="1024" height="1024" fill="url(#background)"/>
  <path fill="${_hex(brandNavy)}" d="$letterTPathData"/>
</svg>
''');

    // Full logo: iOS icon and older Android versions.
    await _savePng('logo-1024.png', const LogoPainter());

    // Android adaptive icon layers, plus the single-colour layer Android 13+
    // uses for themed icons.
    await _savePng(
      'icon-background.png',
      const LogoPainter(background: _androidBackground, letterColor: null),
    );
    await _savePng(
      'icon-foreground.png',
      const LogoPainter(background: null, letterScale: _androidVisible),
    );
    await _savePng(
      'icon-monochrome.png',
      const LogoPainter(
        background: null,
        letterColor: Colors.white,
        letterScale: _androidVisible,
      ),
    );
  });
}
