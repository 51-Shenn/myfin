import 'package:flutter/material.dart';
import 'package:myfin/screens/aichatbot.dart'; // Make sure this is imported

class AiChatbotNav extends StatefulWidget {
  const AiChatbotNav({super.key});

  @override
  State<AiChatbotNav> createState() => _AiChatbotNavState();
}

class _AiChatbotNavState extends State<AiChatbotNav> {
  GlobalKey<NavigatorState> aiChatbotNavKey = GlobalKey<NavigatorState>();

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