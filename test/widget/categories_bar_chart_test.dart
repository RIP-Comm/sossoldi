import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sossoldi/pages/graphs/widgets/categories/categories_bar_chart.dart';
import 'package:sossoldi/providers/categories_provider.dart';

void main() {
  group('completedMonthsAverage', () {
    final totals = [100.0, 200.0, 0.0, 300.0, 10.0, ...List.filled(7, 0.0)];

    test('ignores the current month and the months without transactions', () {
      // May is in progress: average of Jan, Feb and Apr
      expect(completedMonthsAverage(totals, 2026, DateTime(2026, 5, 10)), 200);
    });

    test('uses every month with transactions for a past year', () {
      expect(
        completedMonthsAverage(totals, 2025, DateTime(2026, 5, 10)),
        152.5,
      );
    });

    test('is null when no month is over yet', () {
      expect(
        completedMonthsAverage(totals, 2026, DateTime(2026, 1, 10)),
        isNull,
      );
      expect(
        completedMonthsAverage(totals, 2027, DateTime(2026, 5, 10)),
        isNull,
      );
      expect(
        completedMonthsAverage(
          List.filled(12, 0.0),
          2025,
          DateTime(2026, 5, 10),
        ),
        isNull,
      );
    });
  });

  testWidgets('average line leaves out the month in progress', (tester) async {
    final now = DateTime.now();
    // Every past month spent 100, the current one only 10 so far
    final totals = List.generate(
      12,
      (i) => i < now.month - 1 ? 100.0 : (i == now.month - 1 ? 10.0 : 0.0),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [monthlyTotalsProvider.overrideWith((ref) async => totals)],
        child: const MaterialApp(
          home: Material(
            child: SingleChildScrollView(child: CategoriesBarChart()),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final lines = tester
        .widget<BarChart>(find.byType(BarChart))
        .data
        .extraLinesData
        .horizontalLines;
    if (now.month == 1) {
      expect(lines, isEmpty);
    } else {
      expect(lines.single.y, 100);
    }
  });
}
