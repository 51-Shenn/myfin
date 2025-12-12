import 'package:flutter/material.dart';
import 'package:myfin/features/authentication/domain/entities/member.dart'; 
import 'package:myfin/features/profile/presentation/pages/profile_main.dart';
import 'package:myfin/features/profile/presentation/pages/edit_profile.dart'; 
import 'package:myfin/features/profile/presentation/pages/business_profile.dart'; 

class ProfileNav extends StatefulWidget {
  const ProfileNav({super.key});

  @override
  State<ProfileNav> createState() => _ProfileNavState();
}

class _ProfileNavState extends State<ProfileNav> {
  GlobalKey<NavigatorState> profileNavKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: profileNavKey,
      onGenerateRoute: (RouteSettings settings) {
        return MaterialPageRoute(
          settings: settings,
          builder: (BuildContext context) {
            if (settings.name == '/profile_details') {
              final args = settings.arguments as Member?;
              return EditProfileScreen(member: args);
            } 
            
            // --- ADD THIS BLOCK ---
            if (settings.name == '/business_profile') {
              return const BusinessProfileScreen();
            }
            // ----------------------

            // Return the UserProfileScreen
            return const UserProfileScreen(); 
          }
        );
      },
    );
  }
}