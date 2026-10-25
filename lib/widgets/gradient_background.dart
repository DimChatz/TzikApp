import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme.dart';

/// Full-screen brand gradient with dark status bar icons.
class GradientBackground extends StatelessWidget {
  const GradientBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: DecoratedBox(
        decoration: const BoxDecoration(gradient: brandGradient),
        child: SizedBox.expand(child: child),
      ),
    );
  }
}
