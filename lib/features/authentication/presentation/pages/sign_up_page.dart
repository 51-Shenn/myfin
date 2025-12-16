import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:myfin/core/utils/ui_helpers.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:myfin/core/validators/auth_validator.dart';
import 'package:myfin/features/authentication/presentation/widgets/custom_text_field.dart';
import 'package:myfin/features/authentication/presentation/bloc/auth_bloc.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
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
  String _completePhoneNumber = ''; // Store full international phone number

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
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthRegisterSuccess) {
          // Show success message
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 3),
              ),
            );
          // Switch to sign-in page (page 0)
          context.read<AuthBloc>().add(const AuthPageChanged(0));
        } else if (state is AuthRegisterFailure) {
          // Show error message
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 3),
              ),
            );
        }
      },
      child: BlocBuilder<AuthBloc, AuthState>(
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
                readOnly: true,
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(1900),
                    lastDate: DateTime.now(),
                  );
                  if (pickedDate != null) {
                    _dobController.text = DateFormat(
                      'dd-MM-yyyy',
                    ).format(pickedDate);
                  }
                },
                suffixIcon: const Icon(
                  Icons.calendar_today_outlined,
                  color: Colors.grey,
                  size: 20,
                ),
              ),
              const SizedBox(height: 16),
              // Phone Number with Country Code Picker
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
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: IntlPhoneField(
                      controller: _phoneController,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        hintText: '',
                        counterText: '', // Remove counter text
                      ),
                      initialCountryCode: 'MY', // Malaysia default
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                      dropdownIconPosition: IconPosition.trailing,
                      dropdownTextStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                      flagsButtonPadding: const EdgeInsets.only(left: 8),
                      disableLengthCheck:
                          true, // Disable length validation counter
                      onChanged: (phone) {
                        _completePhoneNumber = phone.completeNumber;
                      },
                    ),
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
                        final firstNameError = AuthValidator.validateRequired(
                          _firstNameController.text,
                          "First name",
                        );
                        final lastNameError = AuthValidator.validateRequired(
                          _lastNameController.text,
                          "Last name",
                        );
                        final dateOfBirthError = AuthValidator.validateRequired(
                          _dobController.text,
                          "Date of birth",
                        );

                        final phoneNumError = AuthValidator.validatePhone(
                          _completePhoneNumber,
                        );
                        final addressError = AuthValidator.validateRequired(
                          _addressController.text,
                          "Address",
                        );
                        final emailError = AuthValidator.validateEmail(
                          _emailController.text,
                        );
                        final passwordError = AuthValidator.validatePassword(
                          _passwordController.text,
                        );
                        final confirmPasswordError =
                            AuthValidator.validateConfirmPassword(
                              _passwordController.text,
                              _confirmPasswordController.text,
                            );

                        if (firstNameError != null) {
                          UiHelpers.showError(context, firstNameError);
                          return;
                        }

                        if (lastNameError != null) {
                          UiHelpers.showError(context, lastNameError);
                          return;
                        }

                        if (emailError != null) {
                          UiHelpers.showError(context, emailError);
                          return;
                        }

                        if (dateOfBirthError != null) {
                          UiHelpers.showError(context, dateOfBirthError);
                          return;
                        }

                        if (phoneNumError != null) {
                          UiHelpers.showError(context, phoneNumError);
                          return;
                        }

                        if (addressError != null) {
                          UiHelpers.showError(context, addressError);
                          return;
                        }

                        if (passwordError != null) {
                          UiHelpers.showError(context, passwordError);
                          return;
                        }

                        if (confirmPasswordError != null) {
                          UiHelpers.showError(context, confirmPasswordError);
                          return;
                        }

                        // ✅ All validation passed → dispatch Bloc event
                        context.read<AuthBloc>().add(
                          AuthRegisterMemberRequested(
                            "${_firstNameController.text} ${_lastNameController.text}",
                            _firstNameController.text,
                            _lastNameController.text,
                            _emailController.text,
                            _passwordController.text,
                            _completePhoneNumber.isNotEmpty
                                ? _completePhoneNumber
                                : _phoneController.text,
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
      ),
    );
  }
}
