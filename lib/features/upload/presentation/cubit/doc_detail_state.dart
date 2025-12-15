import 'package:equatable/equatable.dart';
import 'package:myfin/features/upload/domain/entities/document.dart';
import 'package:myfin/features/upload/domain/entities/doc_line_item.dart';

class DocDetailState extends Equatable {
  final Document? document;
  final List<DocumentLineItem> lineItems;
  final List<AdditionalInfoRow> rows;
  final bool isLoading;
  final bool isSaving;
  final String? errorMessage;
  final String? successMessage;

  const DocDetailState({
    this.document,
    this.lineItems = const [],
    this.rows = const [],
    this.isLoading = false,
    this.isSaving = false,
    this.errorMessage,
    this.successMessage,
  });

  DocDetailState copyWith({
    Document? document,
    List<DocumentLineItem>? lineItems,
    List<AdditionalInfoRow>? rows,
    bool? isLoading,
    bool? isSaving,
    String? errorMessage,
    String? successMessage,
  }) {
    return DocDetailState(
      document: document ?? this.document,
      lineItems: lineItems ?? this.lineItems,
      rows: rows ?? this.rows,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      errorMessage: errorMessage,
      successMessage: successMessage,
    );
  }

  @override
  List<Object?> get props => [
        document,
        lineItems,
        rows,
        isLoading,
        isSaving,
        errorMessage,
        successMessage,
      ];
}