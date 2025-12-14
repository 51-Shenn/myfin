import 'package:flutter/material.dart';

class AuthSwitcher extends StatelessWidget {
  final bool isLogin;
  final VoidCallback onLoginTap;
  final VoidCallback onSignUpTap;

  const AuthSwitcher({
    super.key,
    required this.isLogin,
    required this.onLoginTap,
    required this.onSignUpTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F6F9), // Light grey background
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(child: _buildButton('Log In', isLogin, onLoginTap)),
          Expanded(child: _buildButton('Sign Up', !isLogin, onSignUpTap)),
        ],
      ),
    );
  }

  Widget _buildButton(String text, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        alignment: Alignment.center,
        child: Text(
          text,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: isActive ? Colors.black : Colors.grey[600],
          ),
        ),
      ),
    );
  }
}
