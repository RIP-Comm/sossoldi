import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/models/transaction.dart';

/// Provider to manage the selected transaction type
/// (income or expense) in the transactions page and tabs.
final selectedTransactionTypeProvider = StateProvider.autoDispose(
  (ref) => TransactionType.income,
);
