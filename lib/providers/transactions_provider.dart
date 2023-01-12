import 'package:flutter_riverpod/flutter_riverpod.dart';

final selectedTransactionTypeProvider = StateProvider.autoDispose<List<bool>>((ref) => [false, true, false]);
final transactionImportProvider = StateProvider.autoDispose<num>((ref) => 0);
final selectedRecurringPayProvider = StateProvider.autoDispose<bool>((ref) => false);


class TransactionsNotifier extends StateNotifier<List> {
  // Inizializzamo la lista dei todo con una lista vuota

  TransactionsNotifier() : super([]);

  // Consentiamo alla UI di aggiungere i todo
  void addTodo(Object todo) {
    // Poichè il nostro stato è immutabile, non siamo autorizzati a fare `state.add(todo)`.
    // Dovremmo invece creare una nuova lista di todo contenente
    // gli elementi precedenti e il nuovo

    // Usare lo spread operator di Dart qui è d'aiuto!

    state = [...state, todo];
    // Non c'è bisogno di chiamare "notifiyListeners" o qualcosa di simile.
    // Chiamare "state =" ricostruirà automaticamente la UI quando necessario.
  }

  // Consentiamo di rimuovere i todo
  void removeTodo(String todoId) {
    // Di nuovo, il nostro stato è immutabile. Quindi facciamo una nuova lista
    // invece di modificare la lista esistente.

    state = [
      for (final todo in state)
        if (todo.id != todoId) todo,
    ];
  }

  // Contrassegniamo il todo come completato
  void toggle(String todoId) {
    state = [
      for (final todo in state)
        // contrassegniamo solo il todo corrispondente come completato
        if (todo.id == todoId)
          // Usiamo il metodo `copyWith` implementato prima per aiutarci nel
          // modificare lo stato

          todo.copyWith(completed: !todo.completed)
        else
          // gli altri todo non sono modificati
          todo,
    ];
  }
}

final todosProvider = StateNotifierProvider<TransactionsNotifier, List>((ref) {
  return TransactionsNotifier();
});