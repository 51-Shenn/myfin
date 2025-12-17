import 'package:flutter/material.dart';

class CustomDivider extends StatelessWidget {
  const CustomDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Divider(
      color: Colors.grey[300],
      height: 40,
      thickness: 1,
      indent: 5,
      endIndent: 5,
    );
  }
}