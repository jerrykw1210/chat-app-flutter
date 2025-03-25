part of 'conversation_cubit.dart';

enum GetConversationStatus { initial, success, fail, loading, empty }

enum CreateConversationStatus { initial, success, fail, loading, empty }

class ConversationState extends Equatable {
  final GetConversationStatus getConversationStatus;
  final CreateConversationStatus createConversationStatus;
  final List<db.Conversation> localConversations;
  final List<ConversationSettings>? conversationsSettings;
  const ConversationState({
    this.getConversationStatus = GetConversationStatus.initial,
    this.createConversationStatus = CreateConversationStatus.initial,
    this.localConversations = const [],
    this.conversationsSettings,
  });
  ConversationState copyWith({
    GetConversationStatus? getConversationStatus,
    CreateConversationStatus? createConversationStatus,
    List<db.Conversation>? localConversations,
    List<ConversationSettings>? conversationsSettings,
  }) {
    return ConversationState(
      getConversationStatus:
          getConversationStatus ?? this.getConversationStatus,
      localConversations: localConversations ?? this.localConversations,
      createConversationStatus:
          createConversationStatus ?? this.createConversationStatus,
      conversationsSettings:
          conversationsSettings ?? this.conversationsSettings,
    );
  }

  @override
  List<Object?> get props => [
        getConversationStatus,
        localConversations,
        createConversationStatus,
        conversationsSettings
      ];
}
