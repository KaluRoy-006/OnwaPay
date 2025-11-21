import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'receipt_page.dart';
import 'transaction_model.dart';
import 'transaction_manager.dart';

class TransactionsPage extends StatefulWidget {
  const TransactionsPage({super.key});

  @override
  State<TransactionsPage> createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage> {
  String _selectedFilter = "ALL";
  String _searchQuery = "";
  final Map<String, bool> _groupExpanded = {
    "Today": true,
    "Yesterday": false,
    "Last 7 Days": false,
    "Older": false,
  };

  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _refreshTransactions() async {
    // For demo, we just call setState. Replace with real refresh logic if needed.
    setState(() {});
    await Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = theme.textTheme.bodyLarge?.color ?? Colors.black;
    final subtitleColor = theme.brightness == Brightness.dark ? Colors.white70 : Colors.black54;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Transactions"),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF4A90E2), Color(0xFFFFD700)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // ---------------- Search Bar ----------------
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText: "Search transactions...",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: theme.cardColor.withOpacity(0.1),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (val) => setState(() => _searchQuery = val.trim()),
            ),
          ),

          // ---------------- Filter Chips ----------------
          Padding(
            padding: const EdgeInsets.all(8),
            child: ValueListenableBuilder<List<Transaction>>(
              valueListenable: TransactionManager.transactions,
              builder: (context, allTransactions, _) {
                final allCount = allTransactions.length;
                final successCount = allTransactions.where((tx) => tx.status == "SUCCESS").length;
                final pendingCount = allTransactions.where((tx) => tx.status == "PENDING").length;
                final failedCount = allTransactions.where((tx) => tx.status == "FAILED").length;

                return Wrap(
                  spacing: 8,
                  children: [
                    _buildFilterChip("ALL", allCount, textColor),
                    _buildFilterChip("SUCCESS", successCount, textColor),
                    _buildFilterChip("PENDING", pendingCount, textColor),
                    _buildFilterChip("FAILED", failedCount, textColor),
                  ],
                );
              },
            ),
          ),

          // ---------------- Transaction List ----------------
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refreshTransactions,
              child: ValueListenableBuilder<List<Transaction>>(
                valueListenable: TransactionManager.transactions,
                builder: (context, allTransactions, _) {
                  var filteredTransactions = _selectedFilter == "ALL"
                      ? allTransactions
                      : allTransactions.where((tx) => tx.status == _selectedFilter).toList();

                  // Apply search
                  if (_searchQuery.isNotEmpty) {
                    filteredTransactions = filteredTransactions.where((tx) {
                      return tx.details.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                          tx.reference.toLowerCase().contains(_searchQuery.toLowerCase());
                    }).toList();
                  }

                  if (filteredTransactions.isEmpty) {
                    return Center(
                      child: Text(
                        "No transactions found.",
                        style: TextStyle(color: subtitleColor, fontSize: 16),
                      ),
                    );
                  }

                  final grouped = _groupTransactions(filteredTransactions);

                  return ListView(
                    padding: const EdgeInsets.all(12),
                    children: grouped.keys.map((group) {
                      final transactions = grouped[group]!;

                      return ExpansionTile(
                        key: PageStorageKey(group),
                        initiallyExpanded: _groupExpanded[group] ?? false,
                        title: Text(
                          "$group (${transactions.length})",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                        children: transactions
                            .map((tx) => _buildTransactionTile(tx, theme))
                            .toList(),
                        onExpansionChanged: (expanded) {
                          setState(() {
                            _groupExpanded[group] = expanded;
                          });
                        },
                      );
                    }).toList(),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Map<String, List<Transaction>> _groupTransactions(List<Transaction> txs) {
    final now = DateTime.now();
    Map<String, List<Transaction>> grouped = {
      "Today": [],
      "Yesterday": [],
      "Last 7 Days": [],
      "Older": [],
    };

    for (var tx in txs) {
      final diff = now.difference(tx.date).inDays;
      if (diff == 0) {
        grouped["Today"]!.add(tx);
      } else if (diff == 1) {
        grouped["Yesterday"]!.add(tx);
      } else if (diff <= 7) {
        grouped["Last 7 Days"]!.add(tx);
      } else {
        grouped["Older"]!.add(tx);
      }
    }

    grouped.removeWhere((key, value) => value.isEmpty);
    return grouped;
  }

  Widget _buildTransactionTile(Transaction tx, ThemeData theme) {
    final textColor = theme.textTheme.bodyLarge?.color ?? Colors.black;
    final subtitleColor = theme.brightness == Brightness.dark ? Colors.white70 : Colors.black54;

    final bool isCredit = tx.type == "Receive" || tx.type == "AddFunds";
    final amountText = "${isCredit ? '+' : '-'}${tx.amount.abs()} XAF";
    final amountColor = isCredit ? Colors.blue[700]! : Colors.orange[700]!;

    final statusColor = tx.status == "SUCCESS"
        ? Colors.yellow[700]!
        : tx.status == "FAILED"
        ? Colors.redAccent
        : Colors.blueAccent;
    final statusIcon = tx.status == "SUCCESS"
        ? Icons.check
        : tx.status == "FAILED"
        ? Icons.close
        : Icons.hourglass_empty;

    return Dismissible(
      key: Key(tx.reference),
      background: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        alignment: Alignment.centerLeft,
        color: Colors.redAccent,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      secondaryBackground: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        alignment: Alignment.centerRight,
        color: Colors.orangeAccent,
        child: const Icon(Icons.archive, color: Colors.white),
      ),
      onDismissed: (direction) {
        TransactionManager.removeTransaction(tx);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(direction == DismissDirection.startToEnd
                ? "Transaction deleted"
                : "Transaction archived"),
          ),
        );
      },
      child: Card(
        elevation: 6,
        shadowColor: Colors.blueGrey.withOpacity(0.2),
        margin: const EdgeInsets.symmetric(vertical: 6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: ListTile(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => ReceiptPage(transaction: tx)),
            );
          },
          leading: CircleAvatar(
            radius: 25,
            backgroundColor: amountColor.withOpacity(0.15),
            child: Icon(
              tx.type == "Send"
                  ? Icons.send
                  : tx.type == "Receive"
                  ? Icons.call_received
                  : tx.type == "AddFunds"
                  ? Icons.add
                  : Icons.payment,
              color: amountColor,
            ),
          ),
          title: Text(
            tx.details,
            style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
          ),
          subtitle: Text(
            DateFormat('dd MMM yyyy, hh:mm a').format(tx.date),
            style: TextStyle(fontSize: 12, color: subtitleColor),
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                amountText,
                style: TextStyle(
                  color: amountColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blueAccent.withOpacity(0.3), Colors.yellow.withOpacity(0.3)],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(statusIcon, size: 14, color: statusColor),
                    const SizedBox(width: 4),
                    Text(
                      tx.status,
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, int count, Color textColor) {
    final isSelected = _selectedFilter == label;
    return ChoiceChip(
      label: Text("$label ($count)"),
      selected: isSelected,
      selectedColor: Colors.blueAccent.withOpacity(0.8),
      backgroundColor: Colors.yellow[100]?.withOpacity(0.2),
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : textColor,
        fontWeight: FontWeight.bold,
      ),
      onSelected: (_) {
        setState(() => _selectedFilter = label);
      },
    );
  }
}
