import 'package:flutter/material.dart';

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({super.key});

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        // bottom nav bar
        bottomNavigationBar: NavigationBar(
          selectedIndex: _selectedIndex,
          onDestinationSelected: (int index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          destinations: <NavigationDestination>[
            NavigationDestination(
              selectedIcon: Icon(Icons.bar_chart_rounded),
              icon: Icon(Icons.bar_chart_rounded),
              label: 'Dashboard',
            ),
            NavigationDestination(
              selectedIcon: Icon(Icons.chat_bubble),
              icon: Icon(Icons.chat_bubble_outline),
              label: 'AI Chatbot',
            ),
            NavigationDestination(
              selectedIcon: Icon(Icons.file_upload_outlined),
              icon: Icon(Icons.file_upload_outlined),
              label: 'Upload',
            ),
            NavigationDestination(
              selectedIcon: Icon(Icons.attachment),
              icon: Icon(Icons.attachment_outlined),
              label: 'Reports',
            ),
            NavigationDestination(
              selectedIcon: Icon(Icons.person_rounded),
              icon: Icon(Icons.person_outline_rounded),
              label: 'Profile',
            ),
          ],
        ),
      
        body: SafeArea(
          top: false,
          child: IndexedStack(
            index: _selectedIndex,
            children: [
              // replace with const nav widgets
              Container(color: Colors.red), // DashboardNav
              Container(color: Colors.green), // AiChatbotNav
              Container(color: Colors.blue), // UploadNav
              Container(color: Colors.yellow), // ReportsNav
              Container(color: Colors.orange), // ProfileNav
            ],
          ),
        ),
    );
  }
}
