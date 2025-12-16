import 'package:myfin/features/report/domain/entities/report.dart';
import 'package:myfin/features/upload/domain/entities/doc_line_item.dart';

/// abstract interface for report generators to implement
/// each report type generator must implement these methods
/// - generateSection(String sectionName)
/// - generateGroup(String groupName)
/// - generateItem(String itemName, DocumentLineItem itemData)
/// - generateFullReport(Report report, String businessName, List&lt;DocumentLineItem&gt; reportData)
abstract class ReportGeneratorInterface {
  ReportSection generateSection(String sectionName);

  ReportGroup generateGroup(String groupName);

  ReportLineItem generateItem(String itemName, DocumentLineItem itemData);

  Report generateFullReport(Report report, String businessName, List<DocumentLineItem> reportData);
}
