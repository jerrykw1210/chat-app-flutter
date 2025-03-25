import 'dart:convert';
import 'dart:developer';
import 'dart:io' as io;

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:fixnum/fixnum.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:protech_mobile_chat_stream/constants/string_constant.dart';
import 'package:protech_mobile_chat_stream/model/database.dart' as db;
import 'package:protech_mobile_chat_stream/module/file/repository/file_repository.dart';
import 'package:protech_mobile_chat_stream/service/credential_service.dart';
import 'package:protech_mobile_chat_stream/service/database_helper.dart';
import 'package:protech_mobile_chat_stream/service/response.dart' hide Response;
import 'package:protech_mobile_chat_stream/service/turms_response.dart';
import 'package:protech_mobile_chat_stream/service/turms_service.dart';
import 'package:protech_mobile_chat_stream/utils/service_locator.dart';
import 'package:protech_mobile_chat_stream/utils/string_apis.dart';
import 'package:turms_client_dart/turms_client.dart';

part 'group_state.dart';

class GroupCubit extends Cubit<GroupState> {
  GroupCubit() : super(const GroupState());
  final FileRepository _fileRepository = sl<FileRepository>();

  reset() {
    emit(state.copyWith(
      getGroupMemberStatus: GetGroupMemberStatus.initial,
      leaveGroupStatus: LeaveGroupStatus.initial,
      addGroupMemberStatus: AddGroupMemberStatus.initial,
      kickGroupMemberStatus: KickGroupMemberStatus.initial,
      updateGroupStatus: UpdateGroupStatus.initial,
      updateMemberScopeStatus: UpdateMemberScopeStatus.initial,
      transferOwnerStatus: TransferOwnerStatus.initial,
      createGroupStatus: CreateGroupStatus.initial,
      getGroupInfoStatus: GetGroupInfoStatus.initial,
      joinGroupStatus: JoinGroupStatus.initial,
    ));
  }

  resetGroupInfo(Group? groupInfo) {
    emit(state.copyWith(groupInfo: () => groupInfo));
  }

  Future<void> createGroup(String name, List<UserInfo> users,
      {String? description}) async {
    emit(state.copyWith(createGroupStatus: CreateGroupStatus.loading));
    try {
      String truncatedGroupName =
          name.length > 50 ? name.substring(0, 50) : name;
      final res = await sl<TurmsClient>()
          .groupService
          .createGroup(truncatedGroupName, intro: description);
      // group typeid - 0 (need verification + unmute)
      //               1 (need verification)
      if (res.code == 1000) {
        List<Int64> userIdList = users.map((e) => e.id).toList();

        await sl<TurmsClient>().groupService.addGroupMembers(
            res.data, userIdList.toSet(),
            role: GroupMemberRole.MEMBER);

        List<String> userIdStringList =
            users.map((e) => e.id.toString()).toList();
        userIdStringList.add(sl<CredentialService>().turmsId.toString());
        await sl<DatabaseHelper>().upsertConversation(
            friendId: res.data.toString(),
            members: userIdStringList,
            targetId: res.data.toString(),
            ownerId: sl<CredentialService>().turmsId!,
            title: name,
            lastMessageDate: DateTime.now(),
            isGroup: true);

        await fetchGroupSettings(res.data);

        emit(state.copyWith(createGroupStatus: CreateGroupStatus.success));

        final msgRes = await sl<TurmsClient>().messageService.sendMessage(
              true,
              res.data,
              text: Strings.groupWelcomeMessage.replaceAll("[name]", name),
            );

        if (msgRes.code == ResponseStatusCode.ok) {
          Int64 msgId = msgRes.data;
          await sl<DatabaseHelper>().upsertMessage(
              message: Message(
                  id: msgId,
                  text: Strings.groupWelcomeMessage.replaceAll("[name]", name),
                  senderId: sl<CredentialService>().turmsId!.parseInt64(),
                  groupId: res.data,
                  deliveryDate: DateTime.now().millisecondsSinceEpoch.toInt64(),
                  recipientId: res.data));
        }
      }
      log("res to create group ${res.code} ${res.data}");
    } catch (e) {
      log("create group erorr $e");
    }
  }

