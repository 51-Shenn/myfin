import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myfin/features/authentication/domain/entities/member.dart';
import 'package:myfin/features/profile/data/datasources/profile_remote_data_source.dart';
import 'package:myfin/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:myfin/features/profile/domain/entities/business_profile.dart';
import 'package:myfin/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:myfin/features/profile/presentation/bloc/profile_event.dart';
import 'package:myfin/features/profile/presentation/pages/profile_main.dart';
import 'package:myfin/features/profile/presentation/pages/edit_profile.dart';
import 'package:myfin/features/profile/presentation/pages/business_profile.dart';
import 'package:myfin/features/profile/presentation/pages/edit_business_profile.dart';
import 'package:myfin/features/profile/presentation/pages/change_password.dart';
import 'package:myfin/features/authentication/domain/repositories/member_repository.dart';

class ProfileNav extends StatefulWidget {
  const ProfileNav({super.key});

  @override
  State<ProfileNav> createState() => _ProfileNavState();
}

class _ProfileNavState extends State<ProfileNav> {
  GlobalKey<NavigatorState> profileNavKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    // 1. Get the current User ID directly from Firebase Auth
    // This is safer than relying on Bloc state which might be in "Loading" state
    final user = FirebaseAuth.instance.currentUser;
    final String memberId = user?.uid ?? "";

    // 2. Initialize Bloc
    return BlocProvider(
      create: (_) {
        final profileRepo = ProfileRepositoryImpl(
          remoteDataSource: ProfileRemoteDataSourceImpl(),
        );

        final memberRepo = context.read<MemberRepository>();

        final bloc = ProfileBloc(
          profileRepo: profileRepo,
          memberRepo: memberRepo, // Injecting it here
        );

        if (memberId.isNotEmpty) {
          bloc.add(LoadProfileEvent(memberId));
        }

        return bloc;
      },
      child: Navigator(
        key: profileNavKey,
        onGenerateRoute: (RouteSettings settings) {
          return MaterialPageRoute(
            settings: settings,
            builder: (BuildContext context) {
              // --- Edit User Profile ---
              if (settings.name == '/profile_details') {
                // Get the current state to pass the image bytes
                final profileState = context.read<ProfileBloc>().state;

                // We create a map or a custom argument class to pass both member and image
                final args = {
                  'member': settings.arguments as Member?,
                  'imageBytes': profileState.profileImageBytes,
                };

                return EditProfileScreen(
                  arguments: args,
                ); // Updated Constructor usage
              }

              // --- View Business Profile ---
              if (settings.name == '/business_profile') {
                return const BusinessProfileScreen();
              }

              // --- Edit Business Profile ---
              if (settings.name == '/edit_business_profile') {
                final args = settings.arguments as Map<String, dynamic>;
                return EditBusinessProfileScreen(
                  existingProfile: args['profile'] as BusinessProfile?,
                  memberId: args['memberId'] as String,
                );
              }

              // --- Change Password ---
              if (settings.name == '/change_password') {
                return const ChangePasswordScreen();
              }

              // --- Main Profile Screen ---
              return const UserProfileScreen();
            },
          );
        },
      ),
    );
  }
}
