import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myfin/features/report/data/repositories/report_repository_impl.dart';
import 'package:myfin/features/report/presentation/bloc/report_bloc.dart';
import 'package:myfin/features/report/presentation/bloc/report_state.dart';

class ReportHistoryScreen extends StatefulWidget {
  const ReportHistoryScreen({super.key});

  @override
  State<ReportHistoryScreen> createState() => _ReportHistoryScreenState();
}

class _ReportHistoryScreenState extends State<ReportHistoryScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ReportViewmodel(ReportRepository())..loadReports("M123"),
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
        body: BlocBuilder<ReportViewmodel, ReportState>(
          builder: (context, state) {
            if (state.loading) {
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

            final reports = state.reports;

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: reports.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                return ReportCard(report: reports[index]);
              },
            );
          },
        ),
      ),
    );
  }
}

class ReportCard extends StatelessWidget {
  final ReportUiModel report;

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
          report.report_type,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            report.dateRange,
            style: TextStyle(fontSize: 13, color: Colors.grey[800]),
          ),
        ),
        trailing: Icon(Icons.chevron_right, color: Colors.grey[600]),
        onTap: () {
          // TODO: navigate to report details
          print('Navigate report details: ${report.report_type}');
        },
      ),
    );
  }
}
