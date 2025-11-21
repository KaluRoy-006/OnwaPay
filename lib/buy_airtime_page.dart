import 'dart:math';
import 'package:flutter/material.dart';
import 'transaction_model.dart' as tx_model;
import 'transaction_manager.dart';
import 'receipt_page.dart';

class BuyAirtimePage extends StatefulWidget {
  const BuyAirtimePage({super.key});

  @override
  State<BuyAirtimePage> createState() => _BuyAirtimePageState();
}

class _BuyAirtimePageState extends State<BuyAirtimePage> {
  final TextEditingController phoneCtrl = TextEditingController();
  final TextEditingController amountCtrl = TextEditingController();

  String operator = "";
  String paymentMethod = "Wallet";

  void _detectOperator(String number) {
    if (number.startsWith("67") || number.startsWith("65")) {
      setState(() => operator = "MTN");
    } else if (number.startsWith("69") || number.startsWith("68")) {
      setState(() => operator = "Orange");
    } else {
      setState(() => operator = "");
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final bgColor = Theme.of(context).scaffoldBackgroundColor;
    final gradientColors = const [Color(0xFF1E90FF), Color(0xFFFFD700)];
    final textColor = isDarkMode ? Colors.white : Colors.black87;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text("Buy Airtime"),
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
            // Operator display
            if (operator.isNotEmpty)
              Column(
                children: [
                  Icon(
                    operator == "MTN" ? Icons.signal_cellular_alt : Icons.wifi,
                    size: 60,
                    color: operator == "MTN" ? Colors.yellow[800] : Colors.orange,
                  ),
                  Text(
                    operator,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),

            // Phone number
            _buildInputCard(
              icon: Icons.phone,
              label: "Phone Number",
              child: TextField(
                controller: phoneCtrl,
                keyboardType: TextInputType.phone,
                onChanged: _detectOperator,
                style: TextStyle(color: textColor),
                decoration: InputDecoration(
                  hintText: "e.g. 677xxxxxx",
                  hintStyle: TextStyle(color: textColor.withOpacity(0.6)),
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Amount input + quick selects
            _buildInputCard(
              icon: Icons.money,
              label: "Amount (XAF)",
              child: TextField(
                controller: amountCtrl,
                keyboardType: TextInputType.number,
                style: TextStyle(color: textColor),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: "Enter amount",
                  hintStyle: TextStyle(color: textColor.withOpacity(0.6)),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              children: [500, 1000, 2000, 5000].map((amt) {
                final isSelected = amountCtrl.text == amt.toString();
                return ChoiceChip(
                  label: Text("$amt"),
                  selected: isSelected,
                  selectedColor: gradientColors[0].withOpacity(0.85),
                  backgroundColor: isDarkMode ? Colors.grey[800] : Colors.grey[200],
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : textColor,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                  onSelected: (_) {
                    setState(() => amountCtrl.text = amt.toString());
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // Payment method selector
            _buildPaymentMethodSelector(textColor, gradientColors, isDarkMode),
            const SizedBox(height: 30),

            // Buy button
            _buildBuyButton(gradientColors),
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
    final iconColor = Colors.blueAccent;

    return Card(
      color: cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      shadowColor: Colors.black45,
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
                          fontWeight: FontWeight.bold,
                          color: iconColor.withOpacity(0.85))),
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

  Widget _buildPaymentMethodSelector(Color textColor, List<Color> gradientColors, bool isDarkMode) {
    final methods = ["MTN MoMo", "Orange Money", "Wallet", "Bank"];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Payment Method", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: textColor)),
        const SizedBox(height: 10),
        SizedBox(
          height: 70,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: methods.length,
            itemBuilder: (context, index) {
              final method = methods[index];
              final isSelected = method == paymentMethod;

              return GestureDetector(
                onTap: () => setState(() => paymentMethod = method),
                child: Container(
                  margin: const EdgeInsets.only(right: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    gradient: isSelected
                        ? LinearGradient(colors: gradientColors)
                        : null,
                    color: isSelected ? null : isDarkMode ? Colors.grey[800] : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: isSelected
                        ? [BoxShadow(color: gradientColors[1].withOpacity(0.4), offset: const Offset(0,6), blurRadius: 12)]
                        : [BoxShadow(color: Colors.black12, offset: const Offset(0,3), blurRadius: 6)],
                    border: Border.all(color: isSelected ? gradientColors[1] : Colors.transparent, width: 2),
                  ),
                  child: Text(method,
                      style: TextStyle(
                        color: isSelected ? Colors.white : textColor,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        fontSize: 14,
                      )),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBuyButton(List<Color> gradientColors) {
    return Container(
      width: double.infinity,
      height: 55,
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: gradientColors),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: gradientColors[1].withOpacity(0.4), offset: const Offset(0,6), blurRadius: 12)],
      ),
      child: ElevatedButton(
        onPressed: _confirmPayment,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: const Text(
          "Buy Airtime",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
    );
  }

  void _confirmPayment() {
    final number = phoneCtrl.text.trim();
    final amount = int.tryParse(amountCtrl.text.trim());

    if (number.isEmpty || operator.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Enter valid number")));
      return;
    }

    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Enter valid amount")));
      return;
    }

    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
        title: Text("Confirm Purchase", style: TextStyle(color: theme.textTheme.bodyLarge!.color)),
        content: Text(
          "You are about to recharge $amount XAF on $operator $number using $paymentMethod.",
          style: TextStyle(color: theme.textTheme.bodyLarge!.color),
        ),
        actions: [
          TextButton(
            child: const Text("Cancel"),
            onPressed: () => Navigator.pop(ctx),
          ),
          ElevatedButton(
            child: const Text("Confirm"),
            onPressed: () {
              Navigator.pop(ctx);
              _buyAirtime(number, amount);
            },
          ),
        ],
      ),
    );
  }

  void _buyAirtime(String number, int amount) {
    final ref = "AIR-${DateTime.now().millisecondsSinceEpoch}-${Random().nextInt(9999)}";

    final tx = tx_model.Transaction(
      type: "Airtime",
      details: "$operator Airtime Recharge",
      amount: amount,
      date: DateTime.now(),
      reference: ref,
      status: "SUCCESS",
      destinationBank: operator,
      narration: "Recharge of $number",
      sender: "OnwaPay User",
      account: number,
    );

    TransactionManager.addTransaction(tx);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => ReceiptPage(transaction: tx)),
    );
  }
}
