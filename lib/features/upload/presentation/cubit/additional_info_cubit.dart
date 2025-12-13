import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myfin/features/upload/presentation/cubit/additional_info_state.dart';

class AdditionalInfoCubit extends Cubit<AdditionalInfoState> {
  AdditionalInfoCubit() : super(AdditionalInfoState());

  void addNewRow() {
    final newState = AdditionalInfoState(
      rows: [...state.rows, AdditionalInfoRow(key: '', value: '')],
    );
    emit(newState);
  }

  void updateRowKey(int index, String key) {
    final updatedRows = List<AdditionalInfoRow>.from(state.rows);
    updatedRows[index] = updatedRows[index].copyWith(key: key);
    emit(AdditionalInfoState(rows: updatedRows));
  }

  void updateRowValue(int index, String value) {
    final updatedRows = List<AdditionalInfoRow>.from(state.rows);
    updatedRows[index] = updatedRows[index].copyWith(value: value);
    emit(AdditionalInfoState(rows: updatedRows));
  }

  void deleteRow(int index) {
    final updatedRows = List<AdditionalInfoRow>.from(state.rows);
    updatedRows.removeAt(index);
    emit(AdditionalInfoState(rows: updatedRows));
  }
}