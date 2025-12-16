import 'package:equatable/equatable.dart';
import 'package:myfin/features/upload/domain/entities/document.dart';

abstract class UploadHistoryState extends Equatable {
  const UploadHistoryState();
  @override
  List<Object> get props => [];
}

class UploadHistoryInitial extends UploadHistoryState {}

class UploadHistoryLoading extends UploadHistoryState {}

class UploadHistoryLoaded extends UploadHistoryState {
  final List<Document> documents;
  const UploadHistoryLoaded(this.documents);
  @override
  List<Object> get props => [documents];
}

class UploadHistoryError extends UploadHistoryState {
  final String message;
  const UploadHistoryError(this.message);
  @override
  List<Object> get props => [message];
}