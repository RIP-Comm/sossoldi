import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import "dart:math";
import 'package:sossoldi/shared/ui/widgets/line_chart.dart';
import 'package:fl_chart/fl_chart.dart';

void main() {
  testWidgets('Properly Render Accounts Widget', (WidgetTester tester) async {
    final random = Random(42); // Set fixed seed for reproducible tests
    double lower = -5;
    double upper = 8;

    await tester.pumpWidget(MaterialApp(
      home: Material(
        child: SizedBox(
          height: 400, // Explicit size to ensure proper rendering
          width: 600,
          child: LineChartWidget(
            lineData: List.generate(
                17,
                (i) => FlSpot(i.toDouble(),
                    lower + random.nextDouble() * (upper - lower))),
            lineColor: const Color(0xffffffff),
            line2Data: List.generate(
                30,
                (i) => FlSpot(i.toDouble(),
                    lower + random.nextDouble() * (upper - lower))),
            line2Color: const Color(0xffffffff),
            colorBackground: const Color(0xff356CA3),
            period: Period.month,
          ),
        ),
      ),
    ));

    // Wait for any animations to complete
    await tester.pumpAndSettle();

    // Verify chart is rendered
    expect(find.byType(LineChartWidget), findsOneWidget);

    // Test for visible axis labels (might need adjustment based on actual visible range)
    for (var i = 2; i <= 26; i += 3) {
      expect(find.text(i.toString()), findsOneWidget,
          reason: 'Expected to find axis label "$i"');
    }

    // Test basic chart properties
    final chartWidget =
        tester.widget<LineChartWidget>(find.byType(LineChartWidget));
    expect(chartWidget.lineColor, equals(const Color(0xffffffff)));
    expect(chartWidget.colorBackground, equals(const Color(0xff356CA3)));
  });
}
