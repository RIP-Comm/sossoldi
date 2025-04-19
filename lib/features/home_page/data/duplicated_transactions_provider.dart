import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/models/transaction.dart';

final duplicatedTransactoinProvider =
    StateProvider<Transaction?>((ref) => null);
