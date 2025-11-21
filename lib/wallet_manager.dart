import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Transaction {
  final String type;       // "Add Funds", "Withdraw", "Send", "Payment", "Receive"
  final String details;    // description, recipient, or source
  final int amount;
  final String status;     // "SUCCESS", "FAILED", etc.
  final String reference;  // optional transaction reference
  final DateTime date;

  Transaction({
    required this.type,
    required this.details,
    required this.amount,
    required this.status,
    this.reference = "",
    required this.date,
  });

  factory Transaction.fromMap(Map<String, dynamic> map) => Transaction(
    type: map['type'] ?? '',
    details: map['details'] ?? '',
    amount: map['amount'] ?? 0,
    status: map['status'] ?? '',
    reference: map['reference'] ?? '',
    date: DateTime.parse(map['date']),
  );

  Map<String, dynamic> toMap() => {
    'type': type,
    'details': details,
    'amount': amount,
    'status': status,
    'reference': reference,
    'date': date.toIso8601String(),
  };
}

class WalletManager {
  /// Singleton
  WalletManager._();
  static final WalletManager instance = WalletManager._();

  static ValueNotifier<int> balanceNotifier = ValueNotifier<int>(0);
  static ValueNotifier<List<Transaction>> transactionsNotifier =
  ValueNotifier<List<Transaction>>([]);

  static String accountNumber = "";

  /// Load wallet data for the logged-in user
  static Future<void> loadWalletData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc =
    await FirebaseFirestore.instance.collection('users').doc(user.uid).get();

    accountNumber = doc.data()?['accountNumber'] ?? '';
    balanceNotifier.value = (doc.data()?['balance'] ?? 0).toInt();

    final txCollection = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('transactions')
        .orderBy('date', descending: true)
        .get();

    transactionsNotifier.value = txCollection.docs
        .map((doc) => Transaction.fromMap(doc.data()))
        .toList();
  }

  /// ---------------- Add Funds ----------------
  static Future<void> addFunds(int amount,
      {String source = "Wallet Top-Up"}) async {
    if (amount <= 0) return;

    balanceNotifier.value += amount;

    await _addTransaction(
      type: "Add Funds",
      details: source,
      amount: amount,
      status: "SUCCESS",
    );

    await _updateBalanceInFirestore();
  }

  /// ---------------- Withdraw ----------------
  static Future<bool> withdraw(int amount,
      {String note = "Wallet Withdrawal"}) async {
    if (amount <= 0 || balanceNotifier.value < amount) return false;

    balanceNotifier.value -= amount;

    await _addTransaction(
      type: "Withdraw",
      details: note,
      amount: amount,
      status: "SUCCESS",
    );

    await _updateBalanceInFirestore();
    return true;
  }

  /// ---------------- Send Funds ----------------
  static Future<bool> sendFunds(int amount, {String recipient = "Recipient"}) async {
    if (amount <= 0 || balanceNotifier.value < amount) return false;

    balanceNotifier.value -= amount;

    await _addTransaction(
      type: "Send",
      details: "Sent to $recipient",
      amount: amount,
      status: "SUCCESS",
    );

    await _updateBalanceInFirestore();
    return true;
  }

  /// ---------------- Pay Bills / Buy Bundle / Airtime ----------------
  static Future<bool> payBill(int amount, {String note = "Bill Payment"}) async {
    if (amount <= 0 || balanceNotifier.value < amount) return false;

    balanceNotifier.value -= amount;

    await _addTransaction(
      type: "Payment",
      details: note,
      amount: amount,
      status: "SUCCESS",
    );

    await _updateBalanceInFirestore();
    return true;
  }

  /// ---------------- Receive Money ----------------
  static Future<void> receiveMoney(int amount, {String sender = "Sender"}) async {
    if (amount <= 0) return;

    balanceNotifier.value += amount;

    await _addTransaction(
      type: "Receive",
      details: "Received from $sender",
      amount: amount,
      status: "SUCCESS",
    );

    await _updateBalanceInFirestore();
  }

  /// ---------------- Internal: Add Transaction ----------------
  static Future<void> _addTransaction({
    required String type,
    required String details,
    required int amount,
    String status = "SUCCESS",
    String reference = "",
  }) async {
    final tx = Transaction(
      type: type,
      details: details,
      amount: amount,
      status: status,
      reference: reference,
      date: DateTime.now(),
    );

    transactionsNotifier.value = [tx, ...transactionsNotifier.value];

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('transactions')
        .add(tx.toMap());
  }

  /// ---------------- Update balance in Firestore ----------------
  static Future<void> _updateBalanceInFirestore() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .update({'balance': balanceNotifier.value});
  }

  /// ---------------- Manual Add ----------------
  static void addTransaction(Transaction tx) {
    transactionsNotifier.value = [tx, ...transactionsNotifier.value];
  }

  /// ---------------- Clear All ----------------
  static void clearAll() {
    balanceNotifier.value = 0;
    transactionsNotifier.value = [];
  }
}
