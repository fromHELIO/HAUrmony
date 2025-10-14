import 'package:flutter/material.dart';
import '../constants.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SignupNonAngeliteScreen extends StatefulWidget {
  const SignupNonAngeliteScreen({super.key});

  @override
  State<SignupNonAngeliteScreen> createState() => _SignupNonAngeliteScreenState();
}

class _SignupNonAngeliteScreenState extends State<SignupNonAngeliteScreen> {
  final _formKey = GlobalKey<FormState>();
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final contactController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final supabase = Supabase.instance.client;

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    contactController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  String? _requiredValidator(String? v) {
    if (v == null || v.trim().isEmpty) return 'Required';
    return null;
  }

  String? _emailValidator(String? v) {
    if (v == null || v.trim().isEmpty) return 'Enter your email';
    final email = v.trim();
    final emailRegex = RegExp(r'^[\w\.\-]+@([\w\-]+\.)+[A-Za-z]{2,}$');
    if (!emailRegex.hasMatch(email)) return 'Enter a valid email';
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
        'is_angelite': false,
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
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: kLogoColor,
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'lib/assets/haurmony.png', // fixed path
              width: kLogoSize,
              height: kLogoSize,
              fit: BoxFit.contain,
            ),
            const SizedBox(width: 8),
            Text(
              'HAUrmony',
              style: TextStyle(
                color: kLogoColor,
                fontWeight: FontWeight.bold,
                fontSize: kTitleFontSize,
              ),
            ),
          ],
        ),
      ),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                const Text('Hello, Non – Angelite!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                const Text('Not a student? Not a problem! Sign up with a valid email.'),
                const SizedBox(height: 24),
                TextFormField(controller: firstNameController, decoration: const InputDecoration(labelText: 'First Name'), validator: _requiredValidator),
                const SizedBox(height: 12),
                TextFormField(controller: lastNameController, decoration: const InputDecoration(labelText: 'Last Name'), validator: _requiredValidator),
                const SizedBox(height: 12),
                TextFormField(controller: contactController, decoration: const InputDecoration(labelText: 'Contact Number')),
                const SizedBox(height: 12),
                TextFormField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                  keyboardType: TextInputType.emailAddress,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: _emailValidator,
                ),
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
                        color: Colors.white, // explicit white text
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
