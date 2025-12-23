import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myfin/features/upload/presentation/pages/doc_details.dart';
import 'package:myfin/features/upload/presentation/pages/upload_main.dart';
import 'package:myfin/features/upload/presentation/pages/upload_history.dart';
import 'package:myfin/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:myfin/features/authentication/presentation/bloc/auth_bloc.dart';

class UploadNav extends StatefulWidget {
  const UploadNav({super.key});

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
            if (settings.name == '/doc_details') {
              final args = settings.arguments as DocDetailsArguments?;

              return DocumentDetailsScreen(
                existingDocument: args?.existingDocument,
                existingLineItems: args?.existingLineItems,
                documentId: args?.documentId,
                onDocumentSaved: () {
                  final rootContext = Navigator.of(
                    context,
                    rootNavigator: true,
                  ).context;
                  final authState = rootContext.read<AuthBloc>().state;
                  if (authState is AuthAuthenticatedAsMember) {
                    rootContext.read<DashboardBloc>().add(
                      DashboardRefreshRequested(authState.member.member_id),
                    );
                  }
                },
              );
            } else if (settings.name == '/upload_history') {
              return const UploadHistoryScreen();
            }

            return const UploadScreen();
          },
        );
      },
    );
  }
}
