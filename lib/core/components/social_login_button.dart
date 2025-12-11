import 'package:flutter/material.dart';

class SocialLoginButton extends StatelessWidget {
  final String iconPath;
  const SocialLoginButton({super.key, required this.iconPath});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 1,
            blurRadius: 5,
          )
        ],
      ),
      child: Image.asset(iconPath, height: 24, width: 24),
    );
  }
}