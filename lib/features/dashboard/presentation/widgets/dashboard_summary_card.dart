import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:myfin/features/dashboard/presentation/bloc/dashboard_bloc.dart';

class DashboardSummaryCard extends StatelessWidget {
  final DashboardLoaded state;

  const DashboardSummaryCard({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      symbol: 'RM ',
      decimalDigits: 2,
    );
    final snapshot = state.currentSnapshot;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6B73FF), Color(0xFF000DFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6B73FF).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Total Balance',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            currencyFormat.format(state.totalBalance),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                state.incomeChangePercent >= 0
                    ? Icons.trending_up
                    : Icons.trending_down,
                color: state.incomeChangePercent >= 0
                    ? Colors.greenAccent
                    : Colors.redAccent,
                size: 20,
              ),
              const SizedBox(width: 4),
              Text(
                '${state.incomeChangePercent >= 0 ? '+' : ''}${state.incomeChangePercent}% this month',
                style: TextStyle(
                  color: state.incomeChangePercent >= 0
                      ? Colors.greenAccent
                      : Colors.redAccent,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _buildInfoItem(
                  'Income',
                  snapshot.totalIncome,
                  Icons.arrow_upward,
                  Colors.greenAccent,
                  currencyFormat,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildInfoItem(
                  'Expense',
                  snapshot.totalExpense,
                  Icons.arrow_downward,
                  Colors.redAccent,
                  currencyFormat,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(
    String label,
    double value,
    IconData icon,
    Color iconColor,
    NumberFormat fmt,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
              Text(
                fmt.format(value).replaceAll('RM ', ''),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
