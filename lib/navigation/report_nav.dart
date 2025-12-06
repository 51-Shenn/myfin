import 'package:flutter/material.dart';

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
            if (settings.name == '/report_details') {
              return Container(); // report details screen
            } 

            // use in button
            // onPressed: () => Navigator.pushNamed(context, '/report_details'),

            return Container(); // report screen
          }
        );
      },
    );
  }
}