part of 'chat_trigger_cubit.dart';

enum TypingStatus { typing, notTyping }

enum RecordingStatus { recording, notRecording }

class ChatTriggerState extends Equatable {
  final TypingStatus typingStatus;
  final RecordingStatus recordingStatus;

  final bool isExpandedTextField;
  final bool isReply;
  final Message? messageToReply;
  final bool isBlur;
  final bool isToggled;
  final bool isSelect;
  final bool isEditing;
  final bool showEmoji;
  final List<Message> pinnedMessages;
  final Map<String, dynamic> typing;
  final String toggledReaction;
  final bool isFirstLoad;

  final int expandPadding;
  final Duration stopwatchDuration;
  const ChatTriggerState(
      {this.typingStatus = TypingStatus.notTyping,
      this.recordingStatus = RecordingStatus.notRecording,
      this.isExpandedTextField = false,
      this.isReply = false,
      this.messageToReply,
      this.isBlur = false,
      this.isToggled = false,
      this.isSelect = false,
      this.isEditing = false,
      this.showEmoji = false,
      this.pinnedMessages = const [],
      this.typing = const {},
      this.toggledReaction = "",
      this.isFirstLoad = true,
      this.expandPadding = 10,
      this.stopwatchDuration = const Duration()});
  ChatTriggerState copyWith(
      {TypingStatus? typingStatus,
      RecordingStatus? recordingStatus,
      bool? isExpandedTextField,
      bool? isReply,
      Message? messageToReply,
      bool? isBlur,
      bool? isToggled,
      List<Message>? pinnedMessages,
      bool? isSelect,
      bool? isEditing,
      bool? showEmoji,
      Map<String, dynamic>? typing,
      String? toggledReaction,
      bool? isFirstLoad,
      int? expandPadding,
      Duration? stopwatchDuration}) {
    return ChatTriggerState(
      typingStatus: typingStatus ?? this.typingStatus,
      isExpandedTextField: isExpandedTextField ?? this.isExpandedTextField,
      isReply: isReply ?? this.isReply,
      messageToReply: messageToReply ?? this.messageToReply,
      isBlur: isBlur ?? this.isBlur,
      isToggled: isToggled ?? this.isToggled,
      isSelect: isSelect ?? this.isSelect,
      recordingStatus: recordingStatus ?? this.recordingStatus,
      pinnedMessages: pinnedMessages ?? this.pinnedMessages,
      isEditing: isEditing ?? this.isEditing,
      showEmoji: showEmoji ?? this.showEmoji,
      typing: typing ?? this.typing,
      toggledReaction: toggledReaction ?? this.toggledReaction,
      isFirstLoad: isFirstLoad ?? this.isFirstLoad,
      stopwatchDuration: stopwatchDuration ?? this.stopwatchDuration,
    );
  }

  @override
  List<Object?> get props => [
        typingStatus,
        isExpandedTextField,
        messageToReply,
        isReply,
        isBlur,
        isToggled,
        isSelect,
        recordingStatus,
        pinnedMessages,
        isEditing,
        typing,
        showEmoji,
        toggledReaction,
        isFirstLoad,
        expandPadding,
        stopwatchDuration
      ];
}
