import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myfin/features/authentication/domain/entities/member.dart';
import 'package:myfin/features/profile/domain/entities/business_profile.dart';
import 'package:myfin/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:myfin/features/profile/presentation/pages/profile_main.dart';
import 'package:myfin/features/profile/presentation/pages/edit_profile.dart';
import 'package:myfin/features/profile/presentation/pages/business_profile.dart';
import 'package:myfin/features/profile/presentation/pages/edit_business_profile.dart';
import 'package:myfin/features/profile/presentation/pages/change_password.dart';
import 'package:myfin/features/admin/presentation/pages/user_management_screen.dart';

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
            // Edit User Profile
            if (settings.name == '/profile_details') {
              final args = settings.arguments as Member?;
              return EditProfileScreen(member: args);
            }

            if (settings.name == '/business_profile') {
              return const BusinessProfileScreen();
            }

            if (settings.name == '/edit_business_profile') {
              // Extract arguments map
              final args = settings.arguments as Map<String, dynamic>;
              return BlocProvider.value(
                value: args['bloc'] as ProfileBloc,
                child: EditBusinessProfileScreen(
                  existingProfile: args['profile'] as BusinessProfile?,
                  memberId: args['memberId'] as String,
                ),
              );
            }

            if (settings.name == '/change_password') {
              // We need to pass the existing ProfileBloc to the new screen
              final bloc = settings.arguments as ProfileBloc;
              return BlocProvider.value(
                value: bloc,
                child: const ChangePasswordScreen(),
              );
            }
            
            return const UserProfileScreen();
          },
        );
      },
    );
  }
}