  Future<void> getGroupMember({required Int64 groupId}) async {
    emit(state.copyWith(getGroupMemberStatus: GetGroupMemberStatus.loading));

    try {
      final turmsClient = sl<TurmsClient>();
      log("the group id $groupId");
      final groupMemberRes =
          await turmsClient.groupService.queryGroupMembers(groupId);

      if (groupMemberRes.data?.groupMembers.isNotEmpty ?? false) {
        final userIds =
            groupMemberRes.data!.groupMembers.map((e) => e.userId).toSet();
        final userProfileRes =
            await turmsClient.userService.queryUserProfiles(userIds);

        if (userProfileRes.data.isNotEmpty) {
          groupMemberRes.data!.groupMembers
              .sort((a, b) => a.userId.compareTo(b.userId));
          userProfileRes.data.sort((a, b) => a.id.compareTo(b.id));
          log("group members cubit ${groupMemberRes.data?.groupMembers} ,,,,$userIds,,,${userProfileRes.data}");
          emit(state.copyWith(
            getGroupMemberStatus: GetGroupMemberStatus.success,
            groupMemberList: groupMemberRes.data?.groupMembers,
            memberList: userProfileRes.data,
          ));
        }
      }
    } catch (e) {
      emit(state.copyWith(getGroupMemberStatus: GetGroupMemberStatus.fail));
      log("get group member error: $e");
    }
  }

  Future<void> addGroupMember({
    required Int64 groupId,
    required List<UserInfo> userList,
  }) async {
    emit(state.copyWith(addGroupMemberStatus: AddGroupMemberStatus.loading));

    try {
      List<Int64> userIdList = userList.map((e) => e.id).toList();
      final addMemberRes = await sl<TurmsClient>().groupService.addGroupMembers(
          groupId, userIdList.toSet(),
          role: GroupMemberRole.MEMBER);

      if (addMemberRes.code == 1000) {
        getGroupMember(groupId: groupId);
        emit(
            state.copyWith(addGroupMemberStatus: AddGroupMemberStatus.success));
      }
    } catch (e) {
      log("add member error");
    }
  }

  Future<void> getGroupInfo(Int64 groupId) async {
    try {
      final groupInfoRes =
          await sl<TurmsClient>().groupService.queryJoinedGroupInfos();
      if (groupInfoRes.data?.groups.isNotEmpty ?? false) {
        Group? groupInfo = groupInfoRes.data?.groups
            .singleWhere((group) => group.id == groupId);
        emit(state.copyWith(
            getGroupInfoStatus: GetGroupInfoStatus.success,
            groupInfo: () => groupInfo));
        log("my group info $groupInfo");
      }
    } catch (e) {
      log("get group info error $e");
    }
  }

  Future<void> fetchGroupSettings(Int64 groupId) async {
    TurmsService turmsService = sl<TurmsService>();
    ConversationSettings? conversationSettings;
    final groupSettingsRes =
        await turmsService.handleTurmsResponse<ConversationSettings?>(() async {
      Response<List<ConversationSettings>> res = await sl<TurmsClient>()
          .conversationService
          .queryConversationSettings(groupIds: {groupId});

      if (res.data.isEmpty) {
        return null;
      }

      return res.data.first;
    });

    if (groupSettingsRes is TurmsMapSuccessResponse<ConversationSettings?>) {
      conversationSettings = groupSettingsRes.res;

      if (conversationSettings != null) {
        // conversationSettings.settings;
        sl<DatabaseHelper>().updateGroupSettings(
            conversationId: DatabaseHelper.conversationId(
                targetId: groupId.toString(),
                myId: sl<CredentialService>().turmsId!),
            settings: jsonEncode(conversationSettings.writeToJsonMap()));
      }
    }
  }

  Future<void> updateGroupInfo(
      Int64 groupId, String groupName, String groupDescription) async {
    String truncatedGroupName =
        groupName.length > 50 ? groupName.substring(0, 50) : groupName;
    try {
      final groupInfoRes = await sl<TurmsClient>().groupService.updateGroup(
          groupId,
          name: truncatedGroupName,
          intro: groupDescription);
      if (groupInfoRes.code == 1000) {
        await getGroupInfo(groupId);
        final groupMemberRes =
            await sl<TurmsClient>().groupService.queryGroupMembers(groupId);
        List<String> membersId = [];
        if (groupMemberRes.data?.groupMembers.isNotEmpty ?? false) {
          membersId = groupMemberRes.data!.groupMembers
              .map((e) => e.userId.toString())
              .toList();
        }
        sl<DatabaseHelper>().upsertConversation(
            friendId: state.groupInfo?.id.toString() ?? "",
            members: membersId,
            title: state.groupInfo?.name.toString(),
            targetId: groupId.toString(),
            isGroup: true,
            ownerId: state.groupInfo?.ownerId.toString());
      }
    } catch (e) {
      log("update group info error $e");
    }
  }

