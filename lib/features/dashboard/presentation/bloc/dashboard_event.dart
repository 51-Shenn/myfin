part of 'dashboard_bloc.dart';

abstract class DashboardEvent extends Equatable {
  const DashboardEvent();

  @override
  List<Object> get props => [];
}

class DashboardLoadRequested extends DashboardEvent {
  final String memberId;

  const DashboardLoadRequested(this.memberId);

  @override
  List<Object> get props => [memberId];
}

class DashboardFiscalPeriodChanged extends DashboardEvent {
  final String period;

  const DashboardFiscalPeriodChanged(this.period);

  @override
  List<Object> get props => [period];
}

class DashboardMoneyTypeChanged extends DashboardEvent {
  final bool showMoneyIn; // true = Money In, false = Money Out

  const DashboardMoneyTypeChanged(this.showMoneyIn);

  @override
  List<Object> get props => [showMoneyIn];
}

class DashboardSubscriptionRequested extends DashboardEvent {
  final String memberId;

  const DashboardSubscriptionRequested(this.memberId);

  @override
  List<Object> get props => [memberId];
}

class DashboardRefreshRequested extends DashboardEvent {
  final String memberId;

  const DashboardRefreshRequested(this.memberId);

  @override
  List<Object> get props => [memberId];
}
