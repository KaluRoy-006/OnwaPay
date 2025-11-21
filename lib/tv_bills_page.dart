import 'dart:math';
import 'package:flutter/material.dart';
import 'transaction_model.dart';
import 'transaction_manager.dart';
import 'receipt_page.dart';

class TvBillsPage extends StatefulWidget {
  final String language;
  const TvBillsPage({super.key, this.language = 'en'});

  @override
  State<TvBillsPage> createState() => _TvBillsPageState();
}

class _TvBillsPageState extends State<TvBillsPage> {
  final TextEditingController smartcardCtrl = TextEditingController();
  final TextEditingController amountCtrl = TextEditingController();
  String selectedProvider = "DStv";
  String selectedPackage = "Premium";
  String paymentMethod = "MTN MoMo";

  final Map<String, Map<String, int>> providerPackages = {
    "DStv": {
      "Premium": 55000,
      "Compact Plus": 33000,
      "Compact": 21000,
      "Family": 10500,
      "Access": 5000,
    },
    "GOtv": {
      "Max": 20000,
      "Jolli": 12000,
      "Smallie": 7000,
      "Lite": 4000,
    },
    "Canal+": {
      "Essentiel": 22000,
      "Standard": 35000,
      "Optimum": 50000,
    }
  };

  final List<String> providers = ["DStv", "GOtv", "Canal+"];

  @override
  void initState() {
    super.initState();
    _updateAmount();
  }

