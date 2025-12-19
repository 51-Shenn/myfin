import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:myfin/features/dashboard/presentation/bloc/dashboard_bloc.dart';

class CashFlowChart extends StatelessWidget {
  final DashboardLoaded state;

  const CashFlowChart({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    // Determine which categories to show based on state
    final categoriesMap = state.showMoneyIn
        ? state.currentIncomeCategories
        : state.currentExpenseCategories;

    if (categoriesMap.isEmpty) {
      return Column(
        children: [
          SizedBox(
            height: 200,
            child: PieChart(
              PieChartData(
                sectionsSpace: 0,
                centerSpaceRadius: 50,
                sections: [
                  PieChartSectionData(
                    color: Colors.grey,
                    value: 100,
                    title: '0%',
                    radius: 45,
                    showTitle: true,
                    titleStyle: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    final total = categoriesMap.values.fold(0.0, (sum, val) => sum + val);

    return Column(
      children: [
        SizedBox(
          height: 200,
          child: PieChart(
            PieChartData(
              sectionsSpace: 0,
              centerSpaceRadius: 50,
              sections: categoriesMap.entries.map((entry) {
                final isTouched = false;
                final fontSize = isTouched ? 14.0 : 11.0;
                final radius = isTouched ? 55.0 : 45.0;
                final index = categoriesMap.keys.toList().indexOf(entry.key);
                final color = _getColorForIndex(index);

                final percent = total > 0 ? (entry.value / total) * 100 : 0.0;
                final showPercentage = percent >= 5;

                return PieChartSectionData(
                  color: color,
                  value: entry.value,
                  title: showPercentage ? '${percent.toStringAsFixed(1)}%' : '',
                  radius: radius,
                  titleStyle: TextStyle(
                    fontSize: fontSize,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Legend
        Wrap(
          spacing: 12,
          runSpacing: 8,
          children: categoriesMap.entries.map((entry) {
            final index = categoriesMap.keys.toList().indexOf(entry.key);
            final color = _getColorForIndex(index);
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  entry.key,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ],
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
