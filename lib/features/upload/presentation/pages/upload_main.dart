import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myfin/core/components/bottom_nav_bar.dart';
import 'package:myfin/features/upload/domain/repositories/document_repository.dart';
import 'package:myfin/features/upload/domain/usecases/get_recent_doc_use_case.dart';
import 'package:myfin/features/upload/presentation/cubit/upload_cubit.dart';
import 'package:myfin/features/upload/presentation/cubit/upload_state.dart';
import 'package:myfin/features/upload/presentation/pages/doc_details.dart';
import 'package:myfin/features/upload/presentation/pages/option.dart';
import 'package:myfin/features/upload/presentation/widgets/document_card.dart';
import 'package:myfin/features/upload/presentation/widgets/upload_option_card.dart';

class UploadScreen extends StatelessWidget {
  const UploadScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => UploadCubit(
        getRecentDocumentsUseCase: GetRecentDocumentsUseCase(
          context.read<DocumentRepository>(),
        ),
      )..fetchDocument(),
      child: const UploadView(),
    );
  }
}

class UploadView extends StatelessWidget {
  const UploadView({super.key});

  @override
  Widget build(BuildContext context) {
    final uploadCubit = context.read<UploadCubit>();

    return BlocListener<UploadCubit, UploadState>(
      listener: (context, state) async {
        if (state is UploadError) {
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('Upload Error'),
              content: Text(state.message),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        }
        if (state is UploadNavigateToManual) {
          NavBarController.of(context)?.toggleNavBar();
          Navigator.pushNamed(context, '/doc_details').then((_) {
            if (!context.mounted) return;
            NavBarController.of(context)?.toggleNavBar();
            context.read<UploadCubit>().fetchDocument();
          });
        } else if (state is UploadNavigateToDocDetails) {
          NavBarController.of(context)?.toggleNavBar();
          Navigator.pushNamed(
            context,
            '/doc_details',
            arguments: DocDetailsArguments(
              existingDocument: state.selectedDocument,
              existingLineItems: state.extractedLineItems,
            ),
          ).then((_) {
            if (!context.mounted) return;
            NavBarController.of(context)?.toggleNavBar();
            context.read<UploadCubit>().fetchDocument();
          });
        }
        // else if (state is UploadImagePicked) {
        //   uploadCubit.processPickedImage(state.imagePath);
        // }
        // else if (state is UploadFilePicked) {
        //   uploadCubit.processPickedFile(state.filePath, state.fileName);
        // }
        else if (state is UploadNavigateToHistory) {
          NavBarController.of(context)?.toggleNavBar();
          Navigator.pushNamed(context, '/upload_history').then((_) {
            if (!context.mounted) return;
            NavBarController.of(context)?.toggleNavBar();
            context.read<UploadCubit>().fetchDocument();
          });
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Upload',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
        ),
        body: BlocBuilder<UploadCubit, UploadState>(
          builder: (context, state) {
            return SingleChildScrollView(
              child: Column(
                children: [
                  UploadOptionCard(option: Option.manual),
                  UploadOptionCard(option: Option.file),
                  Row(
                    children: [
                      Expanded(
                        child: UploadOptionCard(
                          option: Option.gallery,
                          customPadding: EdgeInsets.fromLTRB(20, 10, 10, 10),
                        ),
                      ),
                      Expanded(
                        child: UploadOptionCard(
                          option: Option.scan,
                          customPadding: EdgeInsets.fromLTRB(10, 10, 20, 10),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding: EdgeInsets.fromLTRB(5, 10, 0, 10),
                              child: Text(
                                'Recent Uploads',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Spacer(),
                            if (state.document.isNotEmpty &&
                                state.document.length > 2)
                              TextButton(
                                onPressed: () {
                                  uploadCubit.viewAllClicked();
                                },
                                style: TextButton.styleFrom(
                                  splashFactory: NoSplash.splashFactory,
                                ),
                                child: Text(
                                  'View All',
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        Builder(
                          builder: (context) {
                            if (state is UploadLoading) {
                              return const Center(
                                child: Column(
                                  children: [
                                    SizedBox(height: 80),
                                    CircularProgressIndicator(),
                                  ],
                                ),
                              );
                            }

                            if (state is UploadLoaded &&
                                state.document.isEmpty) {
                              return Center(
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                    0,
                                    80,
                                    0,
                                    0,
                                  ),
                                  child: Text(
                                    'No recent uploads',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                              );
                            }

                            if (state is UploadLoaded) {
                              return Column(
                                children: [
                                  for (final doc in state.document.take(2))
                                    DocumentCard(
                                      document: doc,
                                      onTap: () {
                                        uploadCubit.recentUploadedDocClicked(
                                          doc,
                                        );
                                      },
                                    ),
                                ],
                              );
                            }

                            return const Center(
                              child: Column(
                                children: [
                                  SizedBox(height: 50),
                                  CircularProgressIndicator(),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
