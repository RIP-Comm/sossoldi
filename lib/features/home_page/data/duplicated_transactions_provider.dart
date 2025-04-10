import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../model/transaction.dart';

final duplicatedTransactoinProvider =
    StateProvider<Transaction?>((ref) => null);
