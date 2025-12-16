import 'package:flutter/material.dart';
import 'package:myfin/features/report/domain/entities/report.dart';
import 'package:myfin/features/report/presentation/pages/accounts_payable_report.dart';
import 'package:myfin/features/report/presentation/pages/accounts_receivable_report.dart';
import 'package:myfin/features/report/presentation/pages/balance_sheet_report.dart';
import 'package:myfin/features/report/presentation/pages/cash_flow_report.dart';
import 'package:myfin/features/report/presentation/pages/profitloss_report.dart';
import 'package:myfin/features/report/presentation/pages/report_history.dart';
import 'package:myfin/features/report/presentation/pages/report_main.dart';

class ReportsNav extends StatefulWidget {
  const ReportsNav({super.key});

  @override
  State<ReportsNav> createState() => _ReportsNavState();
}

class _ReportsNavState extends State<ReportsNav> {
  GlobalKey<NavigatorState> reportsNavKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: reportsNavKey,
      onGenerateRoute: (RouteSettings settings) {
        return MaterialPageRoute(
          settings: settings,
          builder: (BuildContext context) {
            // routes for report navigation
            if (settings.name == '/report_history') {
              return const ReportHistoryScreen(); // report history screen
            } 

            if (settings.name == '/report_${ReportType.profitLoss.reportTypeToString.toLowerCase().trim().replaceAll(' ', '_')}') {
              return const ProfitAndLossReportScreen(); // profit & loss report screen
            }

            if (settings.name == '/report_${ReportType.cashFlow.reportTypeToString.toLowerCase().trim().replaceAll(' ', '_')}') {
              return const CashFlowStatementScreen(); // cash flow report screen
            }

            if (settings.name == '/report_${ReportType.balanceSheet.reportTypeToString.toLowerCase().trim().replaceAll(' ', '_')}') {
              return const BalanceSheetReportScreen(); // balance sheet report screen
            }
            
            if (settings.name == '/report_${ReportType.accountsPayable.reportTypeToString.toLowerCase().trim().replaceAll(' ', '_')}') {
              return const AccountsPayableReportScreen(); // accounts payable report screen
            }

            if (settings.name == '/report_${ReportType.accountsReceivable.reportTypeToString.toLowerCase().trim().replaceAll(' ', '_')}') {
              return const AccountsReceivableReportScreen(); // accounts receivable report screen
            }

            return const MainReportScreen(); // main report screen
          }
        );
      },
    );
  }
}