import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:fixnum/fixnum.dart';
import 'package:protech_mobile_chat_stream/model/database.dart';
import 'package:protech_mobile_chat_stream/model/message_status_enum.dart';
import 'package:protech_mobile_chat_stream/module/chat/model/attachment_model.dart';
import 'package:protech_mobile_chat_stream/service/credential_service.dart';
import 'package:protech_mobile_chat_stream/utils/service_locator.dart';
import 'package:turms_client_dart/turms_client.dart' as turms hide Value;
import 'package:drift/drift.dart';

class DatabaseHelper {
  final AppDatabase _db = sl<AppDatabase>();
  static Future<void> get() async {}

  static String conversationId(
          {required String targetId, required String myId}) =>
      "c_${targetId}_$myId";

  /// Upsert a message into the database.
  ///
  /// If the message already exists in the database, update the content and
  /// sentAt fields. Otherwise, insert the message into the database.
  ///
  /// The conversationId field is calculated by checking if the message is a
  /// group message. If it is, use the groupId as the conversationId. Otherwise,
  /// use the senderId as the conversationId.
  Future<int> upsertMessage(
      {required turms.Message message,
      int? messageId,
      MessageStatusEnum? status,
      bool receiveMessage = false,
      String? parentMessage}) async {
    String myUserId = sl<CredentialService>().turmsId!;

    // String conversationId = message.hasGroupId()
    //     ? message.groupId.toString()
    //     : receiveMessage
    //         ? message.senderId.toString()
    //         : message.recipientId.toString();

    String targetId = message.hasGroupId() && message.groupId != Int64(0)
        ? message.groupId.toString()
        : myUserId == message.senderId.toString()
            ? message.recipientId.toString()
            : message.senderId.toString();

    if (messageId != null) {
      MessagesCompanion data = MessagesCompanion(
          messageId: Value(messageId),
          conversationId:
              Value(conversationId(targetId: targetId, myId: myUserId)),
          content: Value(message.text),
          receiverId: Value(message.recipientId.toString()),
          attachment: Value(message.records.toString()),
          senderId: Value(message.senderId.toString()),
          parentMessageId: Value(message.parentConversationId.toString()),
          parentMessage: Value(parentMessage),
          type: Value(message.type.name),
          url: Value(jsonEncode(message.url)),
          status: Value(status?.value ?? MessageStatusEnum.sending.value),
          sentAt: Value(
            DateTime.fromMillisecondsSinceEpoch(message.deliveryDate.toInt()),
          ),
          extraInfo: Value(message.extraInfo));

      return await _db.into(_db.messages).insert(
          onConflict: DoUpdate((old) => data, target: [_db.messages.messageId]),
          data);
    }

    MessagesCompanion data = MessagesCompanion(
        id: Value(message.id.toString()),
        conversationId:
            Value(conversationId(targetId: targetId, myId: myUserId)),
        content: Value(message.text),
        receiverId: Value(message.recipientId.toString()),
        attachment: Value(message.records.toString()),
        senderId: Value(message.senderId.toString()),
        parentMessageId: Value(message.parentConversationId.toString()),
        parentMessage: Value(parentMessage),
        type: Value(message.type.name),
        url: Value(jsonEncode(message.url)),
        sentAt: Value(
          DateTime.fromMillisecondsSinceEpoch(message.deliveryDate.toInt()),
        ),
        extraInfo: Value(message.extraInfo));

    return await _db.into(_db.messages).insert(
        onConflict: DoUpdate((old) => data, target: [_db.messages.id]), data);
  }

  Future<int> insertMessage(
      {required turms.Message message,
      MessageStatusEnum? messageStatus,
      String? parentMessage}) async {
    String myUserId = sl<CredentialService>().turmsId!;

    String targetId = message.hasGroupId() && message.groupId != Int64(0)
        ? message.groupId.toString()
        : myUserId == message.senderId.toString()
            ? message.recipientId.toString()
            : message.senderId.toString();

    return await _db.into(_db.messages).insertOnConflictUpdate(
        MessagesCompanion(
            conversationId:
                Value(conversationId(targetId: targetId, myId: myUserId)),
            content: Value(message.text),
            receiverId: Value(message.recipientId.toString()),
            attachment: Value(message.records.toString()),
            senderId: Value(message.senderId.toString()),
            parentMessageId: Value(message.parentConversationId.toString()),
            parentMessage: Value(parentMessage),
            type: Value(message.type.name),
            url: Value(jsonEncode(message.url)),
            status:
                Value(messageStatus?.value ?? MessageStatusEnum.sending.value),
            sentAt: Value(
              DateTime.fromMillisecondsSinceEpoch(message.deliveryDate.toInt()),
            ),
            extraInfo: Value(message.extraInfo)));
  }

