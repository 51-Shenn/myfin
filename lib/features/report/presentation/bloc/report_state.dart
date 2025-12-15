import 'package:equatable/equatable.dart';

// only hold string values for UI display
class ReportCardUiModel extends Equatable {
  final String report_id;
  final String report_type;
  final String dateRange;

  const ReportCardUiModel({
    required this.report_id,
    required this.report_type,
    required this.dateRange,
  });

  @override
  List<Object> get props => [report_id, report_type, dateRange];
}

// TODO: different report ui model state

// state for report bloc
class ReportState extends Equatable {
  final bool loading;
  final bool generating;
  final List<ReportCardUiModel> reports;
  final String? error;

  const ReportState({required this.loading, required this.reports, this.error, required this.generating});

  factory ReportState.initial() =>
      const ReportState(loading: false, generating: false, reports: []);

  ReportState copyWith({
    bool? loading,
    bool? generating,
    List<ReportCardUiModel>? reports,
    String? error,
  }) {
    return ReportState(
      loading: loading ?? this.loading,
      generating: generating ?? this.generating,
      reports: reports ?? this.reports,
      error: error,
    );
  }

  @override
  List<Object?> get props => [loading, reports, error];
}
