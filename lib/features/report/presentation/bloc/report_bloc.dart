import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:myfin/features/report/data/repositories/report_repository_impl.dart';
import 'package:myfin/features/report/presentation/bloc/report_state.dart';

class ReportViewmodel extends Cubit<ReportState> {
  final ReportRepository repo;

  ReportViewmodel(this.repo) : super(ReportState.initial());

  // format fiscal period to date range
  String _formatFiscalPeriod(Map<String, DateTime> period) {
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

  Future<void> loadReports(String member_id) async {
    emit(state.copyWith(loading: true, error: null));
    try {
      final reports = await repo.fetchReportsForMember(member_id);

      final uiReports = reports.map((report) {
        final dateRange = _formatFiscalPeriod(report.fiscal_period);

        return ReportUiModel(
          report_id: report.report_id,
          report_type: report.report_type,
          dateRange: dateRange,
        );
      }).toList();

      emit(ReportState(loading: false, reports: uiReports));
    } catch (e) {
      emit(state.copyWith(loading: false, error: "Failed to load reports"));
    }
  }
}