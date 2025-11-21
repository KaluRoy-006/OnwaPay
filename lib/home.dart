import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'wallet_manager.dart';
import 'add_funds_page.dart';
import 'send_funds_premium_page.dart';
import 'settings_page.dart';
import 'support_page.dart';
import 'buy_bundle_page.dart';
import 'buy_airtime_page.dart';
import 'pay_school_fees_page.dart';
import 'pay_bills_page.dart';
import 'transactions_page.dart';
import 'withdraw_page.dart';
import 'Auth/login_page.dart';
import 'main.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isBalanceVisible = true;
  String _language = 'en';

  @override
  void initState() {
    super.initState();
    WalletManager.transactionsNotifier.addListener(_updateTransactions);
  }

  @override
  void dispose() {
    WalletManager.transactionsNotifier.removeListener(_updateTransactions);
    super.dispose();
  }

  void _updateTransactions() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final themeController = Provider.of<ThemeController>(context);
    final isDarkMode = themeController.isDarkMode;

    final primaryColor = const Color(0xFF002366);

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : Colors.grey[100],
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: primaryColor,
        title: const Text(
          "OnwaPay",
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      drawer: _buildDrawer(themeController, isDarkMode, primaryColor),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBalanceCard(),
            const SizedBox(height: 20),
            _buildFeatureGrid(),
            const SizedBox(height: 20),
            _buildRecentTransactions(isDarkMode),
          ],
        ),
      ),
    );
  }

  // ------------------ DRAWER ------------------
  Widget _buildDrawer(ThemeController themeController, bool isDarkMode, Color drawerColor) {
    final user = FirebaseAuth.instance.currentUser;
    return Drawer(
      child: Container(
        color: drawerColor,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(
                user?.displayName ?? "Guest User",
                style: const TextStyle(color: Colors.white),
              ),
              accountEmail: Text(
                user?.email ?? "Not logged in",
                style: const TextStyle(color: Colors.white70),
              ),
              currentAccountPicture: GestureDetector(
                onTap: () async {
                  if (user != null) await FirebaseAuth.instance.signOut();
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginPage()),
                        (route) => false,
                  );
                },
                child: const CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, size: 40, color: Colors.green),
                ),
              ),
              decoration: BoxDecoration(color: drawerColor),
            ),
            ListTile(
              leading: Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode, color: Colors.white),
              title: Text(isDarkMode ? "Light Mode" : "Dark Mode", style: const TextStyle(color: Colors.white)),
              onTap: () => themeController.toggleTheme(),
            ),
            ListTile(
              leading: const Icon(Icons.language, color: Colors.white),
              title: Text(_language == 'en' ? "Change Language" : "Changer la langue", style: const TextStyle(color: Colors.white)),
              onTap: () => setState(() => _language = _language == 'en' ? 'fr' : 'en'),
            ),
            const Divider(color: Colors.white12),
            ListTile(
              leading: const Icon(Icons.settings, color: Colors.white),
              title: const Text("Settings", style: TextStyle(color: Colors.white)),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsPage())),
            ),
            ListTile(
              leading: const Icon(Icons.support_agent, color: Colors.white),
              title: const Text("Support", style: TextStyle(color: Colors.white)),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SupportPage())),
            ),
            ListTile(
              leading: const Icon(Icons.info, color: Colors.white),
              title: const Text("About", style: TextStyle(color: Colors.white)),
              onTap: () => showAboutDialog(
                context: context,
                applicationName: "OnwaPay",
                applicationVersion: "1.0.0",
                applicationLegalese: "© 2025 OnwaPay Inc.",
              ),
            ),
            const Divider(color: Colors.white12),
            ListTile(
              leading: const Icon(Icons.exit_to_app, color: Colors.red),
              title: const Text("Logout", style: TextStyle(color: Colors.red)),
              onTap: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const LoginPage()), (route) => false);
              },
            ),
          ],
        ),
      ),
    );
  }

  // ------------------ BALANCE CARD ------------------
  Widget _buildBalanceCard() {
    final accountNumber = WalletManager.accountNumber;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF002366), Color(0xFFFFD700)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black45, blurRadius: 12, offset: Offset(0, 6)),
          BoxShadow(color: Colors.white24, blurRadius: 6, offset: Offset(-4, -4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Balance Label + Visibility Toggle
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(_language == 'en' ? "Available balance" : "Solde disponible",
                  style: const TextStyle(color: Colors.white70)),
              IconButton(
                icon: Icon(_isBalanceVisible ? Icons.visibility : Icons.visibility_off, color: Colors.white70),
                onPressed: () => setState(() => _isBalanceVisible = !_isBalanceVisible),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ValueListenableBuilder<int>(
            valueListenable: WalletManager.balanceNotifier,
            builder: (context, balance, _) => Text(
              _isBalanceVisible ? "$balance XAF" : "••••••",
              style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "Account Number: $accountNumber",
            style: const TextStyle(color: Colors.white70, fontSize: 16),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddFundsPage())),
              icon: const Icon(Icons.add),
              label: Text(_language == 'en' ? "Add funds" : "Ajouter des fonds"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.greenAccent[700],
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 8,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ------------------ FEATURE GRID ------------------
  Widget _buildFeatureGrid() {
    final features = [
      _FeatureButtonData(Icons.phone_android, _language == 'en' ? "Buy airtime" : "Acheter du crédit", Colors.blueAccent, const BuyAirtimePage()),
      _FeatureButtonData(Icons.send, _language == 'en' ? "Send funds" : "Envoyer de l'argent", Colors.greenAccent, const SendFundsPagePremium()),
      _FeatureButtonData(Icons.card_giftcard, _language == 'en' ? "Buy a bundle" : "Acheter un forfait", Colors.purpleAccent, const BuyBundlePage()),
      _FeatureButtonData(Icons.school, _language == 'en' ? "Pay School Fees" : "Payer les frais scolaires", Colors.orangeAccent, const PaySchoolFeesPage()),
      _FeatureButtonData(Icons.payment, _language == 'en' ? "Pay Bills" : "Payer les factures", Colors.redAccent, const PayBillsPage()),
      _FeatureButtonData(Icons.history, "Transactions", Colors.indigoAccent, const TransactionsPage()),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 1),
      itemCount: features.length,
      itemBuilder: (context, index) => _FeatureButton3D(features[index]),
    );
  }

  // ------------------ RECENT TRANSACTIONS ------------------
  Widget _buildRecentTransactions(bool isDarkMode) {
    final txList = WalletManager.transactionsNotifier.value.reversed.toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(_language == 'en' ? "Recent Transactions" : "Transactions récentes",
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        if (txList.isEmpty)
          Center(child: Text(_language == 'en' ? "No recent transactions" : "Aucune transaction récente"))
        else
          SizedBox(
            height: 160,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: txList.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) => _TransactionCard3D(tx: txList[index], isDarkMode: isDarkMode),
            ),
          ),
        const SizedBox(height: 20),
        Center(
          child: _SlimFeatureButton3D(
            icon: Icons.account_balance_wallet,
            label: _language == 'en' ? "Withdraw" : "Retirer",
            color: Colors.redAccent,
            page: const WithdrawPage(),
          ),
        ),
      ],
    );
  }
}

