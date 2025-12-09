import 'package:flutter/material.dart';
import 'package:myfin/screens/user_profile.dart'; // Import this

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
            // routes for profile navigation
            if (settings.name == '/profile_details') {
              return Container(); // Placeholder for edit profile screen
            } 

            // Return the new UserProfileScreen
            return const UserProfileScreen(); 
          }
        );
      },
    );
  }
}