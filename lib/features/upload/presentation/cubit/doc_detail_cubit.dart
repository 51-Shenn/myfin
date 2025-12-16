import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myfin/features/upload/domain/entities/document.dart';
import 'package:myfin/features/upload/domain/entities/doc_line_item.dart';
import 'package:myfin/features/upload/domain/repositories/doc_line_item_repository.dart';
import 'package:myfin/features/upload/domain/repositories/document_repository.dart';
import 'package:myfin/features/upload/presentation/cubit/doc_detail_state.dart';

class DocDetailCubit extends Cubit<DocDetailState> {
  final DocumentRepository _docRepository;
  final DocumentLineItemRepository _lineItemRepository;

  DocDetailCubit({
    required DocumentRepository docRepository,
    required DocumentLineItemRepository lineItemRepository,
  }) : _docRepository = docRepository,
       _lineItemRepository = lineItemRepository,
       super(const DocDetailState());

  Future<void> initializeWithData(Document document, List<DocumentLineItem>? lineItems) async {
    emit(state.copyWith(
      isLoading: false,
      document: document,
      // Fills the "Additional Info" section from the Document's metadata
      rows: document.metadata ?? [], 
      // Fills the "Line Items" section (including their attributes)
      lineItems: lineItems ?? [],
    ));

    if (document.id.isNotEmpty && (lineItems == null || lineItems.isEmpty)) {
      try {
        final fetchedItems = await _lineItemRepository.getLineItemsByDocumentId(document.id);
        
        emit(state.copyWith(
          lineItems: fetchedItems,
        ));
      } catch (e) {
        emit(state.copyWith(
          isLoading: false,
          errorMessage: 'Failed to load line items: $e',
        ));
      }
    }
  }

  Future<void> loadDocument(String? documentId) async {
    try {
      emit(state.copyWith(isLoading: true));

      // brand new doc template
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

      final document = await _docRepository.getDocumentById(documentId);
      final lineItems = await _lineItemRepository.getLineItemsByDocumentId(documentId);

      emit(state.copyWith(
        document: document,
        rows: document.metadata,
        lineItems: lineItems,
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Error loading document: $e',
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
      case 'postingDate':
        updatedDoc = state.document!.copyWith(postingDate: value as DateTime);
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

      Document docToSave = state.document!.copyWith(
        metadata: state.rows,
        updatedAt: DateTime.now()
      );

      String docId = docToSave.id;

      if (docId.isEmpty) {
        final createdDoc = await _docRepository.createDocument(docToSave);
        docId = createdDoc.id;
        docToSave = createdDoc;
      }
      else {
        await _docRepository.updateDocument(docToSave);
      }

      for (var item in state.lineItems) {
        final itemToSave = item.copyWith(documentId: docId);

        // check prefix 'TEMP_'
        if (itemToSave.lineItemId.isEmpty || itemToSave.lineItemId.startsWith('TEMP_')) {
          if (itemToSave.lineItemId.length > 15 && int.tryParse(itemToSave.lineItemId) != null) {
            // identified as new item so pass empty id for firestore to generate one
            await _lineItemRepository.createLineItem(itemToSave.copyWith(lineItemId: ''));
          }
          else {
            // it already exists
            await _lineItemRepository.updateLineItem(itemToSave);
          }
        }
        else {
          await _lineItemRepository.updateLineItem(itemToSave);
        }
      }

      List<DocumentLineItem> savedLineItems = [];

      for (var item in state.lineItems) {
        bool isEmpty = (item.description == null ||
          item.description!.trim().isEmpty) &&
          item.total == 0 &&
          item.debit == 0 &&
          item.credit == 0 &&
          item.categoryCode.isEmpty;

        if (isEmpty) {
          continue;
        }

        final itemToSave = item.copyWith(documentId: docId);
        DocumentLineItem resultItem;

        bool isNewItem = itemToSave.lineItemId.isEmpty ||
          itemToSave.lineItemId.length > 20 ||
          itemToSave.lineItemId.startsWith('TEMP_');
        
        if (isNewItem) {
           // Create new
           resultItem = await _lineItemRepository.createLineItem(itemToSave.copyWith(lineItemId: ''));
        } else {
           // Update existing
           resultItem = await _lineItemRepository.updateLineItem(itemToSave);
        }
        
        savedLineItems.add(resultItem);
      }

      emit(state.copyWith(
        document: docToSave,
        isSaving: false,
        successMessage: 'Document saved successfully',
      ));
    } catch (e) {
      emit(state.copyWith(
        isSaving: false,
        errorMessage: 'Failed to save document: $e',
      ));
    }
  }

  Future<void> deleteDocument() async {
    // if new doc, just discard and close the ui
    if (state.document == null || state.document!.id.isEmpty) {
      emit(state.copyWith(successMessage: 'Draft discarded'));
      return;
    }

    try {
      emit(state.copyWith(isSaving: true));

      final docId = state.document!.id;

      await _lineItemRepository.deleteLineItemsByDocumentId(docId);

      await _docRepository.deleteDocument(docId);

      emit(state.copyWith(
        isSaving: false,
        successMessage: 'Document deleted successfully',
      ));
    } catch (e) {
      emit(state.copyWith(
        isSaving: false,
        errorMessage: 'Failed to delete: $e',
      ));
    }
  }

  // --- Row Management ---
  void addNewRow() {
    final uniqueId = 'TEMP_${DateTime.now().microsecondsSinceEpoch.toString()}';
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
      total: 0.0,
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

  void updateLineItemField(String lineItemId, String field, dynamic value) {
    final updatedItems = state.lineItems.map((item) {
      if (item.lineItemId == lineItemId) {
        switch (field) {
          case 'description':
            return item.copyWith(description: value as String);
          case 'category':
            return item.copyWith(categoryCode: value as String);
          case 'amount':
            final doubleVal = double.tryParse(value.toString()) ?? 0.0;
            return item.copyWith(total: doubleVal); 
          case 'date': 
            return item.copyWith(lineDate: value as DateTime);
          default:
            return item;
        }
      }
      return item;
    }).toList();

    emit(state.copyWith(lineItems: updatedItems));
  }
}