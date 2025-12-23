import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:myfin/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:myfin/features/dashboard/presentation/pages/category_documents_page.dart';

class TransactionList extends StatelessWidget {
  final DashboardLoaded state;

  const TransactionList({super.key, required this.state});

  void _navigateToCategoryDocuments(BuildContext context, String categoryName) {
    final transactionType = state.showMoneyIn ? 'income' : 'expense';

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CategoryDocumentsPage(
          categoryName: categoryName,
          transactionType: transactionType,
          selectedPeriod: state.selectedPeriod,
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String categoryName) {
    switch (categoryName) {
      // Income
      case 'Revenue':
        return Icons.monetization_on_outlined;
      case 'Investment Income':
        return Icons.trending_up;
      case 'Other Income':
        return Icons.add_circle_outline;

      // Expenses
      case 'Cost of Goods/Services':
        return Icons.inventory_2_outlined;
      case 'Operating Expenses':
        return Icons.storefront_outlined;
      case 'Marketing & Sales':
        return Icons.campaign_outlined;
      case 'Financial Costs':
        return Icons.account_balance_outlined;
      case 'Administrative':
        return Icons.admin_panel_settings_outlined;
      case 'Capital Expenditure':
        return Icons.domain_outlined;
      case 'Other Expenses':
        return Icons.receipt_long_outlined;

      default:
        return Icons.category_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoriesMap = state.showMoneyIn
        ? state.currentIncomeCategories
        : state.currentExpenseCategories;

    final currencyFormat = NumberFormat.currency(
      symbol: 'RM ',
      decimalDigits: 2,
    );

    final total = categoriesMap.values.fold(0.0, (sum, val) => sum + val);

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: categoriesMap.length,
      itemBuilder: (context, index) {
        final entry = categoriesMap.entries.elementAt(index);
        final color = _getColorForIndex(index);
        final percent = total > 1 ? (entry.value / total) * 100 : 1.0;
        final displayPercent = percent == 0 ? 0.0 : percent.clamp(1.0, 100.0);
        final icon = _getCategoryIcon(entry.key);

        return GestureDetector(
          onTap: () => _navigateToCategoryDocuments(context, entry.key),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: Colors.grey.shade700),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              entry.key,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerRight,
                              child: Text(
                                currencyFormat.format(entry.value),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 8,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          // Ensure factor is 0.0 - 1.0, but at least 1% (0.01) if > 0 so it's visible
                          widthFactor: percent > 0
                              ? (percent / 100).clamp(0.01, 1.0)
                              : 0.0,
                          child: Container(
                            decoration: BoxDecoration(
                              color: color,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${displayPercent.toStringAsFixed(1)}%',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Color _getColorForIndex(int index) {
    const colors = [
      Color(0xFFFF6384),
      Color(0xFF36A2EB),
      Color(0xFFFFCE56),
      Color(0xFF4BC0C0),
      Color(0xFF9966FF),
      Color(0xFFFF9F40),
    ];
    return colors[index % colors.length];
  }
}
