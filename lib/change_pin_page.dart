import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChangePinPage extends StatefulWidget {
  const ChangePinPage({super.key});

  @override
  State<ChangePinPage> createState() => _ChangePinPageState();
}

class _ChangePinPageState extends State<ChangePinPage> {
  final _oldPinController = TextEditingController();
  final _newPinController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    const darkBlue = Color(0xFF0A1D37);
    const gold = Color(0xFFFFC107);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Change PIN"),
        backgroundColor: darkBlue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            TextField(
              controller: _oldPinController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "Old PIN",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _newPinController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "New PIN",
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
              onPressed: _changePin,
              child: const Text("Update PIN"),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _changePin() async {
    final prefs = await SharedPreferences.getInstance();
    final oldPin = prefs.getString('user_pin') ?? '';

    if (_oldPinController.text == oldPin) {
      await prefs.setString('user_pin', _newPinController.text);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("PIN updated successfully")),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Old PIN is incorrect")),
      );
    }
  }
}