  Future<void> disbandGroup(
      Int64 groupId, String localConversationGroupId) async {
    try {
      emit(state.copyWith(leaveGroupStatus: LeaveGroupStatus.loading));

      final deleteGroupRes = await sl<TurmsClient>().groupService.deleteGroup(
            groupId,
          );
      if (deleteGroupRes.code == 1000) {
        sl<DatabaseHelper>()
            .deleteConversation(localConversationGroupId.toString());
        emit(state.copyWith(leaveGroupStatus: LeaveGroupStatus.success));
      }
    } catch (e) {}
  }

  void saveImage(XFile image) {
    emit(state.copyWith(image: image));
  }

  Future<void> kickGroupMember(
      {required Int64 groupId, required Set<Int64> userId}) async {
    emit(state.copyWith(kickGroupMemberStatus: KickGroupMemberStatus.loading));
    final kickMemberRes = await sl<TurmsClient>()
        .groupService
        .removeGroupMembers(groupId, userId);

    log("kick member res ${kickMemberRes.code}");
    if (kickMemberRes.code == 1000) {
      getGroupMember(groupId: groupId);
      emit(state.copyWith(
          kickGroupMemberStatus: KickGroupMemberStatus.success,
          inactiveUsers: []));
    } else {
      emit(state.copyWith(kickGroupMemberStatus: KickGroupMemberStatus.fail));
    }
  }

  Future<void> postGroupAnnouncement(Int64 groupId, String announcement) async {
    try {
      final postAnnouncementRes = await sl<TurmsClient>()
          .groupService
          .updateGroup(groupId, announcement: announcement);
      if (postAnnouncementRes.code == 1000) {
        await getGroupInfo(groupId);
      }
    } catch (e) {
      log("post announcement error $e");
    }
  }

  Future<void> uploadGroupProfileImage(
      XFile file, db.Conversation conversation) async {
    try {
      emit(state.copyWith(
          uploadGroupProfileImageStatus:
              UploadGroupProfileImageStatus.loading));
      final uploadImageRes = await _fileRepository.uploadGroupProfileImage(
          file: file, groupId: conversation.targetId.toString());

      if (uploadImageRes is MapSuccessResponse) {
        io.Directory? dir;
        dir = io.Platform.isIOS
            ? await getApplicationDocumentsDirectory()
            : await getDownloadsDirectory();
        io.File("${dir?.path}/${sl<CredentialService>().turmsId}_${conversation.targetId}.jpg")
            .writeAsBytes(await file.readAsBytes());

        log("conversation group id ${conversation.id} ${file.name}");
        await sl<DatabaseHelper>().updateProfileImage(conversation.id,
            "${sl<CredentialService>().turmsId}_${conversation.targetId}.jpg");
        emit(state.copyWith(
            uploadGroupProfileImageStatus:
                UploadGroupProfileImageStatus.success,
            groupProfileImage:
                "${sl<CredentialService>().turmsId}_${conversation.targetId}.jpg"));
      } else {
        emit(state.copyWith(
            uploadGroupProfileImageStatus: UploadGroupProfileImageStatus.fail));
      }
    } catch (e) {
      emit(state.copyWith(
          uploadGroupProfileImageStatus: UploadGroupProfileImageStatus.fail));
      log("update group info error $e");
    }
  }

  Future<void> queryJoinGroupRequest(Int64 groupId) async {
    try {
      final res =
          await sl<TurmsClient>().groupService.queryJoinRequests(groupId);
      log("get group join request : ${res.code} ${res.data}");
      List<Map<String, dynamic>> groupJoinRequestList = [];

      if (res.code == ResponseStatusCode.ok) {
        if (res.data != null) {
          if (res.data!.groupJoinRequests.isNotEmpty) {
            for (GroupJoinRequest request in res.data!.groupJoinRequests
                .where((request) => request.status == RequestStatus.PENDING)
                .toList()) {
              Map<String, dynamic> groupJoinRequestMap = {};

              UserInfo? usr;

              UserInfo? userInfo = await sl<TurmsService>()
                  .queryUserProfile(request.targetId.toString());

              if (userInfo != null) {
                usr = userInfo;
              }

              groupJoinRequestMap["userInfo"] = usr;

              groupJoinRequestMap["groupJoinRequest"] = request;

              groupJoinRequestList.add(groupJoinRequestMap);
            }
          }
        }
      }

      emit(state.copyWith(groupJoinRequestList: groupJoinRequestList));
    } catch (e) {
      log("get group join request failed : $e");
    }
  }

