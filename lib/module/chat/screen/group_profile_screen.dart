import 'dart:developer';
import 'dart:io' as io;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:protech_mobile_chat_stream/constants/string_constant.dart';
import 'package:protech_mobile_chat_stream/model/database.dart' as db;
import 'package:protech_mobile_chat_stream/module/chat/cubit/chat_cubit.dart';
import 'package:protech_mobile_chat_stream/module/chat/cubit/group_cubit.dart';
import 'package:protech_mobile_chat_stream/module/chat/screen/group_join_request_screen.dart';
import 'package:protech_mobile_chat_stream/module/chat/screen/group_permission_screen.dart';
import 'package:protech_mobile_chat_stream/module/chat/screen/pin_message_screen.dart';
import 'package:protech_mobile_chat_stream/module/friend/cubit/user_cubit.dart';
import 'package:protech_mobile_chat_stream/module/friend/screen/create_group_screen.dart';
import 'package:protech_mobile_chat_stream/route/routes.dart';
import 'package:protech_mobile_chat_stream/service/credential_service.dart';
import 'package:protech_mobile_chat_stream/service/database_helper.dart';
import 'package:protech_mobile_chat_stream/utils/colors.dart';
import 'package:protech_mobile_chat_stream/utils/helper.dart';
import 'package:protech_mobile_chat_stream/utils/service_locator.dart';
import 'package:protech_mobile_chat_stream/utils/string_apis.dart';
import 'package:protech_mobile_chat_stream/utils/toast_utils.dart';
import 'package:protech_mobile_chat_stream/widgets/chat_avatar.dart';
import 'package:protech_mobile_chat_stream/widgets/custom_alert_dialog.dart';
import 'package:turms_client_dart/turms_client.dart';

class GroupProfileScreen extends StatefulWidget {
  const GroupProfileScreen({
    super.key,
    required this.group,
    this.conversationSettings,
  });

  final db.Conversation group;
  final ConversationSettings? conversationSettings;
  @override
  State<GroupProfileScreen> createState() => _GroupProfileScreenState();
}

class _GroupProfileScreenState extends State<GroupProfileScreen> {
  TextEditingController groupNameController = TextEditingController();
  TextEditingController groupDescriptionController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  bool checkPermission(String settingsKey,
      {bool reverseBool = false, bool? customOutputWhenOwnerIdEqualsUserId}) {
    final settings = widget.conversationSettings;
    final ownerId = widget.group.ownerId;
    final userId = sl<CredentialService>().turmsId;
    final trueCondition = reverseBool ? 0 : 1;

    if (settings == null || ownerId == null || userId == null) {
      return reverseBool;
    }

    if (ownerId == userId) {
      return customOutputWhenOwnerIdEqualsUserId ?? !reverseBool;
    }

    return settings.settings[settingsKey]?.int32Value == trueCondition;
  }

  bool isOwner() {
    final ownerId = widget.group.ownerId;
    final userId = sl<CredentialService>().turmsId;
    log("owner id $ownerId $userId");
    return ownerId == userId;
  }

  @override
  void initState() {
    super.initState();
    //context.read<GroupCubit>().reset();
    context.read<UserCubit>().fetchUsers();
    // if (widget.conversationSettings?.settings['NEED_ENTRY_VERIFICATION']
    //         ?.int32Value ==
    //     1)
    if (isOwner()) {
      context.read<GroupCubit>().queryJoinGroupRequest(
            widget.group.targetId.toString().parseInt64(),
          );

      // context.read<GroupCubit>().createInvitation(
      //       widget.group.targetId.toString().parseInt64(),
      //     );
    }
  }

  // bool higherPrivilege(
  //     {required String myScope,
  //     required String targetScope,
  //     bool isOwner = false}) {
  //   if (isOwner) {
  //     return true;
  //   }

  //   if (myScope == GroupMemberScope.moderator &&
  //       targetScope == GroupMemberScope.admin) {
  //     return false;
  //   }

  //   if (myScope == GroupMemberScope.participant) {
  //     return false;
  //   }