  void _updateAmount() {
    final packages = providerPackages[selectedProvider]!;
    if (!packages.containsKey(selectedPackage)) {
      selectedPackage = packages.keys.first;
    }
    amountCtrl.text = packages[selectedPackage]!.toString();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final bgColor = theme.scaffoldBackgroundColor;
    final textColor = isDarkMode ? Colors.white : Colors.black87;
    final gradientColors = const [Color(0xFF1E90FF), Color(0xFFFFD700)];

    String t(String en, String fr) => widget.language == 'en' ? en : fr;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text(t("Pay TV Bills", "Payer les factures TV")),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: gradientColors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 5,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // --- Provider Selection ---
            _buildCardSelector(
              title: t("Select Provider", "Sélectionnez le fournisseur"),
              options: providers,
              selectedOption: selectedProvider,
              onTap: (val) {
                setState(() {
                  selectedProvider = val;
                  _updateAmount();
                });
              },
            ),
            const SizedBox(height: 16),

            // --- Package Selection ---
            _buildPackageSelection(),
            const SizedBox(height: 16),

            // --- Smartcard / IUC ---
            _buildInputCard(
              icon: Icons.confirmation_number,
              label: t("Smartcard / IUC Number", "Numéro Smartcard / IUC"),
              child: TextField(
                controller: smartcardCtrl,
                style: TextStyle(color: textColor),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: "e.g. 1234567890",
                  hintStyle: TextStyle(
                      color: isDarkMode ? Colors.white54 : Colors.black38),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // --- Amount ---
            _buildInputCard(
              icon: Icons.money,
              label: t("Amount (XAF)", "Montant (XAF)"),
              child: TextField(
                controller: amountCtrl,
                keyboardType: TextInputType.number,
                style: TextStyle(color: textColor),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintStyle: TextStyle(
                      color: isDarkMode ? Colors.white54 : Colors.black38),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // --- Payment Method ---
            _buildCardSelector(
              title: t("Payment Method", "Méthode de paiement"),
              options: ["MTN MoMo", "Orange Money", "Bank"],
              selectedOption: paymentMethod,
              onTap: (val) => setState(() => paymentMethod = val),
            ),

            const SizedBox(height: 30),

            // --- Pay Button ---
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
    final iconColor = Colors.amber[700]!;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 6,
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
                          fontWeight: FontWeight.bold,
                          color: iconColor.withOpacity(0.9),
                          fontSize: 15)),
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

  // --- Package Selection ---
  Widget _buildPackageSelection() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? Colors.white : Colors.black87;
    final packages = providerPackages[selectedProvider]!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.language == 'en' ? "Choose Package" : "Choisir le forfait",
          style: TextStyle(
              fontWeight: FontWeight.bold, fontSize: 16, color: textColor),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 130,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: packages.keys.length,
            itemBuilder: (context, index) {
              String pkg = packages.keys.elementAt(index);
              int amt = packages[pkg]!;
              bool isSelected = pkg == selectedPackage;
              bool isPremium = pkg.toLowerCase().contains("premium") ||
                  pkg.toLowerCase().contains("optimum") ||
                  pkg.toLowerCase().contains("max");

              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedPackage = pkg;
                    amountCtrl.text = amt.toString();
                  });
                },
                child: Container(
                  width: 140,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    gradient: isSelected
                        ? const LinearGradient(
                      colors: [Color(0xFF1E90FF), Color(0xFFFFD700)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                        : null,
                    color: isSelected
                        ? null
                        : isDarkMode
                        ? const Color(0xFF2A2A2A)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: isSelected
                        ? [
                      BoxShadow(
                          color: Colors.amber.withOpacity(0.4),
                          offset: const Offset(0, 6),
                          blurRadius: 12)
                    ]
                        : [
                      BoxShadow(
                          color: Colors.black12,
                          offset: const Offset(0, 3),
                          blurRadius: 6)
                    ],
                    border: Border.all(
                        color: isSelected ? Colors.amber : Colors.transparent,
                        width: 2),
                  ),
                  child: Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(pkg,
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color:
                                    isSelected ? Colors.white : textColor)),
                            const SizedBox(height: 8),
                            Text("$amt XAF",
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: isSelected
                                        ? Colors.white70
                                        : textColor)),
                          ],
                        ),
                      ),
                      if (isPremium)
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.amber,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              "Premium",
                              style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87),
                            ),
                          ),
                        )
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // --- Generic Card Selector (for providers & payment methods) ---
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
        Text(title,
            style: TextStyle(
                fontWeight: FontWeight.bold, fontSize: 16, color: textColor)),
        const SizedBox(height: 10),
        SizedBox(
          height: 80,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: options.length,
            itemBuilder: (context, index) {
              String val = options[index];
              bool isSelected = val == selectedOption;
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
                    color: isSelected
                        ? null
                        : isDarkMode
                        ? const Color(0xFF2A2A2A)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: isSelected
                        ? [
                      BoxShadow(
                          color: Colors.amber.withOpacity(0.4),
                          offset: const Offset(0, 6),
                          blurRadius: 12)
                    ]
                        : [
                      BoxShadow(
                          color: Colors.black12,
                          offset: const Offset(0, 3),
                          blurRadius: 6)
                    ],
                    border: Border.all(
                        color: isSelected ? Colors.amber : Colors.transparent,
                        width: 2),
                  ),
                  child: Text(
                    val,
                    style: TextStyle(
                        color: isSelected ? Colors.white : textColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 14),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _payBill() {
    final smartcard = smartcardCtrl.text.trim();
    final amount = int.tryParse(amountCtrl.text.trim());

    if (smartcard.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(widget.language == 'en'
              ? "Enter Smartcard / IUC Number"
              : "Entrez le numéro Smartcard / IUC")));
      return;
    }

    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(widget.language == 'en'
              ? "Enter a valid amount"
              : "Entrez un montant valide")));
      return;
    }

    final ref = "TXN-${DateTime.now().millisecondsSinceEpoch}-${Random().nextInt(9999)}";

    final tx = Transaction(
      type: "Pay Bill",
      details: "$selectedProvider - $selectedPackage",
      amount: amount,
      date: DateTime.now(),
      reference: ref,
      status: "SUCCESS",
      destinationBank: selectedProvider,
      narration: "Payment for $selectedPackage package, Smartcard $smartcard",
      sender: "OnwaPay User",
      account: smartcard,
    );

    TransactionManager.addTransaction(tx);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => ReceiptPage(transaction: tx)),
    );
  }
}
