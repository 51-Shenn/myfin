import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:myfin/core/navigation/app_routes.dart';
import 'package:myfin/features/authentication/data/datasources/member_remote_data_source.dart';
import 'package:myfin/features/authentication/data/repositories/member_repository_impl.dart';
import 'package:myfin/features/authentication/domain/repositories/member_repository.dart';
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
  final sharedPreferences = await SharedPreferences.getInstance();
  // Create Member Repository Dependencies
  final memberRemoteDataSource = MemberRemoteDataSourceImpl(
    firestore: firestore,
  );
  final memberRepository = MemberRepositoryImpl(memberRemoteDataSource);
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
        // Add MemberRepository Provider
        RepositoryProvider<MemberRepository>(
          create: (context) => memberRepository,
        ),
      ],
      child: BlocProvider(
        create: (context) => AppRoutes.createAuthBloc(sharedPreferences),
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
      debugShowCheckedModeBanner: true,
      theme: ThemeData(useMaterial3: true),
      // home: const BottomNavBar(),
      initialRoute: AppRoutes.auth,
      onGenerateRoute: (settings) =>
          AppRoutes.onGenerateRoute(settings, sharedPreferences),
    );
  }
}
