import 'package:myfin/features/dashboard/domain/entities/cash_flow_snapshot.dart';
import 'package:myfin/features/dashboard/domain/repositories/dashboard_repository.dart';

class GetCashFlowDashboardData {
  final DashboardRepository repository;

  GetCashFlowDashboardData(this.repository);

  Future<List<CashFlowSnapshot>> call(String memberId) async {
    return await repository.getCashFlowSnapshots(memberId);
  }
}
