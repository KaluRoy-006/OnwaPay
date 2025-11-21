import 'dart:math';
import 'package:flutter/material.dart';
import 'transaction_model.dart';
import 'transaction_manager.dart';
import 'receipt_page.dart';

class WaterPage extends StatefulWidget {
  final String language;
  const WaterPage({super.key, this.language = 'en'});

  @override
  State<WaterPage> createState() => _WaterPageState();
}

class _WaterPageState extends State<WaterPage> {
  final TextEditingController accountCtrl = TextEditingController();
  final TextEditingController amountCtrl = TextEditingController();
  String paymentMethod = "MTN MoMo";

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final bgColor = Theme.of(context).scaffoldBackgroundColor;
    final gradientColors = const [Color(0xFF1E90FF), Color(0xFFFFD700)];

    String t(String en, String fr) => widget.language == 'en' ? en : fr;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text(t("Pay Water (CAMWATER)", "Payer Eau (CAMWATER)")),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: gradientColors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 6,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildInputCard(
              icon: Icons.water_drop,
              label: t("Customer Number / Account ID", "Numéro client / ID compte"),
              child: TextField(
                controller: accountCtrl,
                style: TextStyle(color: isDarkMode ? Colors.white : Colors.black87),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: "e.g. 123456",
                  hintStyle: TextStyle(color: isDarkMode ? Colors.white54 : Colors.black38),
                ),
              ),
            ),
            const SizedBox(height: 20),
            _buildInputCard(
              icon: Icons.money,
              label: t("Amount (XAF)", "Montant (XAF)"),
              child: TextField(
                controller: amountCtrl,
                keyboardType: TextInputType.number,
                style: TextStyle(color: isDarkMode ? Colors.white : Colors.black87),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: "e.g. 5000",
                  hintStyle: TextStyle(color: isDarkMode ? Colors.white54 : Colors.black38),
                ),
              ),
            ),
            const SizedBox(height: 20),
            _buildPaymentMethodSelector(isDarkMode),
            const SizedBox(height: 30),
            _buildPayButton(gradientColors),
          ],
        ),
      ),
    );
  }

  Widget _buildInputCard({
    required IconData icon,
    required String label,
    required Widget child,
  }) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;
    final iconColor = Colors.blue[700]!;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 5,
      shadowColor: Colors.black45,
      color: cardColor,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 28),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: iconColor.withOpacity(0.85))),
                  const SizedBox(height: 6),
                  child,
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethodSelector(bool isDarkMode) {
    final options = ["MTN MoMo", "Orange Money", "Bank"];
    final textColor = isDarkMode ? Colors.white : Colors.black87;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Payment Method", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: textColor)),
        const SizedBox(height: 10),
        SizedBox(
          height: 70,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: options.length,
            itemBuilder: (context, index) {
              final val = options[index];
              final isSelected = val == paymentMethod;

              return GestureDetector(
                onTap: () => setState(() => paymentMethod = val),
                child: Container(
                  margin: const EdgeInsets.only(right: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    gradient: isSelected
                        ? const LinearGradient(
                      colors: [Color(0xFF1E90FF), Color(0xFFFFD700)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                        : null,
                    color: isSelected ? null : isDarkMode ? const Color(0xFF2A2A2A) : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: isSelected
                        ? [BoxShadow(color: Colors.amber.withOpacity(0.4), offset: const Offset(0,6), blurRadius: 12)]
                        : [BoxShadow(color: Colors.black12, offset: const Offset(0,3), blurRadius: 6)],
                    border: Border.all(color: isSelected ? Colors.amber : Colors.transparent, width: 2),
                  ),
                  child: Text(val, style: TextStyle(color: isSelected ? Colors.white : textColor, fontWeight: FontWeight.bold, fontSize: 14)),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPayButton(List<Color> gradientColors) {
    return Container(
      width: double.infinity,
      height: 55,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(color: Colors.amber.withOpacity(0.4), offset: const Offset(0, 6), blurRadius: 12)
        ],
      ),
      child: ElevatedButton(
        onPressed: _payBill,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: const Text(
          "Pay Now",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
    );
  }

  void _payBill() {
    final account = accountCtrl.text.trim();
    final amount = int.tryParse(amountCtrl.text.trim());

    if (account.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(widget.language == 'en' ? "Enter Customer Number / Account ID" : "Entrez le numéro client / ID compte")));
      return;
    }

    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(widget.language == 'en' ? "Enter a valid amount" : "Entrez un montant valide")));
      return;
    }

    final ref = "TXN-${DateTime.now().millisecondsSinceEpoch}-${Random().nextInt(9999)}";

    final tx = Transaction(
      type: "Water Payment",
      details: "Payment for account $account",
      amount: amount,
      date: DateTime.now(),
      reference: ref,
      status: "SUCCESS",
      destinationBank: "CAMWATER",
      narration: "Payment for account $account",
      sender: "OnwaPay User",
      account: account,
    );

    TransactionManager.addTransaction(tx);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => ReceiptPage(transaction: tx)),
    );
  }
}
