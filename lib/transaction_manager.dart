import 'package:flutter/foundation.dart';
import 'transaction_model.dart' as tx_model;

class TransactionManager {
  static final ValueNotifier<List<tx_model.Transaction>> transactions =
  ValueNotifier<List<tx_model.Transaction>>([]);

  // Add transaction at the beginning (newest first)
  static void addTransaction(tx_model.Transaction tx) {
    transactions.value = [tx, ...transactions.value];
  }

  // Remove a specific transaction by reference
  static void removeTransaction(tx_model.Transaction tx) {
    transactions.value =
        transactions.value.where((t) => t.reference != tx.reference).toList();
  }

  static List<tx_model.Transaction> get all => transactions.value;

  static void clearAll() {
    transactions.value = [];
  }
}
