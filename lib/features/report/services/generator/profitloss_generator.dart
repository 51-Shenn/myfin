// prepare profit and loss report data for page viewing

// get template
// initialize empty list of sections
// for each section in template
//  map each group
//   sum total for all matching doc line item with same group title category
//   return group title and total
//  to list
//  calculate section total from group totals
//  add new section to list
// return report data model with sections list

import 'package:myfin/features/report/domain/entities/report.dart';
import 'package:myfin/features/report/services/generator/report_generator_interface.dart';

class ProfitLossGenerator implements ReportGeneratorInterface {
  @override
  Report generateFullReport(Map<String, dynamic> reportData) {
    // TODO: implement generateFullReport
    throw UnimplementedError();
  }

  @override
  List<double> generateGrandTotal(double amount) {
    // TODO: implement generateGrandTotal
    throw UnimplementedError();
  }

  @override
  List<String> generateGroupHeader(String groupName) {
    // TODO: implement generateGroupHeader
    throw UnimplementedError();
  }

  @override
  List<String> generateItemHeader(String itemName, {Map<String, dynamic>? itemData}) {
    // TODO: implement generateItemHeader
    throw UnimplementedError();
  }

  @override
  List<String> generateReportTitle(Report report, String businessName) {
    // TODO: implement generateReportTitle
    throw UnimplementedError();
  }

  @override
  List<String> generateSectionHeader(String sectionName) {
    // TODO: implement generateSectionHeader
    throw UnimplementedError();
  }

  @override
  List<double> generateSubtotal(String groupName, double amount) {
    // TODO: implement generateSubtotal
    throw UnimplementedError();
  }

  @override
  List<double> generateTotal(String sectionName, double amount) {
    // TODO: implement generateTotal
    throw UnimplementedError();
  }

}
