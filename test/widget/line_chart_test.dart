import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import "dart:math";
import 'package:sossoldi/model/currency.dart';
import 'package:sossoldi/providers/currency_provider.dart';
import 'package:sossoldi/ui/widgets/line_chart.dart';
import 'package:fl_chart/fl_chart.dart';

class _EuroCurrencyState extends CurrencyState {
  @override
  Currency build() => const Currency(
    id: 1,
    symbol: '€',
    code: 'EUR',
    name: 'Euro',
    mainCurrency: true,
  );
}

Future<void> _pumpChart(WidgetTester tester, LineChartWidget chart) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [currencyStateProvider.overrideWith(_EuroCurrencyState.new)],
      child: MaterialApp(
        home: Material(
          child: SizedBox(
            height: 400, // Explicit size to ensure proper rendering
            width: 600,
            child: chart,
          ),
        ),
      ),
    ),
  );

  // Wait for any animations to complete
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('Properly Render Accounts Widget', (WidgetTester tester) async {
    final random = Random(42); // Set fixed seed for reproducible tests
    double lower = -5;
    double upper = 8;

    await _pumpChart(
      tester,
      LineChartWidget(
        lineData: List.generate(
          17,
          (i) => FlSpot(
            i.toDouble(),
            lower + random.nextDouble() * (upper - lower),
          ),
        ),
        lineColor: const Color(0xffffffff),
        line2Data: List.generate(
          30,
          (i) => FlSpot(
            i.toDouble(),
            lower + random.nextDouble() * (upper - lower),
          ),
        ),
        line2Color: const Color(0xffffffff),
        colorBackground: const Color(0xff356CA3),
        period: Period.month,
      ),
    );

    // Verify chart is rendered
    expect(find.byType(LineChartWidget), findsOneWidget);

    // Days are labelled like a calendar: 1, 5, 10, ... (every month has 28+ days)
    for (final day in [1, 5, 10, 15, 20, 25]) {
      expect(
        find.text(day.toString()),
        findsOneWidget,
        reason: 'Expected to find axis label "$day"',
      );
    }
    for (final day in [2, 3, 4, 6, 26]) {
      expect(find.text(day.toString()), findsNothing);
    }

    // Test basic chart properties
    final chartWidget = tester.widget<LineChartWidget>(
      find.byType(LineChartWidget),
    );
    expect(chartWidget.lineColor, equals(const Color(0xffffffff)));
    expect(chartWidget.colorBackground, equals(const Color(0xff356CA3)));
  });

  testWidgets(
    'Yearly chart labels every month, January and December included',
    (WidgetTester tester) async {
      await _pumpChart(
        tester,
        LineChartWidget(
          lineData: List.generate(12, (i) => FlSpot(i.toDouble(), i * 10.0)),
          enableGapFilling: false,
          period: Period.year,
        ),
      );

      for (final month in [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ]) {
        expect(find.text(month), findsOneWidget, reason: 'Missing "$month"');
      }
    },
  );

  testWidgets('Tooltip shows formatted amounts in the colour of their line', (
    WidgetTester tester,
  ) async {
    const currentColor = Color(0xff0000ff);
    const lastColor = Color(0xffff0000);

    await _pumpChart(
      tester,
      LineChartWidget(
        lineData: const [FlSpot(0, 10), FlSpot(1, 1234.5)],
        lineColor: currentColor,
        line2Data: const [FlSpot(0, 20), FlSpot(1, -980)],
        line2Color: lastColor,
      ),
    );

    final data = tester.widget<LineChart>(find.byType(LineChart)).data;
    final currentBar = data.lineBarsData[0];
    final lastBar = data.lineBarsData[1];

    final currentSpot = LineBarSpot(currentBar, 0, currentBar.spots[1]);
    final lastSpot = LineBarSpot(lastBar, 1, lastBar.spots[1]);

    // fl_chart passes the spots sorted by distance from the finger, so either
    // line can come first.
    for (final spots in [
      [currentSpot, lastSpot],
      [lastSpot, currentSpot],
    ]) {
      final items = data.lineTouchData.touchTooltipData.getTooltipItems(spots);
      final values = {
        for (final item in items)
          item!.children!.single.text: item.children!.single.style!.color,
      };
      expect(values, {'1234.50€': currentColor, '-980.00€': lastColor});
    }
  });
}
