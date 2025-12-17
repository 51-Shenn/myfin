import 'package:equatable/equatable.dart';
import 'package:myfin/features/admin/domain/entities/tax_regulation.dart';

abstract class TaxRegulationState extends Equatable {
  @override
  List<Object?> get props => [];
}

class TaxRegulationInitial extends TaxRegulationState {}

class TaxRegulationLoading extends TaxRegulationState {}

class TaxRegulationLoaded extends TaxRegulationState {
  final List<TaxRegulation> regulations;

  TaxRegulationLoaded({required this.regulations});

  @override
  List<Object?> get props => [regulations];
}

class TaxRegulationError extends TaxRegulationState {
  final String message;

  TaxRegulationError({required this.message});

  @override
  List<Object?> get props => [message];
}

class TaxRegulationOperationSuccess extends TaxRegulationState {
  final String message;

  TaxRegulationOperationSuccess({required this.message});

  @override
  List<Object?> get props => [message];
}
