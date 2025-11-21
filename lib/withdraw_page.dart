import 'package:flutter/material.dart';
import 'wallet_manager.dart';

class WithdrawPage extends StatefulWidget {
  const WithdrawPage({super.key});

  @override
  State<WithdrawPage> createState() => _WithdrawPageState();
}

class _WithdrawPageState extends State<WithdrawPage> {
  final TextEditingController _amountController = TextEditingController();
  String? _selectedDestination;
  bool _isProcessing = false;

  final List<String> _destinations = [
    "Orange Money",
    "MTN MoMo",
    "Bank Account",
  ];

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _performWithdrawal() async {
    final int amount = int.tryParse(_amountController.text.trim()) ?? 0;

    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Enter a valid amount")),
      );
      return;
    }

    if (_selectedDestination == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Select a destination")),
      );
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    // Await the async withdraw method
    final bool success = await WalletManager.withdraw(
      amount,
      note: "Withdraw to $_selectedDestination",
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? "Withdrew $amount XAF to $_selectedDestination"
              : "Insufficient wallet balance",
        ),
      ),
    );

    if (success) {
      _amountController.clear();
      setState(() {
        _selectedDestination = null;
      });
    }

    setState(() {
      _isProcessing = false;
    });
  }

  bool get _isButtonDisabled =>
      _isProcessing ||
          _amountController.text.trim().isEmpty ||
          _selectedDestination == null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Withdraw Funds")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Wallet balance
            ValueListenableBuilder<int>(
              valueListenable: WalletManager.balanceNotifier,
              builder: (context, balance, _) {
                return Text(
                  "Wallet Balance: $balance XAF",
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                );
              },
            ),
            const SizedBox(height: 20),

            // Amount input
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Enter amount to withdraw",
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => setState(() {}), // update button state
            ),
            const SizedBox(height: 20),

            // Destination dropdown
            DropdownButtonFormField<String>(
              value: _selectedDestination,
              items: _destinations
                  .map((dest) => DropdownMenuItem(
                value: dest,
                child: Text(dest),
              ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedDestination = value;
                });
              },
              decoration: const InputDecoration(
                labelText: "Select Destination",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 30),

            // Withdraw button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isButtonDisabled ? null : _performWithdrawal,
                child: _isProcessing
                    ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
                    : const Text("Withdraw"),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  backgroundColor: Colors.green[700],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
