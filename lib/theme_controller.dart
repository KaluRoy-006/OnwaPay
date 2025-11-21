// theme_controller.dart
import 'package:flutter/material.dart';

class ThemeController {
  // Use ValueNotifier to allow listening for changes
  ValueNotifier<bool> isDarkModeNotifier = ValueNotifier(false);

  bool get isDarkMode => isDarkModeNotifier.value;

  void toggle() {
    isDarkModeNotifier.value = !isDarkModeNotifier.value;
  }
}

// Create a single global instance
final themeController = ThemeController();
