import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myfin/features/upload/domain/entities/document.dart';
import 'package:myfin/features/upload/domain/entities/doc_line_item.dart';
import 'package:myfin/features/upload/domain/repositories/doc_line_item_repository.dart';
import 'package:myfin/features/upload/domain/repositories/document_repository.dart';
import 'package:myfin/features/upload/presentation/cubit/doc_detail_cubit.dart';
import 'package:myfin/features/upload/presentation/cubit/doc_detail_state.dart';
import 'package:myfin/features/upload/presentation/pages/doc_field_header.dart';
import 'package:intl/intl.dart';

class DocumentDetailsScreen extends StatelessWidget {
  final String? documentId;
  final Document? existingDocument;
  final List<DocumentLineItem>? existingLineItems;

  const DocumentDetailsScreen({
    super.key,
    this.documentId,
    this.existingDocument,
    this.existingLineItems,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final cubit = DocDetailCubit(
          docRepository: context.read<DocumentRepository>(),
          lineItemRepository: context.read<DocumentLineItemRepository>(),
        );
        
        if (existingDocument != null) {
          cubit.initializeWithData(existingDocument!, existingLineItems);
        } 
        else if (documentId != null && documentId!.isNotEmpty) {
          cubit.loadDocument(documentId!);
        }
        else {
          cubit.loadDocument(null);
        }
        
        return cubit;
      },
      child: const DocDetailsView(),
    );
  }
}

class DocDetailsView extends StatelessWidget {
  const DocDetailsView({super.key});

