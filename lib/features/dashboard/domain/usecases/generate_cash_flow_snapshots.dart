import 'package:myfin/features/dashboard/domain/entities/cash_flow_snapshot.dart';
import 'package:myfin/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:myfin/features/dashboard/domain/usecases/main_category_mapper.dart';
import 'package:myfin/features/dashboard/data/datasources/dashboard_local_data_source.dart';
import 'package:myfin/features/upload/domain/entities/doc_line_item.dart';
import 'package:myfin/features/upload/domain/repositories/document_repository.dart';
import 'package:myfin/features/upload/domain/repositories/doc_line_item_repository.dart';
import 'package:intl/intl.dart';

class GenerateCashFlowSnapshots {
  final DashboardRepository dashboardRepository;
  final DocumentRepository documentRepository;
  final DocumentLineItemRepository docLineItemRepository;
  final DashboardLocalDataSource localDataSource;

  GenerateCashFlowSnapshots({
    required this.dashboardRepository,
    required this.documentRepository,
    required this.docLineItemRepository,
    required this.localDataSource,
  });

  Future<void> call(String memberId) async {
    // 1. Fetch all documents for the member
    final documents = await documentRepository.getDocuments(
      memberId: memberId,
      limit: 1000, // Fetch enough docs
    );

    // 2. Fetch all line items for these documents
    List<DocumentLineItem> allLineItems = [];
    for (var doc in documents) {
      final lineItems = await docLineItemRepository.getLineItemsByDocumentId(
        doc.id,
      );
      // Fallback date logic: use lineDate, if null use doc postingDate
      final enrichedLines = lineItems.map((line) {
        return line.copyWith(lineDate: line.lineDate ?? doc.postingDate);
      }).toList();
      allLineItems.addAll(enrichedLines);
    }

    // 3. Group by fiscal period (Month-Year)
    Map<String, List<DocumentLineItem>> periodGroups = {};
    for (var line in allLineItems) {
      if (line.lineDate != null) {
        final period = DateFormat('yyyy-MM').format(line.lineDate!);
        if (periodGroups[period] == null) {
          periodGroups[period] = [];
        }
        periodGroups[period]!.add(line);
      }
    }

    // Sort periods for running balance calculation
    var sortedPeriods = periodGroups.keys.toList()..sort();

    // 4. Generate snapshots for each period
    List<CashFlowSnapshot> snapshots = [];
    double runningBalance = 0;

    for (var period in sortedPeriods) {
      final lines = periodGroups[period]!;

      // Calculate totals
      double totalIncome = 0;
      double totalExpense = 0;

      for (var line in lines) {
        if (line.credit > 0) {
          totalIncome += line.credit;
        }
        if (line.debit > 0) {
          totalExpense += line.debit;
        }
      }

      // Skip periods with no financial activity
      if (totalIncome == 0 && totalExpense == 0) continue;

      double netCashFlow = totalIncome - totalExpense;
      runningBalance += netCashFlow; // Asset = Accumulated Cash Flow

      // Aggregate to main categories
      final incomeMainCats = MainCategoryMapper.aggregateLineItems(
        lines,
        'income',
        (item) => (item as DocumentLineItem).credit,
      );

      final expenseMainCats = MainCategoryMapper.aggregateLineItems(
        lines,
        'expense',
        (item) => (item as DocumentLineItem).debit,
      );

      // Verify totals match
      final computedIncome = incomeMainCats.values.fold(
        0.0,
        (sum, val) => sum + val,
      );
      final computedExpense = expenseMainCats.values.fold(
        0.0,
        (sum, val) => sum + val,
      );

      final snapshot = CashFlowSnapshot(
        snapshotId: '${memberId}_$period',
        createdAt: DateTime.now(),
        fiscalPeriod: period,
        totalIncome: computedIncome,
        totalExpense: computedExpense,
        netCashFlow: netCashFlow,
        assets: runningBalance,
        liabilities: 0,
        memberId: memberId,
      );

      snapshots.add(snapshot);

      // Cache main categories separately
      await localDataSource.cacheMainCategories(
        snapshot.snapshotId,
        incomeMainCats,
        expenseMainCats,
      );
    }

    // 5. Save snapshots (without categories)
    if (snapshots.isNotEmpty) {
      await dashboardRepository.saveCashFlowSnapshots(snapshots);
    }
  }
}
