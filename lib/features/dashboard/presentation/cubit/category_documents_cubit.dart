import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myfin/features/dashboard/presentation/cubit/category_documents_state.dart';
import 'package:myfin/features/upload/domain/repositories/document_repository.dart';

class CategoryDocumentsCubit extends Cubit<CategoryDocumentsState> {
  final DocumentRepository _repository;

  CategoryDocumentsCubit(this._repository)
    : super(const CategoryDocumentsInitial());

  Future<void> loadDocuments({
    required String mainCategory,
    required String transactionType,
    required String selectedPeriod, // "YYYY-MM"
  }) async {
    try {
      emit(const CategoryDocumentsLoading());

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        emit(const CategoryDocumentsError('User not authenticated'));
        return;
      }

      // Parse period to dates
      final parts = selectedPeriod.split('-');
      if (parts.length != 2) throw Exception('Invalid period format');

      final year = int.parse(parts[0]);
      final month = int.parse(parts[1]);

      final startDate = DateTime(year, month);
      final endDate = DateTime(
        year,
        month + 1,
      ).subtract(const Duration(microseconds: 1));

      final documents = await _repository.getDocumentsByMainCategory(
        memberId: user.uid,
        mainCategory: mainCategory,
        transactionType: transactionType,
        startDate: startDate,
        endDate: endDate,
      );

      emit(
        CategoryDocumentsLoaded(
          documents: documents,
          categoryName: mainCategory,
          transactionType: transactionType,
        ),
      );
    } catch (e) {
      emit(CategoryDocumentsError('Failed to load documents: $e'));
    }
  }
}
