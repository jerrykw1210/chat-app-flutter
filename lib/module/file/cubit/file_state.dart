part of 'file_cubit.dart';

enum UploadFileStatus { initial, success, fail, loading, empty }

class FileState extends Equatable {
  const FileState({this.uploadFileStatus = UploadFileStatus.initial});
  final UploadFileStatus uploadFileStatus;

  FileState copyWith({UploadFileStatus? uploadFileStatus}) {
    return FileState(
      uploadFileStatus: uploadFileStatus ?? this.uploadFileStatus,
    );
  }

  @override
  List<Object?> get props => [uploadFileStatus];
}
