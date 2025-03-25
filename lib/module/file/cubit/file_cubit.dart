
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:image_picker/image_picker.dart';
import 'package:protech_mobile_chat_stream/module/file/repository/file_repository.dart';
import 'package:protech_mobile_chat_stream/service/response.dart';
import 'package:protech_mobile_chat_stream/utils/service_locator.dart';

part 'file_state.dart';

class FileCubit extends Cubit<FileState> {
  FileCubit() : super(const FileState());
  final FileRepository _fileRepository = sl<FileRepository>();

  upload({required XFile file}) async {
    emit(state.copyWith(uploadFileStatus: UploadFileStatus.loading));

    final res = await _fileRepository.uploadImage(file: file);
    if (res is MapSuccessResponse) {
      emit(state.copyWith(uploadFileStatus: UploadFileStatus.success));
      return;
    }

    emit(state.copyWith(uploadFileStatus: UploadFileStatus.fail));
  }
}
