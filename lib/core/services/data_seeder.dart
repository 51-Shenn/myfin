import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class DataSeeder {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Uuid _uuid = const Uuid();
  final Random _random = Random();

  // The specific Member ID you provided
  final String targetMemberId = 'umP1hregypZiPlMXFYuOqh6CNNC2';
  final String username = 'SeededUser';

  // Updated List from doc_details.dart
  final List<String> _docTypes = [
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

  // Updated List from doc_details.dart
  final List<String> _statuses = [
    'Draft',
    'Pending Approval',
    'Approved',
    'Posted',
    'Paid',
    'Void',
    'Rejected',
  ];

  // Updated List from doc_line_item_field.dart
  final List<String> _categories = [
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
    'Tax Expense'
  ];

  // Extended generic descriptions to mix and match with the large category list
  final List<String> _descriptions = [
    'Monthly Service Fee', 'Q1 Consultation', 'Office Chairs', 'Dell Monitors',
    'Monthly Office Rent', 'Electricity Bill', 'Water Bill', 'Internet Subscription',
    'Grab Ride to Airport', 'Team Lunch', 'Client Entertainment', 'Google Ads Campaign',
    'Facebook Marketing', 'Audit Services', 'Legal Fees', 'Tax Submission',
    'Software License', 'Cloud Server Hosting', 'Cleaning Services', 'Security Deposit',
    'Laptop Purchase', 'Stationery Batch A', 'Printer Toner', 'Repair Services',
    'Annual Insurance Premium', 'Bank Service Charge', 'Interest Payment'
  ];

  Future<void> seedData() async {
    print("🌱 Starting Data Seed for $targetMemberId...");

    final batch = _firestore.batch();
    
    // Generate 30 Documents as requested
    for (int i = 0; i < 150; i++) {
      // 1. Prepare Document Data
      final String docId = _firestore.collection('documents').doc().id;
      // Random date within the last 90 days
      final DateTime docDate = DateTime.now().subtract(Duration(days: _random.nextInt(90)));
      final String docType = _docTypes[_random.nextInt(_docTypes.length)];
      
      final docData = {
        'memberId': targetMemberId,
        'name': '$docType #${1000 + i} - ${_descriptions[_random.nextInt(_descriptions.length)]}',
        'type': docType,
        'status': _statuses[_random.nextInt(_statuses.length)],
        'createdBy': username,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'postingDate': Timestamp.fromDate(docDate),
        'metadata': [
          {'id': _uuid.v4(), 'key': 'Vendor', 'value': 'Tech Corp Sdn Bhd'},
          {'id': _uuid.v4(), 'key': 'Payment Term', 'value': '30 Days'},
        ],
        'refDocType': null,
        'refDocId': null,
        'imageBase64': null, 
      };

      // Add Document to Batch
      final docRef = _firestore.collection('documents').doc(docId);
      batch.set(docRef, docData);

      // 2. Generate 1-5 Line Items for this Document
      int lineItemCount = _random.nextInt(4) + 1; // 1 to 5 items
      
      for (int j = 0; j < lineItemCount; j++) {
        final String lineId = _firestore.collection('document_line_items').doc().id;
        double amount = (_random.nextDouble() * 2000) + 50; // Random amount 50.00 - 2050.00
        
        final lineData = {
          'documentId': docId,
          'lineNo': j + 1,
          'lineDate': Timestamp.fromDate(docDate),
          'categoryCode': _categories[_random.nextInt(_categories.length)],
          'description': _descriptions[_random.nextInt(_descriptions.length)],
          'total': double.parse(amount.toStringAsFixed(2)),
          'debit': 0.0, // Simplified: Keeping 0.0 as per logic
          'credit': 0.0, // Simplified: Keeping 0.0 as per logic
          'attribute': [
             {'id': _uuid.v4(), 'key': 'Department', 'value': 'General'},
          ],
        };

        final lineRef = _firestore.collection('document_line_items').doc(lineId);
        batch.set(lineRef, lineData);
      }
    }

    // Commit Batch
    await batch.commit();
    print("✅ Successfully seeded 30 documents and their line items for $targetMemberId");
  }
}