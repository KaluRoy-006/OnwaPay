import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'firebase_options.dart';
import 'home.dart';
import 'send_funds_premium_page.dart';
import 'settings_page.dart';
import 'auth/auth_choice_page.dart';

// -------------------------
// MAIN ENTRY POINT
// -------------------------
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // -------------------------
  // Firebase Initialization
  // -------------------------
  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      print("Firebase initialized successfully");
    } else {
      print("Firebase already initialized, skipping");
    }
  } catch (e) {
    print("Firebase init error: $e");
  }

  // -------------------------
  // Load saved theme from SharedPreferences
  // -------------------------
  final prefs = await SharedPreferences.getInstance();
  final savedTheme = prefs.getString('themeMode') ?? 'system';

  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeController(_stringToThemeMode(savedTheme)),
      child: const MyApp(),
    ),
  );
}

// -------------------------
// THEME HELPERS
// -------------------------
ThemeMode _stringToThemeMode(String mode) {
  switch (mode) {
    case 'light':
      return ThemeMode.light;
    case 'dark':
      return ThemeMode.dark;
    default:
      return ThemeMode.system;
  }
}

String _themeModeToString(ThemeMode mode) {
  switch (mode) {
    case ThemeMode.light:
      return 'light';
    case ThemeMode.dark:
      return 'dark';
    default:
      return 'system';
  }
}

// -------------------------
// THEME CONTROLLER
// -------------------------
class ThemeController extends ChangeNotifier {
  ThemeMode _themeMode;
  ThemeController(this._themeMode);

  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  Future<void> toggleTheme() async {
    _themeMode = isDarkMode ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('themeMode', _themeModeToString(_themeMode));
  }

  Future<void> setTheme(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('themeMode', _themeModeToString(mode));
  }
}

// -------------------------
// ROOT APP
// -------------------------
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static const Color darkBlue = Color(0xFF0A1D37);
  static const Color gold = Color(0xFFFFC107);

  @override
  Widget build(BuildContext context) {
    final themeController = Provider.of<ThemeController>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'OnwaPay',
      themeMode: themeController.themeMode,

      // -------------------------
      // LIGHT THEME
      // -------------------------
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: darkBlue,
        scaffoldBackgroundColor: const Color(0xFFF2F5F3),
        appBarTheme: const AppBarTheme(
          backgroundColor: darkBlue,
          foregroundColor: Colors.white,
          elevation: 6,
          shadowColor: Colors.black26,
        ),
        drawerTheme: const DrawerThemeData(backgroundColor: darkBlue),
        colorScheme: ColorScheme.fromSeed(seedColor: gold),
        useMaterial3: true,
      ),

      // -------------------------
      // DARK THEME
      // -------------------------
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: darkBlue,
        scaffoldBackgroundColor: const Color(0xFF0A0F1C),
        appBarTheme: const AppBarTheme(
          backgroundColor: darkBlue,
          foregroundColor: Colors.white,
          elevation: 6,
          shadowColor: Colors.black54,
        ),
        drawerTheme: const DrawerThemeData(backgroundColor: darkBlue),
        colorScheme: ColorScheme.fromSeed(
          seedColor: gold,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),

      // -------------------------
      // APP ENTRY (AUTH FLOW)
      // -------------------------
      home: const AuthWrapper(),
    );
  }
}

// -------------------------
// AUTH WRAPPER
// -------------------------
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Text("Auth error: ${snapshot.error}"),
            ),
          );
        }

        // Go to Auth page if user not signed in
        if (snapshot.data == null) {
          return const AuthChoicePage();
        }

        // Go to main app
        return const RootPage();
      },
    );
  }
}

// -------------------------
// ROOT PAGE (BOTTOM NAVIGATION)
// -------------------------
class RootPage extends StatefulWidget {
  const RootPage({super.key});

  @override
  State<RootPage> createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    HomePage(),
    SendFundsPagePremium(),
    SettingsPage(),
  ];

  static const Color darkBlue = Color(0xFF0A1D37);
  static const Color gold = Color(0xFFFFC107);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 8,
              offset: Offset(0, -3),
            ),
          ],
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: _currentIndex,
          selectedItemColor: gold,
          unselectedItemColor:
          theme.brightness == Brightness.dark ? Colors.white54 : Colors.grey,
          backgroundColor: darkBlue,
          showUnselectedLabels: true,
          onTap: (index) => setState(() => _currentIndex = index),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
            BottomNavigationBarItem(icon: Icon(Icons.send), label: "Send"),
            BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Settings"),
          ],
        ),
      ),
    );
  }
}
