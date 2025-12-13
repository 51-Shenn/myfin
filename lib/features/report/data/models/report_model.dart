// data transfer object DTO for report
class ReportModel {
  final String report_id;
  final DateTime generated_at;
  final Map<String, DateTime> fiscal_period;
  final String report_type;
  final String member_id;

  ReportModel({
    required this.report_id,
    required this.generated_at,
    required this.fiscal_period,
    required this.report_type,
    required this.member_id,
  });

  factory ReportModel.fromJson(Map<String, dynamic> json) {
    return ReportModel(
      report_id: json['report_id'],
      generated_at: DateTime.parse(json['generated_at']),
      fiscal_period: {
        'startDate': DateTime.parse(json['fiscal_period']['startDate']),
        'endDate': DateTime.parse(json['fiscal_period']['endDate']),
      },
      report_type: json['report_type'],
      member_id: json['member_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'report_id': report_id,
      'generated_at': generated_at.toIso8601String(),
      'fiscal_period': {
        'startDate': fiscal_period['startDate']?.toIso8601String(),
        'endDate': fiscal_period['endDate']?.toIso8601String(),
      },
      'report_type': report_type,
      'member_id': member_id,
    };
  }
}