import 'package:equatable/equatable.dart';
import 'package:myfin/features/upload/domain/entities/document.dart';

abstract class CategoryDocumentsState extends Equatable {
  const CategoryDocumentsState();

  @override
  List<Object?> get props => [];
}

class CategoryDocumentsInitial extends CategoryDocumentsState {
  const CategoryDocumentsInitial();
}

class CategoryDocumentsLoading extends CategoryDocumentsState {
  const CategoryDocumentsLoading();
}

class CategoryDocumentsLoaded extends CategoryDocumentsState {
  final List<Document> documents;
  final String categoryName;
  final String transactionType;

  const CategoryDocumentsLoaded({
    required this.documents,
    required this.categoryName,
    required this.transactionType,
  });

  @override
  List<Object?> get props => [documents, categoryName, transactionType];
}

class CategoryDocumentsError extends CategoryDocumentsState {
  final String message;

  const CategoryDocumentsError(this.message);

  @override
  List<Object?> get props => [message];
}
