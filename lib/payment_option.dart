import 'package:flutter/material.dart';
import 'wallet_manager.dart'; // import WalletManager

class PaymentOption extends StatelessWidget {
  final bool walletSelected;
  final ValueChanged<bool> onChanged;

  const PaymentOption({
    super.key,
    required this.walletSelected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Payment method",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        Row(
          children: [
            Radio<bool>(
              value: true,
              groupValue: walletSelected,
              onChanged: (val) {
                if (val != null) onChanged(val);
              },
            ),
            const Text("Wallet"),
            Radio<bool>(
              value: false,
              groupValue: walletSelected,
              onChanged: (val) {
                if (val != null) onChanged(val);
              },
            ),
            const Text("Other (MoMo, Card...)"),
          ],
        ),
        if (walletSelected)
          ValueListenableBuilder<int>(
            valueListenable: WalletManager.balanceNotifier,
            builder: (context, balance, _) {
              return Text(
                "Wallet balance: $balance XAF",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              );
            },
          ),
      ],
    );
  }
}
