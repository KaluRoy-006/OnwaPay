import 'transaction_model.dart' as tx_model;

class TransactionService {
  // Private list of transactions (in memory only)
  final List<tx_model.Transaction> _transactions = [];

  // Add a new transaction
  void addTransaction(tx_model.Transaction tx) {
    _transactions.add(tx);
  }

  // Get all transactions
  List<tx_model.Transaction> getTransactions() {
    return _transactions;
  }

  // Clear all transactions (optional helper)
  void clearTransactions() {
    _transactions.clear();
  }
}
