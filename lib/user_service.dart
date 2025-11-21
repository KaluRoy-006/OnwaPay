import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Generate a unique 10-digit account number
  Future<String> _generateAccountNumber() async {
    final random = Random();
    String accountNumber;

    // Keep generating until we find a number not in use
    do {
      accountNumber = List.generate(10, (_) => random.nextInt(10)).join();
    } while (await _accountNumberExists(accountNumber));

    return accountNumber;
  }

  Future<bool> _accountNumberExists(String number) async {
    final snapshot = await _db
        .collection('users')
        .where('accountNumber', isEqualTo: number)
        .limit(1)
        .get();
    return snapshot.docs.isNotEmpty;
  }

  /// Create Firestore profile for a new user
  Future<void> createUserProfile(User user) async {
    final docRef = _db.collection('users').doc(user.uid);
    final accountNumber = await _generateAccountNumber();

    await docRef.set({
      'uid': user.uid,
      'email': user.email,
      'accountNumber': accountNumber,
      'balance': 0.0,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
