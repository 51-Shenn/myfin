import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:myfin/core/components/bottom_nav_bar.dart';
import 'package:myfin/features/report/domain/entities/report.dart';
import 'package:myfin/features/report/domain/repositories/report_repository.dart';
import 'package:myfin/features/report/presentation/bloc/report_bloc.dart';
import 'package:myfin/features/report/presentation/bloc/report_event.dart';
import 'package:myfin/features/report/presentation/bloc/report_state.dart';

class ReportHistoryScreen extends StatefulWidget {
  const ReportHistoryScreen({super.key});

  @override
  State<ReportHistoryScreen> createState() => _ReportHistoryScreenState();
}

class _ReportHistoryScreenState extends State<ReportHistoryScreen> {
  String member_id = "";

  void _showErrorSnackBar(BuildContext context, String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  void initState() {
    super.initState();
    // Get member_id from current authenticated user
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      member_id = user.uid;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          ReportBLoC(context.read<ReportRepository>())
            ..add(LoadReportsEvent(member_id)),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          scrolledUnderElevation: 0,
          automaticallyImplyLeading: true,
          title: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.attach_file, color: Colors.black, size: 28),
              const SizedBox(width: 8),
              const Text(
                'Reports',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Inter',
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
          centerTitle: true,
        ),
        body: BlocListener<ReportBLoC, ReportState>(
          listener: (context, state) {
            if (state.error != null) {
              _showErrorSnackBar(context, state.error!);
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  context.read<ReportBLoC>().add(ClearErrorEvent());
                }
              });
            }

            // Navigate to generated report after successful creation
            if (!state.generatingReport &&
                state.loadedReportDetails.report_id.isNotEmpty) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  final report = state.loadedReportDetails;
                  NavBarController.of(context)?.toggleNavBar();
                  Navigator.pushNamed(
                    context,
                    '/report_${report.report_type.reportTypeToString.toLowerCase().trim().replaceAll(' ', '_')}',
                    arguments: report,
                  );
                }
              });
            }
          },
          child: BlocBuilder<ReportBLoC, ReportState>(
            builder: (context, state) {
              if (state.loadingReports && state.loadedReports.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state.error != null) {
                return Center(
                  child: Text(
                    state.error!,
                    style: const TextStyle(color: Colors.red),
                  ),
                );
              }

              final reports = state.loadedReports;

              return Padding(
                padding: const EdgeInsets.all(4.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!state.loadingReports && state.loadedReports.isEmpty)
                      Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Center(
                          child: Column(
                            children: [
                              Icon(
                                Icons.description,
                                size: 64,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No reports found',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 8),
                              ElevatedButton(
                                onPressed: () {
                                  context.read<ReportBLoC>().add(
                                    LoadReportsEvent(member_id),
                                  );
                                },
                                child: const Text('Refresh'),
                              ),
                            ],
                          ),
                        ),
                      ),

                    if (state.loadedReports.isNotEmpty && !state.loadingReports)
                      Expanded(
                        child: ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: reports.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            return ReportCard(report: reports[index]);
                          },
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class ReportCard extends StatelessWidget {
  final Report report;

  const ReportCard({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: const Color(0xFFC0C9FF),
            borderRadius: BorderRadius.circular(27),
          ),
          child: const Icon(
            Icons.description_outlined,
            color: Color(0xFF8796F8),
            size: 24,
          ),
        ),
        title: Text(
          report.report_type.reportTypeToString,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            _toDateRange(report.fiscal_period),
            style: TextStyle(fontSize: 13, color: Colors.grey[800]),
          ),
        ),
        trailing: Icon(Icons.chevron_right, color: Colors.grey[600]),
        onTap: () {
          NavBarController.of(context)?.toggleNavBar();
          Navigator.pushNamed(
            context,
            '/report_${report.report_type.reportTypeToString.toLowerCase().trim().replaceAll(' ', '_')}',
            arguments: report,
          );
        },
      ),
    );
  }
}

// format fiscal period to date range
String _toDateRange(Map<String, DateTime> period) {
  final startDate = period['startDate'];
  final endDate = period['endDate'];

  final formatter = DateFormat('dd/MM/yyyy');

  if (startDate != null && endDate != null) {
    final startStr = formatter.format(startDate);
    final endStr = formatter.format(endDate);
    return '$startStr - $endStr';
  }

  return 'Invalid Date';
}
