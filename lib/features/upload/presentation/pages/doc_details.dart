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
import 'package:myfin/features/upload/presentation/widgets/auto_complete_field.dart';
import 'package:myfin/features/upload/presentation/widgets/custom_divider.dart';
import 'package:myfin/features/upload/presentation/widgets/doc_line_item_field.dart';
import 'package:myfin/features/upload/presentation/widgets/doc_text_form_field.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';

class AppValidators {
  static String? required(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Required';
    }
    return null;
  }

  static String? number(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Required';
    }
    if (double.tryParse(value) == null) {
      return 'Invalid number';
    }
    return null;
  }
}

class DocumentDetailsScreen extends StatelessWidget {
  final String? documentId;
  final Document? existingDocument;
  final List<DocumentLineItem>? existingLineItems;
  final bool isReadOnly;

  const DocumentDetailsScreen({
    super.key,
    this.documentId,
    this.existingDocument,
    this.existingLineItems,
    this.isReadOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final cubit = DocDetailCubit(
          docRepository: context.read<DocumentRepository>(),
          lineItemRepository: context.read<DocumentLineItemRepository>(),
        );

        // 1. If objects are passed directly (e.g. from File Upload/OCR), use them.
        if (existingDocument != null) {
          cubit.initializeWithData(existingDocument!, existingLineItems);
        }
        // 2. Otherwise, if an ID is passed, load from DB
        else if (documentId != null && documentId!.isNotEmpty) {
          cubit.loadDocument(documentId!);
        } else {
          cubit.loadDocument(null);
        }

        return cubit;
      },
      child: DocDetailsView(isReadOnly: isReadOnly),
    );
  }
}

class DocDetailsView extends StatefulWidget {
  final bool isReadOnly;
  const DocDetailsView({super.key, this.isReadOnly = false});

  @override
  State<DocDetailsView> createState() => _DocDetailsViewState();
}

class _DocDetailsViewState extends State<DocDetailsView> {
  final _formKey = GlobalKey<FormState>();

