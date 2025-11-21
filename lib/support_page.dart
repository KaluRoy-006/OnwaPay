import 'package:flutter/material.dart';
import 'gradient_button.dart';

class SupportPage extends StatefulWidget {
  const SupportPage({super.key});

  @override
  State<SupportPage> createState() => _SupportPageState();
}

class _SupportPageState extends State<SupportPage> {
  final _formKey = GlobalKey<FormState>();
  final _messageController = TextEditingController();

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Message sent to support!")),
      );
      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Support"),
        backgroundColor: Colors.green[700],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _messageController,
                decoration: const InputDecoration(
                  labelText: "Your Message",
                  border: OutlineInputBorder(),
                ),
                maxLines: 6,
                validator: (val) => (val == null || val.isEmpty) ? "Enter a message" : null,
              ),
              const SizedBox(height: 24),
              GradientButton(
                text: "Send Message",
                enabled: true,
                onPressed: _sendMessage,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
