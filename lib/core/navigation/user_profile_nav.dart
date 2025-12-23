import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myfin/features/profile/data/datasources/profile_remote_data_source.dart';
import 'package:myfin/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:myfin/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:myfin/features/profile/presentation/bloc/profile_event.dart';
import 'package:myfin/features/profile/presentation/pages/profile_main.dart';
import 'package:myfin/features/authentication/domain/repositories/member_repository.dart';

class ProfileNav extends StatefulWidget {
  const ProfileNav({super.key});

  // Public static getter to access the navigator key
  static GlobalKey<NavigatorState> get navigatorKey =>
      _ProfileNavState.profileNavKey;

  @override
  State<ProfileNav> createState() => _ProfileNavState();
}

class _ProfileNavState extends State<ProfileNav> {
  static final GlobalKey<NavigatorState> profileNavKey =
      GlobalKey<NavigatorState>();

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
          // We only need the default route here now
          // The sub-pages are handled by AppRoutes via rootNavigator
          return MaterialPageRoute(
            settings: settings,
            builder: (BuildContext context) {
              return const UserProfileScreen();
            },
          );
        },
      ),
    );
  }
}
