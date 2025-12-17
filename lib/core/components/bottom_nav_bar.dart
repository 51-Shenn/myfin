import 'package:flutter/material.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:myfin/core/navigation/report_nav.dart';
import 'package:myfin/core/navigation/aichatbot_nav.dart';
import 'package:myfin/core/navigation/upload_nav.dart';
import 'package:myfin/core/navigation/user_profile_nav.dart';

class _TabItemBuilder extends DelegateBuilder {
  final List<TabItem<dynamic>> items;
  final Color activeColor;
  final Color color;

  _TabItemBuilder({
    required this.items,
    required this.activeColor,
    required this.color,
  });

  @override
  Widget build(BuildContext context, int index, bool active) {
    final item = items[index];
    final itemColor = active ? activeColor : color;
    final double padding = index == 2 ? 12 : 8;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: active ? itemColor : Colors.white,
          ),
          padding: EdgeInsets.all(padding),
          child: active ? (item.activeIcon ?? item.icon) : item.icon,
        ),
        if (index == 2)
          const SizedBox(height: 20),
        if (item.title?.isNotEmpty ?? false)
          Padding(
            padding: const EdgeInsets.only(top: 0),
            child: Text(
              item.title!,
              style: TextStyle(color: itemColor, fontSize: 11),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
      ],
    );
  }

  @override
  bool fixed() => true;
}

class NavBarController extends InheritedWidget {
  final VoidCallback toggleNavBar;
  final bool isVisible;

  const NavBarController({
    super.key,
    required this.toggleNavBar,
    required this.isVisible,
    required super.child,
  });

  static NavBarController? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<NavBarController>();
  }

  @override
  bool updateShouldNotify(NavBarController oldWidget) {
    return isVisible != oldWidget.isVisible;
  }
}

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({super.key});

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  int _selectedIndex = 0;
  bool _isVisible = true;
  Color blue = const Color(0xFF2B46F9);
  Color shadowBlue = const Color(0xFFD8E4FF);
  Color white = Colors.white;

  List<TabItem<dynamic>> get _navigationDestinations => <TabItem>[
    TabItem(
      activeIcon: Icon(
        Icons.bar_chart_rounded,
        color: white,
        size: 30.0,
        opticalSize: 30.0,
      ),
      icon: Icon(
        Icons.bar_chart_rounded,
        color: blue,
        size: 30.0,
        opticalSize: 30.0,
      ),
      title: 'Dashboard',
    ),
    TabItem(
      activeIcon: Icon(
        Icons.smart_toy,
        color: white,
        size: 30.0,
        opticalSize: 30.0,
      ),
      icon: Icon(
        Icons.smart_toy_outlined,
        color: blue,
        size: 30.0,
        opticalSize: 30.0,
      ),
      title: 'FinAI',
    ),
    TabItem(
      activeIcon: Icon(
        Icons.file_upload_outlined,
        color: Colors.white,
        size: 45.0,
        opticalSize: 10.0,
      ),
      icon: Icon(
        Icons.file_upload_outlined,
        color: blue,
        size: 40.0,
        opticalSize: 10.0,
      ),
      title: '',
    ),
    TabItem(
      activeIcon: Icon(
        Icons.attachment,
        color: white,
        size: 30.0,
        opticalSize: 30.0,
      ),
      icon: Icon(
        Icons.attachment_outlined,
        color: blue,
        size: 30.0,
        opticalSize: 30.0,
      ),
      title: 'Reports',
    ),
    TabItem(
      activeIcon: Icon(
        Icons.person_rounded,
        color: white,
        size: 30.0,
        opticalSize: 30.0,
      ),
      icon: Icon(
        Icons.person_outline_rounded,
        color: blue,
        size: 30.0,
        opticalSize: 30.0,
      ),
      title: 'Profile',
    ),
  ];

  List<Widget> get _pages => <Widget>[
    Container(color: Colors.red),
    const AiChatbotNav(),
    const UploadNav(),
    const ReportsNav(),
    const ProfileNav(),
  ];

  void toggleNavBar() {
    setState(() {
      _isVisible = !_isVisible;
    });
  }

  Widget _buildNavigationBar() {
    return ConvexAppBar.builder(
      itemBuilder: _TabItemBuilder(
        items: _navigationDestinations,
        activeColor: blue,
        color: Colors.black,
      ),
      backgroundColor: Colors.white,
      count: _navigationDestinations.length,
      elevation: 4.0,
      cornerRadius: 8.0,
      curveSize: 80.0,
      shadowColor: shadowBlue,
      initialActiveIndex: _selectedIndex,
      height: 75.0,
      onTap: (index) => setState(() {
        _selectedIndex = index;
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return NavBarController(
      toggleNavBar: toggleNavBar,
      isVisible: _isVisible,
      child: Scaffold(
        bottomNavigationBar: _isVisible ? _buildNavigationBar() : null,
        body: Stack(
          children: [IndexedStack(index: _selectedIndex, children: _pages)],
        ),
      ),
    );
  }
}
