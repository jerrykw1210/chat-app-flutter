import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:fixnum/fixnum.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:protech_mobile_chat_stream/constants/string_constant.dart';
import 'package:protech_mobile_chat_stream/model/database.dart' as db;
import 'package:protech_mobile_chat_stream/model/message_status_enum.dart';
import 'package:protech_mobile_chat_stream/module/chat/model/attachment_model.dart';
import 'package:protech_mobile_chat_stream/module/chat/repository/chat_repository.dart';
import 'package:protech_mobile_chat_stream/module/file/repository/file_repository.dart';
import 'package:protech_mobile_chat_stream/service/credential_service.dart';
import 'package:protech_mobile_chat_stream/service/database_helper.dart';
import 'package:protech_mobile_chat_stream/service/response.dart';
import 'package:protech_mobile_chat_stream/service/turms_response.dart';
import 'package:protech_mobile_chat_stream/service/turms_service.dart';
import 'package:protech_mobile_chat_stream/utils/custom_message_manager.dart';
import 'package:protech_mobile_chat_stream/utils/service_locator.dart';
import 'package:protech_mobile_chat_stream/utils/string_apis.dart';
import 'package:turms_client_dart/turms_client.dart' as turms hide Value;
import 'package:drift/drift.dart';
import 'package:path/path.dart' as p;

