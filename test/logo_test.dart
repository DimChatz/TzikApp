import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tzikapp/widgets/logo.dart';

void main() {
  test('the T outline has the designed size and shape', () {
    expect(letterT.getBounds(), const Rect.fromLTRB(232, 250, 792, 790));
    expect(letterT.contains(const Offset(512, 700)), isTrue, reason: 'stem');
    expect(letterT.contains(const Offset(260, 330)), isTrue, reason: 'bar');
    expect(
      letterT.contains(const Offset(300, 600)),
      isFalse,
      reason: 'beside the stem',
    );
    expect(
      letterT.contains(const Offset(236, 254)),
      isFalse,
      reason: 'rounded corner',
    );
  });

  testWidgets('TzikLogo draws at the requested size', (tester) async {
    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: Center(child: TzikLogo(size: 72)),
      ),
    );
    expect(tester.getSize(find.byType(TzikLogo)), const Size(72, 72));
    expect(find.bySemanticsLabel('TzikApp logo'), findsOneWidget);
  });
}
