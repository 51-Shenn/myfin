import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myfin/features/report/domain/repositories/report_repository.dart';
import 'package:myfin/features/report/presentation/bloc/report_event.dart';
import 'package:myfin/features/report/presentation/bloc/report_state.dart';
import 'package:myfin/features/report/services/generator/report_factory.dart';

class ReportBLoC extends Bloc<ReportEvent, ReportState> {
  final ReportRepository repo;

  ReportBLoC(this.repo) : super(ReportState.initial()) {
    on<LoadReportsEvent>(_onLoadReports);
    on<ClearErrorEvent>(_onClearError);
    on<GenerateReportEvent>(_onGenerateReport);
    on<LoadReportDetailsEvent>(_onLoadReportDetails);
    on<LoadReportDetailsFailure>(_onLoadReporDetailsFail);
  }

  Future<void> _onLoadReports(
    LoadReportsEvent event,
    Emitter<ReportState> emit,
  ) async {
    emit(state.copyWith(loadingReports: true, error: null));

    try {
      final reports = await repo.getReportsByMemberId(event.member_id);

      emit(state.copyWith(loadingReports: false, loadedReports: reports));
    } catch (e) {
      emit(
        state.copyWith(
          loadingReports: false,
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
    emit(
      state.copyWith(
        generatingReport: true,
        loadingReports: false,
        error: null,
      ),
    );

    try {
      final report = ReportFactory.createReportFromEvent(
        event.reportType,
        event.member_id,
        event.startDate,
        event.endDate,
      );

      final generatedReport = await repo.createReport(
        report,
        event.startDate,
        event.endDate,
      );

      if (generatedReport.report_id.isEmpty) {
        emit(
          state.copyWith(
            loadingReports: false,
            generatingReport: false,
            error: 'Failed to generate report id',
          ),
        );
      }

      emit(state.copyWith(generatingReport: false));

      if (generatedReport.report_id.isNotEmpty) {
        emit(state.copyWith(loadedReportDetails: generatedReport));
      }

      // reload reports list
      await _onLoadReports(LoadReportsEvent(event.member_id), emit);
    } catch (e) {
      emit(
        state.copyWith(
          generatingReport: false,
          error: "Failed to generate report: ${e.toString()}",
        ),
      );
    }
  }

  Future<void> _onLoadReportDetails(
    LoadReportDetailsEvent event,
    Emitter<ReportState> emit,
  ) async {
    emit(
      state.copyWith(
        loadingReportDetails: true,
        loadingReports: false,
        generatingReport: false,
        error: null,
      ),
    );

    try {
      final report = await repo.getGeneratedReportByReportId(
        event.reportCard.report_id,
      );

      emit(
        state.copyWith(
          loadingReportDetails: false,
          loadedReportDetails: report,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          loadingReportDetails: false,
          error: "Failed to load report details: ${e.toString()}",
        ),
      );
    }
  }

  Future<void> _onLoadReporDetailsFail(
    LoadReportDetailsFailure event,
    Emitter<ReportState> emit,
  ) async {
    emit(state.copyWith(error: "Failed to load report details"));
  }
}
