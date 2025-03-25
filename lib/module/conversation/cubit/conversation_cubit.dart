import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:protech_mobile_chat_stream/constants/storagekey_constants.dart';
import 'package:protech_mobile_chat_stream/constants/string_constant.dart';
import 'package:protech_mobile_chat_stream/model/database.dart' as db;
import 'package:protech_mobile_chat_stream/service/credential_service.dart';
import 'package:protech_mobile_chat_stream/service/database_helper.dart';
import 'package:protech_mobile_chat_stream/utils/iterable_apis.dart';
import 'package:protech_mobile_chat_stream/utils/service_locator.dart';
import 'package:protech_mobile_chat_stream/utils/string_apis.dart';
import 'package:turms_client_dart/turms_client.dart';

part 'conversation_state.dart';

class ConversationCubit extends Cubit<ConversationState> {
  ConversationCubit() : super(const ConversationState());

  DatabaseHelper dbHelper = sl<DatabaseHelper>();

  getConversations() async {
    try {
      emit(
          state.copyWith(getConversationStatus: GetConversationStatus.loading));
      String? turmsUid = await sl<FlutterSecureStorage>()
          .read(key: StoragekeyConstants.turmsUidKey);
      TurmsClient? turmsClient = sl<TurmsClient>();
      List<db.Conversation> localConversations =
          await sl<DatabaseHelper>().getOwnConversation(turmsUid.toString());
      if (sl<TurmsClient>().driver.isConnected) {
        log("will get friend");

        final getFriendIds =
            await sl<TurmsClient>().userService.queryRelatedUserIds();
        final getGroupIds =
            await sl<TurmsClient>().groupService.queryJoinedGroupIds();

        log("group ids ${getGroupIds.data?.longs}");
        // await turmsClient.userService
        //     .queryUserProfiles(getFriendIds.data?.longs.toSet() ?? {});
        final conversationResponse = await sl<TurmsClient>()
            .conversationService
            .queryPrivateConversations(getFriendIds.data?.longs ?? [],
                showOwnedPm: true);
        final groupConversationResponse = await turmsClient.conversationService
            .queryGroupConversations(getGroupIds.data?.longs ?? []);

        final localConversationIds =
            localConversations.map((e) => e.title).toList();

        try {
          final conversationSettingsRes = await sl<TurmsClient>()
              .conversationService
              .queryConversationSettings(
                  groupIds: getGroupIds.data?.longs.toSet());

          if (conversationSettingsRes.code == 1000) {
            emit(state.copyWith(
                conversationsSettings: conversationSettingsRes.data));
          }
          log("cubit conversation settings ${conversationSettingsRes.data}");
        } catch (e) {
          log("error getting conversation settings $e");
        }

        groupConversationResponse.data.forEach((groupConversation) async {
          if (!localConversationIds
              .contains(groupConversation.groupId.toString())) {
            final groupRes = await turmsClient.groupService
                .queryGroups(getGroupIds.data?.longs.toSet() ?? {});

            if (groupRes.data.isNotEmpty) {
              groupRes.data.forEach((group) async {
                final groupMemberRes =
                    await turmsClient.groupService.queryGroupMembers(group.id);
                List<String> membersId = [];
                if (groupMemberRes.data?.groupMembers.isNotEmpty ?? false) {
                  membersId = groupMemberRes.data!.groupMembers
                      .map((e) => e.userId.toString())
                      .toList();
                }

                log("group data ${groupMemberRes.data!.groupMembers}");
                db.Conversation? existedConversation =
                    localConversations.firstWhereOrNull(
                  (conversation) =>
                      conversation.targetId == group.id.toString(),
                );
                log("existed conversation group ${existedConversation?.avatar}");
                await dbHelper.upsertConversation(
                    friendId: group.id.toString(),
                    members: membersId,
                    title: group.name.toString(),
                    targetId: group.id.toString(),
                    isGroup: true,
                    avatar: existedConversation?.avatar,
                    ownerId: group.ownerId.toString());
                // await sl<AppDatabase>()
                //     .into(sl<AppDatabase>().conversations)
                //     .insertOnConflictUpdate(ConversationsCompanion(
                //         id: drift.Value(group.id.toString()),
                //         title: drift.Value(group.name.toString()),
                //         members: drift.Value(jsonEncode(
                //             groupMemberRes.data!.groupMembers.isNotEmpty
                //                 ? membersId
                //                 : [])),
                //         isGroup: const drift.Value(true)));
              });
            }
          }
        });

        // Insert missing conversations into the database

        // if (missingConversations?.isNotEmpty ?? false) {
        //   for (var conversation in missingConversations!) {
        //     // final id = Helper.generateUUID(); // Generate a new UUID

        //     await db.upsertConversation(
        //         friendId: conversation.toString(),
        //         members: [
        //           conversation.toString(),
        //           sl<TurmsClient>().userService.userInfo!.userId.toString()
        //         ],
        //         isGroup: false,
        //         targetId: conversation.toString(),
        //         ownerId:
        //             sl<TurmsClient>().userService.userInfo!.userId.toString());

        //     // await sl<AppDatabase>()
        //     //     .into(sl<AppDatabase>().conversations)
        //     //     .insert(ConversationsCompanion(
        //     //         id: drift.Value(
        //     //             "c_${conversation}_${sl<TurmsClient>().userService.userInfo!.userId}"),
        //     //         title: drift.Value(conversation.toString()),
        //     //         members: drift.Value(jsonEncode([
        //     //           conversation.toString(),
        //     //           sl<TurmsClient>().userService.userInfo!.userId.toString()
        //     //         ]))));
        //   }
        // }

        for (final conversation in conversationResponse.data) {
          String friendId = sl<CredentialService>().turmsId!.parseInt64() ==
                  conversation.targetId
              ? conversation.ownerId.toString()
              : conversation.targetId.toString();
          String myUserId =
              sl<CredentialService>().turmsId!.parseInt64().toString();

          UserInfo? friendInfo = await turmsClient.userService
              .queryUserProfiles({friendId.parseInt64()}).then(
                  (value) => value.data.firstOrNull);

          await dbHelper.upsertConversation(
              friendId: friendId,
              members: [friendId, myUserId],
              isGroup: false,
              targetId: friendId,
              title: friendInfo?.name ?? Strings.deletedUser,
              avatar: friendInfo?.profilePicture,
              ownerId: myUserId);
        }

        emit(state.copyWith(
          getConversationStatus: GetConversationStatus.success,
        ));

        log("conversationResponse ${conversationResponse.data}");
        log("groupResponse ${groupConversationResponse.data}");
      }
    } catch (error) {
      emit(state.copyWith(getConversationStatus: GetConversationStatus.fail));
      log("get convo failed: $error");
    }
  }
}
