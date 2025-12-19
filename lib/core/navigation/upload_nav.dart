import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myfin/features/upload/presentation/pages/doc_details.dart';
import 'package:myfin/features/upload/presentation/pages/upload_main.dart';
import 'package:myfin/features/upload/presentation/pages/upload_history.dart';
import 'package:myfin/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:myfin/features/authentication/presentation/bloc/auth_bloc.dart';

class UploadNav extends StatefulWidget {
  const UploadNav({super.key});

  // Public static getter to access the navigator key
  static GlobalKey<NavigatorState> get navigatorKey =>
      _UploadNavState.uploadNavKey;

  @override
  State<UploadNav> createState() => _UploadNavState();
}

class _UploadNavState extends State<UploadNav> {
  static final GlobalKey<NavigatorState> uploadNavKey =
      GlobalKey<NavigatorState>();

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
                onDocumentSaved: () {
                  print(
                    '🔄 [DASHBOARD UPDATE] Document saved callback triggered!',
                  );
                  // Get the root context's DashboardBloc and trigger refresh
                  final rootContext = Navigator.of(
                    context,
                    rootNavigator: true,
                  ).context;
                  final authState = rootContext.read<AuthBloc>().state;
                  if (authState is AuthAuthenticatedAsMember) {
                    print(
                      '🔄 [DASHBOARD UPDATE] Triggering DashboardLoadRequested for member: ${authState.member.member_id}',
                    );
                    rootContext.read<DashboardBloc>().add(
                      DashboardLoadRequested(authState.member.member_id),
                    );
                    print(
                      '✅ [DASHBOARD UPDATE] Dashboard refresh triggered successfully!',
                    );
                  } else {
                    print(
                      '❌ [DASHBOARD UPDATE] User not authenticated as member',
                    );
                  }
                },
              );
            } else if (settings.name == '/upload_history') {
              return const UploadHistoryScreen();
            }

            // use in button
            // onPressed: () => Navigator.pushNamed(context, '/upload_doc_details'),

            return const UploadScreen(); // upload screen
          },
        );
      },
    );
  }
}
