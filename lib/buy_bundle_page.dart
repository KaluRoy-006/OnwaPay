import 'dart:math';
import 'package:flutter/material.dart';
import 'package:OnwaPay/wallet_manager.dart';
import 'package:OnwaPay/transaction_manager.dart';
import 'package:OnwaPay/transaction_model.dart' as tx_model;
import 'package:OnwaPay/receipt_page.dart';

class BuyBundlePage extends StatefulWidget {
  const BuyBundlePage({super.key});

  @override
  State<BuyBundlePage> createState() => _BuyBundlePageState();
}

class _BuyBundlePageState extends State<BuyBundlePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String selectedPeriod = "All";
  String selectedCategory = "All";

  final List<Map<String, dynamic>> bundles = [
    {"provider": "MTN", "name": "Daily 100MB", "desc": "100MB valid 24h", "price": 100, "type": "Day", "category": "Data"},
    {"provider": "MTN", "name": "Daily 2GB", "desc": "2GB valid 24h", "price": 1000, "type": "Day", "category": "Data"},
    {"provider": "MTN", "name": "Night 2GB", "desc": "2GB valid 00h-06h", "price": 200, "type": "Night", "category": "Data"},
    {"provider": "MTN", "name": "Weekly 3GB", "desc": "3GB valid 7 days", "price": 3000, "type": "Week", "category": "Data"},
    {"provider": "MTN", "name": "Monthly 50GB", "desc": "50GB valid 30 days", "price": 25500, "type": "Month", "category": "Data"},
    {"provider": "MTN", "name": "Daily Y’ello Talk", "desc": "Unlimited MTN-to-MTN calls 24h", "price": 150, "type": "Day", "category": "Voice"},
    {"provider": "MTN", "name": "Weekly Combo", "desc": "500MB + 50 mins calls", "price": 1500, "type": "Week", "category": "Voice"},
    {"provider": "MTN", "name": "Monthly Combo", "desc": "3GB + 200 mins calls + 200 SMS", "price": 5000, "type": "Month", "category": "Voice"},
    {"provider": "Orange", "name": "Daily 250MB", "desc": "250MB valid 24h", "price": 250, "type": "Day", "category": "Data"},
    {"provider": "Orange", "name": "Daily 600MB", "desc": "600MB valid 24h", "price": 500, "type": "Day", "category": "Data"},
    {"provider": "Orange", "name": "Monthly 10GB", "desc": "10GB valid 30 days", "price": 15000, "type": "Month", "category": "Data"},
    {"provider": "Orange", "name": "Infinity Unlimited", "desc": "Unlimited Internet (30 days)", "price": 14900, "type": "Month", "category": "Data"},
    {"provider": "Orange", "name": "Daily Voice Pack", "desc": "60 mins calls valid 24h", "price": 250, "type": "Day", "category": "Voice"},
    {"provider": "Orange", "name": "Weekly All-in-One", "desc": "1.5GB + 100 mins + 100 SMS", "price": 2500, "type": "Week", "category": "Voice"},
    {"provider": "Orange", "name": "Monthly Max Pack", "desc": "6GB + 300 mins + 300 SMS", "price": 10000, "type": "Month", "category": "Voice"},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> getFilteredBundles(String provider) {
    return bundles.where((bundle) {
      final matchesProvider = provider == "All" ? true : bundle["provider"] == provider;
      final matchesPeriod = selectedPeriod == "All" ? true : bundle["type"] == selectedPeriod;
      final matchesCategory = selectedCategory == "All" ? true : bundle["category"] == selectedCategory;
      return matchesProvider && matchesPeriod && matchesCategory;
    }).toList();
  }

  void _showPaymentOptions(Map<String, dynamic> bundle) {
    final theme = Theme.of(context);
    showModalBottomSheet(
      backgroundColor: theme.scaffoldBackgroundColor,
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (context) {
        String selectedMethod = "Wallet";
        bool isProcessing = false;

        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Choose Payment Method",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: theme.textTheme.bodyLarge?.color,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Column(
                    children: ["MTN MoMo", "Orange Money", "Wallet", "Bank"].map((method) {
                      return RadioListTile<String>(
                        title: Text(method, style: TextStyle(color: theme.textTheme.bodyLarge?.color)),
                        value: method,
                        groupValue: selectedMethod,
                        onChanged: (val) => setSheetState(() => selectedMethod = val!),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: isProcessing
                          ? null
                          : () async {
                        setSheetState(() => isProcessing = true);
                        Navigator.pop(context);
                        await _buyBundle(bundle, selectedMethod);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF42A5F5),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 6,
                        shadowColor: const Color(0xFF42A5F5).withOpacity(0.5),
                      ),
                      child: isProcessing
                          ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                          : const Text("Confirm Payment", style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _buyBundle(Map<String, dynamic> bundle, String method) async {
    bool success = true;

    if (method == "Wallet") {
      success = await WalletManager.withdraw(bundle["price"], note: "Bundle Purchase");
    }

    final ref = "BND-${DateTime.now().millisecondsSinceEpoch}-${Random().nextInt(9999)}";

    final tx = tx_model.Transaction(
      type: "Bundle Purchase",
      details: bundle["name"],
      amount: bundle["price"],
      date: DateTime.now(),
      reference: ref,
      status: success ? "SUCCESS" : "FAILED",
      destinationBank: bundle["provider"],
      narration: "Bundle purchase via $method",
      sender: "KoloPay User",
      account: method,
    );

    TransactionManager.addTransaction(tx);

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ReceiptPage(transaction: tx)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = theme.textTheme.bodyLarge?.color ?? Colors.black;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Buy Bundle"),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [const Color(0xFF42A5F5), const Color(0xFFFFD700)]),
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicator: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            color: const Color(0xFFFFD700).withOpacity(0.7),
          ),
          tabs: const [
            Tab(text: "All"),
            Tab(text: "MTN"),
            Tab(text: "Orange"),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Wrap(
              spacing: 8,
              children: ["All", "Day", "Night", "Week", "Month"].map((f) {
                return ChoiceChip(
                  label: Text(f, style: TextStyle(color: textColor)),
                  selected: selectedPeriod == f,
                  selectedColor: const Color(0xFFFFD700).withOpacity(0.5),
                  onSelected: (val) => setState(() => selectedPeriod = f),
                  backgroundColor: theme.cardColor,
                );
              }).toList(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Wrap(
              spacing: 8,
              children: ["All", "Data", "Voice"].map((c) {
                return ChoiceChip(
                  label: Text(c, style: TextStyle(color: textColor)),
                  selected: selectedCategory == c,
                  selectedColor: const Color(0xFFFFD700).withOpacity(0.5),
                  onSelected: (val) => setState(() => selectedCategory = c),
                  backgroundColor: theme.cardColor,
                );
              }).toList(),
            ),
          ),
          Expanded(child: _buildBundleList()),
        ],
      ),
    );
  }

  Widget _buildBundleList() {
    return TabBarView(
      controller: _tabController,
      children: ["All", "MTN", "Orange"].map((provider) {
        final filtered = getFilteredBundles(provider);
        final theme = Theme.of(context);

        if (filtered.isEmpty) {
          return Center(
            child: Text("No bundles available", style: TextStyle(color: theme.textTheme.bodyLarge?.color)),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: filtered.length,
          itemBuilder: (context, index) {
            final bundle = filtered[index];
            return GestureDetector(
              onTap: () => _showPaymentOptions(bundle),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [theme.cardColor, theme.cardColor.withOpacity(0.9)]),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(color: Colors.black26, blurRadius: 6, offset: const Offset(2, 2)),
                    BoxShadow(color: Colors.white.withOpacity(0.1), blurRadius: 6, offset: const Offset(-2, -2)),
                  ],
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    radius: 25,
                    backgroundColor: Colors.white,
                    child: Image.asset(
                      bundle["provider"] == "MTN" ? "assets/images/MTN_logo.jpg" : "assets/images/Orange_logo.jpg",
                      height: 28,
                    ),
                  ),
                  title: Text(bundle["name"], style: TextStyle(fontWeight: FontWeight.bold, color: theme.textTheme.bodyLarge?.color)),
                  subtitle: Text(bundle["desc"], style: TextStyle(color: theme.textTheme.bodyMedium?.color)),
                  trailing: Text("${bundle["price"]} XAF", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                ),
              ),
            );
          },
        );
      }).toList(),
    );
  }
}
