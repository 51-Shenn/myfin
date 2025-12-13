import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myfin/core/components/custom_text_field.dart';
import 'package:myfin/features/authentication/presentation/bloc/auth_bloc.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  // Assuming Member registration for now.
  // Add controllers
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _dobController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isPasswordObscured = true;
  bool _isConfirmPasswordObscured = true;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _dobController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    labelText: 'First Name',
                    controller: _firstNameController,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: CustomTextField(
                    labelText: 'Last Name',
                    controller: _lastNameController,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            CustomTextField(labelText: 'Email', controller: _emailController),
            const SizedBox(height: 16),
            CustomTextField(
              labelText: 'Birth of date',
              controller: _dobController,
              suffixIcon: const Icon(
                Icons.calendar_today_outlined,
                color: Colors.grey,
                size: 20,
              ),
            ),
            const SizedBox(height: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Phone Number',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      height: 50, // Match TextField height roughly
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.white,
                      ),
                      child: Row(
                        children: [
                          Image.asset('assets/flag.png', width: 25),
                          const Icon(
                            Icons.keyboard_arrow_down,
                            color: Colors.grey,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: TextField(
                          controller: _phoneController,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                          ),
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            CustomTextField(
              labelText: 'Address',
              controller: _addressController,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              labelText: 'Set Password',
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
            CustomTextField(
              labelText: 'Confirm Password',
              controller: _confirmPasswordController,
              obscureText: _isConfirmPasswordObscured,
              suffixIcon: GestureDetector(
                onTap: () {
                  setState(() {
                    _isConfirmPasswordObscured = !_isConfirmPasswordObscured;
                  });
                },
                child: Icon(
                  _isConfirmPasswordObscured
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: Colors.grey,
                ),
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: state is AuthLoading
                  ? null
                  : () {
                      if (_passwordController.text !=
                          _confirmPasswordController.text) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Passwords do not match"),
                          ),
                        );
                        return;
                      }
                      // Dispatch Register Event
                      context.read<AuthBloc>().add(
                        AuthRegisterMemberRequested(
                          "${_firstNameController.text} ${_lastNameController.text}", // Username suggestion
                          _firstNameController.text,
                          _lastNameController.text,
                          _emailController.text,
                          _passwordController.text,
                          _phoneController.text,
                          _addressController.text,
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
              child: state is AuthLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      'Register',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ],
        );
      },
    );
  }
}
