import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/transaction.dart';

final duplicatedTransactoinProvider =
    StateProvider<Transaction?>((ref) => null);
