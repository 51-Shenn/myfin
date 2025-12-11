// lib/navigation/app_routes.dart

import 'package:flutter/material.dart';
import 'package:myfin/screens/Authentication/signin_screen.dart';
import 'package:myfin/screens/Authentication/signup_screen.dart';
import 'package:myfin/components/bottom_nav_bar.dart';

class AppRoutes {
  // Route names
  static const String signin = '/signin';
  static const String signup = '/signup';
  static const String home = '/home';

  // Route generator
  static Map<String, WidgetBuilder> get routes {
    return {
      signin: (context) => const SignInScreen(),
      signup: (context) => const SignUpScreen(),
      home: (context) => const BottomNavBar(),
    };
  }
}