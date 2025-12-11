import 'dart:async';
import 'package:myfin/features/report/domain/entities/report.dart';

// repo implementation
class ReportRepository {
  // testing
  final List<Map<String, dynamic>> _exampleCollection = [
    // {
    //   "report_id": "RPT-001",
    //   "generated_at": "2024-11-10T08:30:00Z",
    //   "fiscal_period": {"startDate": "2024-01-01T00:00:00Z", "endDate": "2024-12-31T23:59:59Z"},
    //   "report_type": "Balance Sheet",
    //   "member_id": "M123",
    // },
    // {
    //   "report_id": "RPT-002",
    //   "generated_at": "2024-10-02T12:00:00Z",
    //   "fiscal_period": {"startDate": "2025-01-01T00:00:00Z", "endDate": "2025-12-31T23:59:59Z"},
    //   "report_type": "P & L Report",
    //   "member_id": "M123",
    // },
  ];

  // fake delay
  Future<void> _delay() async {
    await Future.delayed(Duration(milliseconds: 1000));
  }

  Report _toReport(Map<String, dynamic> json) {
    _delay();
    return Report(
      report_id: json["report_id"],
      generated_at: DateTime.parse(json["generated_at"]),
      fiscal_period: {
        "startDate": DateTime.parse(json["fiscal_period"]["startDate"]),
        "endDate": DateTime.parse(json["fiscal_period"]["endDate"]),
      },
      report_type: json["report_type"],
      member_id: json["member_id"],
    );
  }

  Future<List<Report>> fetchReportsForMember(String memberId) async {
    await _delay();
    final memberReports = _exampleCollection
        .where((doc) => doc["member_id"] == memberId)
        .map(_toReport)
        .toList();
    return memberReports;
  }

  // generate report
  // save report log to firebase
  // fetch data from firebase
  // call report factory to get corresponding report formatter
  // pass report data to report formatter
  // get formatted report -> pass to ui
}
