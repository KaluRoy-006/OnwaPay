import 'package:flutter/material.dart';
import 'transaction_model.dart';

class ReceiptPage extends StatefulWidget {
  final Transaction transaction;
  const ReceiptPage({super.key, required this.transaction});

  @override
  State<ReceiptPage> createState() => _ReceiptPageState();
}

class _ReceiptPageState extends State<ReceiptPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 2))
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _accentColor(String? account) {
    switch (account) {
      case "MTN MoMo":
        return const Color(0xFFFFD700); // Gold
      case "Orange Money":
        return const Color(0xFFFFB74D); // Orange-Gold
      case "Ecobank":
        return const Color(0xFF42A5F5); // Blue
      case "Wallet":
        return const Color(0xFF42A5F5); // Bluish
      default:
        return const Color(0xFF42A5F5);
    }
  }

  String _logoPath(String? account) {
    switch (account) {
      case "MTN MoMo":
        return "assets/images/MTN_logo.jpg";
      case "Orange Money":
        return "assets/images/Orange_logo.jpg";
      case "Ecobank":
        return "assets/images/EcoBank.jpg";
      case "Wallet":
        return "assets/images/OnwaPay_logo.jpg";
      default:
        return "assets/images/OnwaPay_logo.jpg";
    }
  }

  @override
  Widget build(BuildContext context) {
    final tx = widget.transaction;
    final accent = _accentColor(tx.account);
    final logo = _logoPath(tx.account);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Receipt"),
        backgroundColor: accent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Container(
            width: 360,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 12,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // HEADER
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [accent.withOpacity(0.8), accent],
                    ),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  ),
                  child: Column(
                    children: [
                      Image.asset(logo, width: 60, height: 60),
                      const SizedBox(height: 8),
                      AnimatedBuilder(
                        animation: _controller,
                        builder: (context, child) {
                          final glow = Color.lerp(
                              Colors.yellow.shade700, Colors.amber.shade200, _controller.value);
                          return Text(
                            tx.status,
                            style: TextStyle(color: glow, fontSize: 16, fontWeight: FontWeight.bold),
                          );
                        },
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "${tx.amount} XAF",
                        style: const TextStyle(
                            color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // SENDER / RECIPIENT CARD
                _buildCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _row("Sender", tx.sender ?? "N/A"),
                      const SizedBox(height: 6),
                      _row("From Account", tx.account ?? "N/A"),
                      const SizedBox(height: 6),
                      _row("Recipient", tx.destinationBank ?? "N/A"),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // DETAILS CARD
                _buildCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _row("Transaction Type", tx.type),
                      const SizedBox(height: 6),
                      _row("Reference", tx.reference),
                      const SizedBox(height: 6),
                      _row("Narration", tx.narration ?? "N/A"),
                      const SizedBox(height: 6),
                      _row("Date", tx.date.toLocal().toString()),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // FOOTER
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                        colors: [accent.withOpacity(0.2), accent.withOpacity(0.4)]),
                    borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
                  ),
                  child: const Center(
                    child: Text(
                      "Thanks for using OnwaPay",
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _row(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w500)),
        Flexible(
            child: Text(value,
                textAlign: TextAlign.right, style: const TextStyle(fontWeight: FontWeight.bold))),
      ],
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}
