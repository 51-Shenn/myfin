import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myfin/features/dashboard/presentation/cubit/category_documents_cubit.dart';
import 'package:myfin/features/dashboard/presentation/cubit/category_documents_state.dart';
import 'package:myfin/features/upload/domain/repositories/document_repository.dart';
import 'package:myfin/features/upload/presentation/pages/doc_details.dart';
import 'package:myfin/features/upload/presentation/widgets/document_card.dart';

class CategoryDocumentsPage extends StatelessWidget {
  final String categoryName;
  final String transactionType; // 'income' or 'expense'
  final String selectedPeriod;

  const CategoryDocumentsPage({
    super.key,
    required this.categoryName,
    required this.transactionType,
    required this.selectedPeriod,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          CategoryDocumentsCubit(context.read<DocumentRepository>())
            ..loadDocuments(
              mainCategory: categoryName,
              transactionType: transactionType,
              selectedPeriod: selectedPeriod,
            ),
      child: CategoryDocumentsView(
        categoryName: categoryName,
        transactionType: transactionType,
        selectedPeriod: selectedPeriod,
      ),
    );
  }
}

class CategoryDocumentsView extends StatelessWidget {
  final String categoryName;
  final String transactionType;
  final String selectedPeriod;

  const CategoryDocumentsView({
    super.key,
    required this.categoryName,
    required this.transactionType,
    required this.selectedPeriod,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.black,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          children: [
            Text(
              categoryName,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: 'Inter',
              ),
            ),
            Text(
              transactionType == 'income' ? 'Money In' : 'Money Out',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
                fontFamily: 'Inter',
              ),
            ),
          ],
        ),
      ),
      body: BlocBuilder<CategoryDocumentsCubit, CategoryDocumentsState>(
        builder: (context, state) {
          if (state is CategoryDocumentsLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is CategoryDocumentsError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 10),
                  Text(
                    state.message,
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () {
                      context.read<CategoryDocumentsCubit>().loadDocuments(
                        mainCategory: categoryName,
                        transactionType: transactionType,
                        selectedPeriod: selectedPeriod,
                      );
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is CategoryDocumentsLoaded) {
            if (state.documents.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.description_outlined,
                      size: 60,
                      color: Colors.grey[300],
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'No documents found',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 16,
                        fontFamily: 'Inter',
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'for $categoryName',
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 14,
                        fontFamily: 'Inter',
                      ),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () =>
                  context.read<CategoryDocumentsCubit>().loadDocuments(
                    mainCategory: categoryName,
                    transactionType: transactionType,
                    selectedPeriod: selectedPeriod,
                  ),
              child: ListView.separated(
                padding: const EdgeInsets.all(20),
                itemCount: state.documents.length,
                separatorBuilder: (context, index) => const SizedBox(height: 0),
                itemBuilder: (context, index) {
                  final document = state.documents[index];

                  return DocumentCard(
                    document: document,
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DocumentDetailsScreen(
                            existingDocument: document,
                            isReadOnly: true,
                          ),
                        ),
                      );

                      // Refresh list after returning from details
                      if (context.mounted) {
                        context.read<CategoryDocumentsCubit>().loadDocuments(
                          mainCategory: categoryName,
                          transactionType: transactionType,
                          selectedPeriod: selectedPeriod,
                        );
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
