import 'package:flutter/material.dart';
import '../constants.dart';
import '../widgets/app_appbar.dart'; // ADDED
import 'package:supabase_flutter/supabase_flutter.dart';

class SignupAngeliteScreen extends StatefulWidget {
  const SignupAngeliteScreen({super.key});

  @override
  State<SignupAngeliteScreen> createState() => _SignupAngeliteScreenState();
}

class _SignupAngeliteScreenState extends State<SignupAngeliteScreen> {
  final _formKey = GlobalKey<FormState>();
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final contactController = TextEditingController();
  final emailController = TextEditingController();
  final studentNumberController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    contactController.dispose();
    emailController.dispose();
    studentNumberController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  String? _hauEmailValidator(String? v) {
    if (v == null || v.trim().isEmpty) return 'Enter your HAU email';
    final email = v.trim();
    final hauRegex = RegExp(r'^[\w\.\-]+@student\.hau\.edu\.ph$', caseSensitive: false);
    if (!hauRegex.hasMatch(email)) return 'Email must be a valid @student.hau.edu.ph address';
    return null;
  }

  String? _requiredValidator(String? v) {
    if (v == null || v.trim().isEmpty) return 'Required';
    return null;
  }

  String? _passwordValidator(String? v) {
    if (v == null || v.isEmpty) return 'Enter password';
    if (v.length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  String? _confirmPasswordValidator(String? v) {
    if (v == null || v.isEmpty) return 'Confirm password';
    if (v != passwordController.text) return 'Passwords do not match';
    return null;
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final firstname = firstNameController.text.trim();
    final lastname = lastNameController.text.trim();

    final supabase = Supabase.instance.client;

    try {
      final authResponse = await supabase.auth.signUp(
        email: email,
        password: password,
        emailRedirectTo: 'io.supabase.flutter://login-callback/',
      );

    final user = authResponse.user;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sign-up failed.')),
      );
      return;
    }

    await supabase.from('user_info').insert({
      'user_id': user.id,
      'first_name': firstname,
      'last_name': lastname,
      'is_angelite': true,
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sign-up successful. Please verify your account in your email.')
        ),
      );
      Navigator.pop(context);
    }
    } on AuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Authentication error: ${e.message}')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unexpected error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWithHamburger(context, showBack: true, openEndDrawer: false), // REPLACED AppBar
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                const Text('Hello, Angelite!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                const Text('Sign up with your HAU email to get started.'),
                const SizedBox(height: 24),
                TextFormField(controller: firstNameController, decoration: const InputDecoration(labelText: 'First Name'), validator: _requiredValidator),
                const SizedBox(height: 12),
                TextFormField(controller: lastNameController, decoration: const InputDecoration(labelText: 'Last Name'), validator: _requiredValidator),
                const SizedBox(height: 12),
                TextFormField(controller: contactController, decoration: const InputDecoration(labelText: 'Contact Number')),
                const SizedBox(height: 12),
                TextFormField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: 'HAU Email (@student.hau.edu.ph)'),
                  keyboardType: TextInputType.emailAddress,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: _hauEmailValidator,
                ),
                const SizedBox(height: 12),
                TextFormField(controller: studentNumberController, decoration: const InputDecoration(labelText: 'Student Number')),
                const SizedBox(height: 12),
                TextFormField(controller: passwordController, obscureText: true, decoration: const InputDecoration(labelText: 'Password'), validator: _passwordValidator),
                const SizedBox(height: 12),
                TextFormField(controller: confirmPasswordController, obscureText: true, decoration: const InputDecoration(labelText: 'Confirm Password'), validator: _confirmPasswordValidator),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kLogoColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      elevation: 2,
                    ),
                    onPressed: _submit,
                    child: const Text(
                      'SIGN UP',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

}

