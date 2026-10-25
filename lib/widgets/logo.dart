import 'package:flutter/material.dart';

import '../theme.dart';

/// The A as SVG path data on a 1024 x 1024 canvas: a flat-topped A with
/// rounded corners, small fillets under the crossbar and a triangular hole,
/// wound the other way so it stays empty. Also used for the app icons and
/// branding/logo.svg (see tool/render_logo_test.dart).
const letterAPathData =
    'M 411.7 279.4 A 44 44 0 0 1 453.2 250 L 570.8 250 A 44 44 0 0 1 612.3 279.4 '
    'L 771.4 731.4 A 44 44 0 0 1 729.9 790 L 693.2 790 A 44 44 0 0 1 651.7 760.6 '
    'L 612.3 648.7 A 28 28 0 0 0 585.9 630 L 438.1 630 A 28 28 0 0 0 411.7 648.7 '
    'L 372.3 760.6 A 44 44 0 0 1 330.8 790 L 294.1 790 A 44 44 0 0 1 252.6 731.4 Z '
    'M 527.1 406.6 A 16 16 0 0 0 496.9 406.6 L 464.5 498.7 '
    'A 16 16 0 0 0 479.6 520 L 544.4 520 A 16 16 0 0 0 559.5 498.7 Z';

final Path letterA = _parsePathData(letterAPathData);

/// The app logo with the rounded corners of an app icon. A soft shadow sets
/// it apart from the matching gradient behind it.
class AporiaLogo extends StatelessWidget {
  const AporiaLogo({super.key, required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    final corners = BorderRadius.circular(size * 0.2237);
    return Semantics(
      label: 'Aporia logo',
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

  /// Size of the A relative to the full logo.
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
        ..drawPath(letterA, Paint()..color = letterColor!);
    }
  }

  @override
  bool shouldRepaint(LogoPainter oldDelegate) =>
      background != oldDelegate.background ||
      letterColor != oldDelegate.letterColor ||
      letterScale != oldDelegate.letterScale;
}

/// Supports the M, L, A and Z commands used by [letterAPathData].
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
