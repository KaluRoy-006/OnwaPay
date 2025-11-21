import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'update_profile_page.dart';
import 'auth/auth_choice_page.dart';
import 'main.dart'; // For ThemeController

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = Provider.of<ThemeController>(context);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = Theme.of(context).textTheme.bodyLarge!.color;

    const darkBlue = Color(0xFF0A1D37);
    const gold = Color(0xFFFFC107);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF42A5F5), Color(0xFFFFD700)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: ListView(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              "Appearance",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          RadioListTile<ThemeMode>(
            value: ThemeMode.light,
            groupValue: themeController.themeMode,
            title: Text("Light Mode", style: TextStyle(color: textColor)),
            secondary: Icon(Icons.wb_sunny, color: textColor),
            onChanged: (mode) => themeController.setTheme(mode!),
          ),
          RadioListTile<ThemeMode>(
            value: ThemeMode.dark,
            groupValue: themeController.themeMode,
            title: Text("Dark Mode", style: TextStyle(color: textColor)),
            secondary: Icon(Icons.nights_stay, color: textColor),
            onChanged: (mode) => themeController.setTheme(mode!),
          ),
          RadioListTile<ThemeMode>(
            value: ThemeMode.system,
            groupValue: themeController.themeMode,
            title: Text("System Default", style: TextStyle(color: textColor)),
            secondary: Icon(Icons.settings, color: textColor),
            onChanged: (mode) => themeController.setTheme(mode!),
          ),
          const Divider(),
          ListTile(
            leading: Icon(Icons.person, color: textColor),
            title: Text("Update Profile", style: TextStyle(color: textColor)),
            subtitle: Text(
              "Change phone/email",
              style: TextStyle(color: textColor?.withOpacity(0.7)),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const UpdateProfilePage()),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: Icon(Icons.lock, color: textColor),
            title: Text("Change PIN", style: TextStyle(color: textColor)),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("PIN change feature coming soon")),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.exit_to_app, color: Colors.red),
            title: const Text("Logout", style: TextStyle(color: Colors.red)),
            onTap: () => _showLogoutDialog(context),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Logout"),
        content: const Text("Are you sure you want to logout?"),
        actions: [
          TextButton(
            child: const Text("Cancel"),
            onPressed: () => Navigator.pop(ctx),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Logout"),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pop(ctx);
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const AuthChoicePage()),
                    (route) => false,
              );
            },
          ),
        ],
      ),
    );
  }
}
