import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myfin/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:myfin/features/profile/presentation/bloc/profile_event.dart';
import 'package:myfin/features/profile/presentation/bloc/profile_state.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  @override
  Widget build(BuildContext context) {
    // We use BlocConsumer to Listen (side effects) and Build (UI changes)
    return BlocConsumer<ProfileBloc, ProfileState>(
      listener: (context, state) {
        if (state.passwordStatus == FormStatus.submissionFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.error ?? "Update failed"),
              backgroundColor: Colors.red,
            ),
          );
        } else if (state.passwordStatus == FormStatus.submissionSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Password updated successfully'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context); // Go back on success
        }
      },
      builder: (context, state) {
        final isSubmitting = state.passwordStatus == FormStatus.submissionInProgress;

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
            centerTitle: true,
            title: const Text(
              'Change Password',
              style: TextStyle(color: Colors.black, fontSize: 24, fontWeight: FontWeight.bold, fontFamily: 'Inter'),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Create a new password for your account.',
                  style: TextStyle(color: Colors.grey, fontSize: 14, fontFamily: 'Inter'),
                ),
                const SizedBox(height: 30),
                _buildPasswordField(
                  controller: _currentPasswordController,
                  label: 'Current Password',
                  obscureText: _obscureCurrent,
                  onToggleVisibility: () => setState(() => _obscureCurrent = !_obscureCurrent),
                ),
                const SizedBox(height: 20),
                _buildPasswordField(
                  controller: _newPasswordController,
                  label: 'New Password',
                  obscureText: _obscureNew,
                  onToggleVisibility: () => setState(() => _obscureNew = !_obscureNew),
                ),
                const SizedBox(height: 20),
                _buildPasswordField(
                  controller: _confirmPasswordController,
                  label: 'Confirm New Password',
                  obscureText: _obscureConfirm,
                  onToggleVisibility: () => setState(() => _obscureConfirm = !_obscureConfirm),
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: isSubmitting
                        ? null // Disable button while loading
                        : () {
                            // Validation Logic UI Side
                            if (_newPasswordController.text != _confirmPasswordController.text) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Passwords do not match')),
                              );
                              return;
                            }
                            if (_currentPasswordController.text.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Enter current password')),
                              );
                              return;
                            }

                            // Trigger BLoC Event
                            context.read<ProfileBloc>().add(
                                  ChangePasswordEvent(
                                    currentPassword: _currentPasswordController.text,
                                    newPassword: _newPasswordController.text,
                                  ),
                                );
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2B46F9),
                      foregroundColor: Colors.white,
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: isSubmitting
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'Update Password',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, fontFamily: 'Inter'),
                          ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // _buildPasswordField helper remains the same as previous response
  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required bool obscureText,
    required VoidCallback onToggleVisibility,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black87, fontFamily: 'Inter'),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: obscureText,
          style: const TextStyle(fontFamily: 'Inter', fontSize: 15, color: Colors.black),
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF2B46F9), width: 1.5)),
            filled: true,
            fillColor: Colors.white,
            suffixIcon: IconButton(
              icon: Icon(obscureText ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: Colors.grey),
              onPressed: onToggleVisibility,
            ),
          ),
        ),
      ],
    );
  }
}