import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:myfin/core/components/bottom_nav_bar.dart';
import 'package:myfin/features/report/domain/entities/report.dart';
import 'package:myfin/features/report/domain/repositories/report_repository.dart';
import 'package:myfin/features/report/presentation/bloc/report_bloc.dart';
import 'package:myfin/features/report/presentation/bloc/report_event.dart';
import 'package:myfin/features/report/presentation/bloc/report_state.dart';

class MainReportScreen extends StatefulWidget {
  const MainReportScreen({super.key});

  @override
  State<MainReportScreen> createState() => _MainReportScreenState();
}

class _MainReportScreenState extends State<MainReportScreen> {
  String? selectedReportType;
  DateTime? startDate;
  DateTime? endDate;
  String member_id = "";

  List<String> reportTypes = [
    ReportType.profitLoss,
    ReportType.cashFlow,
    ReportType.balanceSheet,
    ReportType.accountsPayable,
    ReportType.accountsReceivable,
  ].map((e) => e.reportTypeToString).toList();

  void _showErrorDialog(BuildContext context, String message) {
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.error_outline, color: Colors.red, size: 28),
              const SizedBox(width: 8),
              const Text('Error'),
            ],
          ),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showSuccessSnackBar(BuildContext context, String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  @override
  void initState() {
    super.initState();
    // Get member_id from current authenticated user
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      member_id = user.uid;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        return BlocProvider(
          create: (_) =>
              ReportBLoC(context.read<ReportRepository>())
                ..add(LoadReportsEvent(member_id)),
          child: Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              backgroundColor: Colors.white,
              scrolledUnderElevation: 0,
              title: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.attach_file, color: Colors.black, size: 28),
                  const SizedBox(width: 8),
                  const Text(
                    'Reports',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Inter',
                      letterSpacing: 1.0,
                    ),
                  ),
                ],
              ),
              centerTitle: true,
            ),
            body: BlocListener<ReportBLoC, ReportState>(
              listener: (context, state) {
                if (state.error != null && mounted) {
                  _showErrorDialog(context, state.error!);
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) {
                      context.read<ReportBLoC>().add(ClearErrorEvent());
                    }
                  });
                }
              },
              child: BlocBuilder<ReportBLoC, ReportState>(
                builder: (context, state) {
                  final reports = state.loadedReports;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Report Functions
                      _buildReportFunctions(context),
                      const SizedBox(height: 16),

                      if (state.loadingReports && state.loadedReports.isEmpty)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(48.0),
                            child: CircularProgressIndicator(),
                          ),
                        ),

                      if (state.error != null)
                        Center(
                          child: Text(
                            state.error!,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),

                      // Recent Reports List
                      if (!state.loadingReports && state.loadedReports.isEmpty)
                        Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: Center(
                            child: Column(
                              children: [
                                Icon(
                                  Icons.description,
                                  size: 64,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No reports found',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                ElevatedButton(
                                  onPressed: () {
                                    if (mounted) {
                                      context.read<ReportBLoC>().add(
                                        LoadReportsEvent(member_id),
                                      );
                                    }
                                  },
                                  child: const Text('Refresh'),
                                ),
                              ],
                            ),
                          ),
                        ),

                      if (state.loadedReports.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: reports.length > 2 ? 2 : reports.length,
                            separatorBuilder: (context, index) =>
                                const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final report = reports[index];
                              return RecentReportCard(report: report);
                            },
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildReportFunctions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 32.0,
              vertical: 24.0,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            // Report Function Container
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Report Type Selector
                const Text(
                  'Report Type',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!, width: 1.5),
                    borderRadius: BorderRadius.circular(27),
                  ),

                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: selectedReportType,
                      isExpanded: true,
                      dropdownColor: Colors.white,
                      icon: const Icon(Icons.keyboard_arrow_down),

                      hint: const Text(
                        'Please select type',
                        style: TextStyle(color: Colors.grey),
                      ),

                      items: reportTypes.map((String type) {
                        return DropdownMenuItem<String>(
                          value: type,
                          child: Text(type),
                        );
                      }).toList(),

                      onChanged: (String? newValue) {
                        setState(() {
                          selectedReportType = newValue;
                        });
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Fiscal Period
                const Text(
                  'Fiscal Period',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          _selectDate(context, true);
                        },
                        style: startDate == null
                            ? ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF2B46F9),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(27),
                                ),
                                elevation: 0,
                              )
                            : OutlinedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.black,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(27),
                                  side: const BorderSide(
                                    color: Color(0xFFE0E0E0),
                                    width: 1.5,
                                  ),
                                ),
                                elevation: 0,
                              ),
                        child: Text(
                          startDate == null
                              ? 'Pick Start Date'
                              : _formatDate(startDate),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          _selectDate(context, false);
                        },
                        style: endDate == null
                            ? ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF2B46F9),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(27),
                                ),
                                elevation: 0,
                              )
                            : OutlinedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.black,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(27),
                                  side: const BorderSide(
                                    color: Color(0xFFE0E0E0),
                                    width: 1.5,
                                  ),
                                ),
                                elevation: 0,
                              ),
                        child: Text(
                          endDate == null
                              ? 'Pick End Date'
                              : _formatDate(endDate),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Generate Report Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      // simple validation
                      if (selectedReportType == null) {
                        _showErrorDialog(
                          context,
                          'Please select a Report Type.',
                        );
                        return;
                      }
                      if (startDate == null || endDate == null) {
                        _showErrorDialog(
                          context,
                          'Please select a Start and End Date.',
                        );
                        return;
                      }
                      if (startDate!.isAfter(endDate!)) {
                        _showErrorDialog(
                          context,
                          'Start Date cannot be after End Date.',
                        );
                        return;
                      }

                      context.read<ReportBLoC>().add(
                        GenerateReportEvent(
                          reportType: selectedReportType!,
                          member_id: member_id,
                          startDate: startDate!,
                          endDate: endDate!,
                        ),
                      );
                      print(
                        'Generate Report: $selectedReportType from $startDate to $endDate',
                      );

                      _showSuccessSnackBar(
                        context,
                        'Report generation started!',
                      );

                      // navigate to generated report after generation complete
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2B46F9),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(27),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Generate Report',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Recent Reports Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Recent Reports',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                TextButton(
                  onPressed: () =>
                      Navigator.pushNamed(context, '/report_history'),
                  child: const Text(
                    'View All',
                    style: TextStyle(
                      color: Color(0xFF2D5FFF),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate
          ? (startDate ?? DateTime.now())
          : (endDate ?? DateTime.now()),
      firstDate: DateTime(DateTime.now().year - 100),
      lastDate: DateTime(DateTime.now().year + 1),
    );

    if (picked != null && mounted) {
      setState(() {
        if (isStartDate) {
          startDate = picked;
        } else {
          endDate = picked;
        }
      });
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Select Date';
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}

class RecentReportCard extends StatelessWidget {
  final Report report;

  const RecentReportCard({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: const Color(0xFFC0C9FF),
            borderRadius: BorderRadius.circular(27),
          ),
          child: const Icon(
            Icons.description_outlined,
            color: Color(0xFF8796F8),
            size: 24,
          ),
        ),
        title: Text(
          report.report_type.reportTypeToString,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        subtitle: Text(
          _toDateRange(report.fiscal_period),
          style: TextStyle(fontSize: 13, color: Colors.grey[800]),
        ),
        trailing: Icon(Icons.chevron_right, color: Colors.grey[600]),
        onTap: () {
          NavBarController.of(context)?.toggleNavBar();
          Navigator.pushNamed(
            context,
            '/report_${report.report_type.reportTypeToString.toLowerCase().trim().replaceAll(' ', '_')}',
            arguments: report,
          );
          print(
            'report.report_id : ${report.report_id}, report.report_type.reportTypeToString : ${report.report_type.reportTypeToString}',
          );
        },
      ),
    );
  }
}

// format fiscal period to date range
String _toDateRange(Map<String, DateTime> period) {
  final startDate = period['startDate'];
  final endDate = period['endDate'];

  final formatter = DateFormat('dd/MM/yyyy');

  if (startDate != null && endDate != null) {
    final startStr = formatter.format(startDate);
    final endStr = formatter.format(endDate);
    return '$startStr - $endStr';
  }

  return 'Invalid Date';
}
