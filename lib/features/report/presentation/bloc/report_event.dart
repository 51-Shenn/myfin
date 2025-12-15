import 'package:equatable/equatable.dart';
import 'package:myfin/features/report/domain/entities/report.dart';

abstract class ReportEvent extends Equatable {
  const ReportEvent();

  @override
  List<Object> get props => [];
}

class LoadReportsEvent extends ReportEvent {
  final String member_id;

  const LoadReportsEvent(this.member_id);

  @override
  List<Object> get props => [member_id];
}

class ClearErrorEvent extends ReportEvent {
  const ClearErrorEvent();
}

class GenerateReportEvent extends ReportEvent {
  final String reportType;
  final String member_id;
  final DateTime startDate;
  final DateTime endDate;

  const GenerateReportEvent({
    required this.reportType,
    required this.member_id,
    required this.startDate,
    required this.endDate,
  });

  @override
  List<Object> get props => [reportType, member_id, startDate, endDate];
}

class LoadReportDetailsEvent extends ReportEvent {
  final Report reportCard;

  const LoadReportDetailsEvent(this.reportCard);

  @override
  List<Object> get props => [reportCard];
}

class LoadReportDetailsFailure extends ReportEvent {
  const LoadReportDetailsFailure();
}
