import 'package:flutter/material.dart';
import 'package:myfin/navigation/app_routes.dart';

class AuthSwitcher extends StatelessWidget {
  final bool isLogin;

  const AuthSwitcher({super.key, required this.isLogin});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(25.0),
      ),
      child: Row(
        children: [
          _buildSwitcherItem(context, 'Log In', AppRoutes.signin, isLogin),
          _buildSwitcherItem(context, 'Sign Up', AppRoutes.signup, !isLogin),
        ],
      ),
    );
  }

  Widget _buildSwitcherItem(BuildContext context, String title, String routeName, bool isSelected) {
    return Expanded(
      child: GestureDetector(
        // Navigate only if the item is not already selected
        onTap: isSelected ? null : () => Navigator.pushReplacementNamed(context, routeName),
        child: Container(
          alignment: Alignment.center,
          decoration: isSelected
              ? BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 10,
                    )
                  ],
                )
              : null,
          child: Text(
            title,
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? Colors.black : Colors.grey[600],
            ),
          ),
        ),
      ),
    );
  }
}