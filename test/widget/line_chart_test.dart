import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import "dart:math";
import '../../lib/custom_widgets/line_chart.dart';
import 'package:fl_chart/fl_chart.dart';

void main() {
    testWidgets('Properly Render Accounts Widget', (WidgetTester tester) async {
      final random = Random();

      double lower = -5;
      double upper = 8;

      await tester.pumpWidget(MaterialApp(
        home: Material(
          child: LineChartWidget(
                    line1Data: [
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
                    colorLine1Data: const Color(0xffffffff),
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
                    colorLine2Data: const Color(0xffffffff),
                    colorBackground: const Color(0xff356CA3),
                    maxDays: 31.0,
                  ),
        ),
      )
    );

    expect(find.text('4'), findsOneWidget);
    expect(find.text('11'), findsOneWidget);
    expect(find.text('18'), findsOneWidget);
    expect(find.text('25'), findsOneWidget);

    }
  );
}