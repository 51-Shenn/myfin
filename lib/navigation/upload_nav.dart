import 'package:flutter/material.dart';

class UploadNav extends StatefulWidget {
  const UploadNav({super.key});

  @override
  State<UploadNav> createState() => _UploadNavState();
}

class _UploadNavState extends State<UploadNav> {
  GlobalKey<NavigatorState> uploadNavKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: uploadNavKey,
      onGenerateRoute: (RouteSettings settings) {
        return MaterialPageRoute(
          settings: settings,
          builder: (BuildContext context) {
            // routes for upload navigation
            if (settings.name == '/upload_doc_details') {
              return Container(); // upload doc details screen
            } 

            // use in button
            // onPressed: () => Navigator.pushNamed(context, '/upload_doc_details'),

            return Container(); // upload screen
          }
        );
      },
    );
  }
}