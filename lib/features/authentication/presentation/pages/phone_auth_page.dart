import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myfin/features/authentication/presentation/bloc/auth_bloc.dart';

class PhoneAuthPage extends StatefulWidget {
  const PhoneAuthPage({super.key});

  @override
  State<PhoneAuthPage> createState() => _PhoneAuthPageState();
}

class _PhoneAuthPageState extends State<PhoneAuthPage> {
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  String _verificationId = '';
  String _phoneNumber = '';

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Phone Authentication',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          // Listen for code sent state
          if (state is AuthPhoneCodeSent) {
            setState(() {
              _verificationId = state.verificationId;
              _phoneNumber = state.phoneNumber;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Verification code sent!'),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 2),
              ),
            );
          }

          // Listen for authentication success
          if (state is AuthAuthenticatedAsMember ||
              state is AuthAuthenticatedAsAdmin) {
            Navigator.pushReplacementNamed(context, '/home');
          }

          // Listen for errors
          if (state is AuthFailure) {
            showError(context, state.message);
          }
        },
        builder: (context, state) {
          // Show OTP input if code has been sent
          if (state is AuthPhoneCodeSent || _verificationId.isNotEmpty) {
            return _buildOTPScreen(state);
          }

          // Show phone number input by default
          return _buildPhoneInputScreen(state);
        },
      ),
    );
  }

  Widget _buildPhoneInputScreen(AuthState state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 20),
          // Icon
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: const Color(0xFF2B46F9).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.phone_android,
              size: 50,
              color: Color(0xFF2B46F9),
            ),
          ),
          const SizedBox(height: 32),
          // Title
          const Text(
            'Enter Your Phone Number',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          // Subtitle
          Text(
            'We will send you a verification code',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          // Phone number input
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: 'Phone Number',
                hintText: '+60123456789',
                prefixIcon: const Icon(Icons.phone, color: Colors.grey),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Helper text
          Text(
            'Include country code (e.g., +60 for Malaysia)',
            style: TextStyle(fontSize: 12, color: Colors.grey[500]),
          ),
          const SizedBox(height: 32),
          // Send code button
          ElevatedButton(
            onPressed: state is AuthLoading
                ? null
                : () {
                    final phoneNumber = _phoneController.text.trim();

                    if (phoneNumber.isEmpty) {
                      showError(context, 'Please enter your phone number');
                      return;
                    }

                    if (!phoneNumber.startsWith('+')) {
                      showError(
                        context,
                        'Phone number must include country code (e.g., +60)',
                      );
                      return;
                    }

                    // Dispatch event to send verification code
                    context.read<AuthBloc>().add(
                      AuthPhoneVerificationRequested(phoneNumber),
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
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Text(
                    'Send Code',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildOTPScreen(AuthState state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 20),
          // Icon
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: const Color(0xFF2B46F9).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.sms_outlined,
              size: 50,
              color: Color(0xFF2B46F9),
            ),
          ),
          const SizedBox(height: 32),
          // Title
          const Text(
            'Enter Verification Code',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          // Subtitle
          Text(
            'We sent a code to $_phoneNumber',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          // OTP input
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: TextField(
              controller: _otpController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                labelText: 'Verification Code',
                hintText: '123456',
                prefixIcon: const Icon(Icons.lock_outline, color: Colors.grey),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                counterText: '', // Hide character counter
              ),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Verify button
          ElevatedButton(
            onPressed: state is AuthLoading
                ? null
                : () {
                    final otp = _otpController.text.trim();

                    if (otp.isEmpty) {
                      showError(context, 'Please enter the verification code');
                      return;
                    }

                    if (otp.length != 6) {
                      showError(context, 'Verification code must be 6 digits');
                      return;
                    }

                    // Dispatch event to verify OTP
                    context.read<AuthBloc>().add(
                      AuthPhoneOTPVerificationRequested(_verificationId, otp),
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
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Text(
                    'Verify',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
          ),
          const SizedBox(height: 16),
          // Resend code button
          TextButton(
            onPressed: state is AuthLoading
                ? null
                : () {
                    // Resend code
                    context.read<AuthBloc>().add(
                      AuthPhoneVerificationRequested(_phoneNumber),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Code resent!'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
            child: const Text(
              'Resend Code',
              style: TextStyle(
                color: Color(0xFF2B46F9),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Change phone number button
          TextButton(
            onPressed: state is AuthLoading
                ? null
                : () {
                    setState(() {
                      _verificationId = '';
                      _phoneNumber = '';
                      _otpController.clear();
                    });
                  },
            child: Text(
              'Change Phone Number',
              style: TextStyle(
                color: Colors.grey[600],
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