  Future<void> _pickDate(BuildContext context, DateTime initialDate, Function(DateTime) onDatePicked) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      onDatePicked(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DocDetailCubit, DocDetailState>(
      listener: (context, state) {
        if (state.successMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.successMessage!),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );

          Future.delayed(const Duration(milliseconds: 500), () {
            if (context.mounted) {
              Navigator.of(context).pop(); 
            }
          });
        }
        if (state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: Text(
              'Document Details',
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: true,
            actions: [
              if (state.isSaving)
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: CircularProgressIndicator(),
                )
              else
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.save, color: Color(0xFF2B46F9)),
                      onPressed: () {
                        if (state.document != null) {
                          context.read<DocDetailCubit>().saveDocument();
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please fill in required fields'),
                              backgroundColor: Colors.orange,
                            ),
                          );
                        }
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_forever, color: Colors.red),
                      onPressed: () {
                        // check if document exists before trying to delete
                        if (state.document == null) return;

                        // ask for permission
                        showDialog(
                          context: context,
                          builder: (dialogContext) => AlertDialog(
                            title: const Text('Delete Document'),
                            content: const Text(
                                'Are you sure you want to delete this document permanently? This action cannot be undone.'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(dialogContext), // close dialog
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(dialogContext);
                                  context.read<DocDetailCubit>().deleteDocument();
                                },
                                child: const Text(
                                  'Delete',
                                  style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
            ],
          ),
          body: state.isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (state.document?.id.isEmpty == true)
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Card(
                              color: Colors.blue[50],
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Row(
                                  children: [
                                    const Icon(Icons.info, color: Colors.blue),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        'Creating new document. Fill in the details below.',
                                        style: TextStyle(color: Colors.blue[700]),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Expanded(
                              child: Column(
                                children: [
                                  _buildTextFormField(
                                    context,
                                    DocFieldHeader.name,
                                    value: state.document?.name ?? '',
                                    onChanged: (value) {
                                      context
                                          .read<DocDetailCubit>()
                                          .updateDocumentField('name', value);
                                    },
                                  ),
                                  _buildTextFormField(
                                    context,
                                    DocFieldHeader.type,
                                    value: state.document?.type ?? '',
                                    onChanged: (value) {
                                      context
                                          .read<DocDetailCubit>()
                                          .updateDocumentField('type', value);
                                    },
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 10),
                            Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.grey[300]!),
                                ),
                                width: 150,
                                height: 150,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.image,
                                        size: 40, color: Colors.grey[500]),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Add Image',
                                      style: TextStyle(color: Colors.grey[600]),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: _buildTextFormField(
                                context,
                                DocFieldHeader.status,
                                value: state.document?.status ?? 'Draft',
                                onChanged: (value) {
                                  context
                                      .read<DocDetailCubit>()
                                      .updateDocumentField('status', value);
                                },
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: _buildTextFormField(
                                context,
                                DocFieldHeader.postingDate,
                                value: state.document != null
                                    ? DateFormat('yyyy-MM-dd').format(state.document!.postingDate)
                                    : '',
                                isDate: true,
                                onTap: () {
                                  if (state.document != null) {
                                    _pickDate(context, state.document!.postingDate, (pickedDate) {
                                      context.read<DocDetailCubit>().updateDocumentField('postingDate', pickedDate);
                                    });
                                  }
                                }
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        BlocBuilder<DocDetailCubit, DocDetailState>(
                          builder: (context, state) {
                            return DynamicKeyValueSection(
                              title: 'Additional Information',
                              rows: state.rows,
                              onAdd: () => context.read<DocDetailCubit>().addNewRow(),
                              onUpdateKey: (idx, val) => context.read<DocDetailCubit>().updateRowKey(idx, val),
                              onUpdateValue: (idx, val) => context.read<DocDetailCubit>().updateRowValue(idx, val),
                              onDelete: (idx) => context.read<DocDetailCubit>().deleteRow(idx),
                            );
                          },
                        ),

                        const SizedBox(height: 20),
                        _buildLineItems(context),
                        _buildDivider(),
                        Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: Material(
                            color: const Color(0xFFD9D9D9),
                            borderRadius: BorderRadius.circular(10.0),
                            clipBehavior: Clip.hardEdge,
                            child: InkWell(
                              onTap: () {
                                context.read<DocDetailCubit>().addNewLineItem();
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                alignment: Alignment.center,
                                child: const Text(
                                  '+ Add New Line Item',
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
        );
      },
    );
  }

  Widget _buildTextFormField(
    BuildContext context,
    DocFieldHeader header, {
    String? value,
    bool readOnly = false,
    bool isAdditional = false,
    void Function(String)? onChanged,
    bool multiLine = false,
    VoidCallback? onTap,
    bool isDate = false
  }) {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isAdditional)
            Text(
              '${header.fieldName}:',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                fontFamily: 'Inter',
              ),
            ),
          const SizedBox(height: 5),
          TextFormField(
            key: isDate? ValueKey(value) : null,
            initialValue: value,
            readOnly: readOnly || isDate,
            onTap: onTap,
            onChanged: onChanged,
            minLines: multiLine ? 3 : 1,
            maxLines: multiLine ? 5 : 1,
            keyboardType:
                multiLine ? TextInputType.multiline : TextInputType.text,
            decoration: InputDecoration(
              suffixIcon: isDate ? const Icon(Icons.calendar_today, size: 20) : null,
              filled: true,
              fillColor: readOnly ? Colors.grey[100] : Colors.white,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5),
                borderSide: const BorderSide(
                  color: Color.fromARGB(255, 204, 204, 204),
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5),
                borderSide: const BorderSide(
                  color: Colors.blue,
                  width: 1.5,
                ),
              ),
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5),
                borderSide: const BorderSide(
                  color: Color.fromARGB(255, 204, 204, 204),
                  width: 1,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLineItems(BuildContext context) {
    return BlocBuilder<DocDetailCubit, DocDetailState>(
      builder: (context, state) {
        if (state.lineItems.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.all(5.0),
              child: Text(
                'Line Items',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ...state.lineItems
                .map((lineItem) => _buildLineItem(context, lineItem)),
          ],
        );
      },
    );
  }

  Widget _buildLineItem(BuildContext context, DocumentLineItem lineItem) {
    final cubit = context.read<DocDetailCubit>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDivider(),
        Row(
          children: [
            Padding(
              padding: const EdgeInsets.all(5.0),
              child: Text(
                'Line ${lineItem.lineNo}',
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (dialogContext) => AlertDialog(
                    title: const Text('Delete Line Item'),
                    content: const Text(
                        'Are you sure you want to delete this line item?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(dialogContext),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          cubit.deleteLineItem(lineItem.lineItemId);
                          Navigator.pop(dialogContext);
                        },
                        child: const Text('Delete',
                            style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
        Row(
          children: [
            Expanded(
              child: _buildTextFormField(
                context,
                DocFieldHeader.date,
                value: lineItem.lineDate != null
                    ? DateFormat('yyyy-MM-dd').format(lineItem.lineDate!)
                    : '',
                isDate: true,
                onTap: () {
                  final initialDate = lineItem.lineDate ?? DateTime.now();
                  _pickDate(context, initialDate, (pickedDate) {
                    cubit.updateLineItemField(lineItem.lineItemId, 'date', pickedDate);
                  });
                },
              ),
            ),
            Expanded(
              flex: 1,
              child: _buildTextFormField(
                context,
                DocFieldHeader.category,
                value: lineItem.categoryCode,
                onChanged: (value) {
                  cubit.updateLineItemField(lineItem.lineItemId, 'category', value);
                },
              ),
            ),
          ],
        ),
        _buildTextFormField(
          context,
          DocFieldHeader.description,
          value: lineItem.description ?? '',
          multiLine: true,
          onChanged: (value) {
            cubit.updateLineItemField(lineItem.lineItemId, 'description', value);
          },
        ),
        _buildTextFormField(
          context,
          DocFieldHeader.total,
          value: lineItem.total.toStringAsFixed(2),
          onChanged: (value) {
            cubit.updateLineItemField(lineItem.lineItemId, 'amount', value);
          }
        ),
        const SizedBox(height: 10),
        DynamicKeyValueSection(
          title: 'Line Item Attributes',
          rows: lineItem.attribute,
          onAdd: () => cubit.addLineItemAttribute(lineItem.lineItemId),
          onUpdateKey: (idx, val) => 
              cubit.updateLineItemAttributeKey(lineItem.lineItemId, idx, val),
          onUpdateValue: (idx, val) => 
              cubit.updateLineItemAttributeValue(lineItem.lineItemId, idx, val),
          onDelete: (idx) => 
              cubit.deleteLineItemAttribute(lineItem.lineItemId, idx),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Divider(
      color: Colors.grey[300],
      height: 40,
      thickness: 1,
      indent: 5,
      endIndent: 5,
    );
  }
}

class DynamicKeyValueSection extends StatelessWidget {
  final String title;
  final List<AdditionalInfoRow> rows;
  final VoidCallback onAdd;
  final Function(int index, String val) onUpdateKey;
  final Function(int index, String val) onUpdateValue;
  final Function(int index) onDelete;

  const DynamicKeyValueSection({
    super.key,
    required this.title,
    required this.rows,
    required this.onAdd,
    required this.onUpdateKey,
    required this.onUpdateValue,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(5.0),
          child: Text(
            title,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ...rows.asMap().entries.map((entry) {
          final index = entry.key;
          final row = entry.value;
          return Row(
            key: ValueKey(row.id),
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: TextFormField(
                    initialValue: row.key,
                    onChanged: (val) => onUpdateKey(index, val),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5),
                        borderSide: const BorderSide(color: Color(0xFFCCCCCC), width: 1),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5),
                        borderSide: const BorderSide(color: Colors.blue, width: 1.5),
                      ),
                    ),
                  ),
                ),
              ),
              const Text(':',
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: TextFormField(
                    initialValue: row.value,
                    onChanged: (val) => onUpdateValue(index, val),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5),
                        borderSide: const BorderSide(color: Color(0xFFCCCCCC), width: 1),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5),
                        borderSide: const BorderSide(color: Colors.blue, width: 1.5),
                      ),
                    ),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (dContext) => AlertDialog(
                      title: const Text('Delete Row'),
                      content: const Text('Delete this item?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(dContext),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () {
                            onDelete(index);
                            Navigator.pop(dContext);
                          },
                          child: const Text('Delete', style: TextStyle(color: Colors.red)),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          );
        }),
        Padding(
          padding: const EdgeInsets.all(5.0),
          child: Material(
            color: const Color(0xFFD9D9D9),
            borderRadius: BorderRadius.circular(10.0),
            clipBehavior: Clip.hardEdge,
            child: InkWell(
              onTap: onAdd,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                alignment: Alignment.center,
                child: const Text(
                  '+ Add Info',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class DocDetailsArguments {
  final Document? existingDocument;
  final List<DocumentLineItem>? existingLineItems;
  final String? documentId;

  DocDetailsArguments({
    this.existingDocument,
    this.existingLineItems,
    this.documentId,
  });
}