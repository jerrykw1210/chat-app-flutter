
import 'package:bloc/bloc.dart';

import 'package:equatable/equatable.dart';

import 'package:protech_mobile_chat_stream/model/database.dart';
import 'package:protech_mobile_chat_stream/module/file/repository/file_repository.dart';
import 'package:protech_mobile_chat_stream/utils/service_locator.dart';

part 'chat_trigger_state.dart';

class ChatTriggerCubit extends Cubit<ChatTriggerState> {
  ChatTriggerCubit() : super(const ChatTriggerState());
  final FileRepository _fileRepository = sl<FileRepository>();

  isTyping(bool isTyping) {
    if (isTyping) {
      emit(state.copyWith(typingStatus: TypingStatus.typing));
    } else {
      emit(state.copyWith(typingStatus: TypingStatus.notTyping));
    }
  }

  toggleExpandTextFieldBar(bool isExpandedTextField) {
    isExpandedTextField = !isExpandedTextField;
    int expandPadding = state.expandPadding;
    if (isExpandedTextField) {
      expandPadding = 25;
    } else {
      expandPadding = 10;
    }
    emit(state.copyWith(
        isExpandedTextField: isExpandedTextField,
        expandPadding: expandPadding));
  }

  toggleReplyMessage({Message? message}) {
    bool isReply = state.isReply;
    isReply = !isReply;
    emit(state.copyWith(isReply: isReply, messageToReply: message));
  }

  toggleblur() {
    bool isBlur = state.isBlur;
    isBlur = !isBlur;
    emit(state.copyWith(isBlur: isBlur));
  }

  toggleBubble() {
    bool isToggled = state.isToggled;
    isToggled = !isToggled;
    emit(state.copyWith(isToggled: isToggled));
  }

  toggleEditing({Message? message}) {
    bool isEditing = state.isEditing;
    isEditing = !isEditing;
    emit(state.copyWith(
        isEditing: isEditing, messageToReply: message)); // message to edit
  }

  isRecording(bool isRecording) {
    if (isRecording) {
      emit(state.copyWith(recordingStatus: RecordingStatus.recording));
    } else {
      emit(state.copyWith(recordingStatus: RecordingStatus.notRecording));
    }
  }

  toggleSelect() {
    bool isSelect = state.isSelect;
    isSelect = !isSelect;
    emit(state.copyWith(isSelect: isSelect));
  }

  toggleEmoji() {
    bool showEmoji = state.showEmoji;
    showEmoji = !showEmoji;
    emit(state.copyWith(showEmoji: showEmoji));
  }

  // toggleEditing(bool isEditing, {TextMessage? message}) {
  //   isEditing = !isEditing;

  //   emit(state.copyWith(
  //       isEditing: isEditing, messageToReply: message)); // message to ediy
  // }
  toggledReaction(String reactionPath) {
    emit(state.copyWith(toggledReaction: reactionPath));
  }

  isFirstLoad() {
    emit(state.copyWith(isFirstLoad: false));
  }

  saveStopwatchTime(Duration duration) {
    emit(state.copyWith(stopwatchDuration: duration));
  }

  resetState() {
    emit(state.copyWith(
        typingStatus: TypingStatus.notTyping,
        recordingStatus: RecordingStatus.notRecording,
        isExpandedTextField: false,
        isReply: false,
        messageToReply: null,
        isBlur: false,
        pinnedMessages: [],
        isSelect: false,
        isFirstLoad: true));
  }
}
