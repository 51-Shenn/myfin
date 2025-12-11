
import 'package:flutter/material.dart';
import 'package:myfin/components/auth_switcher.dart';
import 'package:myfin/components/custom_text_field.dart';
import 'package:intl/intl.dart'; // Add 'intl' package to pubspec.yaml for date formatting

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  // 1. State variables
  bool _isPasswordObscured = true;
  final TextEditingController _dateController = TextEditingController();

  // 2. Clean up controller when widget is removed
  @override
  void dispose() {
    _dateController.dispose();
    super.dispose();
  }

  // 3. Function to show the date picker
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1920), // Set a reasonable start date
      lastDate: DateTime.now(),   // User cannot be born in the future
    );
    if (picked != null) {
      // Format the date and update the controller's text
      String formattedDate = DateFormat('dd/MM/yyyy').format(picked);
      setState(() {
        _dateController.text = formattedDate;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ... (header, logo, title - no changes)
              const SizedBox(height: 60),
              Image.asset('assets/logo.png', height: 64),
              const SizedBox(height: 20),
              const Text(
                'Get Started now',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Create an account or log in to explore\nabout our app',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
              const SizedBox(height: 40),
              const AuthSwitcher(isLogin: false),
              const SizedBox(height: 40),

              // --- FORM ---
              Row(
                children: const [
                  Expanded(child: CustomTextField(labelText: 'First Name')),
                  SizedBox(width: 16),
                  Expanded(child: CustomTextField(labelText: 'Last Name')),
                ],
              ),
              const SizedBox(height: 16),
              const CustomTextField(labelText: 'Email'),
              const SizedBox(height: 16),

              // 4. Date of Birth Field
              CustomTextField(
                labelText: 'Birth of date',
                controller: _dateController, // Use the controller
                isDateField: true,
                onSuffixIconTap: () => _selectDate(context), // Call our function on tap
              ),
              const SizedBox(height: 16),
              const CustomTextField(labelText: 'Phone Number', isPhoneField: true),
              const SizedBox(height: 16),

              // 5. Password Field
              CustomTextField(
                labelText: 'Set Password',
                obscureText: _isPasswordObscured, // Use state variable
                onSuffixIconTap: () {
                  setState(() {
                    _isPasswordObscured = !_isPasswordObscured;
                  });
                },
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2B46F9),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Register', style: TextStyle(fontSize: 16)),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}