  Future<int> updateMessageStatus(
      {required int messageId,
      Int64? id,
      required MessageStatusEnum status}) async {
    MessagesCompanion messagesCompanion =
        MessagesCompanion(status: Value(status.value));

    if (id != null) {
      messagesCompanion = messagesCompanion.copyWith(id: Value(id.toString()));
    }

    return await (_db.update(_db.messages)
          ..where((tbl) =>
              tbl.messageId.equals(messageId) | tbl.rowId.equals(messageId)))
        .write(messagesCompanion);
  }

  /// Insert or update a conversation in the database.
  ///
  /// The [friendId] and [myUserId] are used to generate a unique conversation
  /// ID. The rest of the parameters are optional and can be used to update the
  /// conversation's information.
  ///
  /// The [targetId] is the original ID of the conversation, the [ownerId] is
  /// the ID of the user who created the conversation, the [lastMessageDate] is
  /// the date of the last message in the conversation, the [title] is the
  /// title of the conversation, the [avatar] is the avatar of the conversation,
  /// and the [extraInfo] is any additional information about the conversation.
  ///
  /// If the conversation is not found in the database, it will be inserted.
  /// If the conversation is found, it will be updated with the given
  /// information.
  ///
  /// Returns the number of rows affected by the operation.
  Future<int> upsertConversation(
      {required String friendId,
      required List<String> members,
      required bool isGroup,
      String? targetId,
      String? ownerId,
      DateTime? lastMessageDate,
      String? title,
      String? avatar,
      String? extraInfo}) async {
    String myUserId = sl<CredentialService>().turmsId!;

    return await _db
        .into(_db.conversations)
        .insertOnConflictUpdate(ConversationsCompanion(
          id: Value(conversationId(targetId: friendId, myId: myUserId)),
          title: Value(title ?? friendId),
          members: Value(jsonEncode(members)),
          avatar: Value(avatar),
          isGroup: Value(isGroup),
          targetId: Value(targetId),
          ownerId: Value(ownerId),
          lastMessageDate: lastMessageDate == null
              ? const Value.absent()
              : Value(lastMessageDate),
          extraInfo: Value(extraInfo),
        ));
  }

  /// Watches the messages of a conversation with the given [conversationId].
  ///
  /// This is a stream that emits a list of messages whenever a message is
  /// inserted, updated or deleted in the database.
  ///
  /// The emitted list of messages is sorted by the sentAt field in descending
  /// order, i.e., the latest message is first.
  ///
  /// This function never completes and never emits an error.
  Stream<List<Message>> getMessagesByConversation(String conversationId,
      {DateTime? filteredDateTime}) {
    if (filteredDateTime != null) {
      return (_db.select(_db.messages)
            ..where((tbl) =>
                tbl.conversationId.equals(conversationId) &
                tbl.sentAt.isBiggerOrEqualValue(filteredDateTime)))
          .watch();
    }

    return (_db.select(_db.messages)
          ..where((tbl) => tbl.conversationId.equals(conversationId)))
        .watch();
  }

  Stream<int> getMessagesCount(String conversationId) {
    return (_db.selectOnly(_db.messages)
          ..addColumns([_db.messages.id.count()])
          ..where(_db.messages.conversationId.equals(conversationId)))
        .watchSingle()
        .map((row) => row.read<int>(_db.messages.id.count()) ?? 0);
  }

