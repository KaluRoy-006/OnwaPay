import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';

class UpdateProfilePage extends StatefulWidget {
  const UpdateProfilePage({super.key});

  @override
  State<UpdateProfilePage> createState() => _UpdateProfilePageState();
}

class _UpdateProfilePageState extends State<UpdateProfilePage> {
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();

  bool _isProcessing = false;
  String? _verificationId;
  Timer? _emailCheckTimer;

  @override
  void dispose() {
    _emailController.dispose();
    _phoneController.dispose();
    _otpController.dispose();
    _emailCheckTimer?.cancel();
    super.dispose();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _updateEmail() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || _emailController.text.isEmpty) return;

    try {
      await user.updateEmail(_emailController.text.trim());
      await user.sendEmailVerification();

      _showEmailVerificationDialog();

      // Start auto-check every 5 seconds
      _emailCheckTimer = Timer.periodic(const Duration(seconds: 5), (timer) async {
        await user.reload();
        if (user.emailVerified) {
          timer.cancel();
          _showMessage("Email verified successfully!");
          Navigator.pop(context); // Close dialog if open
        }
      });
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        _showMessage("Please re-login to update email.");
      } else {
        _showMessage("Email update failed: ${e.message}");
      }
    }
  }

  Future<void> _updatePhone() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || _phoneController.text.isEmpty) return;

    setState(() => _isProcessing = true);

    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: _phoneController.text.trim(),
      verificationCompleted: (credential) async {
        try {
          await user.updatePhoneNumber(credential);
          _showMessage("Phone updated successfully.");
        } catch (e) {
          _showMessage("Phone update failed: $e");
        } finally {
          setState(() => _isProcessing = false);
        }
      },
      verificationFailed: (e) {
        _showMessage("Phone verification failed: ${e.message}");
        setState(() => _isProcessing = false);
      },
      codeSent: (verificationId, resendToken) {
        _verificationId = verificationId;
        setState(() => _isProcessing = false);
        _showOTPBottomSheet();
      },
      codeAutoRetrievalTimeout: (verificationId) {
        _verificationId = verificationId;
        setState(() => _isProcessing = false);
      },
    );
  }

  void _showEmailVerificationDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text("Email Verification"),
        content: const Text("A verification email has been sent. Waiting for verification..."),
        actions: [
          TextButton(
            onPressed: () async {
              final user = FirebaseAuth.instance.currentUser;
              await user?.sendEmailVerification();
              _showMessage("Verification email resent.");
            },
            child: const Text("Resend Email"),
          ),
        ],
      ),
    );
  }

  void _showOTPBottomSheet() {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Enter OTP sent to your phone"),
            const SizedBox(height: 12),
            TextField(
              controller: _otpController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "OTP",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                if (_verificationId == null) return;

                final credential = PhoneAuthProvider.credential(
                  verificationId: _verificationId!,
                  smsCode: _otpController.text.trim(),
                );
                try {
                  final user = FirebaseAuth.instance.currentUser;
                  await user?.updatePhoneNumber(credential);
                  Navigator.pop(ctx);
                  _showMessage("Phone updated successfully!");
                } catch (e) {
                  _showMessage("Invalid OTP: $e");
                }
              },
              child: const Text("Verify OTP"),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveChanges() async {
    if (_isProcessing) return;

    if (_emailController.text.isEmpty && _phoneController.text.isEmpty) {
      _showMessage("Please enter email or phone to update.");
      return;
    }

    setState(() => _isProcessing = true);

    if (_emailController.text.isNotEmpty) await _updateEmail();
    if (_phoneController.text.isNotEmpty) await _updatePhone();

    setState(() => _isProcessing = false);
  }

  @override
  Widget build(BuildContext context) {
    const darkBlue = Color(0xFF0A1D37);
    const gold = Color(0xFFFFC107);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Update Profile"),
        backgroundColor: darkBlue,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: "New Email",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: "New Phone Number",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: gold,
                foregroundColor: darkBlue,
                minimumSize: const Size(double.infinity, 50),
              ),
              onPressed: _saveChanges,
              child: _isProcessing
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Save Changes"),
            ),
          ],
        ),
      ),
    );
  }
}
