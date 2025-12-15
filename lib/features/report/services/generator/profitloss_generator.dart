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

import 'package:myfin/features/report/services/generator/report_generator_interface.dart';
import 'package:myfin/features/report/domain/entities/report.dart';
import 'package:myfin/features/report/services/generator/report_template.dart';
import 'package:myfin/features/upload/domain/entities/doc_line_item.dart';

class ProfitLossGenerator implements ReportGeneratorInterface {
  final template = ProfitAndLossTemplate();

  @override
  Report generateFullReport(Report report, String businessName, List<DocumentLineItem> reportData) {
    // TODO: implement generateFullReport
    throw UnimplementedError();
  }

  @override
  ReportGroup generateGroup(String groupName) {
    // TODO: implement generateGroup
    throw UnimplementedError();
  }

  @override
  ReportLineItem generateItem(String itemName, DocumentLineItem itemData) {
    // TODO: implement generateItem
    throw UnimplementedError();
  }

  @override
  ReportSection generateSection(String sectionName) {
    // TODO: implement generateSection
    throw UnimplementedError();
  }

}
