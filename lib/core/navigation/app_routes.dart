import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:myfin/core/components/bottom_nav_bar.dart';
import 'package:myfin/features/authentication/data/datasources/admin_remote_data_source.dart';
import 'package:myfin/features/authentication/data/datasources/auth_local_data_source.dart';
import 'package:myfin/features/authentication/data/datasources/auth_remote_data_source.dart';
import 'package:myfin/features/authentication/data/datasources/member_remote_data_source.dart';
import 'package:myfin/features/authentication/data/repositories/admin_repository_impl.dart';
import 'package:myfin/features/authentication/data/repositories/auth_repository_impl.dart';
import 'package:myfin/features/authentication/data/repositories/member_repository_impl.dart';
import 'package:myfin/features/authentication/domain/usecases/get_current_user_usecase.dart';
import 'package:myfin/features/authentication/domain/usecases/get_saved_email_usecase.dart';
import 'package:myfin/features/authentication/domain/usecases/reset_password_usecase.dart';
import 'package:myfin/features/authentication/domain/usecases/save_email_usecase.dart';
import 'package:myfin/features/authentication/domain/usecases/sign_in_usecase.dart';
import 'package:myfin/features/authentication/domain/usecases/sign_in_with_google_usecase.dart';
import 'package:myfin/features/authentication/domain/usecases/sign_out_usecase.dart';
import 'package:myfin/features/authentication/domain/usecases/sign_up_usecase.dart';
import 'package:myfin/features/authentication/presentation/bloc/auth_bloc.dart';
import 'package:myfin/features/authentication/presentation/pages/auth_main.dart';
import 'package:myfin/features/authentication/presentation/pages/forget_password_page.dart';
import 'package:myfin/features/admin/presentation/pages/admin_main.dart';

class AppRoutes {
  static const String auth = '/auth';
  static const String home = '/home';
  static const String adminHome = '/admin-home';
  static const String forgetPassword = '/forget-password';

  static AuthBloc createAuthBloc(SharedPreferences sharedPreferences) {
    final firebaseAuth = FirebaseAuth.instance;
    final firestore = FirebaseFirestore.instance;
    final googleSignIn = GoogleSignIn();

    final authRemote = AuthRemoteDataSourceImpl(
      firebaseAuth: firebaseAuth,
      googleSignIn: googleSignIn,
    );
    final authLocal = AuthLocalDataSourceImpl(
      sharedPreferences: sharedPreferences,
    );
    final memberRemote = MemberRemoteDataSourceImpl(firestore: firestore);
    final adminRemote = AdminRemoteDataSourceImpl(firestore: firestore);

    final authRepo = AuthRepositoryImpl(authRemote, authLocal);
    final memberRepo = MemberRepositoryImpl(memberRemote);
    final adminRepo = AdminRepositoryImpl(adminRemote);

    final signInUseCase = SignInUseCase(
      authRepository: authRepo,
      memberRepository: memberRepo,
      adminRepository: adminRepo,
    );
    final signUpUseCase = SignUpUseCase(
      authRepository: authRepo,
      memberRepository: memberRepo,
      adminRepository: adminRepo,
    );
    final getCurrentUserUseCase = GetCurrentUserUseCase(
      authRepository: authRepo,
      memberRepository: memberRepo,
      adminRepository: adminRepo,
    );
    final signOutUseCase = SignOutUseCase(authRepository: authRepo);
    final resetPasswordUseCase = ResetPasswordUseCase(authRepository: authRepo);
    final signInWithGoogleUseCase = SignInWithGoogleUseCase(
      authRepository: authRepo,
      memberRepository: memberRepo,
      adminRepository: adminRepo,
    );
    final saveEmailUseCase = SaveEmailUseCase(authRepository: authRepo);
    final getSavedEmailUseCase = GetSavedEmailUseCase(authRepository: authRepo);

    return AuthBloc(
      signIn: signInUseCase,
      signUp: signUpUseCase,
      getCurrentUser: getCurrentUserUseCase,
      signOut: signOutUseCase,
      resetPassword: resetPasswordUseCase,
      signInWithGoogle: signInWithGoogleUseCase,
      saveEmail: saveEmailUseCase,
      getSavedEmail: getSavedEmailUseCase,
    )..add(AuthCheckRequested());
  }

  static Route<dynamic> onGenerateRoute(
    RouteSettings settings,
    SharedPreferences sharedPreferences,
  ) {
    switch (settings.name) {
      case auth:
        return MaterialPageRoute(builder: (_) => const AuthMainPage());
      case home:
        return MaterialPageRoute(builder: (_) => const BottomNavBar());
      case forgetPassword:
        final authBloc = settings.arguments as AuthBloc;
        return MaterialPageRoute(
          builder: (_) => BlocProvider.value(
            value: authBloc,
            child: const ForgetPasswordPage(),
          ),
        );
      case adminHome:
        return MaterialPageRoute(builder: (_) => const AdminMainScreen());

      default:
        return MaterialPageRoute(
          builder: (_) =>
              const Scaffold(body: Center(child: Text('Page not found'))),
        );
    }
  }
}
