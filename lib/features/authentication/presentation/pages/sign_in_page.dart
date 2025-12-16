import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myfin/features/authentication/presentation/widgets/custom_text_field.dart';
import 'package:myfin/features/authentication/presentation/widgets/social_login_button.dart';
import 'package:myfin/features/authentication/presentation/bloc/auth_bloc.dart';
import 'package:myfin/core/navigation/app_routes.dart';
import 'package:myfin/core/validators/auth_validator.dart';

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
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
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
                        showError(context, emailError);
                        return;
                      }

                      final passwordError = AuthValidator.validateRequired(
                        _passwordController.text.trim(),
                        "Password",
                      );

                      if (passwordError != null) {
                        showError(context, passwordError);
                        return;
                      }

                      // All validation passed → dispatch login event
                      context.read<AuthBloc>().add(
                        AuthLoginRequested(
                          _emailController.text.trim(),
                          _passwordController.text.trim(),
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Google Sign-In
                SocialLoginButton(
                  iconPath: 'assets/google.png',
                  onTap: state is AuthLoading
                      ? null
                      : () {
                          context.read<AuthBloc>().add(
                            AuthGoogleSignInRequested(),
                          );
                        },
                ),
                // Facebook Login
                SocialLoginButton(
                  iconPath: 'assets/facebook.png',
                  onTap: state is AuthLoading
                      ? null
                      : () {
                          context.read<AuthBloc>().add(
                            AuthFacebookSignInRequested(),
                          );
                        },
                ),
                // Apple Sign-In
                SocialLoginButton(
                  iconPath: 'assets/apple.png',
                  onTap: state is AuthLoading
                      ? null
                      : () {
                          context.read<AuthBloc>().add(
                            AuthAppleSignInRequested(),
                          );
                        },
                ),
                // More options (Phone Auth)
                SocialLoginButton(
                  iconPath: 'assets/more.png',
                  onTap: state is AuthLoading
                      ? null
                      : () {
                          Navigator.pushNamed(
                            context,
                            AppRoutes.phoneAuth,
                            arguments: context.read<AuthBloc>(),
                          );
                        },
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
