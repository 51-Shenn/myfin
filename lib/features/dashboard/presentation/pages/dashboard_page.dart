import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myfin/features/authentication/presentation/bloc/auth_bloc.dart';
import 'package:myfin/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:myfin/features/dashboard/presentation/widgets/dashboard_summary_card.dart';
import 'package:myfin/features/dashboard/presentation/widgets/cash_flow_chart.dart';
import 'package:myfin/features/dashboard/presentation/widgets/transaction_list.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  void _loadDashboardData() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticatedAsMember) {
      context.read<DashboardBloc>().add(
        DashboardLoadRequested(authState.member.member_id),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, authState) {
        if (authState is AuthAuthenticatedAsMember) {
          context.read<DashboardBloc>().add(
            DashboardLoadRequested(authState.member.member_id),
          );
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text(
            'Dashboard',
            style: TextStyle(
              color: Colors.black,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
        ),
        body: BlocBuilder<DashboardBloc, DashboardState>(
          builder: (context, state) {
            if (state is DashboardInitial) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is DashboardLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is DashboardError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(state.message),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _loadDashboardData,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            } else if (state is DashboardLoaded) {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DashboardSummaryCard(state: state),
                    const SizedBox(height: 24),
                    const Text(
                      'Cash Flow',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.grey.shade200),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          _buildFilterHeader(state),
                          const SizedBox(height: 24),
                          CashFlowChart(state: state),
                          const SizedBox(height: 24),
                          TransactionList(state: state),
                        ],
                      ),
                    ),
                    const SizedBox(height: 80), 
                  ],
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildFilterHeader(DashboardLoaded state) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        state.snapshots.isEmpty
            ? const Text(
                'No Data',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              )
            : DropdownButton<String>(
                value: state.selectedPeriod,
                underline: const SizedBox(),
                icon: const Icon(Icons.keyboard_arrow_down),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                items: state.snapshots.map((s) => s.fiscalPeriod).toSet().map((
                  period,
                ) {
                  return DropdownMenuItem(value: period, child: Text(period));
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    context.read<DashboardBloc>().add(
                      DashboardFiscalPeriodChanged(value),
                    );
                  }
                },
              ),
        Row(
          children: [
            _buildFilterButton(
              context,
              'Money in',
              isActive: state.showMoneyIn,
              onTap: () => context.read<DashboardBloc>().add(
                const DashboardMoneyTypeChanged(true),
              ),
            ),
            const SizedBox(width: 8),
            _buildFilterButton(
              context,
              'Money out',
              isActive: !state.showMoneyIn,
              onTap: () => context.read<DashboardBloc>().add(
                const DashboardMoneyTypeChanged(false),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFilterButton(
    BuildContext context,
    String label, {
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? Colors.blue : Colors.grey.shade300,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.blue : Colors.grey.shade600,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
