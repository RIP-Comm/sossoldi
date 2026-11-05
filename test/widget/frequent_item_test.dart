import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sossoldi/pages/transactions/create_transaction/widgets/frequent_item.dart';

void main() {
  Future<void> pumpItem(
    WidgetTester tester, {
    bool selected = false,
    VoidCallback? onTap,
    bool disableAnimations = false,
  }) => tester.pumpWidget(
    MaterialApp(
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(
          context,
        ).copyWith(disableAnimations: disableAnimations),
        child: child!,
      ),
      home: Scaffold(
        body: FrequentItem(
          label: 'Leisure',
          icon: Icons.movie,
          color: Colors.blue,
          selected: selected,
          onTap: onTap,
        ),
      ),
    ),
  );

  double iconScale(WidgetTester tester) => tester
      .widget<ScaleTransition>(
        find.ancestor(
          of: find.byIcon(Icons.movie),
          matching: find.byType(ScaleTransition),
        ),
      )
      .scale
      .value;

  double badgeScale(WidgetTester tester) =>
      tester.widget<AnimatedScale>(find.byType(AnimatedScale)).scale;

  testWidgets('GIVEN an item '
      'WHEN it is tapped '
      'THEN the icon bounces and the callback runs', (
    WidgetTester tester,
  ) async {
    var taps = 0;
    await pumpItem(tester, onTap: () => taps++);
    expect(iconScale(tester), 1.0);

    await tester.tap(find.text('Leisure'));
    await tester.pump();
    await tester.pump(FrequentItem.animationDuration * 0.2);
    expect(iconScale(tester), lessThan(1.0));
    await tester.pump(FrequentItem.animationDuration * 0.4);
    expect(iconScale(tester), greaterThan(1.0));
    await tester.pumpAndSettle();
    expect(iconScale(tester), 1.0);
    expect(taps, 1);
  });

  testWidgets('GIVEN an unselected item '
      'WHEN it becomes selected '
      'THEN the check badge pops in', (WidgetTester tester) async {
    await pumpItem(tester);
    expect(badgeScale(tester), 0);

    await pumpItem(tester, selected: true);
    await tester.pumpAndSettle();
    expect(badgeScale(tester), 1);
  });

  testWidgets('GIVEN animations disabled by the system '
      'WHEN an item is tapped '
      'THEN the icon does not bounce', (WidgetTester tester) async {
    var taps = 0;
    await pumpItem(tester, onTap: () => taps++, disableAnimations: true);

    await tester.tap(find.text('Leisure'));
    await tester.pump();
    await tester.pump(FrequentItem.animationDuration * 0.2);
    expect(iconScale(tester), 1.0);
    expect(taps, 1);
  });
}
