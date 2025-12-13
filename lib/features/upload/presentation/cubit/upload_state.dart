import 'package:equatable/equatable.dart';
import 'package:myfin/features/upload/domain/entities/document.dart';

abstract class UploadState extends Equatable {
  final List<Document> document;
  const UploadState(this.document);

  @override
  List<Object> get props => [document];
}

class UploadInitial extends UploadState {
  const UploadInitial() : super(const []);
}

class UploadLoading extends UploadState {
  const UploadLoading(super.document);
}

class UploadLoaded extends UploadState {
  const UploadLoaded(super.recentUploads);

  @override
  List<Object> get props => [document];
}

class UploadError extends UploadState {
  final String message;
  const UploadError(super.document, this.message);

  @override
  List<Object> get props => [document, message];
}

class UploadNavigateToManual extends UploadState {
  const UploadNavigateToManual(super.document);
}

class UploadImagePicked extends UploadState {
  final String imagePath;

  const UploadImagePicked(super.document, this.imagePath);

  @override
  List<Object> get props => [document, imagePath];
}

class UploadFilePicked extends UploadState {
  final String filePath;
  final String fileName;

  const UploadFilePicked(super.document, this.filePath, this.fileName);

  @override
  List<Object> get props => [document, filePath, fileName];
}