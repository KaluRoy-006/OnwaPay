import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../main.dart'; // For ThemeController and MyApp

import '../home.dart'; // Navigate to HomePage after OTP verification

class OTPVerificationPage extends StatefulWidget {
  final String verificationId;
  final int? resendToken;
  final String? phoneNumber;

  const OTPVerificationPage({
    super.key,
    required this.verificationId,
    this.resendToken,
    this.phoneNumber,
  });

  @override
  State<OTPVerificationPage> createState() => _OTPVerificationPageState();
}

class _OTPVerificationPageState extends State<OTPVerificationPage> {
  final TextEditingController _otpController = TextEditingController();
  bool _isLoading = false;
  bool _isResending = false;
  String? _currentVerificationId;

  @override
  void initState() {
    super.initState();
    _currentVerificationId = widget.verificationId;
  }

  Future<void> _verifyOTP() async {
    final code = _otpController.text.trim();
    if (code.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Please enter the OTP")));
      return;
    }

    setState(() => _isLoading = true);
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: _currentVerificationId!,
        smsCode: code,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);

      // ✅ Navigate to HomePage instead of RootPage
      if (context.mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const HomePage()),
              (route) => false,
        );
      }
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Invalid OTP: ${e.message}")));
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error verifying code: $e")));
    }

    setState(() => _isLoading = false);
  }

  Future<void> _resendOTP() async {
    if (widget.phoneNumber == null) return;

    setState(() => _isResending = true);

    try {
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: widget.phoneNumber!,
        forceResendingToken: widget.resendToken,
        verificationCompleted: (_) {},
        verificationFailed: (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Resend failed: ${e.message}")),
          );
        },
        codeSent: (newVerificationId, newResendToken) {
          _currentVerificationId = newVerificationId;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("OTP code resent successfully")),
          );
        },
        codeAutoRetrievalTimeout: (verificationId) {
          _currentVerificationId = verificationId;
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error resending code: $e")));
    }

    setState(() => _isResending = false);
  }

  @override
  Widget build(BuildContext context) {
    const darkBlue = Color(0xFF0A1D37);
    const gold = Color(0xFFFFC107);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Verify OTP"),
        backgroundColor: darkBlue,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 32),
            const Icon(Icons.lock_outline, color: darkBlue, size: 64),
            const SizedBox(height: 24),
            const Text(
              "Enter the 6-digit code sent to your phone",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: darkBlue),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _otpController,
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              maxLength: 6,
              decoration: InputDecoration(
                counterText: "",
                hintText: "------",
                hintStyle: const TextStyle(
                    letterSpacing: 8, color: Colors.grey, fontSize: 24),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: gold, width: 2),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              style: const TextStyle(
                  fontSize: 24,
                  letterSpacing: 8,
                  color: darkBlue,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 32),
            _isLoading
                ? const CircularProgressIndicator(color: gold)
                : ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: gold,
                foregroundColor: darkBlue,
                minimumSize: const Size(double.infinity, 55),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: _verifyOTP,
              child: const Text(
                "Verify & Continue",
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: _isResending ? null : _resendOTP,
              child: _isResending
                  ? const CircularProgressIndicator(color: gold)
                  : const Text(
                "Resend Code",
                style: TextStyle(
                  color: darkBlue,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
