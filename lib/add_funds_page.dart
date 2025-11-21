import 'package:flutter/material.dart';
import 'wallet_manager.dart';

class AddFundsPage extends StatefulWidget {
  const AddFundsPage({super.key});

  @override
  State<AddFundsPage> createState() => _AddFundsPageState();
}

class _AddFundsPageState extends State<AddFundsPage> {
  final _amountController = TextEditingController();
  bool _loading = false;
  String? _error;

  Future<void> _addFunds() async {
    final text = _amountController.text.trim();
    if (text.isEmpty) {
      setState(() => _error = "Please enter an amount");
      return;
    }

    final amount = int.tryParse(text);
    if (amount == null || amount <= 0) {
      setState(() => _error = "Enter a valid amount greater than 0");
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final tx = Transaction(
        type: "Add Funds",
        details: "Wallet Top-Up",
        amount: amount,
        status: "SUCCESS",       // ✅ added
        date: DateTime.now(),
      );

      WalletManager.addTransaction(tx);  // ✅ no await needed

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Successfully added $amount XAF to your wallet")),
      );

      _amountController.clear();
    } catch (e) {
      setState(() => _error = "Failed to add funds: $e");
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Funds")),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              "Enter Amount to Add",
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Amount (XAF)",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            if (_error != null)
              Text(_error!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 12),
            _loading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
              onPressed: _addFunds,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                "Add Funds",
                style: TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 20),
            ValueListenableBuilder<int>(
              valueListenable: WalletManager.balanceNotifier,
              builder: (context, balance, _) => Text(
                "Current Balance: $balance XAF",
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
