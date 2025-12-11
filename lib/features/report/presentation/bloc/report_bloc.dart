import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:myfin/features/report/data/repositories/report_repository_impl.dart';
import 'package:myfin/features/report/presentation/bloc/report_event.dart';
import 'package:myfin/features/report/presentation/bloc/report_state.dart';

class ReportBLoC extends Bloc<ReportEvent, ReportState> {
  final ReportRepository repo;

  ReportBLoC(this.repo) : super(ReportState.initial()) {
    // event handlers
    // ui call event -> invoke function -> emit new state
    on<LoadReportsEvent>(_onLoadReports);
    on<ClearErrorEvent>(_onClearError);
    on<GenerateReportEvent>(_onGenerateReport);
  }

  Future<void> _onLoadReports(
    LoadReportsEvent event,
    Emitter<ReportState> emit,
  ) async {
    emit(state.copyWith(loading: true, generating: false, error: null));

    try {
      final reports = await repo.fetchReportsForMember(event.member_id);

      final uiReports = reports.map((report) {
        final dateRange = _toDateRange(report.fiscal_period);

        return ReportUiModel(
          report_id: report.report_id,
          report_type: report.report_type,
          dateRange: dateRange,
        );
      }).toList();

      emit(ReportState(loading: false, generating: false, reports: uiReports));
    } catch (e) {
      emit(
        state.copyWith(
          loading: false,
          error: "Failed to load reports: ${e.toString()}",
        ),
      );
    }
  }

  void _onClearError(ClearErrorEvent event, Emitter<ReportState> emit) {
    emit(state.copyWith(error: null));
  }

  Future<void> _onGenerateReport(
    GenerateReportEvent event,
    Emitter<ReportState> emit,
  ) async {
    emit(state.copyWith(generating: true, error: null));

    try {
      final fiscal_period = _toFiscalPeriod(event.startDate, event.endDate);

      // call generate report func pass fiscal_period, report_type, member_id

      emit(state.copyWith(generating: false));

      // reload reports list
      await _onLoadReports(LoadReportsEvent(event.member_id), emit);
    } catch (e) {
      emit(
        state.copyWith(
          generating: false,
          error: "Failed to generate report: ${e.toString()}",
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

  // format startDate and endDate to fiscal period
  Map<String, DateTime> _toFiscalPeriod(DateTime startDate, DateTime endDate) {
    return {'startDate': startDate, 'endDate': endDate};
  }
}