  /// Watches the user's own conversations from the database.
  ///
  /// This method returns a stream of lists, where each list contains
  /// conversations that belong to the user with the specified [currentUserId].
  /// The stream emits updates whenever a conversation is inserted, updated,
  /// or deleted in the database.
  ///
  /// The conversations are filtered by the user's ID and sorted first by
  /// the pinned status in descending order, then by the date of the last
  /// message in descending order, ensuring that pinned conversations and
  /// those with recent activity appear first.
  Stream<List<Conversation>> getOwnConversationStream(String currentUserId) {
    final query = _db.customSelect(
      '''
    SELECT c.*, COUNT(m.id) AS messageCount
    FROM conversations c
    LEFT JOIN messages m ON c.id = m.conversation_id
    WHERE c.id LIKE '%_$currentUserId'
    GROUP BY c.id
    HAVING COUNT(m.id) > 0
    ORDER BY c.is_pinned DESC, c.last_message_date DESC
    ''',
      readsFrom: {
        _db.conversations,
        _db.messages
      }, // Specify the tables to read from
    );

    return query.watch().map((rows) {
      return rows.map((row) {
        row.data.remove("messageCount");
        return _db.conversations.map(row.data);
        // return Conversation(
        //   id: row.read("id"),
        //   title: row.read("title"),
        //   members: row.read("members"),
        //   avatar: row.read("avatar"),
        //   isGroup: row.read("is_group"),
        //   targetId: row.read("target_id"),
        //   ownerId: row.read("owner_id"),
        //   lastMessageDate: row.read("last_message_date"),
        //   extraInfo: row.read("extra_info"),
        //   createdAt: row.read("created_at"),
        //   isPinned: row.read("is_pinned"),
        //   isMuted: row.read("is_muted"),
        //   settings: row.read("settings"),
        // );
      }).toList();
    });

    return (_db.select(_db.conversations)
          ..where((tbl) => tbl.id.like('%_$currentUserId'))
          ..orderBy([
            (tbl) =>
                OrderingTerm(expression: tbl.isPinned, mode: OrderingMode.desc),
            (tbl) => OrderingTerm(
                expression: tbl.lastMessageDate, mode: OrderingMode.desc)
          ]))
        .watch();
  }

  Stream<List<Message>> getOwnFavouriteMessagesStream(String currentUserId) {
    return (_db.select(_db.messages)
          ..where((tbl) =>
              tbl.conversationId.like('%_$currentUserId') &
              tbl.isFavourite.equals(true)))
        .watch();
  }

  /// Retrieves the user's own conversations from the database.
  ///
  /// This method returns a future with a list of conversations that belong to
  /// the user with the specified [currentUserId].
  ///
  /// The conversations are filtered by the user's ID and sorted first by
  /// the pinned status in descending order, then by the date of the last
  /// message in descending order, ensuring that pinned conversations and
  /// those with recent activity appear first.
  Future<List<Conversation>> getOwnConversation(String currentUserId) async {
    return (_db.select(_db.conversations)
          ..where((tbl) => tbl.id.like('%_$currentUserId')))
        .get();
  }

  Future<Conversation?> getConversation(String conversationId) async {
    try {
      return await (_db.select(_db.conversations)
            ..where((tbl) => tbl.id.equals(conversationId)))
          .getSingle();
    } catch (e) {
      log("Get conversation error $e");
      return null;
    }
  }

  Future<void> updateGroupSettings(
      {required String conversationId, required String settings}) async {
    await (_db.update(_db.conversations)
          ..where((tbl) => tbl.id.equals(conversationId)))
        .write(ConversationsCompanion(
      settings: Value(settings),
    ));
  }

  Stream<Conversation> getGroupSettings(String conversationId) {
    return (_db.select(_db.conversations)
          ..where((tbl) => tbl.id.equals(conversationId)))
        .watchSingle();
  }

  /// Pinned a conversation in the database.
  ///
  /// This method takes a [conversationId] and updates the corresponding
  /// conversation in the database to be pinned.
  ///
  /// This method does not return a value and does not throw an exception.
  ///
  /// The conversation is identified by the [conversationId] which is a unique
  /// identifier for the conversation.
  Future<void> pinConversation(String conversationId) async {
    await (_db.update(_db.conversations)
          ..where((tbl) => tbl.id.equals(conversationId)))
        .write(const ConversationsCompanion(
      isPinned: Value(true),
    ));
  }

  /// Unpins a conversation in the database.
  ///
  /// This method takes a [conversationId] and updates the corresponding
  /// conversation in the database to be unpinned.
  ///
  /// This method does not return a value and does not throw an exception.
  ///
  /// The conversation is identified by the [conversationId] which is a unique
  /// identifier for the conversation.
  Future<void> unPinConversation(String conversationId) async {
    await (_db.update(_db.conversations)
          ..where((tbl) => tbl.id.equals(conversationId)))
        .write(const ConversationsCompanion(
      isPinned: Value(false),
    ));
  }

  /// Mutes a conversation in the database.
  ///
  /// This method takes a [conversationId] and updates the corresponding
  /// conversation in the database to be muted.
  ///
  /// This method does not return a value and does not throw an exception.
  ///
  /// The conversation is identified by the [conversationId] which is a unique
  /// identifier for the conversation.
  Future<void> muteConversation(String conversationId) async {
    await (_db.update(_db.conversations)
          ..where((tbl) => tbl.id.equals(conversationId)))
        .write(const ConversationsCompanion(
      isMuted: Value(true),
    ));
  }

