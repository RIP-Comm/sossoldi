import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import "dart:math";
import 'package:sossoldi/custom_widgets/line_chart.dart';
import 'package:fl_chart/fl_chart.dart';

void main() {
  testWidgets('Properly Render Accounts Widget', (WidgetTester tester) async {
    final random = Random();

    double lower = -5;
    double upper = 8;

    await tester.pumpWidget(MaterialApp(
      home: Material(
        child: LineChartWidget(
          lineData: [
            FlSpot(0, lower + random.nextDouble() * (upper - lower)),
            FlSpot(1, lower + random.nextDouble() * (upper - lower)),
            FlSpot(2, lower + random.nextDouble() * (upper - lower)),
            FlSpot(3, lower + random.nextDouble() * (upper - lower)),
            FlSpot(4, lower + random.nextDouble() * (upper - lower)),
            FlSpot(5, lower + random.nextDouble() * (upper - lower)),
            FlSpot(6, lower + random.nextDouble() * (upper - lower)),
            FlSpot(7, lower + random.nextDouble() * (upper - lower)),
            FlSpot(8, lower + random.nextDouble() * (upper - lower)),
            FlSpot(9, lower + random.nextDouble() * (upper - lower)),
            FlSpot(10, lower + random.nextDouble() * (upper - lower)),
            FlSpot(11, lower + random.nextDouble() * (upper - lower)),
            FlSpot(12, lower + random.nextDouble() * (upper - lower)),
            FlSpot(13, lower + random.nextDouble() * (upper - lower)),
            FlSpot(14, lower + random.nextDouble() * (upper - lower)),
            FlSpot(15, lower + random.nextDouble() * (upper - lower)),
            FlSpot(16, lower + random.nextDouble() * (upper - lower)),
          ],
          lineColor: const Color(0xffffffff),
          line2Data: [
            FlSpot(0, lower + random.nextDouble() * (upper - lower)),
            FlSpot(1, lower + random.nextDouble() * (upper - lower)),
            FlSpot(2, lower + random.nextDouble() * (upper - lower)),
            FlSpot(3, lower + random.nextDouble() * (upper - lower)),
            FlSpot(4, lower + random.nextDouble() * (upper - lower)),
            FlSpot(5, lower + random.nextDouble() * (upper - lower)),
            FlSpot(6, lower + random.nextDouble() * (upper - lower)),
            FlSpot(7, lower + random.nextDouble() * (upper - lower)),
            FlSpot(8, lower + random.nextDouble() * (upper - lower)),
            FlSpot(9, lower + random.nextDouble() * (upper - lower)),
            FlSpot(10, lower + random.nextDouble() * (upper - lower)),
            FlSpot(11, lower + random.nextDouble() * (upper - lower)),
            FlSpot(12, lower + random.nextDouble() * (upper - lower)),
            FlSpot(13, lower + random.nextDouble() * (upper - lower)),
            FlSpot(14, lower + random.nextDouble() * (upper - lower)),
            FlSpot(15, lower + random.nextDouble() * (upper - lower)),
            FlSpot(16, lower + random.nextDouble() * (upper - lower)),
            FlSpot(17, lower + random.nextDouble() * (upper - lower)),
            FlSpot(18, lower + random.nextDouble() * (upper - lower)),
            FlSpot(19, lower + random.nextDouble() * (upper - lower)),
            FlSpot(20, lower + random.nextDouble() * (upper - lower)),
            FlSpot(21, lower + random.nextDouble() * (upper - lower)),
            FlSpot(22, lower + random.nextDouble() * (upper - lower)),
            FlSpot(23, lower + random.nextDouble() * (upper - lower)),
            FlSpot(24, lower + random.nextDouble() * (upper - lower)),
            FlSpot(25, lower + random.nextDouble() * (upper - lower)),
            FlSpot(26, lower + random.nextDouble() * (upper - lower)),
            FlSpot(27, lower + random.nextDouble() * (upper - lower)),
            FlSpot(28, lower + random.nextDouble() * (upper - lower)),
            FlSpot(29, lower + random.nextDouble() * (upper - lower)),
          ],
          line2Color: const Color(0xffffffff),
          colorBackground: const Color(0xff356CA3),
          period: Period.month,
        ),
      ),
    ));

    expect(find.text('2'), findsOneWidget);
    expect(find.text('5'), findsOneWidget);
    expect(find.text('8'), findsOneWidget);
    expect(find.text('11'), findsOneWidget);
    expect(find.text('14'), findsOneWidget);
    expect(find.text('17'), findsOneWidget);
    expect(find.text('20'), findsOneWidget);
    expect(find.text('23'), findsOneWidget);
    expect(find.text('26'), findsOneWidget);
    expect(find.text('29'), findsOneWidget);
  });
}
