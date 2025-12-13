import 'package:equatable/equatable.dart';

class AdditionalInfoState extends Equatable {
  final List<AdditionalInfoRow> rows;

  const AdditionalInfoState({this.rows = const []});

  AdditionalInfoState copyWith({
    List<AdditionalInfoRow>? rows,
  }) {
    return AdditionalInfoState(
      rows: rows ?? this.rows,
    );
  }

  @override
  List<Object> get props => [rows];
}

class AdditionalInfoRow extends Equatable {
  final String id;
  final String key;
  final String value;

  AdditionalInfoRow({
    String? id,
    required this.key,
    required this.value,
  }) : id = id ?? DateTime.now().microsecondsSinceEpoch.toString();

  AdditionalInfoRow copyWith({
    String? id,
    String? key,
    String? value,
  }) {
    return AdditionalInfoRow(
      id: id ?? this.id, // keep the original id
      key: key ?? this.key,
      value: value ?? this.value,
    );
  }

  @override
  List<Object> get props => [id, key, value];
}