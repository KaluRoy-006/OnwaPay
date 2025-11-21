import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../home.dart'; // Navigate to HomePage after email verification

class EmailVerificationPage extends StatefulWidget {
  final String email;
  const EmailVerificationPage({super.key, required this.email});

  @override
  State<EmailVerificationPage> createState() => _EmailVerificationPageState();
}

class _EmailVerificationPageState extends State<EmailVerificationPage> {
  bool _isLoading = false;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _checkPendingDynamicLink(); // Auto sign-in if magic link already opened
  }

  /// ✅ 1. Handle any pending sign-in links (after user clicks email link)
  Future<void> _checkPendingDynamicLink() async {
    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final email = widget.email;

      // Retrieve any link saved from your dynamic link handler
      final link = prefs.getString('pending_sign_in_link');

      if (link != null && _auth.isSignInWithEmailLink(link)) {
        await _auth.signInWithEmailLink(email: email, emailLink: link);
        await prefs.remove('pending_sign_in_link');

        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const HomePage()),
                (route) => false,
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error verifying email: $e")),
      );
    }

    setState(() => _isLoading = false);
  }

  /// ✅ 2. Re-send the magic link correctly
  Future<void> _sendVerificationEmail() async {
    setState(() => _isLoading = true);
    try {
      final actionCodeSettings = ActionCodeSettings(
        // ✅ Must be your authorized Firebase Hosting domain
        url: 'https://kolopay1970.web.app/',
        handleCodeInApp: true,
        iOSBundleId: 'com.example.onwapay',
        androidPackageName: 'com.example.onwapay',
        androidInstallApp: true,
        androidMinimumVersion: '21',
      );

      await _auth.sendSignInLinkToEmail(
        email: widget.email,
        actionCodeSettings: actionCodeSettings,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Check your email for the sign-in link")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error: $e")));
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    const darkBlue = Color(0xFF0A1D37);
    const gold = Color(0xFFFFC107);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Verify Email"),
        backgroundColor: darkBlue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "A magic link has been sent to ${widget.email}. "
                  "Click the link in your email to log in automatically.",
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: gold,
                foregroundColor: darkBlue,
                minimumSize: const Size(double.infinity, 50),
              ),
              onPressed: _sendVerificationEmail,
              child: const Text("Resend Link"),
            ),
          ],
        ),
      ),
    );
  }
}
