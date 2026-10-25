import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tzikapp/widgets/logo.dart';

void main() {
  test('the A outline has the designed shape', () {
    bool filled(double x, double y) => letterA.contains(Offset(x, y));
    expect(filled(512, 270), isTrue, reason: 'apex');
    expect(filled(300, 760), isTrue, reason: 'left leg');
    expect(filled(724, 760), isTrue, reason: 'right leg');
    expect(filled(512, 580), isTrue, reason: 'crossbar');
    expect(filled(512, 480), isFalse, reason: 'hole above the crossbar');
    expect(filled(512, 720), isFalse, reason: 'between the legs');
    expect(filled(236, 786), isFalse, reason: 'rounded corner');
    expect(filled(300, 300), isFalse, reason: 'beside the apex');
  });

  testWidgets('AporiaLogo draws at the requested size', (tester) async {
    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: Center(child: AporiaLogo(size: 72)),
      ),
    );
    expect(tester.getSize(find.byType(AporiaLogo)), const Size(72, 72));
    expect(find.bySemanticsLabel('Aporia logo'), findsOneWidget);
  });
}
