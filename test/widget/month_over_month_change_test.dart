import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sossoldi/pages/graphs/graphs_page.dart';

void main() {
  group('monthOverMonthChange', () {
    test('is the change of the last balance over the previous one', () {
      expect(
        monthOverMonthChange(const [
          FlSpot(0, 50),
          FlSpot(1, 200),
          FlSpot(2, 150),
        ]),
        -25,
      );
    });

    test('a negative balance that improves is a gain', () {
      expect(monthOverMonthChange(const [FlSpot(0, -100), FlSpot(1, -50)]), 50);
    });

    test('is null when it cannot be computed', () {
      expect(monthOverMonthChange(const []), isNull);
      expect(monthOverMonthChange(const [FlSpot(0, 100)]), isNull);
      // Previously Infinity%
      expect(
        monthOverMonthChange(const [FlSpot(0, 0), FlSpot(1, 100)]),
        isNull,
      );
    });
  });
}
