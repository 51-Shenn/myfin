import 'package:flutter/material.dart';
import 'package:myfin/features/fin_ai/presentation/pages/fin_ai_main.dart';

class AiChatbotNav extends StatefulWidget {
  const AiChatbotNav({super.key});

  // Public static getter to access the navigator key
  static GlobalKey<NavigatorState> get navigatorKey =>
      _AiChatbotNavState.aiChatbotNavKey;

  @override
  State<AiChatbotNav> createState() => _AiChatbotNavState();
}

class _AiChatbotNavState extends State<AiChatbotNav> {
  static final GlobalKey<NavigatorState> aiChatbotNavKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: aiChatbotNavKey,
      onGenerateRoute: (RouteSettings settings) {
        return MaterialPageRoute(
          settings: settings,
          builder: (BuildContext context) {
            return const AiChatbotScreen();
          }
        );
      },
    );
  }
}