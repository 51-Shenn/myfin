import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:myfin/core/components/bottom_nav_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:myfin/core/navigation/app_routes.dart';
import 'package:myfin/features/authentication/data/datasources/admin_remote_data_source.dart';
import 'package:myfin/features/authentication/data/datasources/auth_local_data_source.dart'; // Added
import 'package:myfin/features/authentication/data/datasources/auth_remote_data_source.dart';
import 'package:myfin/features/authentication/data/datasources/member_remote_data_source.dart';
import 'package:myfin/features/authentication/data/repositories/admin_repository_impl.dart';
import 'package:myfin/features/authentication/data/repositories/auth_repository_impl.dart';
import 'package:myfin/features/authentication/data/repositories/member_repository_impl.dart';
import 'package:myfin/features/authentication/domain/repositories/auth_repository.dart';
import 'package:myfin/features/authentication/domain/usecases/get_current_user_usecase.dart';
import 'package:myfin/features/authentication/domain/usecases/get_saved_email_usecase.dart'; // Added
import 'package:myfin/features/authentication/domain/usecases/reset_password_usecase.dart';
import 'package:myfin/features/authentication/domain/usecases/save_email_usecase.dart'; // Added
import 'package:myfin/features/authentication/domain/usecases/sign_in_usecase.dart';
import 'package:myfin/features/authentication/domain/usecases/sign_in_with_google_usecase.dart'; // Added
import 'package:myfin/features/authentication/domain/usecases/sign_out_usecase.dart';
import 'package:myfin/features/authentication/domain/usecases/sign_up_usecase.dart';
import 'package:myfin/features/authentication/presentation/bloc/auth_bloc.dart';
import 'package:myfin/features/upload/data/datasources/firestore_doc_line_data_source.dart';
import 'package:myfin/features/upload/data/datasources/firestore_document_data_source.dart';
import 'package:myfin/features/upload/data/repositories/doc_line_item_repository_impl.dart';
import 'package:myfin/features/upload/data/repositories/document_repository_impl.dart';
import 'package:myfin/features/upload/domain/repositories/doc_line_item_repository.dart';
import 'package:myfin/features/upload/domain/repositories/document_repository.dart';
import 'package:myfin/firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final firestore = FirebaseFirestore.instance;
  final firebaseAuth = FirebaseAuth.instance;
  final sharedPreferences = await SharedPreferences.getInstance(); // Ensure this is awaited

  // --- 1. Initialize Auth Dependencies ---
  final authRemote = AuthRemoteDataSourceImpl(firebaseAuth: firebaseAuth);
  final authLocal = AuthLocalDataSourceImpl(sharedPreferences: sharedPreferences); // NEW
  final memberRemote = MemberRemoteDataSourceImpl(firestore: firestore);
  final adminRemote = AdminRemoteDataSourceImpl(firestore: firestore);

  // FIXED: Passed both remote and local data sources
  final authRepo = AuthRepositoryImpl(authRemote, authLocal); 
  final memberRepo = MemberRepositoryImpl(memberRemote);
  final adminRepo = AdminRepositoryImpl(adminRemote);

  final signInUseCase = SignInUseCase(
    authRepository: authRepo,
    adminRepository: adminRepo,
    memberRepository: memberRepo,
  );
  final signUpUseCase = SignUpUseCase(
    authRepository: authRepo,
    adminRepository: adminRepo,
    memberRepository: memberRepo,
  );
  final getCurrentUserUseCase = GetCurrentUserUseCase(
    authRepository: authRepo,
    adminRepository: adminRepo,
    memberRepository: memberRepo,
  );
  
  // NEW USE CASES
  final signInWithGoogleUseCase = SignInWithGoogleUseCase(
    authRepository: authRepo,
    adminRepository: adminRepo,
    memberRepository: memberRepo,
  );
  final saveEmailUseCase = SaveEmailUseCase(authRepository: authRepo);
  final getSavedEmailUseCase = GetSavedEmailUseCase(authRepository: authRepo);
  
  final signOutUseCase = SignOutUseCase(authRepository: authRepo);
  final resetPasswordUseCase = ResetPasswordUseCase(authRepository: authRepo);

  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider<DocumentRepository>(
          create: (context) => DocumentRepositoryImpl(
            FirestoreDocumentDataSource(firestore: firestore),
          ),
        ),
        RepositoryProvider<DocumentLineItemRepository>(
          create: (context) => DocumentLineItemRepositoryImpl(
            FirestoreDocumentLineItemDataSource(firestore: firestore),
          ),
        ),
        // Provide AuthRepository in case other blocs need it directly
        RepositoryProvider<AuthRepository>.value(value: authRepo),
      ],
      // --- 2. Provide AuthBloc Globally ---
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>(
            create: (context) => AuthBloc(
              signIn: signInUseCase,
              signUp: signUpUseCase,
              getCurrentUser: getCurrentUserUseCase,
              signOut: signOutUseCase,
              resetPassword: resetPasswordUseCase,
              // FIXED: Added missing named arguments
              signInWithGoogle: signInWithGoogleUseCase,
              saveEmail: saveEmailUseCase,
              getSavedEmail: getSavedEmailUseCase,
            )..add(AuthCheckRequested()), // Check login status immediately
          ),
        ],
        child: MainApp(sharedPreferences: sharedPreferences),
      ),
    ),
  );
}

class MainApp extends StatelessWidget {
  final SharedPreferences sharedPreferences;
  const MainApp({super.key, required this.sharedPreferences});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true),

      // home: const BottomNavBar(),
      initialRoute: AppRoutes.auth,
      onGenerateRoute: (settings) =>
          AppRoutes.onGenerateRoute(settings, sharedPreferences),
    );
  }
}