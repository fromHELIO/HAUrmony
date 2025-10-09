import 'package:flutter/material.dart';

const Color logoRed = Color(0xFFA32020); // Use your logo's red color

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Forgot Password', style: TextStyle(color: logoRed)),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: logoRed),
        elevation: 1,
        centerTitle: true, // centers only the AppBar title
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            const Text(
              'Reset your password',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: logoRed),
            ),
            const SizedBox(height: 8),
            const Text('Enter your email address and we\'ll send you a link to reset your password.'),
            const SizedBox(height: 24),
            const Text('Email', style: TextStyle(fontWeight: FontWeight.bold, color: logoRed)),
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: logoRed,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  elevation: 2,
                ),
                onPressed: () {
                  final email = emailController.text;
                  if (email.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please enter your email')),
                    );
                  } else {
                    // Simulate sending reset link
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Password reset link sent to $email')),
                    );
                  }
                },
                child: const Text(
                  'SEND RESET LINK',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    letterSpacing: 1,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}