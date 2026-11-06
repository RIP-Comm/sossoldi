import 'package:flutter_test/flutter_test.dart';
import 'package:sossoldi/services/database/repositories/transactions_repository.dart';
import 'package:sossoldi/services/database/repositories/account_repository.dart';
import 'package:sossoldi/services/database/repositories/bank_connection_repository.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../../../support/bank_sync_harness.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();

  test(
    'transaction editor recognizes the bank ledger until local disconnect',
    () async {
      final harness = BankSyncHarness(databaseFactoryFfi);
      await harness.open();
      addTearDown(harness.close);
      expect((await harness.service.syncAccount(1)).completed, isTrue);
      final database = NativeContractDatabase(harness.db);
      final repository = TransactionsRepository(database: database);
      final transaction = (await repository.selectAll()).single;
      expect(transaction.isBankImported, isTrue);
      expect(transaction.copy(note: 'Local note').isBankImported, isTrue);
      expect(transaction.toJson().containsKey('bankImported'), isFalse);
      expect(
        (await repository.selectById(transaction.id!)).isBankImported,
        isTrue,
      );
      final accountHistory = await AccountRepository(
        database: database,
      ).getTransactions(1, 10);
      expect(accountHistory.single['bankImported'], 1);
      await BankConnectionRepository.withDatabase(
        harness.db,
      ).disconnectLocally(1);
      expect(
        (await repository.selectById(transaction.id!)).isBankImported,
        isFalse,
      );
      expect((await repository.selectAll()).single.amount, transaction.amount);
    },
  );

  test(
    'search with apostrophes and an empty type filter preserves bank ownership',
    () async {
      final harness = BankSyncHarness(databaseFactoryFfi);
      await harness.open();
      addTearDown(harness.close);
      harness.pages = [
        [bankRecord(note: "McDonald's synthetic purchase")],
      ];
      expect((await harness.service.syncAccount(1)).completed, isTrue);
      final repository = TransactionsRepository(
        database: NativeContractDatabase(harness.db),
      );

      final imported = await repository.selectAll(
        label: "mcdonald's",
        transactionType: [],
      );
      expect(imported, hasLength(1));
      expect(imported.single.note, "McDonald's synthetic purchase");
      expect(imported.single.isBankImported, isTrue);
      expect(await repository.getAllLabels(label: "mcdonald's"), [
        "mcdonald's synthetic purchase",
      ]);

      await BankConnectionRepository.withDatabase(
        harness.db,
      ).disconnectLocally(1);
      final manual = await repository.selectAll(
        label: "mcdonald's",
        transactionType: [],
      );
      expect(manual.single.id, imported.single.id);
      expect(manual.single.isBankImported, isFalse);
    },
  );
}
