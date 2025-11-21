import 'dart:math';
import 'package:flutter/material.dart';
import 'transaction_model.dart';
import 'transaction_manager.dart';
import 'receipt_page.dart';

class InternetPage extends StatefulWidget {
  final String language;
  const InternetPage({super.key, this.language = 'en'});

  @override
  State<InternetPage> createState() => _InternetPageState();
}

class _InternetPageState extends State<InternetPage> {
  final TextEditingController accountCtrl = TextEditingController();
  String paymentMethod = "MTN MoMo";
  int? selectedAmount;

  final Map<String, List<Map<String, dynamic>>> homePlans = {
    "MTN Home NoLimit": [
      {"name": "NoLimit Explore - 4Mbps", "price": 14900},
      {"name": "NoLimit Confort - 8Mbps", "price": 19900},
      {"name": "NoLimit Premium - 20Mbps", "price": 29900},
    ],
    "Orange HomeBox": [
      {"name": "HomeBox Basic - 3Mbps", "price": 12000},
      {"name": "HomeBox Standard - 7Mbps", "price": 18000},
      {"name": "HomeBox Premium - 15Mbps", "price": 25000},
    ],
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final bgColor = theme.scaffoldBackgroundColor;
    final gradientColors = const [Color(0xFF1E90FF), Color(0xFFFFD700)];

    String t(String en, String fr) => widget.language == 'en' ? en : fr;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text(t("Pay Internet", "Payer Internet")),
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
            // Account input
            _buildInputCard(
              icon: Icons.person,
              label: t("Subscription ID / Phone Number", "ID d'abonnement / Numéro de téléphone"),
              child: TextField(
                controller: accountCtrl,
                style: TextStyle(color: isDarkMode ? Colors.white : Colors.black87),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: "e.g. 690123456",
                  hintStyle: TextStyle(color: isDarkMode ? Colors.white54 : Colors.black38),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Payment method
            _buildCardSelector(
              title: t("Payment Method", "Méthode de paiement"),
              options: ["MTN MoMo", "Orange Money", "Bank"],
              selectedOption: paymentMethod,
              onTap: (val) => setState(() => paymentMethod = val),
            ),
            const SizedBox(height: 20),

            // Plans section
            _buildPlansSection(isDarkMode),

            const SizedBox(height: 30),

            // Pay button
            Container(
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
                  BoxShadow(
                      color: Colors.amber.withOpacity(0.4),
                      offset: const Offset(0, 6),
                      blurRadius: 12)
                ],
              ),
              child: ElevatedButton(
                onPressed: _payBill,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(
                  t("Pay Now", "Payer maintenant"),
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Input Card ---
  Widget _buildInputCard({
    required IconData icon,
    required String label,
    required Widget child,
  }) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;
    final iconColor = Colors.orange[700]!;

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

  // --- Plan Cards ---
  Widget _buildPlansSection(bool isDarkMode) {
    final textColor = isDarkMode ? Colors.white : Colors.black87;
    final accentColor = Colors.orange[700]!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: homePlans.entries.map((entry) {
        final provider = entry.key;
        final plans = entry.value;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(provider, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
            const SizedBox(height: 10),
            SizedBox(
              height: 140,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: plans.length,
                itemBuilder: (context, index) {
                  final plan = plans[index];
                  final isSelected = selectedAmount == plan["price"];
                  final isPremium = plan["name"].toString().toLowerCase().contains("premium");

                  return GestureDetector(
                    onTap: () {
                      setState(() => selectedAmount = plan["price"]);
                    },
                    child: Container(
                      width: 180,
                      margin: const EdgeInsets.only(right: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: isSelected
                            ? const LinearGradient(
                          colors: [Color(0xFF1E90FF), Color(0xFFFFD700)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                            : null,
                        color: isSelected ? null : isDarkMode ? const Color(0xFF2A2A2A) : Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: isSelected
                            ? [BoxShadow(color: Colors.amber.withOpacity(0.4), offset: const Offset(0,6), blurRadius: 12)]
                            : [BoxShadow(color: Colors.black12, offset: const Offset(0,3), blurRadius: 6)],
                        border: Border.all(color: isSelected ? Colors.amber : Colors.transparent, width: 2),
                      ),
                      child: Stack(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(plan["name"],
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: isSelected ? Colors.white : textColor)),
                              const SizedBox(height: 8),
                              Text("${plan['price']} XAF",
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: isSelected ? Colors.white70 : textColor)),
                            ],
                          ),
                          if (isPremium)
                            Positioned(
                              top: 8,
                              right: 8,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.amber,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  "Premium",
                                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black87),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
          ],
        );
      }).toList(),
    );
  }

  // --- Card Selector ---
  Widget _buildCardSelector({
    required String title,
    required List<String> options,
    required String selectedOption,
    required Function(String) onTap,
  }) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? Colors.white : Colors.black87;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: textColor)),
        const SizedBox(height: 10),
        SizedBox(
          height: 80,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: options.length,
            itemBuilder: (context, index) {
              final val = options[index];
              final isSelected = val == selectedOption;

              return GestureDetector(
                onTap: () => onTap(val),
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

  void _payBill() {
    final account = accountCtrl.text.trim();
    final amount = selectedAmount;

    if (account.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(widget.language == 'en'
              ? "Enter Subscription ID / Phone Number"
              : "Entrez l'ID d'abonnement / Numéro")));
      return;
    }

    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(widget.language == 'en'
              ? "Select a plan to continue"
              : "Sélectionnez un forfait pour continuer")));
      return;
    }

    final ref = "TXN-${DateTime.now().millisecondsSinceEpoch}-${Random().nextInt(9999)}";

    final tx = Transaction(
      type: "Internet Payment",
      details: "Payment via $paymentMethod",
      amount: amount,
      date: DateTime.now(),
      reference: ref,
      status: "SUCCESS",
      destinationBank: paymentMethod,
      narration: "Payment for Internet, Account $account",
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
