
import 'package:flutter/material.dart';
import 'package:myfin/components/auth_switcher.dart';
import 'package:myfin/components/custom_text_field.dart';
import 'package:myfin/components/social_login_button.dart';
import 'package:myfin/navigation/app_routes.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  // 1. State variable to track password visibility
  bool _isPasswordObscured = true;

  bool _rememberMe = false;

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
              const AuthSwitcher(isLogin: true),
              const SizedBox(height: 40),

              // --- FORM ---
              const CustomTextField(labelText: 'Email'),
              const SizedBox(height: 16),

              // 2. Updated Password Field
              CustomTextField(
                labelText: 'Password',
                obscureText: _isPasswordObscured, // Use state variable
                onSuffixIconTap: () {
                  // 3. Toggle the state when icon is tapped
                  setState(() {
                    _isPasswordObscured = !_isPasswordObscured;
                  });
                },
              ),

              // ... (rest of the screen - no changes)
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Checkbox(
                        value: _rememberMe,
                        onChanged: (bool? newValue) {
                          setState(() {
                            _rememberMe = newValue ?? false;
                          });
                        },
                      ),
                      const Text('Remember me'),
                    ],
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text(
                      'Forgot Password?',
                      style: TextStyle(color: Color(0xFF2B46F9)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  // TODO: Firebase login logic here
                  Navigator.pushReplacementNamed(context, AppRoutes.home);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2B46F9),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Log In', style: TextStyle(fontSize: 16)),
              ),
              const SizedBox(height: 30),
              const Text('Or login with', textAlign: TextAlign.center),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SocialLoginButton(iconPath: 'assets/google.png'),
                  const SizedBox(width: 16),
                  SocialLoginButton(iconPath: 'assets/facebook.png'),
                  const SizedBox(width: 16),
                  SocialLoginButton(iconPath: 'assets/apple.png'),
                  const SizedBox(width: 16),
                  SocialLoginButton(iconPath: 'assets/more.png'),
                ],
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
