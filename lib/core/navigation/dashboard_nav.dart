import 'package:flutter/material.dart';
import 'package:myfin/features/dashboard/presentation/pages/dashboard_page.dart';

class DashboardNav extends StatefulWidget {
  const DashboardNav({super.key});

  @override
  State<DashboardNav> createState() => _DashboardNavState();
}

class _DashboardNavState extends State<DashboardNav> {
  GlobalKey<NavigatorState> dashboardNavKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: dashboardNavKey,
      onGenerateRoute: (RouteSettings settings) {
        return MaterialPageRoute(
          settings: settings,
          builder: (BuildContext context) {
            // routes for dashboard navigation
            if (settings.name == '/dashboard_details') {
              return Container(); // dashboard details screen
            }

            // use in button
            // onPressed: () => Navigator.pushNamed(context, '/dashboard_details'),

            return const DashboardPage();
          },
        );
      },
    );
  }
}
