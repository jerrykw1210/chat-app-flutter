part of 'settings_cubit.dart';

enum DeleteChatHistoryStatus { initial, success, fail, loading, empty }

class SettingsState extends Equatable {
  const SettingsState(
      {this.deleteChatHistoryStatus = DeleteChatHistoryStatus.initial,
      this.errorMessage});
  final DeleteChatHistoryStatus deleteChatHistoryStatus;
  final String? errorMessage;

  SettingsState copyWith(
      {DeleteChatHistoryStatus? deleteChatHistoryStatus,
      String? errorMessage}) {
    return SettingsState(
        deleteChatHistoryStatus:
            deleteChatHistoryStatus ?? this.deleteChatHistoryStatus,
        errorMessage: errorMessage ?? this.errorMessage);
  }

  @override
  List<Object> get props => [deleteChatHistoryStatus];
}
