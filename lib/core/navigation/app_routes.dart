import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hive/hive.dart';
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
import 'package:myfin/features/upload/presentation/pages/doc_details.dart';
import 'package:myfin/features/upload/presentation/pages/upload_history.dart';
import 'package:myfin/features/report/presentation/pages/report_history.dart';
import 'package:myfin/features/profile/presentation/pages/business_profile.dart';
import 'package:myfin/features/profile/presentation/pages/edit_profile.dart';
import 'package:myfin/features/profile/presentation/pages/change_password.dart';
import 'package:myfin/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:myfin/features/profile/presentation/pages/change_email_screen.dart';
import 'package:myfin/features/profile/presentation/pages/edit_business_profile.dart';
import 'package:myfin/features/profile/domain/entities/business_profile.dart';
import 'package:myfin/features/dashboard/data/datasources/dashboard_remote_data_source.dart';
import 'package:myfin/features/dashboard/data/datasources/dashboard_local_data_source.dart';
import 'package:myfin/features/dashboard/data/repositories/dashboard_repository_impl.dart';
import 'package:myfin/features/dashboard/domain/usecases/get_cash_flow_dashboard_data.dart';
import 'package:myfin/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:myfin/features/dashboard/domain/usecases/generate_cash_flow_snapshots.dart';
import 'package:myfin/features/dashboard/domain/usecases/subscribe_to_dashboard.dart';
import 'package:myfin/features/upload/data/datasources/firestore_doc_line_data_source.dart';
import 'package:myfin/features/upload/data/datasources/firestore_document_data_source.dart';
import 'package:myfin/features/upload/data/repositories/doc_line_item_repository_impl.dart';
import 'package:myfin/features/upload/data/repositories/document_repository_impl.dart';

class AppRoutes {
  static const String auth = '/auth';
  static const String home = '/home';
  static const String adminHome = '/admin-home';
  static const String forgetPassword = '/forget-password';
  static const String docDetails = '/doc_details';
  static const String uploadHistory = '/upload_history';
  static const String reportHistory = '/report_history';
  static const String businessProfile = '/business_profile';
  static const String profileDetails = '/profile_details';
  static const String changePassword = '/change_password';
  static const String adminDashboard = '/admin_dashboard';
  static const String editBusinessProfile = '/edit_business_profile';
  static const String changeEmail = '/change_email';

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

  static DashboardBloc createDashboardBloc() {
    final firestore = FirebaseFirestore.instance;
    final remoteDataSource = DashboardRemoteDataSourceImpl(
      firestore: firestore,
    );

    // Create local data source for caching
    final localDataSource = DashboardLocalDataSourceImpl(
      box: Hive.box('dashboard_cache'),
    );

    final repository = DashboardRepositoryImpl(
      remoteDataSource: remoteDataSource,
      localDataSource: localDataSource,
    );
    final getDashboardData = GetCashFlowDashboardData(repository);

    final documentDataSource = FirestoreDocumentDataSource(
      firestore: firestore,
    );
    final lineItemDataSource = FirestoreDocumentLineItemDataSource(
      firestore: firestore,
    );
    final documentRepository = DocumentRepositoryImpl(
      documentDataSource,
      lineItemDataSource,
    );

    final lineItemRepository = DocumentLineItemRepositoryImpl(
      lineItemDataSource,
    );

    final generateSnapshots = GenerateCashFlowSnapshots(
      dashboardRepository: repository,
      documentRepository: documentRepository,
      docLineItemRepository: lineItemRepository,
      localDataSource: localDataSource,
    );
    final subscribeToDashboard = SubscribeToDashboard(repository);

    return DashboardBloc(
      getDashboardData: getDashboardData,
      generateSnapshots: generateSnapshots,
      subscribeToDashboard: subscribeToDashboard,
      localDataSource: localDataSource,
    );
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
      case docDetails:
        final args = settings.arguments as DocDetailsArguments?;
        return MaterialPageRoute(
          builder: (_) => DocumentDetailsScreen(
            existingDocument: args?.existingDocument,
            existingLineItems: args?.existingLineItems,
            documentId: args?.documentId,
          ),
        );
      case uploadHistory:
        return MaterialPageRoute(builder: (_) => const UploadHistoryScreen());
      case reportHistory:
        return MaterialPageRoute(builder: (_) => const ReportHistoryScreen());
      case businessProfile:
        // Expecting ProfileBloc passed in arguments
        final bloc = settings.arguments as ProfileBloc;
        return MaterialPageRoute(
          builder: (_) => BlocProvider.value(
            value: bloc,
            child: const BusinessProfileScreen(),
          ),
        );
      case profileDetails:
        // Expecting a Map with 'bloc' and 'args'
        final args = settings.arguments as Map<String, dynamic>;
        final bloc = args['bloc'] as ProfileBloc;
        return MaterialPageRoute(
          builder: (_) => BlocProvider.value(
            value: bloc,
            child: EditProfileScreen(arguments: args),
          ),
        );
      case editBusinessProfile:
        final args = settings.arguments as Map<String, dynamic>;
        final bloc = args['bloc'] as ProfileBloc;
        return MaterialPageRoute(
          builder: (_) => BlocProvider.value(
            value: bloc,
            child: EditBusinessProfileScreen(
              existingProfile: args['profile'] as BusinessProfile?,
              memberId: args['memberId'] as String,
            ),
          ),
        );
      case changePassword:
        final bloc = settings.arguments as ProfileBloc;
        return MaterialPageRoute(
          builder: (_) => BlocProvider.value(
            value: bloc,
            child: const ChangePasswordScreen(),
          ),
        );
      case changeEmail:
        final bloc = settings.arguments as ProfileBloc;
        return MaterialPageRoute(
          builder: (_) => BlocProvider.value(
            value: bloc,
            child: const ChangeEmailScreen(),
          ),
        );
      case adminDashboard:
        return MaterialPageRoute(builder: (_) => const AdminMainScreen());
      default:
        return MaterialPageRoute(builder: (_) => const BottomNavBar());
    }
  }
}
