import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:myfin/features/upload/domain/entities/doc_line_item.dart';
import 'package:myfin/features/upload/presentation/cubit/doc_detail_cubit.dart';
import 'package:myfin/features/upload/presentation/cubit/doc_detail_state.dart';
import 'package:myfin/features/upload/presentation/pages/doc_details.dart';
import 'package:myfin/features/upload/presentation/pages/doc_field_header.dart';
import 'package:myfin/features/upload/presentation/widgets/auto_complete_field.dart';
import 'package:myfin/features/upload/presentation/widgets/custom_divider.dart';
import 'package:myfin/features/upload/presentation/widgets/doc_text_form_field.dart';

class DocLineItemField extends StatelessWidget {
  final bool isReadOnly;
  const DocLineItemField({super.key, this.isReadOnly = false});

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

  @override
  Widget build(BuildContext context) {
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
            ...state.lineItems.map(
              (lineItem) => _buildLineItem(context, lineItem),
            ),
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
        CustomDivider(),
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
            if (!isReadOnly)
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (dialogContext) => AlertDialog(
                      title: const Text('Delete Line Item'),
                      content: const Text(
                        'Are you sure you want to delete this line item?',
                      ),
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
        ),
        Row(
          children: [
            Expanded(
              child: DocTextFormField(
                header: DocFieldHeader.date,
                value: lineItem.lineDate != null
                    ? DateFormat('yyyy-MM-dd').format(lineItem.lineDate!)
                    : '',
                isDate: true,
                enabled: !isReadOnly,
                validator: AppValidators.required,
                onTap: () {
                  if (isReadOnly) return;
                  final initialDate = lineItem.lineDate ?? DateTime.now();
                  _pickDate(context, initialDate, (pickedDate) {
                    cubit.updateLineItemField(
                      lineItem.lineItemId,
                      'date',
                      pickedDate,
                    );
                  });
                },
              ),
            ),
            Expanded(
              child: AutoCompleteField(
                header: DocFieldHeader.category,
                value: lineItem.categoryCode,
                items: lineCategory,
                enabled: !isReadOnly,
                validator: AppValidators.required,
                onChanged: (value) {
                  cubit.updateLineItemField(
                    lineItem.lineItemId,
                    'category',
                    value,
                  );
                },
              ),
            ),
          ],
        ),
        DocTextFormField(
          header: DocFieldHeader.description,
          value: lineItem.description ?? '',
          multiLine: true,
          enabled: !isReadOnly,
          validator: AppValidators.required,
          onChanged: (value) {
            cubit.updateLineItemField(
              lineItem.lineItemId,
              'description',
              value,
            );
          },
        ),
        DocTextFormField(
          header: DocFieldHeader.total,
          value: lineItem.total.toStringAsFixed(2),
          enabled: !isReadOnly,
          validator: AppValidators.number,
          onChanged: (value) {
            cubit.updateLineItemField(lineItem.lineItemId, 'amount', value);
          },
        ),
        const SizedBox(height: 10),
        DynamicKeyValueSection(
          title: 'Additional Line Info',
          rows: lineItem.attribute,
          isReadOnly: isReadOnly,
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
}

const List<String> lineCategory = [
  'Product Revenue',
  'Service Revenue',
  'Subscription Revenue',
  'Rental Revenue',
  'Other Operating Revenue',
  'Sales Returns',
  'Sales Discounts',
  'Sales Allowances',
  'Interest Income',
  'Dividend Income',
  'Investment Gains',
  'Insurance Claims',
  'Gain on Sale of Assets',
  'Other Income',
  'Opening Inventory',
  'Purchases',
  'Delivery Fees',
  'Purchase Returns',
  'Purchase Discounts',
  'Closing Inventory',
  'Other Cost of Goods Sold',
  'Direct Labor Costs',
  'Contractor Costs',
  'Other Cost of Services',
  'Advertising',
  'Sales Commissions',
  'Sales Salaries',
  'Travel & Entertainment',
  'Shipping/Delivery-Out',
  'Office Salaries',
  'Office Rent',
  'Office Utilities',
  'Office Supplies',
  'Telephone & Internet',
  'Repairs & Maintenance',
  'Insurance',
  'Professional Fees',
  'Bank Charges',
  'Training & Development',
  'Depreciation (Office, Equipment, Vehicles)',
  'Amortization (Patents, Trademarks, Software)',
  'Licenses & Permits',
  'Security',
  'Outsourcing Expenses',
  'Subscriptions & Tools',
  'HR & Recruiting',
  'Interest Expense',
  'Loss on Sale of Assets',
  'Investment Losses',
  'Penalties & Fines',
  'Legal Settlements',
  'Impairment Losses',
  'Other Expenses',
  'Purchase of Assets',
  'Money Lent to Others',
  'Money Collected from Others',
  'Stock',
  'Stock Repurchase',
  'Dividend Payment',
  'Debt',
  'Debt Repayment',
  'Notes Payable',
  'Notes Repayment',
  'Cash & Cash Equivalents',
  'Intangible Assets',
  'Long-term Investments',
  'Other Assets',
  'Shared Premium',
  'Owner Investment',
  'Owner Drawing',
  'Partner Investment',
  'Partner Drawing',
  'Tax Expense',
];
