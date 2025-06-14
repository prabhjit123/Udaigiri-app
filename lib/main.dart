import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'core/theme/app_theme.dart';
import 'screens/dashboard/dashboard_page.dart';
import 'screens/login_page.dart';
import 'screens/email_verification_page.dart';
import 'firebase_options.dart'; // Ensure this file is generated from Firebase Console

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const UdaigiriApp());
}

class UdaigiriApp extends StatelessWidget {
  const UdaigiriApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Udaigiri Hostel App',
      theme: AppTheme.darkTheme, // ✅ your custom theme
      debugShowCheckedModeBanner: false,
      home: const DashboardPage(),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        final user = snapshot.data;

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (user == null) {
          return const LoginPage(); // 🔓 Not logged in
        }

        if (!user.emailVerified) {
          return EmailVerificationPage(
  name: user.displayName ?? 'User',
  entryNumber: user.email?.split('@').first ?? 'unknown',
  roomNumber: 'N/A', // 🔁 Replace this with actual room number if available
  email: user.email ?? 'unknown@hostel.com',
);
        }

        return const DashboardPage(); // ✅ Verified and logged in
      },
    );
  }
}
