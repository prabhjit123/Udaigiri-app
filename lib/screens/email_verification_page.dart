import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dashboard/dashboard_page.dart';

class EmailVerificationPage extends StatefulWidget {
  final String name;
  final String entryNumber;
  final String roomNumber;
  final String email;

  const EmailVerificationPage({
    super.key,
    required this.name,
    required this.entryNumber,
    required this.roomNumber,
    required this.email,
  });

  @override
  State<EmailVerificationPage> createState() => _EmailVerificationPageState();
}

class _EmailVerificationPageState extends State<EmailVerificationPage> {
  Timer? timer;
  bool isEmailVerified = false;
  bool canResendEmail = true;
  bool loading = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _checkEmailVerified(initial: true);

    // Poll periodically every 5 seconds
    timer = Timer.periodic(const Duration(seconds: 5), (_) => _checkEmailVerified());
  }

  Future<void> _checkEmailVerified({bool initial = false}) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await user.reload(); // 👈 Force refresh
    final refreshedUser = FirebaseAuth.instance.currentUser;

    if (refreshedUser != null && refreshedUser.emailVerified) {
      timer?.cancel();
      setState(() {
        isEmailVerified = true;
        loading = false;
      });

      // Navigate to dashboard
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const DashboardPage()),
        );
      }
    } else if (initial) {
      // Initial check complete, but not verified
      setState(() {
        isEmailVerified = false;
        loading = false;
      });
    }
  }

  Future<void> _sendVerificationEmail() async {
    try {
      setState(() {
        canResendEmail = false;
        loading = true;
        errorMessage = null;
      });

      final user = FirebaseAuth.instance.currentUser;
      await user?.sendEmailVerification();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Verification email sent')),
      );

      // Cooldown period before resend is allowed
      await Future.delayed(const Duration(seconds: 30));
      if (mounted) {
        setState(() {
          canResendEmail = true;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send email: $e')),
      );
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF282829),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.email_outlined, color: Colors.white, size: 80),
              const SizedBox(height: 20),
              Text(
                'A verification email has been sent to:\n${widget.email}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70, fontSize: 16),
              ),
              const SizedBox(height: 30),

              loading
                  ? const CircularProgressIndicator(color: Colors.deepPurpleAccent)
                  : isEmailVerified
                      ? const Text(
                          'Email verified! Redirecting...',
                          style: TextStyle(color: Colors.green, fontSize: 16),
                        )
                      : canResendEmail
                          ? ElevatedButton(
                              onPressed: _sendVerificationEmail,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.deepPurpleAccent,
                              ),
                              child: const Text('Send Verification Email'),
                            )
                          : const Text(
                              'Please wait before resending...',
                              style: TextStyle(color: Colors.grey),
                            ),

              const SizedBox(height: 20),

              if (errorMessage != null)
                Text(
                  errorMessage!,
                  style: const TextStyle(color: Colors.redAccent),
                  textAlign: TextAlign.center,
                )
            ],
          ),
        ),
      ),
    );
  }
}