// ------------------ FEATURE BUTTONS ------------------
class _FeatureButtonData {
  final IconData icon;
  final String label;
  final Color color;
  final Widget page;
  const _FeatureButtonData(this.icon, this.label, this.color, this.page);
}

class _FeatureButton3D extends StatefulWidget {
  final _FeatureButtonData data;
  const _FeatureButton3D(this.data);

  @override
  State<_FeatureButton3D> createState() => _FeatureButton3DState();
}

class _FeatureButton3DState extends State<_FeatureButton3D> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final color = widget.data.color;
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        Navigator.push(context, MaterialPageRoute(builder: (_) => widget.data.page));
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        transform: Matrix4.identity()..scale(_isPressed ? 0.97 : 1.0),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: _isPressed ? [color.withOpacity(0.7), color.withOpacity(0.5)] : [color.withOpacity(0.85), color.withOpacity(0.65)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: _isPressed
              ? [BoxShadow(color: Colors.black26, offset: const Offset(2, 2), blurRadius: 4)]
              : [
            BoxShadow(color: Colors.black45, offset: const Offset(6, 6), blurRadius: 10),
            BoxShadow(color: Colors.white.withOpacity(0.15), offset: const Offset(-4, -4), blurRadius: 6),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(radius: 28, backgroundColor: Colors.white, child: Icon(widget.data.icon, color: color, size: 28)),
            const SizedBox(height: 10),
            Text(widget.data.label,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, shadows: [Shadow(color: Colors.black26, offset: Offset(1, 1), blurRadius: 2)])),
          ],
        ),
      ),
    );
  }
}

