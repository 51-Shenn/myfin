// only hold string values for UI display
class ReportUiModel {
  final String report_id;
  final String report_type;
  final String dateRange;

  ReportUiModel({
    required this.report_id,
    required this.report_type,
    required this.dateRange,
  });
}

// state for report viewmodel
class ReportState {
  final bool loading;
  final List<ReportUiModel> reports;
  final String? error;

  ReportState({
    required this.loading,
    required this.reports,
    this.error,
  });

  factory ReportState.initial() =>
      ReportState(loading: false, reports: []);

  ReportState copyWith({
    bool? loading,
    List<ReportUiModel>? reports,
    String? error,
  }) {
    return ReportState(
      loading: loading ?? this.loading,
      reports: reports ?? this.reports,
      error: error,
    );
  }
}