import 'package:flutter/material.dart';
import 'package:myfin/features/upload/presentation/pages/doc_details.dart';
import 'package:myfin/features/upload/presentation/pages/upload_history.dart';
import 'package:myfin/features/upload/presentation/pages/upload_main.dart';

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
            if (settings.name == '/doc_details') {
              final args = settings.arguments as DocDetailsArguments?;

              return DocumentDetailsScreen(
                existingDocument: args?.existingDocument,
                existingLineItems: args?.existingLineItems,
                documentId: args?.documentId,
              );
            } 
            else if (settings.name == '/upload_history') {
              // return UploadHistoryScreen();
            }

            // use in button
            // onPressed: () => Navigator.pushNamed(context, '/upload_doc_details'),

            return UploadScreen(); // upload screen
          }
        );
      },
    );
  }
}