class _SlimFeatureButton3D extends StatefulWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Widget page;

  const _SlimFeatureButton3D({required this.icon, required this.label, required this.color, required this.page});

  @override
  State<_SlimFeatureButton3D> createState() => _SlimFeatureButton3DState();
}

class _SlimFeatureButton3DState extends State<_SlimFeatureButton3D> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        Navigator.push(context, MaterialPageRoute(builder: (_) => widget.page));
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        transform: Matrix4.identity()..scale(_isPressed ? 0.97 : 1.0),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: _isPressed ? [widget.color.withOpacity(0.7), widget.color.withOpacity(0.5)] : [widget.color.withOpacity(0.85), widget.color.withOpacity(0.65)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.black45, offset: const Offset(4, 4), blurRadius: _isPressed ? 8 : 6),
            BoxShadow(color: Colors.white.withOpacity(_isPressed ? 0.25 : 0.15), offset: const Offset(-2, -2), blurRadius: _isPressed ? 8 : 4),
            if (_isPressed) BoxShadow(color: widget.color.withOpacity(0.4), offset: const Offset(0, 0), blurRadius: 16, spreadRadius: 1),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(widget.icon, color: Colors.white),
            const SizedBox(width: 8),
            Text(widget.label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

class _TransactionCard3D extends StatelessWidget {
  final Transaction tx;
  final bool isDarkMode;

  const _TransactionCard3D({required this.tx, required this.isDarkMode});

  @override
  Widget build(BuildContext context) {
    final isCredit = tx.type == "Add Funds" || tx.type == "Receive";
    final amountText = "${isCredit ? '+' : '-'}${tx.amount} XAF";
    final amountColor = isCredit ? Colors.greenAccent : Colors.redAccent;

    IconData icon;
    switch (tx.type) {
      case "Add Funds":
        icon = Icons.add;
        break;
      case "Withdraw":
      case "Payment":
        icon = Icons.remove;
        break;
      case "Send":
        icon = Icons.send;
        break;
      case "Receive":
        icon = Icons.call_received;
        break;
      default:
        icon = Icons.payment;
    }

    return Container(
      width: 220,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDarkMode ? [const Color(0xFF2A2A2A), const Color(0xFF1E1E1E)] : [Colors.white, Colors.grey[100]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black45, blurRadius: 8, offset: Offset(0, 4)),
          BoxShadow(color: Colors.white24, blurRadius: 6, offset: Offset(-4, -4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: amountColor.withOpacity(0.1),
                child: Icon(icon, color: amountColor),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(tx.details, style: const TextStyle(fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
              ),
            ],
          ),
          Text(amountText, style: TextStyle(fontWeight: FontWeight.bold, color: amountColor, fontSize: 16)),
          Text("${tx.date.day.toString().padLeft(2, '0')}-${tx.date.month.toString().padLeft(2, '0')}-${tx.date.year}",
              style: TextStyle(color: isDarkMode ? Colors.white60 : Colors.black54)),
        ],
      ),
    );
  }
}