  /// Unmutes a conversation in the database.
  ///
  /// This method takes a [conversationId] and updates the corresponding
  /// conversation in the database to be unmuted.
  ///
  /// This method does not return a value and does not throw an exception.
  ///
  /// The conversation is identified by the [conversationId] which is a unique
  /// identifier for the conversation.
  Future<void> unMuteConversation(String conversationId) async {
    await (_db.update(_db.conversations)
          ..where((tbl) => tbl.id.equals(conversationId)))
        .write(const ConversationsCompanion(
      isMuted: Value(false),
    ));
  }

  /// Unmutes all conversations in the database.
  ///
  /// This method does not return a value and does not throw an exception.
  ///
  /// This method updates all conversations in the database to be unmuted.
  Future<void> unMuteAllConversation() async {
    await (_db.update(_db.conversations)..where((tbl) => tbl.id.isNotNull()))
        .write(const ConversationsCompanion(
      isMuted: Value(false),
    ));
  }

  /// Unpins all conversations in the database.
  ///
  /// This method updates all conversations to be unpinned, effectively setting
  /// the `isPinned` status to false for every conversation.
  ///
  /// This method does not return a value and does not throw an exception.

  Future<void> unPinAllConversation() async {
    await (_db.update(_db.conversations)..where((tbl) => tbl.id.isNotNull()))
        .write(const ConversationsCompanion(
      isPinned: Value(false),
    ));
  }

  /// Updates the last message date of a conversation in the database.
  ///
  /// This method takes a [conversationId] and a [lastMessageDate] and updates
  /// the corresponding conversation in the database with the given
  /// [lastMessageDate].
  ///
  /// This method does not return a value and does not throw an exception.
  ///
  /// The conversation is identified by the [conversationId] which is a unique
  /// identifier for the conversation.
  Future<void> updateConversationLastMessageDate(String conversationId,
      {required DateTime lastMessageDate}) async {
    await (_db.update(_db.conversations)
          ..where((tbl) =>
              (tbl.id.equals(conversationId) &
                  tbl.lastMessageDate.isSmallerOrEqualValue(lastMessageDate)) |
              tbl.lastMessageDate.isNull()))
        .write(ConversationsCompanion(
      lastMessageDate: Value(lastMessageDate),
    ));
  }

  Future<void> favouriteMessage(String messageId) async {
    await (_db.update(_db.messages)..where((tbl) => tbl.id.equals(messageId)))
        .write(const MessagesCompanion(
      isFavourite: Value(true),
    ));
  }

  Future<void> unFavouriteMessage(String messageId) async {
    await (_db.update(_db.messages)..where((tbl) => tbl.id.equals(messageId)))
        .write(const MessagesCompanion(
      isFavourite: Value(false),
    ));
  }

  Future<void> unFavouriteAllMessage() async {
    await (_db.update(_db.messages)..where((tbl) => tbl.id.isNotNull()))
        .write(const MessagesCompanion(
      isFavourite: Value(false),
    ));
  }

  /// Deletes all messages and conversations from the database.
  ///
  /// This method is typically used during development for testing purposes.
  /// It is not intended to be used in production code as it permanently deletes
  /// all data from the database.
  Future<void> clearDatabase() async {
    await _db.delete(_db.messages).go();
    await _db.delete(_db.conversations).go();
    await _db.delete(_db.contacts).go();
    await _db.delete(_db.conversationSettings).go();
  }

  Future<void> deleteConversation(String conversationId) async {
    final query = _db.delete(_db.messages)
      ..where((tbl) => tbl.conversationId.equals(conversationId));
    await query.go();
  }

  Future<void> updateProfileImage(String conversationId, String avatar) async {
    await (_db.update(_db.conversations)
          ..where((tbl) {
            log("avatarrrrr $avatar ${tbl.id.equals(conversationId)} ");

            return tbl.id.equals(conversationId);
          }))
        .write(ConversationsCompanion(
      avatar: Value(avatar),
    ));
  }

  Future<int> upsertSticker(
      {required String stickerPath,
      required String stickerUrl,
      String? name,
      String? friendId}) async {
    String myUserId = sl<CredentialService>().turmsId!;

    return await _db
        .into(_db.stickers)
        .insertOnConflictUpdate(StickersCompanion(
          id: Value(stickerUrl),
          name: Value(name.toString()),
          path: Value(stickerPath),
          userId: Value(myUserId),
        ));
  }

