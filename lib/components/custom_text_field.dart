import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final String labelText;
  final bool isDateField;
  final bool isPhoneField;
  final TextEditingController? controller;
  final VoidCallback? onSuffixIconTap;
  final String? initialValue;
  
  // --- CHANGE 1: Make obscureText nullable ---
  final bool? obscureText;

  const CustomTextField({
    super.key,
    required this.labelText,
    this.isDateField = false,
    this.isPhoneField = false,
    this.controller,
    this.onSuffixIconTap,
    this.initialValue,
    this.obscureText, // It no longer has a default value
  });

  @override
  Widget build(BuildContext context) {
    assert(initialValue == null || controller == null);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          labelText,
          style: const TextStyle(color: Colors.black54, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          initialValue: initialValue,
          // --- CHANGE 2: Handle the nullable value ---
          // If obscureText is null, it's not a password field, so default to false.
          obscureText: obscureText ?? false,
          readOnly: isDateField,
          onTap: isDateField ? onSuffixIconTap : null,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey[100],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            suffixIcon: _buildSuffixIcon(),
            prefixIcon: isPhoneField ? _buildPhonePrefix() : null,
          ),
        ),
      ],
    );
  }

  Widget? _buildSuffixIcon() {
    // --- CHANGE 3: The Logic is now correct ---
    // This 'if' block will ONLY run for password fields where obscureText is passed.
    if (obscureText != null) {
      return IconButton(
        icon: Icon(
          // Use the non-null assertion '!' since we've checked it's not null.
          obscureText! ? Icons.visibility_off_outlined : Icons.visibility_outlined,
          color: Colors.grey,
        ),
        onPressed: onSuffixIconTap,
      );
    }
    // This 'if' block will run for the date field and is now correctly separated.
    if (isDateField) {
      return IconButton(
        icon: const Icon(Icons.calendar_today_outlined, color: Colors.grey),
        onPressed: onSuffixIconTap,
      );
    }
    return null; // No icon for other fields
  }

  // Helper to build the phone prefix (no changes here)
  Widget _buildPhonePrefix() {
    // ... code for this function is unchanged
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(width: 10),
        Image.asset('assets/flag.png', width: 24),
        const SizedBox(width: 8),
        const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
        const SizedBox(width: 8),
        Container(height: 24, width: 1, color: Colors.grey[300]),
        const SizedBox(width: 8),
      ],
    );
  }
}