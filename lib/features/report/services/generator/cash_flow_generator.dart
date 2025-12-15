// prepare cash flow statement report data for page viewing

import 'package:myfin/features/report/services/generator/report_generator_interface.dart';
import 'package:myfin/features/report/domain/entities/report.dart';
import 'package:myfin/features/report/services/generator/report_template.dart';
import 'package:myfin/features/upload/domain/entities/doc_line_item.dart';

class CashFlowGenerator implements ReportGeneratorInterface {
  final template = CashFlowTemplate();

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