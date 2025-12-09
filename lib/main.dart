import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:myfin/firebase_options.dart';
import 'package:myfin/components/bottom_nav_bar.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: true,
      theme: ThemeData(useMaterial3: true),
      home: const BottomNavBar(),
    );
  }
}