  Stream<List<Sticker>> getStickers() {
    return (_db.select(_db.stickers)).watch();
  }

  Stream<int> getConversationUnreadCount(String conversationId) {
    String myId = sl<CredentialService>().turmsId!;

    return (_db.selectOnly(_db.messages)
          ..addColumns([_db.messages.id.count()])
          ..where(_db.messages.conversationId.equals(conversationId) &
              _db.messages.isRead.equals(false) &
              _db.messages.senderId.isNotValue(myId)))
        .watchSingle()
        .map((row) => row.read<int>(_db.messages.id.count()) ?? 0);
  }

  Stream<int> getTotalUnreadCount() {
    String myId = sl<CredentialService>().turmsId!;

    return (_db.selectOnly(_db.messages)
          ..addColumns([_db.messages.id.count()])
          ..where(_db.messages.conversationId.like('%_$myId') &
              _db.messages.isRead.equals(false) &
              _db.messages.senderId.isNotValue(myId)))
        .watchSingle()
        .map((row) => row.read<int>(_db.messages.id.count()) ?? 0);
  }

  Future<Conversation?> getConversationByTargetId(String targetId) async {
    String myId = await sl<CredentialService>().getTurmsId ?? "";

    final conversation = await (_db.select(_db.conversations)
          ..where((tbl) =>
              tbl.id.equals(conversationId(targetId: targetId, myId: myId))))
        .getSingleOrNull();
    log("is this conversation muted? ConversationId: ${conversationId(targetId: targetId, myId: myId)} $conversation");
    bool isMuted = conversation?.isMuted ?? false;

    return conversation;
  }

  Future<int> getUnreadCount(String conversationId, DateTime readAt) async {
    String myId = sl<CredentialService>().turmsId!;

    int unReadMessageCount = await (_db.select(_db.messages)
          ..where((tbl) =>
              tbl.conversationId.equals(conversationId) &
              tbl.sentAt.isSmallerOrEqualValue(readAt) &
              tbl.senderId.isNotValue(myId) &
              tbl.isRead.equals(false)))
        .get()
        .then((result) => result.length);

    return unReadMessageCount;
  }

  Future<void> updateLoadingMessageToFailed() async {
    await (_db.update(_db.messages)
          ..where((tbl) => tbl.status.equals(MessageStatusEnum.sending.value)))
        .write(MessagesCompanion(
      status: Value(MessageStatusEnum.failed.value),
    ));
  }

  Future<void> updateReadStatus(String conversationId, DateTime readAt) async {
    String myId = sl<CredentialService>().turmsId!;

    await (_db.update(_db.messages)
          ..where((tbl) =>
              tbl.conversationId.equals(conversationId) &
              tbl.sentAt.isSmallerOrEqualValue(readAt) &
              tbl.senderId.isNotValue(myId)))
        .write(const MessagesCompanion(
      isRead: Value(true),
    ));
  }

  Future<void> deleteSticker(String stickerUrl) async {
    final query = _db.delete(_db.stickers)
      ..where((tbl) => tbl.id.equals(stickerUrl));
    await query.go();
  }

  Future<int> updateMessage(
    String messageId, {
    String? text,
    String? parentMessage,
    String? url,
    String? extraInfo,
    String? messageType,
    bool isPin = false,
    MessageStatusEnum? messageStatus,
  }) async {
    final currentMessage = await (_db.select(_db.messages)
          ..where((tbl) => tbl.id.equals(messageId)))
        .getSingleOrNull();
    log("cu $currentMessage $text $extraInfo");
    return await (_db.update(_db.messages)
          ..where((tbl) => tbl.id.equals(messageId)))
        .write(MessagesCompanion(
            content: Value(text ?? currentMessage?.content ?? ""),
            parentMessageId: Value(parentMessage 
                ?? currentMessage?.parentMessageId ?? "0"),
            parentMessage:
                Value(parentMessage ?? currentMessage?.parentMessage),
            url: Value(url ?? currentMessage?.url),
            extraInfo: Value(extraInfo ?? currentMessage?.extraInfo),
            type: Value(messageType ?? currentMessage?.type ?? "TEXT_TYPE"),
            isPinned: Value(isPin),
            status:
                Value(messageStatus?.value ?? currentMessage?.status ?? 0)));
  }

