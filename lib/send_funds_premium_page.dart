import 'dart:math';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'wallet_manager.dart';
import 'transaction_model.dart' as tx_model;
import 'transaction_manager.dart';
import 'onwapay_appbar.dart';
import 'receipt_page.dart';

class SendFundsPagePremium extends StatefulWidget {
  const SendFundsPagePremium({super.key});

  @override
  State<SendFundsPagePremium> createState() => _SendFundsPagePremiumState();
}

class _SendFundsPagePremiumState extends State<SendFundsPagePremium> {
  String fromAccount = "Wallet";
  String detectedAccount = "";
  bool includeCharges = true;
  final double charges = 1000.0;

  final TextEditingController recipientCtrl = TextEditingController();
  final TextEditingController amountCtrl = TextEditingController();
  final TextEditingController referenceCtrl = TextEditingController();

  String recipientName = "";
  bool isLookingUp = false;
  String lookupError = "";

  final Map<String, String> accountLogos = {
    "Wallet": "assets/images/OnwaPay_logo.jpg",
    "MTN MoMo": "assets/images/MTN_logo.jpg",
    "Orange Money": "assets/images/Orange_logo.jpg",
    "Ecobank": "assets/images/EcoBank.jpg",
  };

  @override
  void dispose() {
    recipientCtrl.dispose();
    amountCtrl.dispose();
    referenceCtrl.dispose();
    super.dispose();
  }

  String detectAccount(String number) {
    final cleaned = number.replaceAll(RegExp(r'\s+'), '');
    if (cleaned.startsWith('67') || cleaned.startsWith('650') || cleaned.startsWith('651')) return "MTN MoMo";
    if (cleaned.startsWith('69') || cleaned.startsWith('655') || cleaned.startsWith('656')) return "Orange Money";
    if (cleaned.startsWith('22') || cleaned.startsWith('66') || cleaned.startsWith('222') || cleaned.startsWith('333')) return "Ecobank";
    return "";
  }

  Color accentFor(String account) {
    switch (account) {
      case "MTN MoMo":
        return const Color(0xFFFFD700); // golden
      case "Orange Money":
        return Colors.deepOrangeAccent;
      case "Ecobank":
        return Colors.blueAccent;
      default:
        return const Color(0xFF42A5F5); // bluish
    }
  }

  Future<void> performLookup(String number) async {
    setState(() {
      isLookingUp = true;
      recipientName = "";
      lookupError = "";
    });

    await Future.delayed(const Duration(milliseconds: 600));

    if (detectedAccount.isEmpty) {
      setState(() {
        isLookingUp = false;
        lookupError = "Unknown operator / invalid prefix";
      });
      return;
    }

    final clean = number.replaceAll(RegExp(r'\s+'), '');
    if (!RegExp(r'^\d{8,}$').hasMatch(clean)) {
      setState(() {
        isLookingUp = false;
        lookupError = "Number looks invalid";
      });
      return;
    }

    setState(() {
      isLookingUp = false;
      recipientName = _mockNameForNumber(clean);
      lookupError = "";
    });
  }

  String _mockNameForNumber(String number) {
    final endings = int.tryParse(number.substring(number.length - 2)) ?? Random().nextInt(99);
    final list = ["John Doe", "Grace Mbah", "Richard Afimchou", "Amaka Okeke", "Paul Nji", "Linda Eno", "Jane Smith"];
    return list[endings % list.length];
  }

  void onRecipientChanged(String value) {
    final account = detectAccount(value);
    setState(() => detectedAccount = account);

    if (value.trim().isEmpty) {
      setState(() {
        recipientName = "";
        lookupError = "";
        isLookingUp = false;
      });
      return;
    }

    performLookup(value.trim());
  }

