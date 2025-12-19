import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:myfin/features/profile/data/datasources/profile_remote_data_source.dart';
import 'package:myfin/features/report/data/datasources/report_remote_data_source.dart';
import 'package:myfin/features/report/data/repositories/report_repository_impl.dart';
import 'package:myfin/features/report/domain/repositories/report_repository.dart';
import 'package:hive_flutter/hive_flutter.dart';
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

  await Hive.initFlutter();
  await Hive.openBox('dashboard_cache');

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
            FirestoreDocumentLineItemDataSource(firestore: firestore),
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
        RepositoryProvider<ReportRepository>(
          create: (context) => ReportRepositoryImpl(
            FirestoreReportDataSource(firestore: firestore),
            ProfileRemoteDataSourceImpl(),
          ),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => AppRoutes.createAuthBloc(sharedPreferences),
          ),
          BlocProvider(create: (context) => AppRoutes.createDashboardBloc()),
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