part 'chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  ChatCubit() : super(ChatState());

  final ChatRepository chatRepository = sl<ChatRepository>();
  final FileRepository _fileRepository = sl<FileRepository>();
  final TurmsService turmsService = sl<TurmsService>();

  void selectMessage(db.Message message) {
    List<db.Message> selectedMessages = List.from(state.selectedMessages);
    if (selectedMessages
        .any((messageInList) => messageInList.id == message.id)) {
      selectedMessages
          .removeWhere((messageInList) => messageInList.id == message.id);
    } else {
      selectedMessages.add(message);
    }
    emit(state.copyWith(selectedMessages: selectedMessages));
    log("selected message ${state.selectedMessages}");
  }

  void selectUser(dynamic user) {
    List<dynamic> selectedUsers = List.from(state.selectedUsers);
    if (selectedUsers.any((userInList) => userInList.id == user.id)) {
      selectedUsers.removeWhere((userInList) => userInList.id == user.id);
    } else {
      selectedUsers.add(user);
    }
    emit(state.copyWith(selectedUsers: selectedUsers));
  }

  void resetSelectedUser() {
    emit(state.copyWith(
      selectedUsers: [],
    ));
  }

  void forwardMessage(List<Int64> usersId, List<db.Message> messages,
      {bool isGroupMessage = false}) async {
    bool forwardSuccess = true;
    try {
      emit(state.copyWith(forwardMessageStatus: ForwardMessageStatus.loading));

      for (Int64 userId in usersId) {
        for (db.Message message in messages) {
          if (message.id != null) {
            turms.MessageType messageType = turms.MessageType.TEXT_TYPE;
            List<String> url = [];

            if (message.type == "IMAGE_TYPE") {
              messageType = turms.MessageType.IMAGE_TYPE;
            }

            if (message.type == "VIDEO_TYPE") {
              messageType = turms.MessageType.VIDEO_TYPE;
            }

            if (message.type == "VOICE_TYPE") {
              messageType = turms.MessageType.VOICE_TYPE;
            }

            if (message.type == "FILE_TYPE") {
              messageType = turms.MessageType.FILE_TYPE;
            }
            if (message.type == "NAMECARD_TYPE") {
              messageType = turms.MessageType.NAMECARD_TYPE;
            }
            if (message.type == "STICKER_TYPE") {
              messageType = turms.MessageType.STICKER_TYPE;
            }

            if (message.url != null) {
              for (String attachment in jsonDecode(message.url!)) {
                url.add(attachment);
              }
            }
            db.Conversation? conversation = await sl<DatabaseHelper>()
                .getConversation(DatabaseHelper.conversationId(
                    targetId: userId.toString(),
                    myId: sl<CredentialService>().turmsId.toString()));
            if (conversation == null) {
              final res = await sl<TurmsService>()
                  .handleTurmsResponse<turms.UserInfo?>(() async {
                turms.UserInfo? friendInfo = await sl<TurmsService>()
                    .queryUserProfile(userId.toString());

                return friendInfo;
              });
              if (res is TurmsMapSuccessResponse<turms.UserInfo?>) {
                await sl<DatabaseHelper>().upsertConversation(
                    friendId: userId.toString(),
                    members: [
                      userId.toString(),
                      sl<CredentialService>().turmsId.toString()
                    ],
                    isGroup: false,
                    targetId: userId.toString(),
                    title: res.res?.name ?? userId.toString(),
                    ownerId: sl<CredentialService>().turmsId.toString());
              }
            }

            sendMessage(userId,
                sl<CredentialService>().turmsId?.parseInt64() ?? Int64(0),
                isGroupMessage: isGroupMessage,
                message: message.content,
                messageType: messageType,
                url: url,
                extraInfo: message.extraInfo);

            // if (res is TurmsInvalidErrorResponse<Int64>) {
            //   log("forward error ${res.code} ${res.reason}");

            //   emit(state.copyWith(
            //       forwardMessageStatus: ForwardMessageStatus.failed));

            //   emit(state.copyWith(
            //       forwardMessageStatus: ForwardMessageStatus.initial));

            //   forwardSuccess = false;
            // }
          }
        }
      }

      if (forwardSuccess) {
        emit(
            state.copyWith(forwardMessageStatus: ForwardMessageStatus.success));

        emit(
            state.copyWith(forwardMessageStatus: ForwardMessageStatus.initial));
      }
    } catch (e) {
      log("error query channel $e");
    }
  }

  void saveAttachment(BuildContext context) async {
    // List<Message> messages =
    //     StreamChannel.of(context).channel.state?.messages ?? [];
    // List<Attachment> attachments = [];
    // for (Message message in messages) {
    //   if (message.attachments.isNotEmpty) {
    //     attachments.addAll(message.attachments);
    //   }
    // }
    // emit(state.copyWith(attachmentList: attachments));
  }

  void savePinnedMessages(String messageId, bool toPin) async {
    log("message id to pin $messageId $toPin");
    try {
      final pinRes = await sl<turms.TurmsClient>()
          .messageService
          .updateSentMessage(messageId.parseInt64(), text: "", toPin: toPin);
      if (pinRes.code == 1000) {
        //message.isPinned = toPin;
        log("can pin liao");
        sl<DatabaseHelper>().updateMessage(
          messageId,
          isPin: toPin,
        );
      }
    } catch (e) {
      log("error pinning message $e");
    }

    // List<db.Message> messages = List.from(StreamChannel.of(context)
    //     .channel
    //     .state
    //     ?.messages
    //     .where((msg) => msg.pinned)
    //     .toList() as List<db.Message>);
    // emit(state.copyWith(pinnedMessages: messages));
  }

  Future<void> unpinMessage(
      BuildContext context, db.Message pinnedMessage) async {
    List<db.Message> messages = List.from(state.pinnedMessages);
    try {
      // UpdateMessageResponse res =
      //     await StreamChannel.of(context).channel.unpinMessage(pinnedMessage);
      Future.delayed(Durations.short2);
      // if (!res.message.pinned) {
      //   messages.remove(pinnedMessage);
      // }
      emit(state.copyWith(
        pinnedMessages: messages,
      ));
    } catch (e) {
      log("error unpin $e");
    }
  }

  void expandText(String id) {
    List<String> expandIdList = List.from(state.expandTextId);
    if (expandIdList.contains(id)) {
      expandIdList.remove(id);
    } else {
      expandIdList.add(id);
    }
    log("expand list $expandIdList");
    emit(state.copyWith(expandTextId: expandIdList));
  }

  // Future<void> changeRole(Member member, String type, String id) async {
  //   try {
  //     member.copyWith(channelRole: "channel_moderator");
  //     await ChatService.instance.changeRole(member, type, id);
  //   } catch (e) {
  //     log("error when changing role $e");
  //   }
  // }
  Future<void> getGif() async {
    Response res = await chatRepository.getGif();
    if (res is MapSuccessResponse) {
      List gif = res.jsonRes['data'];
      log("the gif is ${gif[0]['embed_url']}");
      emit(state.copyWith(gifUrl: gif));
    }
    log("res get gif ${state.gifUrl}");
  }

  Future<void> searchGif(String keyword) async {
    Response res = await chatRepository.searchGif(keyword);
    if (res is MapSuccessResponse) {
      List gif = res.jsonRes['data'];
      log("the gif is ${gif[0]['embed_url']}");
      emit(state.copyWith(gifUrl: gif));
    }
    log("res get gif ${state.gifUrl}");
  }

  sendNamecard(Int64 id, {bool isGroup = false}) {
    emit(state.copyWith(
        sendNamecard: true, isGroup: isGroup, sendNamecardToId: id));
  }

  resetNamecard() {
    emit(state.copyWith(sendNamecard: false, sendNamecardToId: Int64(0)));
  }

  void resetSelectedMessageList() {
    emit(state.copyWith(selectedMessages: [], expandTextId: []));
  }

  Future<void> querySearchedMessage(String messageId) async {
    try {
      // List<Message> messages =
      //     await GetStreamService().queryMessage(channel, messageId: messageId);

      emit(state.copyWith(
          querySearchStatus: QuerySearchStatus.success, searchedMessages: []));
    } catch (e) {
      log("error when searching message $e");
    }
  }

  Future<void> resetSearchState() async {
    try {
      emit(state.copyWith(
          querySearchStatus: QuerySearchStatus.initial, searchedMessages: []));
    } catch (e) {
      log("error when querying message $e");
    }
  }

  Future muteOrUnmuteChat(bool doMute) async {
    try {
      if (doMute) {
        sl<turms.TurmsClient>().messageService.removeMessageListener(
          (message, addition) {
            log('onMessage: remove listener: $message');
          },
        );
      } else {
        sl<turms.TurmsClient>().messageService.addMessageListener(
          (message, addition) {
            log('onMessage: added listener: $message');
          },
        );
      }
    } catch (e) {
      log("error when muting chat $e");
    }
  }

  bool _checkPermission(String settingsKey,
      {bool reverseBool = false,
      bool? customOutputWhenOwnerIdEqualsUserId,
      turms.ConversationSettings? settings,
      required turms.GroupMember groupMember}) {
    // final settings = widget.conversationSettings;
    final userId = sl<CredentialService>().turmsId;
    final trueCondition = reverseBool ? 0 : 1;

    if (settings == null || userId == null) {
      return reverseBool;
    }

    if (groupMember.role == turms.GroupMemberRole.OWNER) {
      return customOutputWhenOwnerIdEqualsUserId ?? !reverseBool;
    }

    return settings.settings[settingsKey]?.int32Value == trueCondition;
  }

  Future<void> queryGroupMessages() async {
    // final getRelatedGroupIds =
    //     await sl<turms.TurmsClient>().groupService.queryJoinedGroupIds();

    final getRelatedGroup =
        await sl<turms.TurmsClient>().groupService.queryJoinedGroupInfos();

    List<turms.Group> groups = getRelatedGroup.data?.groups ?? [];

    // Set<Int64> fromIds = getRelatedGroupIds.data?.longs.toSet() ?? <Int64>{};

    // log("qgm! from ids $fromIds");

    for (turms.Group group in groups) {
      turms.ConversationSettings? groupSettings;
      turms.GroupMember? groupMember;
      List<String>? groupMembers;
      final myUserId = sl<CredentialService>().turmsId;
      DateTime? filteredDate;

      final groupSettingsRes = await turmsService
          .handleTurmsResponse<turms.ConversationSettings?>(() async {
        turms.Response<List<turms.ConversationSettings>> res =
            await sl<turms.TurmsClient>()
                .conversationService
                .queryConversationSettings(groupIds: {group.id});

        if (res.data.isEmpty) {
          return null;
        }

        return res.data.first;
      });

      if (groupSettingsRes
          is TurmsMapSuccessResponse<turms.ConversationSettings?>) {
        groupSettings = groupSettingsRes.res;
      }

      // if (groupSettings == null) {
      //   continue;
      // }

      final groupMemberRes = await turmsService
          .handleTurmsResponse<List<turms.GroupMember>?>(() async {
        final res = await sl<turms.TurmsClient>()
            .groupService
            .queryGroupMembers(group.id);

        if (res.data == null) {
          return null;
        }

        return res.data!.groupMembers;
      });

      if (groupMemberRes is TurmsMapSuccessResponse<List<turms.GroupMember>?>) {
        if (groupMemberRes.res != null) {
          groupMembers = groupMemberRes.res!
              .map((member) => member.userId.toString())
              .toList();
          for (turms.GroupMember gMember in groupMemberRes.res!) {
            if (gMember.userId.toString() == myUserId) {
              groupMember = gMember;
            }
          }
        }
      }

      if (groupMember == null || groupMembers == null) {
        continue;
      }

      // log("qgm! group ${group.toString()}");

      // log("qgm! group settings ${groupSettings?.toString()}");

      // log("qgm! group member ${groupMember.toString()}");

      // log("qgm! can see history ${_checkPermission("CAN_MEMBERS_LIST_MESSAGE_HISTORY", settings: groupSettings, groupMember: groupMember)}");

      if (!_checkPermission("CAN_MEMBERS_LIST_MESSAGE_HISTORY",
          settings: groupSettings, groupMember: groupMember)) {
        filteredDate =
            DateTime.fromMillisecondsSinceEpoch(groupMember.joinDate.toInt());
      }

      // log("qgm! filtered date $filteredDate");
      final res =
          await turmsService.handleTurmsResponse<List<turms.Message>>(() async {
        turms.Response<List<turms.Message>> res = await sl<turms.TurmsClient>()
            .messageService
            .queryMessages(
                fromIds: {group.id},
                areGroupMessages: true,
                maxCount: 500,
                deliveryDateStart: filteredDate,
                showOwnedMessages: true);

        return res.data;
      });

      if (res is TurmsInvalidErrorResponse<List<turms.Message>>) {
        log("qgm! group messages failed ${res.code} ${res.reason}");
        continue;
      }

      if (res is TurmsMapSuccessResponse<List<turms.Message>>) {
        List<turms.Message> messages = res.res ?? [];

        log("qgm! group messages $messages");

        for (turms.Message message in messages) {
          if (message.hasRecallDate()) {
            continue;
          }

          if (message.type == turms.MessageType.TEXT_TYPE &&
              message.text.isBlank) {
            continue;
          }

          db.Conversation? conversation = await sl<DatabaseHelper>()
              .getConversation(DatabaseHelper.conversationId(
                  targetId: group.id.toString(), myId: myUserId!));

          if (conversation == null) {
            await sl<DatabaseHelper>().upsertConversation(
                friendId: group.id.toString(),
                members: groupMembers,
                isGroup: message.groupId != 0 ? true : false,
                targetId: message.groupId.toString(),
                ownerId: group.ownerId.toString(),
                title: group.name.length > 50
                    ? group.name.substring(0, 50)
                    : group.name,
                lastMessageDate: DateTime.fromMillisecondsSinceEpoch(
                    message.deliveryDate.toInt()));
          } else {
            sl<DatabaseHelper>().updateConversationLastMessageDate(
              DatabaseHelper.conversationId(
                  targetId: group.id.toString(), myId: myUserId),
              lastMessageDate: DateTime.fromMillisecondsSinceEpoch(
                  message.deliveryDate.toInt()),
            );
          }

          if (message.hasParentConversationId() &&
              message.parentConversationId != Int64(0)) {
            getParentMessage(message.parentConversationId, message.id);
          }
          sl<DatabaseHelper>().upsertMessage(
            message: message,
          );
        }
      }

      if (res is TurmsInvalidErrorResponse<List<turms.Message>>) {
        log("query group messages failed : ${res.code} ${res.reason}");
        return;
      }
    }

    // for (Int64 fromIds in fromIds) {
    //   turms.Group? group;
    //   turms.ConversationSettings? groupSettings;
    //   turms.GroupMember? groupMember;
    //   List<String>? groupMembers;
    //   final myUserId = sl<CredentialService>().turmsId;
    //   DateTime? filteredDate;

    //   final groupRes =
    //       await turmsService.handleTurmsResponse<turms.Group?>(() async {
    //     turms.Response<List<turms.Group>> res =
    //         await turmsService.groupService.queryGroups({fromIds});

    //     if (res.data.isEmpty) {
    //       return null;
    //     }

    //     return res.data.first;
    //   });

    //   if (groupRes is TurmsMapSuccessResponse<turms.Group?>) {
    //     group = groupRes.res;
    //   }

    //   if (group == null) {
    //     continue;
    //   }
    // }
  }

  /// Queries messages from related users and updates the local database.
  ///
  /// This function retrieves the user IDs related to the current user,
  /// queries messages from these users, and logs the messages. It filters
  /// messages that are not empty and are not system messages, and upserts
  /// them into the local database. The conversation ID is determined based
  /// on whether the recipient ID matches the current user's ID.
  Future<void> queryMessages(
      {Int64? targetId, bool areGroupMessage = false, Int64? groupId}) async {
    Set<Int64> fromIds;
    bool queryGroupMessages;

    if (targetId != null) {
      fromIds = {targetId};
      queryGroupMessages = areGroupMessage;
    } else if (areGroupMessage) {
      final getRelatedGroupIds =
          await sl<turms.TurmsClient>().groupService.queryJoinedGroupIds();
      fromIds = getRelatedGroupIds.data?.longs.toSet() ?? <Int64>{};
      queryGroupMessages = true;
    } else {
      final getRelatedRes =
          await sl<turms.TurmsClient>().userService.queryRelatedUserIds();
      fromIds = getRelatedRes.data?.longs.toSet() ?? <Int64>{};
      queryGroupMessages = false;
    }

    log("from ids: $fromIds query group messages: $queryGroupMessages");

    if (fromIds.isNotEmpty) {
      try {
        turms.Response<List<turms.Message>> res = await sl<turms.TurmsClient>()
            .messageService
            .queryMessages(
                fromIds: fromIds,
                areGroupMessages: queryGroupMessages,
                maxCount: 500,
                showOwnedMessages: true);
        if (res.data.isNotEmpty) {
          for (var message in res.data) {
            String myId = sl<CredentialService>().turmsId ?? "0";
            db.Conversation? conversation = await sl<DatabaseHelper>()
                .getConversation(message.hasGroupId()
                    ? message.groupId != Int64(0)
                        ? DatabaseHelper.conversationId(
                            targetId: message.groupId.toString(), myId: myId)
                        : DatabaseHelper.conversationId(
                            targetId: message.recipientId.toString() == myId
                                ? message.senderId.toString()
                                : message.recipientId.toString(),
                            myId: myId)
                    : DatabaseHelper.conversationId(
                        targetId: message.recipientId.toString() == myId
                            ? message.senderId.toString()
                            : message.recipientId.toString(),
                        myId: myId));
            if (conversation == null) {
              if (message.hasGroupId() && message.groupId != Int64(0)) {
                String friendId = message.groupId.toString();
                final groupMemberRes = await sl<turms.TurmsClient>()
                    .groupService
                    .queryGroupMembers(message.groupId);
                List<String> membersId = [];
                if (groupMemberRes.data?.groupMembers.isNotEmpty ?? false) {
                  membersId = groupMemberRes.data!.groupMembers
                      .map((e) => e.userId.toString())
                      .toList();
                }

                final groupDatas = await sl<turms.TurmsClient>()
                    .groupService
                    .queryGroups({message.groupId});

                final groupData =
                    groupDatas.data.isEmpty ? null : groupDatas.data.first;

                await sl<DatabaseHelper>().upsertConversation(
                    friendId: friendId,
                    members: membersId,
                    isGroup: message.groupId != 0 ? true : false,
                    targetId: message.groupId.toString(),
                    ownerId: groupData?.ownerId.toString() ??
                        message.recipientId.toString(),
                    title: groupData?.name ?? friendId,
                    lastMessageDate: DateTime.fromMillisecondsSinceEpoch(
                        message.deliveryDate.toInt()));
              } else {
                String friendId =
                    sl<CredentialService>().turmsId!.parseInt64() ==
                            message.senderId
                        ? message.recipientId.toString()
                        : message.senderId.toString();

                turms.UserInfo? friendInfo =
                    await sl<TurmsService>().queryUserProfile(friendId);

                await sl<DatabaseHelper>().upsertConversation(
                    friendId: friendId,
                    members: [friendId, sl<CredentialService>().turmsId!],
                    isGroup: message.groupId != 0 ? true : false,
                    targetId: friendId,
                    ownerId: sl<CredentialService>().turmsId!,
                    title: friendInfo?.name ?? "Deleted User",
                    lastMessageDate: DateTime.fromMillisecondsSinceEpoch(
                        message.deliveryDate.toInt()));
              }
            }

            if (message.hasRecallDate()) {
              continue;
            }

            if (message.type == turms.MessageType.TEXT_TYPE &&
                message.text.isBlank) {
              continue;
            }

            if (!message.hasRecallDate() &&
                !(message.type == turms.MessageType.TEXT_TYPE &&
                    message.text.isBlank)) {
              String myUserId = sl<CredentialService>().turmsId ??
                  sl<turms.TurmsClient>()
                      .userService
                      .userInfo!
                      .userId
                      .toString();
              String targetId = message.hasGroupId()
                  ? message.groupId.toString()
                  : myUserId == message.senderId.toString()
                      ? message.recipientId.toString()
                      : message.senderId.toString();
              if (message.hasParentConversationId() &&
                  message.parentConversationId != Int64(0)) {
                getParentMessage(message.parentConversationId, message.id);
              }
              sl<DatabaseHelper>().upsertMessage(
                message: message,
              );

              sl<DatabaseHelper>().updateConversationLastMessageDate(
                DatabaseHelper.conversationId(
                    targetId: targetId, myId: myUserId),
                lastMessageDate: DateTime.fromMillisecondsSinceEpoch(
                    message.deliveryDate.toInt()),
              );
            }

            // if (message.isSystemMessage &&
            //     message.type == turms.MessageType.VIDEO_TYPE) {
            //   String myUserId = sl<CredentialService>().turmsId ??
            //       sl<turms.TurmsClient>().userService.userInfo!.userId.toString();
            //   String targetId = message.hasGroupId()
            //       ? message.groupId.toString()
            //       : myUserId == message.senderId.toString()
            //           ? message.recipientId.toString()
            //           : message.senderId.toString();
            //   if (message.hasParentConversationId() &&
            //       message.parentConversationId != Int64(0)) {
            //     getParentMessage(message.parentConversationId, message);
            //   }
            //   sl<DatabaseHelper>().upsertMessage(
            //     message: message,
            //   );
            //   sl<DatabaseHelper>().updateConversationLastMessageDate(
            //     DatabaseHelper.conversationId(targetId: targetId, myId: myUserId),
            //     lastMessageDate: DateTime.fromMillisecondsSinceEpoch(
            //         message.deliveryDate.toInt()),
            //   );
            // }
          }
        }
      } catch (e) {
        log("query messages failed $e");
      }
    }
  }

  Future getImage(String fileUrl, String fileName, Int64 msgId) async {
    emit(state.copyWith(downloadImageStatus: DownloadImageStatus.downloading));
    final getImageRes = await _fileRepository.getImage(fileUrl: fileUrl);
    List<AttachmentModel> imagesList = List.from(state.attachmentList ?? []);
    AttachmentModel image = AttachmentModel(
      fileName: fileName,
      fileUrl: fileUrl,
      type: "image",
      fileSize: getImageRes.elementSizeInBytes,
    );
    imagesList.add(image);
    log("image list in cubit $imagesList");
    // Get the local directory
    Directory? dir = Platform.isIOS
        ? await getApplicationDocumentsDirectory()
        : await getDownloadsDirectory();

    // Create the file path
    final filePath = '${dir?.path}/$fileName';

    // Write the bytes to the file
    final file = File(filePath);
    if (!await file.exists()) {
      await file.writeAsBytes(getImageRes);
      await sl<DatabaseHelper>().updateMessage(msgId.toString(),
          extraInfo: jsonEncode({
            'attachments': [image.toJson()]
          }));
    }
    emit(state.copyWith(
        downloadImageStatus: DownloadImageStatus.downloaded,
        attachmentList: imagesList));
  }

  Future getVideo(String fileUrl, String fileName, Int64 msgId) async {
    emit(state.copyWith(downloadStatus: DownloadStatus.downloading));
    final getImageRes = await _fileRepository.getImage(fileUrl: fileUrl);
    List<AttachmentModel> videoList = List.from(state.attachmentList ?? []);
    AttachmentModel video = AttachmentModel(
      fileName: fileName,
      fileUrl: fileUrl,
      type: "video",
      fileSize: getImageRes.elementSizeInBytes,
    );
    // temporarily disabled for multiple video select
    videoList.add(video);
    // Get the local directory
    Directory? dir = Platform.isIOS
        ? await getApplicationDocumentsDirectory()
        : await getDownloadsDirectory();

    // Create the file path
    final filePath = '${dir?.path}/$fileName';

    // Write the bytes to the file
    final file = File(filePath);
    await file.writeAsBytes(getImageRes);
    await sl<DatabaseHelper>().updateMessage(msgId.toString(),
        extraInfo: jsonEncode({
          'attachments': [video.toJson()]
        }));
    List<String> videoThumbnail = List.from(state.videoThumbnail);
    videoThumbnail.remove(videoThumbnail.singleWhere((thumb) => p
        .basenameWithoutExtension(thumb)
        .contains(p.basenameWithoutExtension(fileName))));

    emit(state.copyWith(
        downloadStatus: DownloadStatus.downloaded,
        attachmentList: videoList,
        videoThumbnail: videoThumbnail));
  }

  /// Sends a message to the given [receiverId] from the given [senderId].
  ///
  /// If [message] is given, it will be sent as a text message. If
  /// [attachments] is given, it will be sent as a record message.
  ///
  Future sendMessage(
    Int64 receiverId,
    Int64 senderId, {
    String? message,
    List<Uint8List>? attachments = const [],
    db.Message? parentMessage,
    bool isGroupMessage = false,
    turms.MessageType messageType = turms.MessageType.TEXT_TYPE,
    List<String>? url = const [],
    String? imagePath = "",
    Int64? groupId,
    String? extraInfo,
    int? rowId,
  }) async {
    // log("Attachments size: ${attachments?[0].lengthInBytes}");
    DateTime currentDateTime = DateTime.now();

    sl<DatabaseHelper>().updateConversationLastMessageDate(
        DatabaseHelper.conversationId(
            targetId: receiverId.toString(), myId: senderId.toString()),
        lastMessageDate: currentDateTime);

    try {
      log("send url $url");
      log("send $messageType extra info $extraInfo");
      final friendRes =
          await sl<turms.TurmsClient>().userService.queryFriends();
      if (!isGroupMessage &&
          friendRes.code == 1000 &&
          friendRes.data!.userRelationships.isNotEmpty) {
        if (friendRes.data!.userRelationships.every(
            (relationship) => relationship.relatedUserId != receiverId)) {
          CustomMessageManager.showConnectionStatus(
              message: Strings.cannotSendToDeletedFriend);
          return;
        }
      } else if (!isGroupMessage && friendRes.code == 1001) {
        CustomMessageManager.showConnectionStatus(
            message: Strings.cannotSendToDeletedFriend);
        return;
      } else if (isGroupMessage) {
        try {
          final groupMemberRes =
              await sl<turms.TurmsClient>().groupService.queryGroupMembers(
                    groupId ?? Int64(0),
                  );
          log("group member res ${groupMemberRes.code}");
        } catch (e) {
          if ((e as turms.ResponseException).code == 3421) {
            // only group members can query group member
            CustomMessageManager.showConnectionStatus(
                message: Strings.youHaveBeenKickedOut);
            return;
          }
        }
      }
      int messageId =
          messageType != turms.MessageType.TEXT_TYPE ? rowId ?? 0 : 0;
      if (messageType == turms.MessageType.TEXT_TYPE) {
        if (parentMessage?.id?.isNotEmpty ?? false) {
          messageId = await sl<DatabaseHelper>().insertMessage(
              message: turms.Message(
                  text: message?.trim(),
                  groupId: isGroupMessage ? receiverId : null,
                  //records: attachments?.map((e) => e.toList()),
                  recipientId: receiverId,
                  senderId: senderId,
                  type: messageType,
                  parentConversationId: parentMessage?.id?.parseInt64(),
                  url: url,
                  deliveryDate: DateTime.now().millisecondsSinceEpoch.toInt64(),
                  extraInfo: extraInfo),
              messageStatus: MessageStatusEnum.sending,
              parentMessage: jsonEncode(parentMessage));
        } else {
          log("extra info when send $extraInfo");
          messageId = await sl<DatabaseHelper>().insertMessage(
            message: turms.Message(
                text: message?.trim(),
                groupId: isGroupMessage ? receiverId : null,
                //records: attachments?.map((e) => e.toList()),
                recipientId: receiverId,
                senderId: senderId,
                parentConversationId: parentMessage?.id?.parseInt64(),
                type: messageType,
                url: url,
                deliveryDate: DateTime.now().millisecondsSinceEpoch.toInt64(),
                extraInfo: extraInfo),
            messageStatus: MessageStatusEnum.sending,
          );
        }
      } else {
        if (parentMessage?.id?.isNotEmpty ?? false) {
          sl<DatabaseHelper>().upsertMessage(
              message: turms.Message(
                  // id: msgId.toInt64(),
                  text: message?.trim(),
                  groupId: isGroupMessage ? receiverId : null,
                  //records: attachments?.map((e) => e.toList()),
                  recipientId: receiverId,
                  senderId: senderId,
                  type: messageType,
                  parentConversationId: parentMessage?.id?.parseInt64(),
                  url: url,
                  deliveryDate: DateTime.now().millisecondsSinceEpoch.toInt64(),
                  extraInfo: extraInfo),
              messageId: messageId,
              parentMessage: jsonEncode(parentMessage));
        } else if (messageType == turms.MessageType.NAMECARD_TYPE) {
          messageId = await sl<DatabaseHelper>().insertMessage(
            message: turms.Message(
                // id: msgId.toInt64(),
                text: message?.trim(),
                groupId: isGroupMessage ? receiverId : null,
                //records: attachments?.map((e) => e.toList()),
                recipientId: receiverId,
                senderId: senderId,
                parentConversationId: parentMessage?.id?.parseInt64(),
                type: messageType,
                url: url,
                deliveryDate: DateTime.now().millisecondsSinceEpoch.toInt64(),
                extraInfo: extraInfo),
          );
        } else {
          await sl<DatabaseHelper>().upsertMessage(
            messageId: messageId,
            message: turms.Message(
                // id: msgId.toInt64(),
                text: message?.trim(),
                groupId: isGroupMessage ? receiverId : null,
                //records: attachments?.map((e) => e.toList()),
                recipientId: receiverId,
                senderId: senderId,
                parentConversationId: parentMessage?.id?.parseInt64(),
                type: messageType,
                url: url,
                deliveryDate: DateTime.now().millisecondsSinceEpoch.toInt64(),
                extraInfo: extraInfo),
          );
        }
      }

      final res = await sl<TurmsService>().handleTurmsResponse<Int64>(() async {
        final sendMsgRes = (await sl<turms.TurmsClient>()
            .messageService
            .sendMessage(isGroupMessage, receiverId,
                text: message?.trim(),
                records: attachments,
                parentConversationId: parentMessage?.id?.parseInt64(),
                messageType: messageType,
                url: messageType != turms.MessageType.TEXT_TYPE ? url : [],
                extraInfo: extraInfo));
        final msgId = sendMsgRes.data;

        print('message $msgId has been sent');
        print('send message response ${sendMsgRes.code} ${sendMsgRes.data}');
        return msgId;
      });

      log("send message response from turms $res");

      if (res is TurmsMapSuccessResponse<Int64>) {
        if (res.res != null) {
          sl<DatabaseHelper>().updateMessageStatus(
              id: res.res!,
              status: MessageStatusEnum.sent,
              messageId: messageId);

          return;
        }

        sl<DatabaseHelper>().updateMessageStatus(
            status: MessageStatusEnum.failed, messageId: messageId);

        return;
      }

      sl<DatabaseHelper>().updateMessageStatus(
          status: MessageStatusEnum.failed, messageId: messageId);

      // final sendMsgRes = (await sl<turms.TurmsClient>()
      //     .messageService
      //     .sendMessage(isGroupMessage, receiverId,
      //         text: message,
      //         records: attachments,
      //         parentConversationId: parentMessageId.toInt64(),
      //         messageType: messageType,
      //         url: messageType != turms.MessageType.TEXT_TYPE ? url : [],
      //         extraInfo: extraInfo));
      // final msgId = sendMsgRes.data;
      // print('message $msgId has been sent');
      // print('send message response ${sendMsgRes.code} ${sendMsgRes.data}');

      // if (parentMessageId != 0) {
      //   db.Message parentMessage = await (sl<db.AppDatabase>().messages.select()
      //         ..where(
      //             (message) => message.id.equals(parentMessageId.toString())))
      //       .getSingle();
      //   sl<DatabaseHelper>().upsertMessage(
      //       message: turms.Message(
      //           id: msgId.toInt64(),
      //           text: message,
      //           groupId: isGroupMessage ? receiverId : null,
      //           //records: attachments?.map((e) => e.toList()),
      //           recipientId: receiverId,
      //           senderId: senderId,
      //           type: messageType,
      //           parentConversationId: parentMessageId,
      //           url: url,
      //           deliveryDate: DateTime.now().millisecondsSinceEpoch.toInt64(),
      //           extraInfo: extraInfo),
      //       parentMessage: jsonEncode(parentMessage));
      // } else {
      //   log("extra info when send $extraInfo");
      //   sl<DatabaseHelper>().upsertMessage(
      //     message: turms.Message(
      //         id: msgId.toInt64(),
      //         text: message,
      //         groupId: isGroupMessage ? receiverId : null,
      //         //records: attachments?.map((e) => e.toList()),
      //         recipientId: receiverId,
      //         senderId: senderId,
      //         parentConversationId: parentMessageId,
      //         type: messageType,
      //         url: url,
      //         deliveryDate: DateTime.now().millisecondsSinceEpoch.toInt64(),
      //         extraInfo: extraInfo),
      //   );
      // }
    } catch (e) {
      log("error when sending message $e");
    }
  }

  /// This function gets the parent message of a message from the database.
  ///
  /// [parentMessageId] is the id of the parent message.
  ///
  /// [message] is the message of which we want to get the parent message.
  Future getParentMessage(Int64 parentMessageId, Int64 messageId) async {
    db.Message parentMessage = await (sl<db.AppDatabase>().messages.select()
          ..where((message) => message.id.equals(parentMessageId.toString())))
        .getSingle();
    sl<DatabaseHelper>().updateMessage(messageId.toString(),
        parentMessage: jsonEncode(parentMessage));
  }

  /// Recalls a message from the message list.
  ///
  /// Given a message and a list of messages, this function attempts to recall
  /// the specified message by identifying all messages that have it as their
  /// parent message. It then triggers a recall operation using the Turms client.
  /// If successful, the message content is updated to indicate deletion, and
  /// any child messages' parent message is updated accordingly. Emits the recall
  /// status during the process.
  ///
  /// [message] is the message to be recalled.
  /// [messageList] is the list of messages to search through for parent-child
  /// relationships.
  ///
  /// Emits [RecallMessageStatus.loading] before starting the process, and
  /// [RecallMessageStatus.success] upon successful completion. In case of a
  /// timeout error, emits [RecallMessageStatus.recallTimeout] with an error
  /// message.

  Future recallMessage(db.Message message, List<db.Message> messageList) async {
    if (message.id != null) {
      try {
        List<db.Message> messagesToRecall = messageList.where((msg) {
          if (msg.parentMessage != null) {
            return jsonDecode(msg.parentMessage.toString())['id'] == message.id;
          }

          return false;
        }).toList();
        emit(state.copyWith(recallMessageStatus: RecallMessageStatus.loading));
        final msgId =
            (await sl<turms.TurmsClient>().messageService.recallMessage(
                  message.id?.parseInt64() ?? Int64(0),
                ));
        log("msg code ${msgId.code}");

        if (msgId.code == 1000) {
          // await sl<DatabaseHelper>().updateMessage(
          //     message.id?.toString() ?? "0",
          //     text: Strings.messageHasBeenRecalled,
          //     extraInfo: "{'isDeleted':true}");
          // final updatedRecalledMessage = await (sl<db.AppDatabase>()
          //         .select(sl<db.AppDatabase>().messages)
          //       ..where((tbl) => tbl.id.equals(message.id?.toString() ?? "0")))
          //     .getSingleOrNull();
          // for (var msg in messagesToRecall) {
          //   log("message to update and parent ${msg.id} $updatedRecalledMessage");
          //   sl<DatabaseHelper>().updateMessage(
          //     msg.id?.toString() ?? "0",
          //     parentMessage: jsonEncode(updatedRecalledMessage),
          //   );
          // }
        }

        emit(state.copyWith(recallMessageStatus: RecallMessageStatus.success));
      } catch (e) {
        log("error turms delete $e");
        if (e is turms.ResponseException) {
          if (e.code == 5204) {
            emit(state.copyWith(
                recallMessageStatus: RecallMessageStatus.recallTimeout,
                recallErrorMessage: e.reason));
          }
        }
      }
      log("error when deleting message ${state.recallMessageStatus} ");
    }
  }

  /// Uploads an attachment to Turms and logs the URL of the uploaded
  /// attachment. The attachment is uploaded to the private conversation
  /// with the given [userId].
  ///
  /// [attachment] is the bytes of the attachment to be uploaded.
  ///
  Future<void> sendAttachment(
      String receiverId, List<XFile> attachments, turms.MessageType messageType,
      {String caption = "",
      bool isGroup = false,
      db.Message? parentMessage}) async {
    for (var file in attachments) {
      List<String> urls = [];
      AttachmentModel? attachment;
      late int messageId;
      String localPath = file.path;
      final directory = Platform.isIOS
          ? await getApplicationDocumentsDirectory()
          : await getDownloadsDirectory();

      if (directory != null) {
        localPath = '${directory.path}/${file.name}';
        await File(localPath).writeAsBytes(await file.readAsBytes());
      }

      int fileBytes = await file.length();
      log("file mimi ${file.mimeType}");
      attachment = AttachmentModel(
        fileName: file.name,
        fileUrl: file.name,
        localPath: localPath,
        mimeType:
            messageType == turms.MessageType.VIDEO_TYPE ? "video/mp4" : null,
        type: messageType == turms.MessageType.VIDEO_TYPE ? "video" : "file",
        fileSize: fileBytes,
      );

      messageId = await sl<DatabaseHelper>().insertMessage(
        message: turms.Message(
          text: "",
          // groupId: isGroupMessage ? receiverId : null,
          //records: attachments?.map((e) => e.toList()),
          recipientId: receiverId.parseInt64(),
          senderId: sl<CredentialService>().turmsId!.parseInt64(),
          type: messageType,
          url: [jsonEncode(attachment.toJson())],
          parentConversationId: parentMessage?.id?.parseInt64(),
          deliveryDate: DateTime.now().millisecondsSinceEpoch.toInt64(),
        ),
        messageStatus: MessageStatusEnum.sending,
      );
      try {
        emit(state.copyWith(
            uploadAttachmentStatus: UploadAttachmentStatus.uploading,
            fileToUpload: file));
        final res = await _fileRepository.uploadFile(file: file);
        if (res is MapSuccessResponse && res.jsonRes.containsKey('data')) {
          final data = res.jsonRes['data'];
          final fileUrl = data['fileUrl'] as String?;
          final fileName = data['filename'] as String?;
          final thumbFileUrl = data['thumbFileUrl'] as String?;
          final fileBytes = await file.length();

          if (fileUrl != null && !urls.contains(fileUrl)) {
            // urls.add(fileUrl);
            // Save file locally
            final directory = Platform.isIOS
                ? await getApplicationDocumentsDirectory()
                : await getDownloadsDirectory();
            if (directory != null) {
              final filePath = '${directory.path}/$fileUrl';
              await File(filePath).writeAsBytes(await file.readAsBytes());
              attachment = AttachmentModel(
                fileName: fileName ?? fileUrl,
                fileUrl: fileUrl,
                localPath: filePath,
                mimeType: messageType == turms.MessageType.VIDEO_TYPE
                    ? "video/mp4"
                    : null,
                type: messageType == turms.MessageType.VIDEO_TYPE
                    ? "video"
                    : "file",
                fileSize: fileBytes,
                thumbnailPath: thumbFileUrl,
              );
              urls.add(jsonEncode(attachment.toJson()));
              log("file url video $fileUrl $messageId $urls ${attachment.fileUrl}");

              //urls.add(jsonEncode(attachment.toJson()));
              sl<DatabaseHelper>()
                  .updateMessage(messageId.toString(), url: jsonEncode(urls));
            }
          }

          emit(state.copyWith(
              uploadAttachmentStatus: UploadAttachmentStatus.uploaded,
              fileToUpload: null));
        }
      } catch (e) {
        log("Error uploading image: $e");
        sl<DatabaseHelper>().updateMessageStatus(
            status: MessageStatusEnum.failed, messageId: messageId);
        return;
      }
      if (urls.isEmpty) {
        emit(state.copyWith(
            uploadAttachmentStatus: UploadAttachmentStatus.failed,
            fileToUpload: null));
        sl<DatabaseHelper>().updateMessageStatus(
            status: MessageStatusEnum.failed, messageId: messageId);
        return;
      }
      log("message id before send to turms $messageId");
      sendMessage(
        receiverId.parseInt64(),
        sl<CredentialService>().turmsId!.parseInt64(),
        messageType: messageType,
        message: caption,
        url: urls,
        parentMessage: parentMessage,
        isGroupMessage: isGroup,
        rowId: messageId,
      );
    }
  }

  /// Uploads an image attachment to the server.
  ///
  /// [attachment] is the path of the image file to be uploaded.
  /// [receiverId] is the ID of the user who will receive the image.
  /// [groupId] is an optional parameter specifying the group ID if the image
  /// is being sent to a group. Defaults to an empty string.
  ///
  /// This function uploads the image using the chat repository and does not
  /// return any result.
  Future<void> uploadImage(List<XFile> attachments, String receiverId,
      {String caption = "", bool isGroup = false}) async {
    for (var file in attachments) {
      List<String> urls = [];
      AttachmentModel? attachment;
      late int messageId;
      String localPath = file.path;
      final directory = Platform.isIOS
          ? await getApplicationDocumentsDirectory()
          : await getDownloadsDirectory();

      if (directory != null) {
        localPath =
            '${directory.path}/${sl<CredentialService>().turmsId}_${file.name}';
        await File(localPath).writeAsBytes(await file.readAsBytes());
      }

      int fileBytes = await file.length();
      attachment = AttachmentModel(
          fileName: file.name,
          fileUrl: file.path,
          localPath: localPath,
          type: 'image',
          fileSize: fileBytes,
          thumbnailPath: file.name);

      messageId = await sl<DatabaseHelper>().insertMessage(
        message: turms.Message(
          text: "",
          // groupId: isGroupMessage ? receiverId : null,
          //records: attachments?.map((e) => e.toList()),
          recipientId: receiverId.parseInt64(),
          senderId: sl<CredentialService>().turmsId!.parseInt64(),
          type: turms.MessageType.IMAGE_TYPE,
          url: [jsonEncode(attachment.toJson())],
          deliveryDate: DateTime.now().millisecondsSinceEpoch.toInt64(),
        ),
        messageStatus: MessageStatusEnum.sending,
      );
      try {
        emit(state.copyWith(
            uploadAttachmentStatus: UploadAttachmentStatus.uploading,
            fileToUpload: file));
        final res = await _fileRepository.uploadImage(file: file);
        if (res is MapSuccessResponse && res.jsonRes.containsKey('data')) {
          final data = res.jsonRes['data'];
          final fileUrl = data['fileUrl'] as String?;
          final fileName = data['filename'] as String?;
          final thumbFileUrl = data['thumbFileUrl'] as String?;
          final fileBytes = await file.length();

          if (fileUrl != null && !urls.contains(fileUrl)) {
            // urls.add(fileUrl);
            // Save file locally
            final directory = Platform.isIOS
                ? await getApplicationDocumentsDirectory()
                : await getDownloadsDirectory();
            if (directory != null) {
              final filePath =
                  '${directory.path}/${sl<CredentialService>().turmsId}_$fileUrl';
              await File(filePath).writeAsBytes(await file.readAsBytes());
              attachment = AttachmentModel(
                fileName: fileName ?? fileUrl,
                fileUrl: fileUrl,
                localPath: filePath,
                type: 'image', // Assuming these are images
                fileSize: fileBytes,
                thumbnailPath: thumbFileUrl,
              );
              urls.add(jsonEncode(attachment.toJson()));
              log("file url image $fileUrl $messageId $urls ${attachment.fileUrl}");

              //urls.add(jsonEncode(attachment.toJson()));
              sl<DatabaseHelper>()
                  .updateMessage(messageId.toString(), url: jsonEncode(urls));
            }
          }

          emit(state.copyWith(
              uploadAttachmentStatus: UploadAttachmentStatus.uploaded,
              fileToUpload: null));
        }
      } catch (e) {
        log("Error uploading image: $e");
        sl<DatabaseHelper>().updateMessageStatus(
            status: MessageStatusEnum.failed, messageId: messageId);
        return;
      }
      if (urls.isEmpty) {
        emit(state.copyWith(
            uploadAttachmentStatus: UploadAttachmentStatus.failed,
            fileToUpload: null));
        sl<DatabaseHelper>().updateMessageStatus(
            status: MessageStatusEnum.failed, messageId: messageId);
        return;
      }
      log("message id before send to turms $messageId");
      sendMessage(
        receiverId.parseInt64(),
        sl<CredentialService>().turmsId!.parseInt64(),
        messageType: turms.MessageType.IMAGE_TYPE,
        message: caption,
        url: urls,
        isGroupMessage: isGroup,
        rowId: messageId,
      );
    }

    // hide for phase 2
    // sendMessage(
    //   receiverId.parseInt64(),
    //   sl<turms.TurmsClient>().userService.userInfo!.userId,
    //   messageType: turms.MessageType.IMAGE_TYPE,
    //   message: caption,
    //   url: urls,
    //   isGroupMessage: isGroup,
    //   rowId: messageId,
    //   extraInfo: jsonEncode({'attachments': attachmentInfo}),
    // );
  }

  sendSticker(String sticker, String receiverId, {bool isGroup = false}) async {
    List<String> urls = [];
    List<Map<String, dynamic>> attachmentInfo = [];
    List<Map<String, dynamic>> localAttachmentInfo = [];

    int messageId = await sl<DatabaseHelper>().insertMessage(
      message: turms.Message(
        text: "",
        // groupId: isGroupMessage ? receiverId : null,
        //records: attachments?.map((e) => e.toList()),
        recipientId: receiverId.parseInt64(),
        senderId: sl<CredentialService>().turmsId!.parseInt64(),
        type: turms.MessageType.STICKER_TYPE,
        url: [],
        deliveryDate: DateTime.now().millisecondsSinceEpoch.toInt64(),
        //extraInfo: jsonEncode({'attachments': localAttachmentInfo})
      ),
      messageStatus: MessageStatusEnum.sending,
    );

    // if (urls.isEmpty || attachmentInfo.isEmpty) {
    //   emit(state.copyWith(
    //       uploadAttachmentStatus: UploadAttachmentStatus.failed,
    //       fileToUpload: null));
    //   sl<DatabaseHelper>().updateMessageStatus(
    //       status: MessageStatusEnum.failed, messageId: messageId);
    //   return;
    // }

    // Send the message with attachment info
    sendMessage(
      receiverId.parseInt64(),
      sl<turms.TurmsClient>().userService.userInfo!.userId,
      messageType: turms.MessageType.STICKER_TYPE,
      url: [sticker],
      message: "",
      isGroupMessage: isGroup,
      rowId: messageId,
      //extraInfo: jsonEncode({'attachments': attachmentInfo}),
    );
  }

  /// Checks if the image with the given [filename] exists on the device.
  ///
  /// If the image exists, it is added to the list of images in the state.
  /// If the image does not exist, the thumbnail of the image is retrieved
  /// from the server using the [thumbnail] URL.
  ///
  /// This function throws a [PlatformException] if there is an error accessing
  /// the file, and a generic error if there is an error generating the thumbnail.
  // Future<void> checkImageExist(db.Message message, {String? thumbnail}) async {
  //   try {
  //     AttachmentModel attachment =
  //         (jsonDecode(message.extraInfo.toString())['attachments']
  //                 as List<dynamic>)
  //             .map((e) => AttachmentModel.fromJson(e as Map<String, dynamic>))
  //             .toList()
  //             .first;
  //     final directoryPath = Platform.isIOS
  //         ? (await getApplicationDocumentsDirectory()).path
  //         : (await getDownloadsDirectory())?.path ??
  //             "/storage/emulated/0/Download";
  //     final filePath = '$directoryPath/${attachment.name}';
  //     final file = File(filePath);
  //     log("files path ${filePath} ${await file.exists()}");
  //     if (await file.exists()) {
  //       // await sl<DatabaseHelper>().updateMessage(
  //       //     message.id,
  //       //     jsonEncode({
  //       //       'attachments': [attachment.toJson()]
  //       //     }));

  //       if (!(state.attachmentList
  //           .any((image) => image.name == attachment.name))) {
  //         final updatedImageList =
  //             List<AttachmentModel>.from(state.attachmentList ?? [])
  //               ..add(attachment);
  //         emit(state.copyWith(attachmentList: updatedImageList));
  //       }
  //     } else {
  //       if (thumbnail != "" && message.type == "IMAGE_TYPE") {
  //         getThumbnail(thumbnail.toString());
  //       } else {
  //         final files = List<AttachmentModel>.from(state.filesToDownload ?? [])
  //           ..add(attachment);

  //         emit(state.copyWith(filesToDownload: files));
  //       }
  //     }
  //   } on PlatformException catch (e) {
  //     log('Error accessing file: ${e.message}');
  //   } catch (err) {
  //     log("Error generating thumbnail: $err");
  //   }
  // }

  // Future getThumbnail(String fileUrl) async {
  //   final getImageRes =
  //       await _fileRepository.getThumbnailImage(fileUrl: fileUrl);

  //   List<Map<String, dynamic>> thumbnailList =
  //       List.from(state.thumbnailList ?? []);
  //   thumbnailList.add({"thumbnailUrl": fileUrl, "thumbnailBytes": getImageRes});
  //   emit(state.copyWith(thumbnailList: thumbnailList));
  // }

  /// Checks if the video with the given [filename] exists on the device.
  ///
  /// If the video exists, it is added to the list of videos in the state.
  /// If the video does not exist, the thumbnail of the video is retrieved
  /// from the server using the [videoUrl] URL.
  ///
  /// This function throws a [PlatformException] if there is an error accessing
  /// the file, and a generic error if there is an error generating the thumbnail.
  Future<void> checkVideoExist(
      AttachmentModel attachment, db.Message message) async {
    try {
      Directory? dir = Platform.isIOS
          ? await getApplicationDocumentsDirectory()
          : await getDownloadsDirectory();
      String path = '${dir?.path}/${attachment.fileName}';
      if (await File(path).exists()) {
        List<AttachmentModel> videos = List.from(state.attachmentList);
        List<String> videoThumbnail = List.from(state.videoThumbnail);

        if (videoThumbnail
            .any((element) => element == attachment.thumbnailPath)) {
          videoThumbnail.remove(attachment.thumbnailPath);
        }
        // if (attachment.attachmentBytes == null) {
        //   attachment.attachmentBytes = await File(path).readAsBytes();

        //   await sl<DatabaseHelper>().updateMessage(
        //       message.id,
        //       jsonEncode({
        //         'attachments': [attachment.toJson()]
        //       }));
        // }
        if (!videos.contains(attachment)) {
          videos.add(attachment);
        }
        emit(state.copyWith(
            attachmentList: videos, videoThumbnail: videoThumbnail));
      } else {
        if (!state.videoThumbnail
            .any((thumb) => thumb == attachment.fileName)) {
          //String thumbnailPath = '${dir?.path}/thumbnail-${attachment.name}';
          try {
            final videoBytes =
                await _fileRepository.getImage(fileUrl: attachment.fileUrl);
            // Get the temporary directory
            final tempDir = await getTemporaryDirectory();
            final tempVideoPath =
                '${tempDir.path}/thumbnail-${attachment.fileName}';

            // Write the video bytes to a temporary file
            final tempVideoFile = File(tempVideoPath);
            await tempVideoFile.writeAsBytes(videoBytes);
            // final thumbnailName = await VideoThumbnail.thumbnailFile(
            //   video: tempVideoPath,
            //   //thumbnailPath: thumbnailPath,
            //   maxHeight:
            //       64, // specify the height of the thumbnail, let the width auto-scaled to keep the source aspect ratio
            //   quality: 75,
            // );
            // // Clean up the temporary video file
            // await tempVideoFile.delete();
            // log("temp video $thumbnailName");
            // if (!state.videoThumbnail.contains(thumbnailName)) {
            //   emit(state.copyWith(
            //       videoThumbnail: List<String>.from(state.videoThumbnail)
            //         ..add(thumbnailName.toString())));
            // }
          } catch (e) {
            log("thumbnail error $e");
          }
        }
      }
    } on PlatformException catch (e) {
      log('Error accessing file: ${e.message}');
    } catch (err) {
      log("Error generating thumbnail: $err");
    }
  }

  Future<void> downloadFile(String uri, String filename, Int64 msgId) async {
    Directory? dir;
    if (Platform.isIOS) {
      dir = await getApplicationDocumentsDirectory();
    } else {
      dir = await getDownloadsDirectory();
    }

    String path = '${dir?.path}/$filename';
    log("savePath: $path ${jsonDecode(uri)[0]}");

    // Get the local directory

    if (await File(path).exists()) {
      emit(state.copyWith(
        downloadImageStatus: DownloadImageStatus.downloaded,
      ));
      await OpenFile.open(path);
    } else {
      emit(state.copyWith(
          downloadStatus: DownloadStatus.downloading,
          fileToDownload:
              AttachmentModel.fromJson(jsonDecode(jsonDecode(uri)[0]))));

      final getFileRes = await _fileRepository.getImage(
          fileUrl:
              AttachmentModel.fromJson(jsonDecode(jsonDecode(uri)[0])).fileUrl);
      List<AttachmentModel> fileList = List.from(state.attachmentList ?? []);
      AttachmentModel fileAttachment = AttachmentModel(
        fileName: filename,
        fileUrl: uri,
        type: "file",
        fileSize: getFileRes.elementSizeInBytes,
      );
      fileList.add(fileAttachment);
      // Write the bytes to the file
      final file = File(path);
      await file.writeAsBytes(getFileRes);
      await sl<DatabaseHelper>().updateMessage(msgId.toString(),
          extraInfo: jsonEncode({
            'attachments': [fileAttachment.toJson()]
          }));
      emit(state.copyWith(
          downloadStatus: DownloadStatus.downloaded,
          fileToDownload: null,
          attachmentList: fileList));
    }
  }

  Future deleteMessage(
    List<db.Message> messageList,
  ) async {
    try {
      emit(state.copyWith(recallMessageStatus: RecallMessageStatus.loading));
      log("turms token ${sl<CredentialService>().turmsToken}");
      final msgId = (await sl<turms.TurmsClient>().messageService.deleteMessage(
            deviceType: Platform.isAndroid
                ? turms.DeviceType.ANDROID
                : turms.DeviceType.IOS,
            messageIds: messageList.map((e) {
              log("message to delete ${e.id}");
              return e.id?.parseInt64() ?? Int64(0);
            }).toList(),
          ));
      log("msg code ${msgId.code}");
      if (msgId.code == 1000) {
        messageList.forEach((message) async {
          sl<DatabaseHelper>().deleteMessage(message.id ?? "");
        });
      }

      emit(state.copyWith(recallMessageStatus: RecallMessageStatus.success));
    } catch (e) {
      if (e is turms.ResponseException) {
        log("error turms delete ${e.code} ${e.reason}");
        if (e.code == 5204) {
          emit(state.copyWith(
              recallMessageStatus: RecallMessageStatus.recallTimeout,
              recallErrorMessage: e.reason));
        }
      }
    }
    log("error when deleting message ${state.recallMessageStatus}");
  }

  editMessage(db.Message message) async {
    DateTime currentDateTime = DateTime.now();
    // String friendId =
    //     myId == senderId ? receiverId.toString() : senderId.toString();

    sl<DatabaseHelper>().updateConversationLastMessageDate(
        DatabaseHelper.conversationId(
            targetId: message.receiverId.toString(),
            myId: message.senderId.toString()),
        lastMessageDate: currentDateTime);
    int messageId = 0;
    try {
      messageId = await sl<DatabaseHelper>().updateMessage(
          message.id.toString(),
          messageStatus: MessageStatusEnum.sending,
          text: message.content);

      final sendMsgRes = (await sl<turms.TurmsClient>()
          .messageService
          .updateSentMessage(message.id?.parseInt64() ?? Int64(0),
              text: message.content));

      // print('message $msgId has been sent');
      // print('send message response ${sendMsgRes.code} ${sendMsgRes.data}');

      log("edit message response from turms $sendMsgRes ${message.content}");

      if (sendMsgRes.code == 1000) {
        log("edit message response ${sendMsgRes.code}");
        messageId = await sl<DatabaseHelper>().updateMessage(
            message.id.toString(),
            messageStatus: MessageStatusEnum.sent,
            text: message.content);
        // sl<DatabaseHelper>().updateMessageStatus(
        //     // id: res.res!,
        //     status: MessageStatusEnum.sent,
        //     messageId: messageId);

        return;
      }

      sl<DatabaseHelper>().updateMessageStatus(
          status: MessageStatusEnum.failed, messageId: messageId);

      return;

      // sl<DatabaseHelper>().updateMessageStatus(
      //     status: MessageStatusEnum.failed, messageId: messageId);

      // final sendMsgRes = (await sl<turms.TurmsClient>()
      //     .messageService
      //     .sendMessage(isGroupMessage, receiverId,
      //         text: message,
      //         records: attachments,
      //         parentConversationId: parentMessageId.toInt64(),
      //         messageType: messageType,
      //         url: messageType != turms.MessageType.TEXT_TYPE ? url : [],
      //         extraInfo: extraInfo));
      // final msgId = sendMsgRes.data;
      // print('message $msgId has been sent');
      // print('send message response ${sendMsgRes.code} ${sendMsgRes.data}');

      // if (parentMessageId != 0) {
      //   db.Message parentMessage = await (sl<db.AppDatabase>().messages.select()
      //         ..where(
      //             (message) => message.id.equals(parentMessageId.toString())))
      //       .getSingle();
      //   sl<DatabaseHelper>().upsertMessage(
      //       message: turms.Message(
      //           id: msgId.toInt64(),
      //           text: message,
      //           groupId: isGroupMessage ? receiverId : null,
      //           //records: attachments?.map((e) => e.toList()),
      //           recipientId: receiverId,
      //           senderId: senderId,
      //           type: messageType,
      //           parentConversationId: parentMessageId,
      //           url: url,
      //           deliveryDate: DateTime.now().millisecondsSinceEpoch.toInt64(),
      //           extraInfo: extraInfo),
      //       parentMessage: jsonEncode(parentMessage));
      // } else {
      //   log("extra info when send $extraInfo");
      //   sl<DatabaseHelper>().upsertMessage(
      //     message: turms.Message(
      //         id: msgId.toInt64(),
      //         text: message,
      //         groupId: isGroupMessage ? receiverId : null,
      //         //records: attachments?.map((e) => e.toList()),
      //         recipientId: receiverId,
      //         senderId: senderId,
      //         parentConversationId: parentMessageId,
      //         type: messageType,
      //         url: url,
      //         deliveryDate: DateTime.now().millisecondsSinceEpoch.toInt64(),
      //         extraInfo: extraInfo),
      //   );
      // }
    } catch (e) {
      log("error when sending message $e");
    }
  }
}
