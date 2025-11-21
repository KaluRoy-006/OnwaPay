import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:OnwaPay/main.dart'; // matches your pubspec.yaml name

void main() {
  testWidgets('AuthPage displays logo, title, and buttons', (WidgetTester tester) async {
    // Build the app
    await tester.pumpWidget(const MyApp());

    // Wait for any animations
    await tester.pumpAndSettle();

    // Check for the logo (Image.asset)
    expect(find.byType(Image), findsOneWidget);

    // Check for title text
    expect(find.text('Welcome to KoloPay'), findsOneWidget);

    // Check for Sign Up button
    expect(find.text('Sign Up'), findsOneWidget);

    // Check for Login button
    expect(find.text('Login'), findsOneWidget);
  });
}
