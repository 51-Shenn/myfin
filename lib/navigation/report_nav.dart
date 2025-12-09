import 'package:flutter/material.dart';
import 'package:myfin/screens/report/report_history.dart';
import 'package:myfin/screens/report/report_main.dart';

class ReportsNav extends StatefulWidget {
  const ReportsNav({super.key});

  @override
  State<ReportsNav> createState() => _ReportsNavState();
}

class _ReportsNavState extends State<ReportsNav> {
  GlobalKey<NavigatorState> reportsNavKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: reportsNavKey,
      onGenerateRoute: (RouteSettings settings) {
        return MaterialPageRoute(
          settings: settings,
          builder: (BuildContext context) {
            // routes for report navigation
            if (settings.name == '/report_history') {
              return const ReportHistoryScreen(); // report history screen
            } 

            // use in button
            // onPressed: () => Navigator.pushNamed(context, '/report_details'),

            return const ReportScreen(); // report screen
          }
        );
      },
    );
  }
}