import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myfin/features/upload/domain/entities/document.dart';
import 'package:myfin/features/upload/domain/entities/doc_line_item.dart';
import 'package:myfin/features/upload/presentation/cubit/doc_detail_state.dart';

class DocDetailCubit extends Cubit<DocDetailState> {
  DocDetailCubit() : super(DocDetailState());

  // === 1. THIS IS THE KEY FUNCTION FOR PRE-FILLING ===
  void initializeWithData(Document document, List<DocumentLineItem>? lineItems) {
    emit(state.copyWith(
      isLoading: false,
      document: document,
      // Fills the "Additional Info" section from the Document's metadata
      rows: document.metadata ?? [], 
      // Fills the "Line Items" section (including their attributes)
      lineItems: lineItems ?? [],
    ));
  }

  // === 2. STANDARD LOAD BY ID ===
  Future<void> loadDocument(String? documentId) async {
    try {
      emit(state.copyWith(isLoading: true));

      // Case: Creating a brand new blank document
      if (documentId == null || documentId.isEmpty) {
        final document = Document(
          id: '',
          memberId: '',
          name: '',
          type: '',
          status: '',
          createdBy: 'Current User',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          postingDate: DateTime.now(),
          metadata: [],
        );

        emit(state.copyWith(
          document: document,
          isLoading: false,
          rows: [],
          lineItems: [],
        ));
        return;
      }

      // Case: Loading from API (Mocked here)
      await Future.delayed(const Duration(seconds: 1));

      final document = Document(
        id: documentId,
        memberId: 'user123',
        name: 'Invoice #1001',
        type: 'Invoice',
        status: 'Draft',
        createdBy: 'Admin',
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        updatedAt: DateTime.now(),
        postingDate: DateTime.now(),
        metadata: [
          AdditionalInfoRow(id: '1', key: 'PO Number', value: 'PO-999'),
        ],
      );

      final mockLineItems = [
        DocumentLineItem(
          lineItemId: 'l1',
          documentId: documentId,
          lineNo: 1,
          categoryCode: 'FOOD',
          description: 'Lunch',
          debit: 50.0,
          credit: 0.0,
          attribute: [
             AdditionalInfoRow(id: 'a1', key: 'Spice Level', value: 'High'),
          ],
        )
      ];

      emit(state.copyWith(
        document: document,
        rows: document.metadata,
        lineItems: mockLineItems,
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      ));
    }
  }

  void updateDocumentField(String field, dynamic value) {
    if (state.document == null) return;

    Document updatedDoc;
    switch (field) {
      case 'name':
        updatedDoc = state.document!.copyWith(name: value as String);
        break;
      case 'type':
        updatedDoc = state.document!.copyWith(type: value as String);
        break;
      case 'status':
        updatedDoc = state.document!.copyWith(status: value as String);
        break;
      default:
        updatedDoc = state.document!;
    }
    emit(state.copyWith(document: updatedDoc));
  }

  Future<void> saveDocument() async {
    if (state.document == null) {
      emit(state.copyWith(errorMessage: 'No document to save'));
      return;
    }

    try {
      emit(state.copyWith(isSaving: true));

      // Simulate API Save
      await Future.delayed(const Duration(seconds: 1));

      emit(state.copyWith(
        isSaving: false,
        successMessage: 'Document saved successfully',
      ));

      Future.delayed(const Duration(seconds: 3), () {
        if (!isClosed) {
          emit(state.copyWith(successMessage: null));
        }
      });
    } catch (e) {
      emit(state.copyWith(
        isSaving: false,
        errorMessage: 'Failed to save document: $e',
      ));
    }
  }

  // --- Row Management ---
  void addNewRow() {
    final uniqueId = DateTime.now().microsecondsSinceEpoch.toString();
    emit(state.copyWith(
      rows: [...state.rows, AdditionalInfoRow(id: uniqueId, key: '', value: '')]
    ));
  }

  void updateRowKey(int index, String key) {
    final updatedRows = List<AdditionalInfoRow>.from(state.rows);
    updatedRows[index] = updatedRows[index].copyWith(key: key);
    emit(state.copyWith(rows: updatedRows));
  }

  void updateRowValue(int index, String value) {
    final updatedRows = List<AdditionalInfoRow>.from(state.rows);
    updatedRows[index] = updatedRows[index].copyWith(value: value);
    emit(state.copyWith(rows: updatedRows));
  }

  void deleteRow(int index) {
    final updatedRows = List<AdditionalInfoRow>.from(state.rows);
    updatedRows.removeAt(index);
    emit(state.copyWith(rows: updatedRows));
  }

  // --- Line Item Management ---
  void addNewLineItem() {
    final uniqueId = DateTime.now().microsecondsSinceEpoch.toString();
    final newLineItem = DocumentLineItem(
      lineItemId: uniqueId,
      documentId: state.document?.id ?? '',
      lineNo: state.lineItems.length + 1,
      categoryCode: '',
      debit: 0.0,
      credit: 0.0,
      attribute: [],
    );
    emit(state.copyWith(lineItems: [...state.lineItems, newLineItem]));
  }

  void deleteLineItem(String lineItemId) {
    final updatedItems = state.lineItems
        .where((item) => item.lineItemId != lineItemId)
        .toList();
    emit(state.copyWith(lineItems: updatedItems));
  }

  // --- Line Item Attribute Management ---
  void addLineItemAttribute(String lineItemId) {
    final uniqueId = DateTime.now().microsecondsSinceEpoch.toString();
    final updatedItems = state.lineItems.map((item) {
      if (item.lineItemId == lineItemId) {
        return item.copyWith(
          attribute: [...item.attribute, AdditionalInfoRow(id: uniqueId, key: '', value: '')]
        );
      }
      return item;
    }).toList();
    emit(state.copyWith(lineItems: updatedItems));
  }

  void updateLineItemAttributeKey(String lineItemId, int index, String newKey) {
    final updatedItems = state.lineItems.map((item) {
      if (item.lineItemId == lineItemId) {
        final newAttributes = List<AdditionalInfoRow>.from(item.attribute);
        newAttributes[index] = newAttributes[index].copyWith(key: newKey);
        return item.copyWith(attribute: newAttributes);
      }
      return item;
    }).toList();
    emit(state.copyWith(lineItems: updatedItems));
  }

  void updateLineItemAttributeValue(String lineItemId, int index, String newValue) {
    final updatedItems = state.lineItems.map((item) {
      if (item.lineItemId == lineItemId) {
        final newAttributes = List<AdditionalInfoRow>.from(item.attribute);
        newAttributes[index] = newAttributes[index].copyWith(value: newValue);
        return item.copyWith(attribute: newAttributes);
      }
      return item;
    }).toList();
    emit(state.copyWith(lineItems: updatedItems));
  }

  void deleteLineItemAttribute(String lineItemId, int index) {
    final updatedItems = state.lineItems.map((item) {
      if (item.lineItemId == lineItemId) {
        final newAttributes = List<AdditionalInfoRow>.from(item.attribute);
        newAttributes.removeAt(index);
        return item.copyWith(attribute: newAttributes);
      }
      return item;
    }).toList();
    emit(state.copyWith(lineItems: updatedItems));
  }
}