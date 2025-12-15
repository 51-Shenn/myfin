import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myfin/features/upload/domain/repositories/document_repository.dart';
import 'package:myfin/features/upload/presentation/cubit/upload_history_cubit.dart';
import 'package:myfin/features/upload/presentation/cubit/upload_history_state.dart';
import 'package:myfin/features/upload/presentation/pages/doc_details.dart';
import 'package:myfin/features/upload/presentation/widgets/document_card.dart';

class UploadHistoryScreen extends StatelessWidget {
  const UploadHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => UploadHistoryCubit(
        context.read<DocumentRepository>(),
      )..fetchHistory(),
      child: const UploadHistoryView(),
    );
  }
}

class UploadHistoryView extends StatelessWidget {
  const UploadHistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Upload History',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: BlocBuilder<UploadHistoryCubit, UploadHistoryState>(
        builder: (context, state) {
          if (state is UploadHistoryLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is UploadHistoryError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 10),
                  Text(state.message, style: const TextStyle(color: Colors.red)),
                  TextButton(
                    onPressed: () => context.read<UploadHistoryCubit>().fetchHistory(),
                    child: const Text("Retry"),
                  )
                ],
              ),
            );
          }

          if (state is UploadHistoryLoaded) {
            if (state.documents.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.history, size: 60, color: Colors.grey[300]),
                    const SizedBox(height: 10),
                    const Text(
                      "No upload history found",
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () => context.read<UploadHistoryCubit>().fetchHistory(),
              child: ListView.separated(
                padding: const EdgeInsets.all(20),
                itemCount: state.documents.length,
                separatorBuilder: (context, index) => const SizedBox(height: 0),
                itemBuilder: (context, index) {
                  final document = state.documents[index];
                  
                  return DocumentCard(
                    document: document,
                    onTap: () async {                      
                      await Navigator.pushNamed(
                        context,
                        '/doc_details',
                        arguments: DocDetailsArguments(
                          existingDocument: document,
                        ),
                      );

                      if (context.mounted) {
                        context.read<UploadHistoryCubit>().fetchHistory();
                      }
                    },
                  );
                },
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}