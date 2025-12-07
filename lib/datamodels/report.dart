class Report {
  final String report_id;
  final DateTime generated_at;
  final Map<String, DateTime> fiscal_period;
  final String report_type;
  final String member_id;

  Report({
    required this.report_id,
    required this.generated_at,
    required this.fiscal_period,
    required this.report_type,
    required this.member_id,
  });

  @override
  String toString() {
    return 'Report(ID: $report_id, Type: $report_type, Period: ${fiscal_period['startDate']} - ${fiscal_period['endDate']})';
  }
}