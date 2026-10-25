import 'package:flutter/material.dart';

import '../theme.dart';

/// The T as SVG path data on a 1024 x 1024 canvas: rounded outer corners and
/// small fillets where the stem meets the bar. Also used for the app icons
/// and branding/logo.svg (see tool/render_logo_test.dart).
const letterTPathData =
    'M276 250 L748 250 A44 44 0 0 1 792 294 L792 364 A44 44 0 0 1 748 408 '
    'L626 408 A28 28 0 0 0 598 436 L598 746 A44 44 0 0 1 554 790 '
    'L470 790 A44 44 0 0 1 426 746 L426 436 A28 28 0 0 0 398 408 '
    'L276 408 A44 44 0 0 1 232 364 L232 294 A44 44 0 0 1 276 250 Z';

final Path letterT = _parsePathData(letterTPathData);

/// The app logo with the rounded corners of an app icon. A soft shadow sets
/// it apart from the matching gradient behind it.
class TzikLogo extends StatelessWidget {
  const TzikLogo({super.key, required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    final corners = BorderRadius.circular(size * 0.2237);
    return Semantics(
      label: 'TzikApp logo',
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: corners,
          boxShadow: [
            BoxShadow(
              color: brandNavy.withValues(alpha: 0.2),
              blurRadius: size * 0.16,
              offset: Offset(0, size * 0.06),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: corners,
          child: CustomPaint(
            size: Size.square(size),
            painter: const LogoPainter(),
          ),
        ),
      ),
    );
  }
}

/// Paints the logo, or parts of it for the app icon layers.
class LogoPainter extends CustomPainter {
  const LogoPainter({
    this.background = brandGradient,
    this.letterColor = brandNavy,
    this.letterScale = 1,
  });

  /// Null leaves the background transparent.
  final Gradient? background;

  /// Null leaves out the letter.
  final Color? letterColor;

  /// Size of the T relative to the full logo.
  final double letterScale;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 1024);
    const canvasRect = Rect.fromLTWH(0, 0, 1024, 1024);
    if (background != null) {
      canvas.drawRect(
        canvasRect,
        Paint()..shader = background!.createShader(canvasRect),
      );
    }
    if (letterColor != null) {
      canvas
        ..translate(512, 512)
        ..scale(letterScale)
        ..translate(-512, -512)
        ..drawPath(letterT, Paint()..color = letterColor!);
    }
  }

  @override
  bool shouldRepaint(LogoPainter oldDelegate) =>
      background != oldDelegate.background ||
      letterColor != oldDelegate.letterColor ||
      letterScale != oldDelegate.letterScale;
}

/// Supports the M, L, A and Z commands used by [letterTPathData].
Path _parsePathData(String data) {
  final tokens = RegExp(r'[MLAZ]|-?[\d.]+')
      .allMatches(data)
      .map((m) => m[0]!)
      .toList();
  final path = Path();
  var i = 0;
  double next() => double.parse(tokens[i++]);
  while (i < tokens.length) {
    switch (tokens[i++]) {
      case 'M':
        path.moveTo(next(), next());
      case 'L':
        path.lineTo(next(), next());
      case 'A':
        final radius = Radius.elliptical(next(), next());
        final rotation = next();
        final largeArc = next() == 1;
        final clockwise = next() == 1;
        path.arcToPoint(
          Offset(next(), next()),
          radius: radius,
          rotation: rotation,
          largeArc: largeArc,
          clockwise: clockwise,
        );
      case 'Z':
        path.close();
    }
  }
  return path;
}