  // Future<int> upsertGroupConversationSettings(
  //     {required turms.ConversationSettings settings,
  //     bool receiveMessage = false,
  //     String? parentMessage}) async {
  //   String myUserId = sl<CredentialService>().turmsId!;

  //   // String conversationId = message.hasGroupId()
  //   //     ? message.groupId.toString()
  //   //     : receiveMessage
  //   //         ? message.senderId.toString()
  //   //         : message.recipientId.toString();

  //   String targetId = message.hasGroupId() && message.groupId != Int64(0)
  //       ? message.groupId.toString()
  //       : myUserId == message.senderId.toString()
  //           ? message.recipientId.toString()
  //           : message.senderId.toString();

  //   return await _db.into(_db.messages).insertOnConflictUpdate(
  //       MessagesCompanion(
  //           id: Value(message.id.toString()),
  //           conversationId:
  //               Value(conversationId(targetId: targetId, myId: myUserId)),
  //           content: Value(message.text),
  //           receiverId: Value(message.recipientId.toString()),
  //           attachment: Value(message.records.toString()),
  //           senderId: Value(message.senderId.toString()),
  //           parentMessageId: Value(message.parentConversationId.toString()),
  //           parentMessage: Value(parentMessage),
  //           type: Value(message.type.name),
  //           url: Value(jsonEncode(message.url)),
  //           sentAt: Value(
  //             DateTime.fromMillisecondsSinceEpoch(message.deliveryDate.toInt()),
  //           ),
  //           extraInfo: Value(message.extraInfo)));
  // }
  Future<void> deleteMessage(String messageId) async {
    final query = _db.delete(_db.messages)
      ..where((tbl) => tbl.id.equals(messageId));
    await query.go();
  }

  /// This function gets the pinned messages of a conversation from the database.
  ///
  /// [conversationId] is the id of the conversation.
  ///
  /// Returns a list of messages that are pinned in the conversation.
  Stream<List<Message>> getPinnedMessage(String conversationId) {
    return (_db.select(_db.messages)
          ..where((tbl) =>
              tbl.conversationId.equals(conversationId) &
              tbl.isPinned.equals(true)))
        .watch();
  }

  Stream<List<Message>> getMedia(String conversationId, String type) {
    return (_db.select(_db.messages)
          ..where((tbl) =>
              tbl.conversationId.equals(conversationId) &
              tbl.type.equals(type)))
        .watch()
        .asyncMap((messages) async {
      List<Message> messagesWithAttachment = [];
      for (var message in messages) {
        final attachment = AttachmentModel.fromJson(
            jsonDecode(jsonDecode(message.url.toString())[0]));
        final exists = await File(attachment.localPath.toString()).exists();
        if (exists) {
          messagesWithAttachment.add(message);
        }
      }
      return messagesWithAttachment;
    });
  }

  Stream<List<Message>> getMediaTotal(
      String conversationId, List<String> types) {
    return (_db.select(_db.messages)
          ..where((tbl) =>
              tbl.conversationId.equals(conversationId) & tbl.type.isIn(types)))
        .watch();
  }

  Future<void> upsertUserRelationship(
      String id, String userId, String relatedUserId, String status) async {
    await _db.into(_db.userRelationships).insertOnConflictUpdate(
          UserRelationshipsCompanion(
            id: Value(id),
            userId: Value(userId),
            relatedUserId: Value(relatedUserId),
            status: Value(status),
          ),
        );
  }

  Stream<UserRelationship> fetchRelationship(String id) {
    return (_db.select(_db.userRelationships)
          ..where((tbl) => tbl.id.equals(id)))
        .watchSingle();
  }

  Future<UserRelationship> getSingleRelationship(String id) {
    return (_db.select(_db.userRelationships)
          ..where((tbl) => tbl.id.equals(id)))
        .getSingle();
  }

  Future<List<UserRelationship>> getRelationshipList() {
    return (_db.select(_db.userRelationships)).get();
  }

  Future<void> updateRelationship(
    String id,
    String status,
  ) async {
    await (_db.update(_db.userRelationships)..where((tbl) => tbl.id.equals(id)))
        .write(UserRelationshipsCompanion(
      status: Value(status),
    ));
  }

  Future<void> updateGroupName(
    String name,
    String id,
  ) async {
    await (_db.update(_db.conversations)..where((tbl) => tbl.id.equals(id)))
        .write(ConversationsCompanion(
      title: Value(name),
    ));
  }
}
