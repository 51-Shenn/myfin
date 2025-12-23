import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';

class BalancedDataSeeder {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Uuid _uuid = const Uuid();

  // "Created By" name for display purposes
  final String username = 'System Admin';

  Future<void> seedBalancedData() async {
    // 1. Get Current User Dynamically
    final user = FirebaseAuth.instance.currentUser;
    
    if (user == null) {
      print("❌ Error: You must be logged in to seed data.");
      return;
    }

    final String targetMemberId = user.uid;
    print("⚖️ Seeding Balanced Data for User ID: $targetMemberId...");

    final batch = _firestore.batch();
    final DateTime now = DateTime.now();
    // Force date to 1st of current month to ensure it appears in reports
    final DateTime postingDate = DateTime(now.year, now.month, 1, 12, 0, 0);

    // =========================================================================
    // THE BALANCED DATA SET (Assets = 161,800 | Liab+Eq = 161,800)
    // =========================================================================

    // 1. CAPITAL (Equity +100k, Cash +100k)
    await _addDoc(batch, targetMemberId, "Capital Injection", "Capital Injection Record", "Approved", postingDate, [
      _Line("Stock", "Initial Capital", 100000.00, isCredit: true)
    ]);

    // 2. LOAN (Liabilities +50k, Cash +50k)
    // Note: With the code fix, this will correctly increase Cash.
    await _addDoc(batch, targetMemberId, "Business Loan", "Loan Agreement", "Posted", postingDate, [
      _Line("Debt", "Bank Loan", 50000.00, isCredit: true)
    ]);

    // 3. ASSET PURCHASE (Asset +20k, Cash -20k)
    // Note: Your logic auto-calculates 20% depreciation (4k) later.
    await _addDoc(batch, targetMemberId, "Server Purchase", "Asset Purchase Invoice", "Posted", postingDate, [
      _Line("Purchase of Assets", "Dell Servers", 20000.00, isDebit: true)
    ]);

    // 4. REVENUE (Equity +30k, Cash +30k)
    await _addDoc(batch, targetMemberId, "Software Sales", "Sales Invoice", "Posted", postingDate.add(const Duration(days: 1)), [
      _Line("Product Revenue", "App Licensing", 30000.00, isCredit: true)
    ]);

    // 5. EXPENSES (Equity -14.2k, Cash -14.2k)
    // - Rent: 5,000
    // - Salaries: 8,000
    // - Utilities: 1,200
    await _addDoc(batch, targetMemberId, "Office Rent", "Payment Voucher", "Paid", postingDate.add(const Duration(days: 2)), [
      _Line("Office Rent", "HQ Rent", 5000.00, isDebit: true)
    ]);
    
    await _addDoc(batch, targetMemberId, "Staff Salaries", "Payroll Slip", "Posted", postingDate.add(const Duration(days: 15)), [
      _Line("Office Salaries", "Jan Payroll", 8000.00, isDebit: true)
    ]);

    await _addDoc(batch, targetMemberId, "Electric Bill", "Payment Voucher", "Paid", postingDate.add(const Duration(days: 20)), [
      _Line("Office Utilities", "TNB Bill", 1200.00, isDebit: true)
    ]);

    await batch.commit();
    print("✅ Seed Complete! Refresh your Dashboard.");
  }

  Future<void> _addDoc(
    WriteBatch batch, 
    String memberId,
    String name, 
    String type, 
    String status, 
    DateTime date, 
    List<_Line> lines
  ) async {
    final String docId = _firestore.collection('documents').doc().id;

    final docData = {
      'id': docId,
      'memberId': memberId, // USING DYNAMIC ID
      'name': name,
      'type': type,
      'status': status,
      'createdBy': username,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'postingDate': Timestamp.fromDate(date),
      'metadata': [
        {'id': _uuid.v4(), 'key': 'Generated', 'value': 'BalancedSeeder'},
      ],
      'refDocType': null,
      'refDocId': null,
      'imageBase64': null, 
    };

    final docRef = _firestore.collection('documents').doc(docId);
    batch.set(docRef, docData);

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];
      final String lineId = _firestore.collection('document_line_items').doc().id;
      
      final lineData = {
        'lineItemId': lineId,
        'documentId': docId,
        'lineNo': i + 1,
        'lineDate': Timestamp.fromDate(date),
        'categoryCode': line.category,
        'description': line.desc,
        'total': line.amount,
        'debit': line.isDebit ? line.amount : 0.0,
        'credit': line.isCredit ? line.amount : 0.0,
        'attribute': [],
      };

      final lineRef = _firestore.collection('document_line_items').doc(lineId);
      batch.set(lineRef, lineData);
    }
  }
}

class _Line {
  final String category;
  final String desc;
  final double amount;
  final bool isDebit;
  final bool isCredit;

  _Line(this.category, this.desc, this.amount, {this.isDebit = false, this.isCredit = false});
}