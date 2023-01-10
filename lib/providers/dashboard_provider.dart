import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/accounts_provider.dart';
import '../model/bank_account.dart';

final dashboardProvider = FutureProvider.autoDispose<void>((ref) async {
  // al posto di questo ovviamente ci va la query sul db per ottenere i dati veri
  const List<BankAccount> accountList = [
    BankAccount(name: 'Main account', value: 1235.10),
    BankAccount(name: 'N26', value: 3823.56),
    BankAccount(name: 'Fineco', value: 0.07),
  ];

  ref.read(accountListProvider.notifier).state = accountList;
});


// final caseListProvider = FutureProvider.autoDispose.family<List<Case>, int?>((ref, category) async {
//   Map filter = {
//     "tag": ref.read(tagFilterProvider),
//     "sesso": ref.read(sessoFilterProvider),
//     "categoria": category ?? ref.read(categoryFilterProvider),
//     "emofilia": ref.read(emofiliaFilterProvider),
//     "regime": ref.read(regimeFilterProvider),
//     "eta_min": ref.read(etaFilterProvider).start.round(),
//     "eta_max": ref.read(etaFilterProvider).end.round(),
//   };
//   filter.removeWhere((key, value) => value == null || value == 0 || value == 100);
//   return ref.read(apiProvider).getCases(filter: filter);
// });