  Future<void> _pickDate(
    BuildContext context,
    DateTime initialDate,
    Function(DateTime) onDatePicked,
  ) async {
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

  Future<void> _pickImage(BuildContext context) async {
    final ImagePicker picker = ImagePicker();

    // show dialog to choose source
    final ImageSource? source = await showDialog<ImageSource>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Image Source'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Gallery'),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Camera'),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
            ],
          ),
        );
      },
    );

    if (source == null) return;

    try {
      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        // read image bytes and convert to base64
        final bytes = await image.readAsBytes();
        final base64Image = base64Encode(bytes);

        // update document with base64 image
        if (context.mounted) {
          context.read<DocDetailCubit>().updateDocumentField(
            'imageBase64',
            base64Image,
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
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
              if (widget.isReadOnly)
                const SizedBox.shrink()
              else if (state.isSaving)
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                )
              else
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.save, color: Color(0xFF2B46F9)),
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          if (state.document != null) {
                            context.read<DocDetailCubit>().saveDocument();
                          }
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please fix errors in the form'),
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
                              'Are you sure you want to delete this document permanently? This action cannot be undone.',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(
                                  dialogContext,
                                ), // close dialog
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(dialogContext);
                                  context
                                      .read<DocDetailCubit>()
                                      .deleteDocument();
                                },
                                child: const Text(
                                  'Delete',
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold,
                                  ),
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
              : Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
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
                                      const Icon(
                                        Icons.info,
                                        color: Colors.blue,
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          'Creating new document. Fill in the details below.',
                                          style: TextStyle(
                                            color: Colors.blue[700],
                                          ),
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
                                    DocTextFormField(
                                      header: DocFieldHeader.name,
                                      value: state.document?.name ?? '',
                                      enabled: !widget.isReadOnly,
                                      validator: AppValidators.required,
                                      onChanged: (value) {
                                        context
                                            .read<DocDetailCubit>()
                                            .updateDocumentField('name', value);
                                      },
                                    ),
                                    AutoCompleteField(
                                      header: DocFieldHeader.type,
                                      value: state.document?.type,
                                      enabled: !widget.isReadOnly,
                                      validator: AppValidators.required,
                                      items: docType,
                                      onChanged: (value) {
                                        context
                                            .read<DocDetailCubit>()
                                            .updateDocumentField('type', value);
                                        context
                                            .read<DocDetailCubit>()
                                            .updateDocumentField('type', value);
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 10),
                              if (!widget.isReadOnly)
                                Padding(
                                  padding: const EdgeInsets.all(5.0),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.grey[200],
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: Colors.grey[300]!,
                                      ),
                                    ),
                                    width: 150,
                                    height: 150,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.image,
                                          size: 40,
                                          color: Colors.grey[500],
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Add Image',
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                          ),
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
                                child: AutoCompleteField(
                                  header: DocFieldHeader.status,
                                  value: state.document?.status ?? 'Draft',
                                  items:
                                      docStatus, // Pass the list defined above
                                  enabled: !widget.isReadOnly,
                                  validator: AppValidators
                                      .required, // Ensure you have the AppValidators class from the previous step
                                  onChanged: (value) {
                                    context
                                        .read<DocDetailCubit>()
                                        .updateDocumentField('status', value);
                                  },
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: DocTextFormField(
                                  header: DocFieldHeader.postingDate,
                                  validator: AppValidators.required,
                                  enabled: !widget.isReadOnly,
                                  value: state.document != null
                                      ? DateFormat(
                                          'yyyy-MM-dd',
                                        ).format(state.document!.postingDate)
                                      : '',
                                  isDate: true,
                                  onTap: () {
                                    if (!widget.isReadOnly &&
                                        state.document != null) {
                                      _pickDate(
                                        context,
                                        state.document!.postingDate,
                                        (pickedDate) {
                                          context
                                              .read<DocDetailCubit>()
                                              .updateDocumentField(
                                                'postingDate',
                                                pickedDate,
                                              );
                                        },
                                      );
                                    }
                                  },
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
                                isReadOnly: widget.isReadOnly,
                                onAdd: () =>
                                    context.read<DocDetailCubit>().addNewRow(),
                                onUpdateKey: (idx, val) => context
                                    .read<DocDetailCubit>()
                                    .updateRowKey(idx, val),
                                onUpdateValue: (idx, val) => context
                                    .read<DocDetailCubit>()
                                    .updateRowValue(idx, val),
                                onDelete: (idx) => context
                                    .read<DocDetailCubit>()
                                    .deleteRow(idx),
                              );
                            },
                          ),

                          const SizedBox(height: 20),
                          DocLineItemField(isReadOnly: widget.isReadOnly),
                          if (!widget.isReadOnly)
                            Column(
                              children: [
                                CustomDivider(),
                                Padding(
                                  padding: const EdgeInsets.all(5.0),
                                  child: Material(
                                    color: const Color(0xFFD9D9D9),
                                    borderRadius: BorderRadius.circular(10.0),
                                    clipBehavior: Clip.hardEdge,
                                    child: InkWell(
                                      onTap: () {
                                        context
                                            .read<DocDetailCubit>()
                                            .addNewLineItem();
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 10,
                                        ),
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
                              ],
                            ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ),
        );
      },
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
  final bool isReadOnly;

  const DynamicKeyValueSection({
    super.key,
    required this.title,
    required this.rows,
    required this.onAdd,
    required this.onUpdateKey,
    required this.onUpdateValue,
    required this.onDelete,
    this.isReadOnly = false,
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
                    readOnly: isReadOnly,
                    enabled: !isReadOnly,
                    style: const TextStyle(color: Colors.black),
                    onChanged: (val) => onUpdateKey(index, val),
                    validator: (val) =>
                        val == null || val.isEmpty ? 'Field required' : null,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 5,
                        vertical: 12,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5),
                        borderSide: const BorderSide(
                          color: Color(0xFFCCCCCC),
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
                      errorBorder: OutlineInputBorder(
                        // Added error style
                        borderRadius: BorderRadius.circular(5),
                        borderSide: const BorderSide(
                          color: Colors.red,
                          width: 1,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const Text(
                ':',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
              ),
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: TextFormField(
                    initialValue: row.value,
                    readOnly: isReadOnly,
                    enabled: !isReadOnly,
                    style: const TextStyle(color: Colors.black),
                    onChanged: (val) => onUpdateValue(index, val),
                    validator: (val) =>
                        val == null || val.isEmpty ? 'Value required' : null,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 5,
                        vertical: 12,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5),
                        borderSide: const BorderSide(
                          color: Color(0xFFCCCCCC),
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
                    ),
                  ),
                ),
              ),
              if (!isReadOnly)
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
                            child: const Text(
                              'Delete',
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
            ],
          );
        }),
        if (!isReadOnly)
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

const List<String> docType = [
  'Sales Invoice',
  'Official Receipt',
  'Cash Receipt',
  'Credit Note',
  'Debit Note',
  'Sales Order',
  'Purchase Order',
  'Supplier Invoice',
  'Goods Received Note',
  'Delivery Order',
  'Payment Voucher',
  'Receipt Voucher',
  'Journal Voucher',
  'Expense Claim Form',
  'Payroll Slip',
  'Time Sheet',
  'Bank Statement',
  'Deposit Slip',
  'Cheque Stub',
  'Petty Cash Voucher',
  'Stock Issue Note',
  'Stock Return Note',
  'Inventory Adjustment Form',
  'Asset Purchase Invoice',
  'Asset Disposal Form',
  'Loan Agreement',
  'Loan Repayment Schedule',
  'Dividend Voucher',
  'Capital Injection Record',
  'Owner Drawing Record',
  'Contract Agreement',
  'Service Report',
  'Maintenance Record',
  'Insurance Claim Form',
  'Tax Invoice',
  'Tax Payment Receipt',
];

const List<String> docStatus = [
  'Draft',
  'Pending Approval',
  'Approved',
  'Posted',
  'Paid',
  'Void',
  'Rejected',
];