  void goToConfirm() {
    final amt = double.tryParse(amountCtrl.text) ?? 0.0;
    final total = amt + (includeCharges ? charges : 0.0);

    if (recipientCtrl.text.trim().isEmpty) return _showSnack("Please enter recipient number", success: false);
    if (detectedAccount.isEmpty) return _showSnack("Operator not recognized — check number", success: false);
    if (amt <= 0) return _showSnack("Enter a valid amount", success: false);
    if (recipientName.isEmpty) return _showSnack("Recipient name not available — double-check number", success: false);

    final tx = tx_model.Transaction(
      type: "Send Funds",
      details: "To ${recipientCtrl.text} via $detectedAccount",
      amount: total.toInt(),
      date: DateTime.now(),
      reference: referenceCtrl.text.trim().isEmpty ? _generateRef() : referenceCtrl.text.trim(),
      status: "SUCCESS",
      destinationBank: recipientCtrl.text.trim(),
      narration: "Sent ${total.toStringAsFixed(0)} XAF to $recipientName",
    );

    TransactionManager.addTransaction(tx);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => ReceiptPage(transaction: tx)),
    );
  }

  String _generateRef() => "TXN-${DateTime.now().millisecondsSinceEpoch}-${Random().nextInt(9999)}";

  void _showSnack(String msg, {bool success = true}) {
    final theme = Theme.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: TextStyle(color: theme.brightness == Brightness.dark ? Colors.white : Colors.black)),
        backgroundColor: success ? Colors.green.shade700 : Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = accentFor(detectedAccount.isEmpty ? fromAccount : detectedAccount);
    final bgColor = theme.scaffoldBackgroundColor;
    final cardColor = theme.brightness == Brightness.dark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = theme.textTheme.bodyLarge!.color;

    return Scaffold(
      appBar: const OnwaPayAppBar(title: "Send Funds"),
      backgroundColor: bgColor,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // FROM account with bluish-golden gradient
            _premiumBox(
              cardColor,
              gradient: LinearGradient(colors: [const Color(0xFF42A5F5), const Color(0xFFFFD700)]),
              child: Row(
                children: [
                  Image.asset(accountLogos[fromAccount]!, width: 40, height: 40),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(fromAccount, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor)),
                  ),
                  DropdownButton<String>(
                    value: fromAccount,
                    underline: const SizedBox(),
                    items: accountLogos.keys.map((k) {
                      return DropdownMenuItem(
                        value: k,
                        child: Row(
                          children: [
                            Image.asset(accountLogos[k]!, width: 24, height: 24),
                            const SizedBox(width: 8),
                            Text(k, style: TextStyle(color: textColor)),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (v) { if (v != null) setState(() => fromAccount = v); },
                  )
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Recipient
            _premiumBox(
              cardColor,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Recipient", style: TextStyle(fontWeight: FontWeight.w600, color: textColor)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: recipientCtrl,
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                            hintText: "Enter recipient number",
                            hintStyle: TextStyle(color: textColor?.withOpacity(0.6)),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                            filled: true,
                            fillColor: cardColor,
                          ),
                          style: TextStyle(color: textColor),
                          onChanged: onRecipientChanged,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: detectedAccount.isEmpty ? Colors.grey[300] : accent.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: detectedAccount.isEmpty
                            ? Icon(Icons.phone_android, size: 30, color: Colors.grey[600])
                            : Image.asset(accountLogos[detectedAccount]!, width: 42, height: 42),
                      )
                    ],
                  ),
                  const SizedBox(height: 10),
                  if (isLookingUp)
                    Text("Checking account...", style: TextStyle(color: textColor?.withOpacity(0.6)))
                  else if (lookupError.isNotEmpty)
                    Text(lookupError, style: const TextStyle(color: Colors.red))
                  else if (recipientName.isNotEmpty)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Name: $recipientName", style: TextStyle(fontWeight: FontWeight.bold, color: accent)),
                          Text(detectedAccount, style: TextStyle(color: accent, fontWeight: FontWeight.w600)),
                        ],
                      ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Amount
            _premiumBox(
              cardColor,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Amount", style: TextStyle(fontWeight: FontWeight.w600, color: textColor)),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: amountCtrl,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      prefixText: "XAF ",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: cardColor,
                    ),
                    style: TextStyle(color: textColor),
                    onChanged: (_) => setState(() {}),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Reference
            _premiumBox(
              cardColor,
              child: TextFormField(
                controller: referenceCtrl,
                decoration: InputDecoration(
                  labelText: "Reference (optional)",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: cardColor,
                ),
                style: TextStyle(color: textColor),
              ),
            ),
            const SizedBox(height: 12),

            // Charges toggle
            _premiumBox(
              cardColor,
              child: Row(
                children: [
                  Checkbox(
                    value: includeCharges,
                    onChanged: (v) => setState(() => includeCharges = v ?? true),
                    activeColor: accent,
                  ),
                  Text("Include charges", style: TextStyle(color: textColor)),
                  const Spacer(),
                  Text("Fee: ${includeCharges ? charges.toStringAsFixed(0) : '0'} XAF",
                      style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Wallet balance
            if (fromAccount == "Wallet")
              _premiumBox(
                cardColor,
                child: ValueListenableBuilder<int>(
                  valueListenable: WalletManager.balanceNotifier,
                  builder: (context, bal, _) => Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Wallet balance:", style: TextStyle(fontWeight: FontWeight.w600, color: textColor)),
                      Text("$bal XAF", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green.shade700)),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 16),

            // Continue button
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: goToConfirm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accent,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 6,
                      shadowColor: accent.withOpacity(0.5),
                    ),
                    child: const Text("Continue", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _premiumBox(Color bgColor, {required Widget child, Gradient? gradient}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: gradient == null ? bgColor : null,
        gradient: gradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }
}
