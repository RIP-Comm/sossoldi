import 'package:flutter_test/flutter_test.dart';
import 'package:sossoldi/model/transaction.dart';
import 'package:sossoldi/providers/transactions_provider.dart';

void main() {
  // Creiamo un'istanza del notifier che contiene la funzione da testare
  final notifier = AsyncTransactionsNotifier();

  group('calculatePastTransactionDates', () {
    test('monthly recurrence - regular month', () {
      final startDate = DateTime(2023, 1, 15); // 15 gennaio 2023
      final endDate = DateTime(2023, 4, 1); // 1 aprile 2023

      final dates = notifier.calculatePastTransactionDates(
          startDate, endDate, Recurrence.monthly);

      expect(dates.length, 3);
      expect(dates[0], DateTime(2023, 1, 15)); // 15 gennaio
      expect(dates[1], DateTime(2023, 2, 15)); // 15 febbraio
      expect(dates[2], DateTime(2023, 3, 15)); // 15 marzo
    });

    test('daily recurrence', () {
      final startDate = DateTime(2023, 1, 1);
      final endDate = DateTime(2023, 1, 5);

      final dates = notifier.calculatePastTransactionDates(
          startDate, endDate, Recurrence.daily);

      expect(dates.length, 4);
      expect(dates[0], DateTime(2023, 1, 1));
      expect(dates[1], DateTime(2023, 1, 2));
      expect(dates[2], DateTime(2023, 1, 3));
      expect(dates[3], DateTime(2023, 1, 4));
    });

    test('monthly recurrence - month boundary (31 gennaio -> 28 febbraio)', () {
      final startDate = DateTime(2023, 1, 31); // 31 gennaio 2023
      final endDate = DateTime(2023, 3, 1); // 1 marzo 2023

      final dates = notifier.calculatePastTransactionDates(
          startDate, endDate, Recurrence.monthly);

      expect(dates.length, 2);
      expect(dates[0], DateTime(2023, 1, 31)); // 31 gennaio
      expect(dates[1], DateTime(2023, 2, 28)); // 28 febbraio (non 31)
    });

    test('monthly recurrence - leap year (31 gennaio -> 29 febbraio 2020)', () {
      final startDate = DateTime(2020, 1, 31); // 31 gennaio 2020
      final endDate = DateTime(2020, 3, 1); // 1 marzo 2020

      final dates = notifier.calculatePastTransactionDates(
          startDate, endDate, Recurrence.monthly);

      expect(dates.length, 2);
      expect(dates[0], DateTime(2020, 1, 31)); // 31 gennaio
      expect(dates[1], DateTime(2020, 2, 29)); // 29 febbraio (anno bisestile)
    });

    test('weekly recurrence', () {
      final startDate = DateTime(2023, 1, 1); // domenica
      final endDate = DateTime(2023, 1, 29); // domenica

      final dates = notifier.calculatePastTransactionDates(
          startDate, endDate, Recurrence.weekly);

      expect(dates.length, 4);
      expect(dates[0], DateTime(2023, 1, 1)); // 1 gennaio
      expect(dates[1], DateTime(2023, 1, 8)); // 8 gennaio
      expect(dates[2], DateTime(2023, 1, 15)); // 15 gennaio
      expect(dates[3], DateTime(2023, 1, 22)); // 22 gennaio
    });

    test('bimonthly recurrence', () {
      final startDate = DateTime(2023, 1, 15); // 15 gennaio 2023
      final endDate = DateTime(2023, 7, 1); // 1 luglio 2023

      final dates = notifier.calculatePastTransactionDates(
          startDate, endDate, Recurrence.bimonthly);

      expect(dates.length, 3);
      expect(dates[0], DateTime(2023, 1, 15)); // 15 gennaio
      expect(dates[1], DateTime(2023, 3, 15)); // 15 marzo
      expect(dates[2], DateTime(2023, 5, 15)); // 15 maggio
    });

    test('quarterly recurrence', () {
      final startDate = DateTime(2023, 1, 15); // 15 gennaio 2023
      final endDate = DateTime(2023, 10, 1); // 1 ottobre 2023

      final dates = notifier.calculatePastTransactionDates(
          startDate, endDate, Recurrence.quarterly);

      expect(dates.length, 3);
      expect(dates[0], DateTime(2023, 1, 15)); // 15 gennaio
      expect(dates[1], DateTime(2023, 4, 15)); // 15 aprile
      expect(dates[2], DateTime(2023, 7, 15)); // 15 luglio
    });
  });
}
