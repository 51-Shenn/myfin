import 'package:myfin/features/dashboard/domain/entities/cash_flow_snapshot.dart';
import 'package:myfin/features/dashboard/domain/repositories/dashboard_repository.dart';

class SubscribeToDashboard {
  final DashboardRepository repository;

  SubscribeToDashboard(this.repository);

  Stream<List<CashFlowSnapshot>> call(String memberId) {
    return repository.getSnapshotsStream(memberId);
  }
}