  //   if (myScope == targetScope) {
  //     return false;
  //   }

  //   return true;
  // }
  TextEditingController groupAnnouncementController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    GroupMember ownself = context
        .read<GroupCubit>()
        .state
        .groupMemberList
        .singleWhere((member) =>
            member.userId ==
            (sl<CredentialService>().turmsId ?? "0").parseInt64());
    return Scaffold(
      appBar: AppBar(
        title: Text(
          Strings.groupProfile,
          style: Theme.of(context)
              .textTheme
              .bodyLarge
              ?.copyWith(color: Colors.white),
        ),
        backgroundColor: AppColor.chatSenderBubbleColor,
        centerTitle: true,
        actions: [
          IconButton(
              onPressed: () {
                if (!isOwner()) {
                  ToastUtils.showToast(
                      context: context,
                      msg: Strings.onlyOwnerCanAccess,
                      type: Type.warning);
                  return;
                }

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => GroupPermissionScreen(
                        conversationSettings: widget.conversationSettings!,
                        groupId: widget.group.targetId.toString()),
                  ),
                );
              },
              icon: const Icon(Icons.edit))
        ],
      ),
      backgroundColor: AppColor.greyBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Column(
                  children: [
                    BlocConsumer<GroupCubit, GroupState>(
                      listener: (context, state) {
                        if (state.uploadGroupProfileImageStatus ==
                            UploadGroupProfileImageStatus.success) {
                          ToastUtils.showToast(
                              context: context,
                              msg: Strings.changeProfileImageSuccessfully,
                              type: Type.success);
                        }
                        if (state.uploadGroupProfileImageStatus ==
                            UploadGroupProfileImageStatus.fail) {
                          ToastUtils.showToast(
                              context: context,
                              msg: Strings.unableToChangeProfileImage,
                              type: Type.danger);
                        }
                      },
                      builder: (context, state) {
                        log("group avatar ${state.groupProfileImage}");
                        return ListTile(
                          tileColor: Colors.white,
                          leading: state.uploadGroupProfileImageStatus ==
                                  UploadGroupProfileImageStatus.loading
                              ? const CircularProgressIndicator()
                              : GestureDetector(
                                  onTap: () async {
                                    final image = await _picker.pickImage(
                                        source: ImageSource.gallery);
                                    if (image != null) {
                                      context
                                          .read<GroupCubit>()
                                          .uploadGroupProfileImage(
                                              image, widget.group);
                                    }
                                  },
                                  child: ChatAvatar(
                                      errorWidget: CircleAvatar(
                                        child: Image.file(
                                          io.File(
                                              "${Helper.directory?.path}/${state.groupProfileImage == "" ? widget.group.avatar : state.groupProfileImage}"),
                                          errorBuilder:
                                              (context, error, stackTrace) =>
                                                  Text(state.groupInfo?.name[0]
                                                          .toString() ??
                                                      ""),
                                        ),
                                      ),
                                      isGroup: true,
                                      targetId:
                                          widget.group.targetId.toString(),
                                      radius: 20),
                                ),
                          title: Text(state.groupInfo?.name.toString() ?? ""),
                          subtitle: Text(
                            state.groupInfo?.intro.toString() ?? "",
                          ),
                          trailing: BlocBuilder<GroupCubit, GroupState>(
                            builder: (context, state) {
                              // return (widget
                              //             .conversationSettings
                              //             ?.settings[
                              //                 'GROUP_UPDATE_MEMBER_MODIFY_NAME_STATUS']
                              //             ?.int32Value ==
                              //         0)
                              return (checkPermission(
                                      "GROUP_UPDATE_MEMBER_MODIFY_NAME_STATUS"))
                                  ? IconButton(
                                      icon: const Icon(Icons.edit),
                                      onPressed: () => showDialog(
                                          context: context,
                                          builder: (context) {
                                            if (state.groupInfo != null) {
                                              groupNameController.text =
                                                  state.groupInfo?.name ?? "";
                                              groupDescriptionController.text =
                                                  state.groupInfo?.intro ?? "";
                                              groupAnnouncementController.text =
                                                  state.groupInfo
                                                          ?.announcement ??
                                                      "";
                                            }
                                            return AlertDialog(
                                                title: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          Strings.edit,
                                                          style: Theme.of(
                                                                  context)
                                                              .textTheme
                                                              .bodyLarge
                                                              ?.copyWith(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold),
                                                        ),
                                                        Text(
                                                          Strings.editGroupInfo,
                                                          style:
                                                              Theme.of(context)
                                                                  .textTheme
                                                                  .bodyMedium,
                                                        ),
                                                      ],
                                                    ),
                                                    IconButton(
                                                      icon: const Icon(
                                                          Icons.close),
                                                      onPressed: () =>
                                                          Navigator.pop(
                                                              context),
                                                    )
                                                  ],
                                                ),
                                                content: SingleChildScrollView(
                                                  child: Column(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(
                                                                bottom: 5.0),
                                                        child: Text(
                                                            Strings.groupName),
                                                      ),
                                                      TextField(
                                                        controller:
                                                            groupNameController,
                                                      ),
                                                      const SizedBox(
                                                        height: 20,
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(
                                                                bottom: 5.0),
                                                        child: Text(Strings
                                                            .groupDescription),
                                                      ),
                                                      TextField(
                                                        controller:
                                                            groupDescriptionController,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                actions: [
                                                  SizedBox(
                                                    width: MediaQuery.sizeOf(
                                                                context)
                                                            .width *
                                                        0.8,
                                                    child: FilledButton(
                                                        style: FilledButton
                                                            .styleFrom(
                                                          backgroundColor: AppColor
                                                              .chatSenderBubbleColor,
                                                          shape: RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          8.0)),
                                                        ),
                                                        onPressed: () async {
                                                          context
                                                              .read<
                                                                  GroupCubit>()
                                                              .updateGroupInfo(
                                                                  widget.group
                                                                      .targetId!
                                                                      .parseInt64(),
                                                                  groupNameController
                                                                      .text,
                                                                  groupDescriptionController
                                                                      .text);
                                                          Navigator.pop(
                                                              context);
                                                        },
                                                        child:
                                                            Text(Strings.save)),
                                                  ),
                                                  SizedBox(
                                                    width: MediaQuery.sizeOf(
                                                                context)
                                                            .width *
                                                        0.8,
                                                    child: FilledButton(
                                                        style: FilledButton
                                                            .styleFrom(
                                                          backgroundColor:
                                                              Colors.white,
                                                          shape: RoundedRectangleBorder(
                                                              side: const BorderSide(
                                                                  color: AppColor
                                                                      .greyButtonBorderColor),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          8.0)),
                                                        ),
                                                        onPressed: () {
                                                          Navigator.pop(
                                                              context);
                                                        },
                                                        child: Text(
                                                          Strings.cancel,
                                                          style: Theme.of(
                                                                  context)
                                                              .textTheme
                                                              .bodyMedium
                                                              ?.copyWith(
                                                                  color: Colors
                                                                      .black),
                                                        )),
                                                  ),
                                                ]);
                                          }),
                                    )
                                  : const SizedBox();
                            },
                          ),
                        );
                      },
                    )
                  ],
                ),
              ),
              ListTile(
                title: Text(Strings.groupAnnouncement),
                tileColor: Colors.white,
                subtitle: BlocBuilder<GroupCubit, GroupState>(
                  builder: (context, state) {
                    return Text(state.groupInfo?.announcement.toString() ?? "");
                  },
                ),
                trailing: ownself.role == GroupMemberRole.OWNER
                    ? IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => CustomAlertDialog.showGeneralDialog(
                          context: context,
                          title: Strings.groupAnnouncement,
                          content: TextField(
                            controller: groupAnnouncementController,
                            maxLines: 3,
                          ),
                          onPositiveActionPressed: () {
                            context.read<GroupCubit>().postGroupAnnouncement(
                                  widget.group.targetId!.parseInt64(),
                                  groupAnnouncementController.text,
                                );
                            Navigator.pop(context);
                          },
                        ),
                      )
                    : const SizedBox(),
              ),
              if (isOwner()) const Divider(thickness: 1, height: 8),
              if (isOwner())
                ListTile(
                  leading: BlocBuilder<GroupCubit, GroupState>(
                    builder: (context, state) {
                      return Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                              padding: const EdgeInsets.all(5.0),
                              decoration: BoxDecoration(
                                  color: Colors.blue,
                                  borderRadius: BorderRadius.circular(10.0)),
                              child: const Icon(
                                Icons.person_add_alt_1,
                                color: Colors.white,
                              )),
                          if (state.groupJoinRequestList.isNotEmpty)
                            Positioned(
                                top: -2,
                                right: -4,
                                child: CircleAvatar(
                                    backgroundColor: Colors.red,
                                    radius: 8,
                                    child: Center(
                                      child: Text(
                                          state.groupJoinRequestList.length > 99
                                              ? "99"
                                              : state
                                                  .groupJoinRequestList.length
                                                  .toString(),
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 10)),
                                    ))),
                        ],
                      );
                    },
                  ),
                  tileColor: Colors.white,
                  title: Text(Strings.groupJoinRequest),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => GroupJoinRequestScreen(
                          groupId: widget.group.targetId!,
                        ),
                      ),
                    );
                  },
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      BlocBuilder<GroupCubit, GroupState>(
                        builder: (context, state) {
                          return Text(
                            state.groupJoinRequestList.length.toString(),
                            style: Theme.of(context).textTheme.bodyMedium,
                          );
                        },
                      ),
                      const Icon(
                        Icons.chevron_right,
                        size: 16,
                      ),
                    ],
                  ),
                ),
              const Divider(thickness: 1, height: 8),
              StreamBuilder(
                  stream: sl<DatabaseHelper>().getMediaTotal(widget.group.id,
                      ["IMAGE_TYPE", "VIDEO_TYPE", "FILE_TYPE"]),
                  builder: (context, message) {
                    return ListTile(
                      leading: Container(
                          padding: const EdgeInsets.all(5.0),
                          decoration: BoxDecoration(
                              color: Colors.blue,
                              borderRadius: BorderRadius.circular(10.0)),
                          child: const Icon(
                            Icons.photo,
                            color: Colors.white,
                          )),
                      tileColor: Colors.white,
                      title: Text(Strings.mediaLinkFile),
                      onTap: () => Navigator.pushNamed(
                          context, AppPage.friendMedia.routeName,
                          arguments: widget.group.id),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            message.data?.length.toString() ?? "0",
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const Icon(
                            Icons.chevron_right,
                            size: 16,
                          ),
                        ],
                      ),
                    );
                  }),
              Padding(
                padding: const EdgeInsets.only(top: 1.0, bottom: 8.0),
                child: ListTile(
                  leading: Image.asset("assets/Buttons/pinned-icon.jpg"),
                  tileColor: Colors.white,
                  title: Text(Strings.pinnedMessages),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => PinMessageScreen(
                        conversationId: widget.group.id,
                      ),
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      StreamBuilder(
                        stream: sl<DatabaseHelper>()
                            .getPinnedMessage(widget.group.id),
                        builder: (context, message) {
                          return Text(
                            message.data?.length.toString() ?? "0",
                            style: Theme.of(context).textTheme.bodyMedium,
                          );
                        },
                      ),
                      const Icon(
                        Icons.chevron_right,
                        size: 16,
                      ),
                    ],
                  ),
                ),
              ),
              // BlocBuilder<GroupCubit, GroupState>(
              //   builder: (context, groupState) {
              //     if (groupState.groupJoinRequestList.isNotEmpty) {
              //       return ListView.builder(
              //           itemCount: groupState.groupJoinRequestList.length,
              //           shrinkWrap: true,
              //           itemBuilder: (context, index) {
              //             return ListTile(
              //               tileColor: Colors.white,
              //               leading: const CircleAvatar(
              //                 backgroundColor: Colors.blue,
              //                 child: Icon(Icons.person),
              //               ),
              //               title: Text(
              //                   "${groupState.groupJoinRequestList[index].requesterId}"),
              //               trailing: Row(
              //                 mainAxisSize: MainAxisSize.min,
              //                 children: [
              //                   IconButton(
              //                     icon: const Icon(
              //                       Icons.done,
              //                       color: Colors.green,
              //                     ),
              //                     onPressed: () => context
              //                         .read<GroupCubit>()
              //                         .respondGroupRequest(
              //                             groupState
              //                                 .groupJoinRequestList[index].id
              //                                 .toInt(),
              //                             ResponseAction.ACCEPT,
              //                             widget.group.targetId!.parseInt64()),
              //                   ),
              //                   IconButton(
              //                     icon: const Icon(
              //                       Icons.cancel,
              //                       color: Colors.red,
              //                     ),
              //                     onPressed: () => context
              //                         .read<GroupCubit>()
              //                         .respondGroupRequest(
              //                             groupState
              //                                 .groupJoinRequestList[index].id
              //                                 .toInt(),
              //                             ResponseAction.DECLINE,
              //                             widget.group.targetId!.parseInt64()),
              //                   ),
              //                 ],
              //               ),
              //             );
              //           });
              //     }
              //     return const SizedBox();
              //   },
              // ),

              // const Padding(
              //   padding: EdgeInsets.symmetric(vertical: 3.0),
              //   child: ListTile(
              //     tileColor: Colors.white,
              //     title: Text("Nickname"),
              //     trailing: Icon(Icons.arrow_forward_ios),
              //   ),
              // ),
              // const ListTile(
              //   tileColor: Colors.white,
              //   title: Text("Group"),
              //   trailing: Icon(Icons.arrow_forward_ios),
              // ),
              // const Padding(
              //   padding: EdgeInsets.symmetric(vertical: 8.0),
              //   child: ListTile(
              //     tileColor: Colors.white,
              //     title: Text("Personal Signature"),
              //     trailing: Icon(Icons.arrow_forward_ios),
              //   ),
              // ),
              BlocBuilder<GroupCubit, GroupState>(
                builder: (context, state) {
                  // if (state.getGroupMemberStatus ==
                  //     GetGroupMemberStatus.success) {
                  return Container(
                    color: Colors.white,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Text(
                                  "${state.memberList.length} ${Strings.members}"),
                            ),
                            // if (widget
                            //             .conversationSettings
                            //             ?.settings[
                            //                 'CAN_MEMBERS_ADD_NEW_MEMBER']
                            //             ?.int32Value ==
                            //         0 ||
                            //     ownself.role == GroupMemberRole.OWNER)
                            if (checkPermission("CAN_MEMBERS_ADD_NEW_MEMBER"))
                              TextButton.icon(
                                  onPressed: () {
                                    //log("current role ${group.state?.currentUserMember?.user?.extraData['channel_role']}");
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) => AddGroupScreen(
                                          groupId: widget.group.targetId!,
                                          isAddMember: true,
                                          requiredEntryVerification:
                                              checkPermission(
                                                  "NEED_ENTRY_VERIFICATION",
                                                  customOutputWhenOwnerIdEqualsUserId:
                                                      false),
                                        ),
                                      ),
                                    );
                                  },
                                  label: Text(Strings.addMember)),
                          ],
                        ),
                        BlocBuilder<GroupCubit, GroupState>(
                          builder: (context, state) {
                            // return widget
                            //             .conversationSettings
                            //             ?.settings[
                            //                 'CAN_MEMBERS_LIST_MEMBERS']
                            //             ?.int32Value ==
                            //         0
                            return checkPermission("CAN_MEMBERS_LIST_MEMBERS")
                                ? ListView.builder(
                                    itemCount: state.memberList.length,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemBuilder: (context, index) {
                                      GroupMember member =
                                          state.groupMemberList[index];

                                      bool isAdmin =
                                          member.role == GroupMemberRole.OWNER;
                                      log("lansai ${state.memberList[index]}");
                                      return BlocBuilder<UserCubit, UserState>(
                                        builder: (context, userState) {
                                          return ListTile(
                                            leading: ChatAvatar(
                                                errorWidget: CircleAvatar(
                                                  child: Image.network(
                                                    width: 80,
                                                    height: 80,
                                                    state
                                                        .memberList[index].name,
                                                    errorBuilder: (context,
                                                            error,
                                                            stackTrace) =>
                                                        Text(state.groupInfo
                                                                ?.name[0]
                                                                .toString() ??
                                                            ""),
                                                  ),
                                                ),
                                                targetId: state
                                                    .memberList[index].id
                                                    .toString(),
                                                radius: 20),
                                            title: Text(
                                                state.memberList[index].name),
                                            onTap: () {
                                              if (isAdmin ||
                                                  ownself.role !=
                                                      GroupMemberRole.OWNER) {
                                                return;
                                              }

                                              showModalBottomSheet(
                                                context: context,
                                                builder: (context) {
                                                  return SizedBox(
                                                    width: MediaQuery.sizeOf(
                                                            context)
                                                        .width,
                                                    child: Column(
                                                      mainAxisSize:
                                                          MainAxisSize.max,
                                                      children: [
                                                        ChatAvatar(
                                                            errorWidget:
                                                                CircleAvatar(
                                                              child:
                                                                  Image.network(
                                                                width: 80,
                                                                height: 80,
                                                                state
                                                                    .memberList[
                                                                        index]
                                                                    .name,
                                                                errorBuilder: (context,
                                                                        error,
                                                                        stackTrace) =>
                                                                    Text(state
                                                                            .groupInfo
                                                                            ?.name[0]
                                                                            .toString() ??
                                                                        ""),
                                                              ),
                                                            ),
                                                            targetId: state
                                                                .memberList[
                                                                    index]
                                                                .id
                                                                .toString(),
                                                            radius: 20),
                                                        Text(state
                                                            .memberList[index]
                                                            .name),
                                                        if (!userState.usersList
                                                            .contains(state
                                                                    .memberList[
                                                                index]))
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                        24.0),
                                                            child: SizedBox(
                                                                width: MediaQuery
                                                                        .sizeOf(
                                                                            context)
                                                                    .width,
                                                                child: BlocListener<
                                                                    UserCubit,
                                                                    UserState>(
                                                                  listenWhen: (previous,
                                                                          current) =>
                                                                      previous.createRelationshipStatus !=
                                                                          current
                                                                              .createRelationshipStatus ||
                                                                      previous.sendFriendRequestStatus !=
                                                                          current
                                                                              .sendFriendRequestStatus,
                                                                  listener:
                                                                      (context,
                                                                          userState) {
                                                                    if (userState
                                                                            .userSettings['ADD_I_NEED_VERIFICATION']
                                                                            ?.int32Value ==
                                                                        1) {
                                                                      context
                                                                          .read<
                                                                              UserCubit>()
                                                                          .sendFriendRequest(state
                                                                              .memberList[index]
                                                                              .id);
                                                                    } else {
                                                                      context
                                                                          .read<
                                                                              UserCubit>()
                                                                          .addFriendWithoutRequest(state
                                                                              .memberList[index]
                                                                              .id);
                                                                    }
                                                                    if (userState
                                                                            .createRelationshipStatus ==
                                                                        CreateRelationshipStatus
                                                                            .success) {
                                                                      ToastUtils
                                                                          .showToast(
                                                                        context:
                                                                            context,
                                                                        msg: Strings
                                                                            .friendAddedSuccessfully,
                                                                        type: Type
                                                                            .success,
                                                                      );
                                                                      Navigator.pop(
                                                                          context);
                                                                    }
                                                                    if (userState
                                                                            .sendFriendRequestStatus ==
                                                                        SendFriendRequestStatus
                                                                            .success) {
                                                                      ToastUtils
                                                                          .showToast(
                                                                        context:
                                                                            context,
                                                                        msg: Strings
                                                                            .friendRequestSentSuccessfully,
                                                                        type: Type
                                                                            .success,
                                                                      );
                                                                      Navigator.pop(
                                                                          context);
                                                                    }
                                                                  },
                                                                  child: ElevatedButton(
                                                                      style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16)),
                                                                      onPressed: () {
                                                                        // context
                                                                        //     .read<UserCubit>()
                                                                        //     .sendFriendRequest(widget.userInfo.id);
                                                                        context
                                                                            .read<UserCubit>()
                                                                            .getUserSettings();
                                                                      },
                                                                      child: Text(Strings.addFriend, style: const TextStyle(color: Colors.white, fontSize: 16, fontFamily: "Inter", fontWeight: FontWeight.w400))),
                                                                )),
                                                          ),
                                                        TextButton(
                                                            onPressed: () {
                                                              if (ownself.role ==
                                                                      GroupMemberRole
                                                                          .OWNER &&
                                                                  member !=
                                                                      ownself) {
                                                                showDialog(
                                                                  context:
                                                                      context,
                                                                  builder:
                                                                      (dialogContext) =>
                                                                          AlertDialog(
                                                                    title: Row(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .spaceBetween,
                                                                      children: [
                                                                        Container(
                                                                          padding: const EdgeInsets
                                                                              .all(
                                                                              12),
                                                                          decoration: const BoxDecoration(
                                                                              shape: BoxShape.circle,
                                                                              color: Color.fromRGBO(254, 243, 242, 1)),
                                                                          child:
                                                                              Container(
                                                                            padding:
                                                                                const EdgeInsets.all(12),
                                                                            decoration:
                                                                                const BoxDecoration(shape: BoxShape.circle, color: Color.fromRGBO(254, 228, 226, 1)),
                                                                            child:
                                                                                SvgPicture.asset("assets/Buttons/users-minus.svg"),
                                                                          ),
                                                                        ),
                                                                        IconButton(
                                                                            onPressed: () =>
                                                                                Navigator.pop(context),
                                                                            icon: const Icon(Icons.close))
                                                                      ],
                                                                    ),
                                                                    content:
                                                                        Column(
                                                                      mainAxisSize:
                                                                          MainAxisSize
                                                                              .min,
                                                                      children: [
                                                                        Text(
                                                                          "${Strings.areYouSureYouWantToRemove} ${state.memberList[index].name}",
                                                                          style: Theme.of(context)
                                                                              .textTheme
                                                                              .bodyLarge
                                                                              ?.copyWith(fontWeight: FontWeight.bold),
                                                                        ),
                                                                        Text(Strings
                                                                            .kickMemberDescription)
                                                                      ],
                                                                    ),
                                                                    actions: [
                                                                      if (!((sl<TurmsClient>().userService.userInfo?.userId ==
                                                                              member
                                                                                  .userId) &&
                                                                          isAdmin))
                                                                        BlocListener<
                                                                            GroupCubit,
                                                                            GroupState>(
                                                                          listener:
                                                                              (context, state) {
                                                                            if (state.kickGroupMemberStatus ==
                                                                                KickGroupMemberStatus.success) {
                                                                              ToastUtils.showToast(context: context, msg: Strings.memberKicked);
                                                                            }
                                                                          },
                                                                          child:
                                                                              SizedBox(
                                                                            width:
                                                                                MediaQuery.sizeOf(context).width * 0.8,
                                                                            child: FilledButton(
                                                                                style: FilledButton.styleFrom(
                                                                                  backgroundColor: AppColor.redButton,
                                                                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                                                                                ),
                                                                                onPressed: () async {
                                                                                  await context.read<GroupCubit>().kickGroupMember(groupId: widget.group.targetId!.parseInt64(), userId: {
                                                                                    state.groupMemberList[index].userId
                                                                                  });

                                                                                  Navigator.pop(dialogContext);
                                                                                },
                                                                                child: Text(Strings.kickMember)),
                                                                          ),
                                                                        ),
                                                                      SizedBox(
                                                                        width: MediaQuery.sizeOf(context).width *
                                                                            0.8,
                                                                        child: FilledButton(
                                                                            style: FilledButton.styleFrom(
                                                                              backgroundColor: Colors.white,
                                                                              shape: RoundedRectangleBorder(side: const BorderSide(color: AppColor.greyButtonBorderColor), borderRadius: BorderRadius.circular(8.0)),
                                                                            ),
                                                                            onPressed: () {
                                                                              Navigator.pop(context);
                                                                            },
                                                                            child: Text(
                                                                              Strings.cancel,
                                                                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.black),
                                                                            )),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                );
                                                              } else {
                                                                return;
                                                              }
                                                            },
                                                            child: Text(
                                                              isAdmin
                                                                  ? Strings
                                                                      .admin
                                                                  : ownself.role ==
                                                                          GroupMemberRole
                                                                              .OWNER
                                                                      ? Strings
                                                                          .delete
                                                                      : "",
                                                              style: Theme.of(
                                                                      context)
                                                                  .textTheme
                                                                  .bodyMedium
                                                                  ?.copyWith(
                                                                      color: isAdmin
                                                                          ? AppColor
                                                                              .greyText
                                                                          : AppColor
                                                                              .errorText),
                                                            ))
                                                      ],
                                                    ),
                                                  );
                                                },
                                              );
                                            },
                                            trailing: isAdmin
                                                ? Text(Strings.admin)
                                                : ownself.role !=
                                                        GroupMemberRole.OWNER
                                                    ? const SizedBox()
                                                    : const Icon(Icons
                                                        .arrow_forward_ios),
                                            // Row(
                                            //   mainAxisSize: MainAxisSize.min,
                                            //   children: [
                                            //     Text(isAdmin
                                            //         ? "admin"
                                            //         : ""), // check member is it moderator, if yes then display on the right

                                            //     if (member.userId !=
                                            //         context
                                            //             .read<ProfileCubit>()
                                            //             .state
                                            //             .userProfile
                                            //             ?.turmsUid
                                            //             ?.toInt64())
                                            //       // may have custom role in future but for now ignore first
                                            //       const Icon(Icons.chevron_right)
                                            //   ],
                                            // ),
                                          );
                                        },
                                      );
                                    },
                                    shrinkWrap: true,
                                  )
                                : const SizedBox();
                          },
                        ),
                      ],
                    ),
                  );
                  //}
                },
              ),
              const SizedBox(
                height: 50,
              ),

              BlocListener<GroupCubit, GroupState>(
                listener: (context, state) {
                  if (state.leaveGroupStatus == LeaveGroupStatus.fail) {
                    showDialog(
                      context: context,
                      builder: (dialogContext) => AlertDialog(
                        title: Text(
                          Strings.ownerFailedToLeaveGroupDesc,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        content: FilledButton(
                          onPressed: () => Navigator.pop(dialogContext),
                          child: Text(Strings.ok),
                        ),
                      ),
                    );
                  } else if (state.leaveGroupStatus ==
                      LeaveGroupStatus.success) {
                    context.read<GroupCubit>().reset();
                    Navigator.of(context).popUntil(
                        ModalRoute.withName(AppPage.navBar.routeName));
                  }
                },
                child: FilledButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (dialogContext) => AlertDialog(
                          title: Text(
                            "${Strings.exit} ${widget.group.title}?",
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              TextButton(
                                  onPressed: () {
                                    if (isOwner()) {
                                      context.read<GroupCubit>().disbandGroup(
                                          widget.group.targetId!.parseInt64(),
                                          widget.group.id);
                                    } else {
                                      context.read<GroupCubit>().leaveGroup(
                                          widget.group.targetId!.parseInt64(),
                                          widget.group.id);
                                    }
                                    // context
                                    //     .read<ChatBloc>()
                                    //     .add(GetConversationList());
                                    Navigator.pop(dialogContext);
                                  },
                                  child: Text(isOwner()
                                      ? Strings.disbandGroup
                                      : Strings.leaveGroup))
                            ],
                          ),
                        ),
                      );
                    },
                    child: Text(
                        isOwner() ? Strings.disbandGroup : Strings.leaveGroup)),
              )
            ],
          ),
        ),
      ),
    );
  }
}
