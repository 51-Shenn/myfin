import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myfin/features/authentication/presentation/widgets/custom_text_field.dart';
import 'package:myfin/features/authentication/presentation/widgets/social_login_button.dart';
import 'package:myfin/features/authentication/presentation/bloc/auth_bloc.dart';
import 'package:myfin/core/navigation/app_routes.dart';
import 'package:myfin/core/validators/auth_validator.dart';
import 'package:myfin/core/utils/ui_helpers.dart';

// For generate data
import 'package:myfin/core/services/data_seeder.dart';
//

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isPasswordObscured = true;
  bool _rememberMe = false;

  @override
  void initState() {
    super.initState();
    // Use post-frame callback to ensure BlocConsumer listener is ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthBloc>().add(AuthCheckSavedEmailRequested());
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        // Auto-fill email if savedEmail exists in state
        if (state is AuthUnauthenticated && state.savedEmail != null) {
          if (state.savedEmail!.isNotEmpty) {
            // Use post-frame callback to avoid setState during build
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (_emailController.text != state.savedEmail) {
                _emailController.text = state.savedEmail!;
                if (mounted) {
                  setState(() {
                    _rememberMe = true;
                  });
                }
              }
            });
          }
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CustomTextField(labelText: 'Email', controller: _emailController),
            const SizedBox(height: 16),
            CustomTextField(
              labelText: 'Password',
              controller: _passwordController,
              obscureText: _isPasswordObscured,
              suffixIcon: GestureDetector(
                onTap: () {
                  setState(() {
                    _isPasswordObscured = !_isPasswordObscured;
                  });
                },
                child: Icon(
                  _isPasswordObscured
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: Colors.grey,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    SizedBox(
                      height: 24,
                      width: 24,
                      child: Checkbox(
                        value: _rememberMe,
                        onChanged: (value) {
                          setState(() {
                            _rememberMe = value ?? false;
                          });
                        },
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                        side: const BorderSide(color: Colors.grey),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Remember me',
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () => Navigator.pushNamed(
                    context,
                    AppRoutes.forgetPassword,
                    arguments: context.read<AuthBloc>(),
                  ),
                  child: const Text(
                    'Forgot Password ?',
                    style: TextStyle(
                      color: Color(0xFF2B46F9),
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: state is AuthLoading
                  ? null
                  : () {
                      final emailError = AuthValidator.validateEmail(
                        _emailController.text.trim(),
                      );

                      if (emailError != null) {
                        UiHelpers.showError(context, emailError);
                        return;
                      }

                      final passwordError = AuthValidator.validateRequired(
                        _passwordController.text.trim(),
                        "Password",
                      );

                      if (passwordError != null) {
                        UiHelpers.showError(context, passwordError);
                        return;
                      }

                      // All validation passed → dispatch login event
                      context.read<AuthBloc>().add(
                        AuthLoginRequested(
                          _emailController.text.trim(),
                          _passwordController.text.trim(),
                          rememberMe: _rememberMe,
                        ),
                      );
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2B46F9),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Log In',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(child: Divider(color: Colors.grey[300])),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Or login with',
                    style: TextStyle(color: Colors.grey[500], fontSize: 14),
                  ),
                ),
                Expanded(child: Divider(color: Colors.grey[300])),
              ],
            ),
            const SizedBox(height: 24),
            Center(
              child: SocialLoginButton(
                iconPath: 'assets/google.png',
                onTap: state is AuthLoading
                    ? null
                    : () {
                        context.read<AuthBloc>().add(
                          AuthGoogleSignInRequested(),
                        );
                      },
              ),
            ),
          ],
        );
      },
    );
  }
}
