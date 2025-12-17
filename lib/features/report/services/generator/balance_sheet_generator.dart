// prepare balance sheet report data for page viewing

import 'package:myfin/features/report/domain/entities/report.dart';
import 'package:myfin/features/report/services/generator/report_template.dart';
import 'package:myfin/features/upload/domain/entities/doc_line_item.dart';
import 'package:myfin/features/upload/domain/entities/document.dart';

class BalanceSheetGenerator {
  final template = BalanceSheetTemplate();

  Report generateFullReport(Report report, String businessName,  List<Document> docData, List<DocumentLineItem> docLineData) {
    // TODO: implement generateFullReport
    throw UnimplementedError();
  }

  ReportGroup generateGroup(String groupName) {
    // TODO: implement generateGroup
    throw UnimplementedError();
  }

  ReportLineItem generateItem(String itemName, DocumentLineItem itemData) {
    // TODO: implement generateItem
    throw UnimplementedError();
  }

  ReportSection generateSection(String sectionName) {
    // TODO: implement generateSection
    throw UnimplementedError();
  }

}