  Future<void> joinGroupRequest(Int64 groupId, String targetId) async {
    try {
      emit(state.copyWith(joinGroupStatus: JoinGroupStatus.loading));
      final res = await sl<TurmsClient>()
          .groupService
          .createJoinRequest(groupId, "", targetId.parseInt64());
      if (res.code == 1000) {
        emit(state.copyWith(joinGroupStatus: JoinGroupStatus.success));
      } else {
        emit(state.copyWith(joinGroupStatus: JoinGroupStatus.fail));
      }
      log("join group request : ${res.code}");
    } catch (e) {
      emit(state.copyWith(joinGroupStatus: JoinGroupStatus.fail));

      log("join group request failed : $e");
    }
  }

  Future<void> createInvitation(Int64 groupId) async {
    try {
      // final res = await sl<TurmsClient>().groupService.joinGroup(
      //       groupId,
      //     );
      final res = await sl<TurmsClient>()
          .groupService
          .createInvitation(groupId, 5359819054758387712.toInt64(), "");
      log("send group invitation request : ${res.code}");
    } catch (e) {
      log("send group invitation request failed : $e");
    }
  }

  Future<void> respondGroupRequest(
      int requestId, ResponseAction action, Int64 groupId) async {
    try {
      final res = await sl<TurmsClient>()
          .groupService
          .replyJoinRequest(requestId.toInt64(), action);
      if (res.code == 1000) {
        queryJoinGroupRequest(groupId);
        getGroupMember(groupId: groupId);
      }
      log("accept group join request : ${res.code}");
    } catch (e) {
      log("accept group join failed : $e");
    }
  }

  Future<void> queryInactiveUsers(Int64 groupId) async {
    try {
      final res =
          await sl<TurmsClient>().groupService.queryGroupMembers(groupId);
      final userRes = await sl<TurmsClient>().userService.queryUserProfiles(
          res.data?.groupMembers.map((e) => e.userId).toList().toSet() ?? {});
      List<UserInfo> inactiveUsers =
          userRes.data.where((user) => !user.active).toList();
      emit(state.copyWith(inactiveUsers: inactiveUsers));
    } catch (e) {
      log("query inactive users failed : $e");
    }
  }

  Future<void> fetchGroup() async {
    try {
      emit(state.copyWith(fetchGroupStatus: FetchGroupStatus.loading));
      final groupInfoRes =
          await sl<TurmsClient>().groupService.queryJoinedGroupInfos();

      if (groupInfoRes.code == ResponseStatusCode.noContent) {
        emit(state.copyWith(fetchGroupStatus: FetchGroupStatus.empty));
      }
      if (groupInfoRes.code == ResponseStatusCode.ok) {
        if (groupInfoRes.data?.groups.isEmpty ?? false) {
          emit(state.copyWith(fetchGroupStatus: FetchGroupStatus.empty));
        }
        emit(state.copyWith(
            groupList: groupInfoRes.data?.groups,
            fetchGroupStatus: FetchGroupStatus.success));
      }
    } catch (e) {}
  }

  Future<void> leaveGroup(
      Int64 groupId, String localConversationGroupId) async {
    try {
      emit(state.copyWith(leaveGroupStatus: LeaveGroupStatus.loading));
      log("current logged user ${sl<TurmsClient>().userService.userInfo}");
      final deleteGroupRes = await sl<TurmsClient>().groupService.quitGroup(
            groupId,
          );
      if (deleteGroupRes.code == 1000) {
        sl<DatabaseHelper>()
            .deleteConversation(localConversationGroupId.toString());
        emit(state.copyWith(leaveGroupStatus: LeaveGroupStatus.success));
      }
    } catch (e) {
      log("error leaving group: $e");
    }
  }

  void resetGroupImageStatus() {
    emit(state.copyWith(
        uploadGroupProfileImageStatus: UploadGroupProfileImageStatus.initial,
        groupProfileImage: ""));
  }
}
