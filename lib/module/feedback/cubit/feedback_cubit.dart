import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:image_picker/image_picker.dart';
import 'package:protech_mobile_chat_stream/constants/string_constant.dart';
import 'package:protech_mobile_chat_stream/module/feedback/repository/feedback_repository.dart';
import 'package:protech_mobile_chat_stream/module/file/repository/file_repository.dart';
import 'package:protech_mobile_chat_stream/service/response.dart';
import 'package:protech_mobile_chat_stream/utils/service_locator.dart';

part 'feedback_state.dart';

class FeedbackCubit extends Cubit<FeedbackState> {
  FeedbackCubit() : super(FeedbackState());
  final FeedbackRepository _feedbackRepository = sl<FeedbackRepository>();
  final FileRepository _fileRepository = sl<FileRepository>();

  void submitFeedback(
      {required String content,
      required String category,
      required List<XFile> attachment}) async {
    emit(state.copyWith(submitFeedbackStatus: SubmitFeedbackStatus.loading));
    List<Future<Response>> uploadFutures = [];
    List<String> attachmentList = [];

    if (attachment.isNotEmpty) {
      for (XFile img in attachment) {
        uploadFutures
            .add(_feedbackRepository.uploadFeedbackImage(attachment: img));
      }
    }

    List<Response> uploadRes = await Future.wait(uploadFutures);

    for (Response res in uploadRes) {
      log("upload response $res");

      if (res is ConnectionRefusedResponse ||
          res is TimeoutResponse ||
          res is NoInternetResponse) {
        emit(state.copyWith(
            submitFeedbackStatus: SubmitFeedbackStatus.fail,
            errorMessage: Strings.unableToConnectToServer));
        return;
      }

      if (res is MapSuccessResponse) {
        if (res.jsonRes.containsKey('data')) {
          attachmentList.add(res.jsonRes['data']['fileUrl']);
        }
      }
    }

    final res = await _feedbackRepository.submitFeedback(
        content: content, category: category, attachment: attachmentList);

    if (res is MapSuccessResponse) {
      emit(state.copyWith(submitFeedbackStatus: SubmitFeedbackStatus.success));
      return;
    }

    emit(state.copyWith(submitFeedbackStatus: SubmitFeedbackStatus.fail));
  }
}
