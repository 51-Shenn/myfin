import 'package:equatable/equatable.dart';
import 'package:myfin/features/report/domain/entities/report.dart';

// state for report bloc
class ReportState extends Equatable {
  final bool loadingReports;
  final bool generatingReport;
  final bool loadingReportDetails;
  final List<Report> loadedReports;
  final Report loadedReportDetails;
  final String? error;

  const ReportState({
    required this.loadingReports,
    required this.generatingReport,
    required this.loadingReportDetails,
    required this.loadedReports,
    required this.loadedReportDetails,
    this.error,
  });

  factory ReportState.initial() => ReportState(
    loadingReports: false,
    generatingReport: false,
    loadingReportDetails: false,
    loadedReports: [],
    loadedReportDetails: Report.initial(),
  );

  ReportState copyWith({
    bool? loadingReports,
    bool? generatingReport,
    bool? loadingReportDetails,
    List<Report>? loadedReports,
    Report? loadedReportDetails,
    String? error,
  }) {
    return ReportState(
      loadingReports: loadingReports ?? this.loadingReports,
      generatingReport: generatingReport ?? this.generatingReport,
      loadingReportDetails: loadingReportDetails ?? this.loadingReportDetails,
      loadedReports: loadedReports ?? this.loadedReports,
      loadedReportDetails: loadedReportDetails ?? this.loadedReportDetails,
      error: error,
    );
  }

  @override
  List<Object?> get props => [
    loadingReports,
    generatingReport,
    loadingReportDetails,
    loadedReports,
    loadedReportDetails,
    error,
  ];
}
