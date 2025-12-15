import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myfin/core/components/bottom_nav_bar.dart';
import 'package:myfin/features/report/data/repositories/report_repository_impl.dart';
import 'package:myfin/features/report/domain/entities/report.dart';
import 'package:myfin/features/report/presentation/bloc/report_bloc.dart';
import 'package:myfin/features/report/presentation/bloc/report_event.dart';
import 'package:myfin/features/report/presentation/bloc/report_state.dart';

class ProfitAndLossReportScreen extends StatefulWidget {
  const ProfitAndLossReportScreen({super.key});

  @override
  State<ProfitAndLossReportScreen> createState() =>
      _ProfitAndLossReportScreenState();
}

class _ProfitAndLossReportScreenState extends State<ProfitAndLossReportScreen> {
  ProfitAndLossReport profitAndLossReport = ProfitAndLossReport.initial();

  void _showErrorSnackBar(BuildContext context, String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    profitAndLossReport =
        ModalRoute.of(context)!.settings.arguments as ProfitAndLossReport;

    return BlocProvider(
      create: (_) =>
          ReportBLoC(ReportRepository())
            ..add(LoadReportDetailsEvent(profitAndLossReport)),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          scrolledUnderElevation: 0,
          automaticallyImplyLeading: false,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            color: Colors.black,
            onPressed: () {
              NavBarController.of(context)?.toggleNavBar();
              Navigator.pop(context);
            },
          ),
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
            if (state.error != null && mounted) {
              _showErrorSnackBar(context, state.error!);
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  context.read<ReportBLoC>().add(ClearErrorEvent());
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

              return Container(
                color: Colors.red,
                child: Padding(
                  padding: EdgeInsetsGeometry.all(16.0),
                  child: Text(profitAndLossReport.report_id),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
