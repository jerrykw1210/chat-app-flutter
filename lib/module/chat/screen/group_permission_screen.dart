import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:protech_mobile_chat_stream/constants/string_constant.dart';
import 'package:protech_mobile_chat_stream/module/chat/cubit/group_permission_cubit.dart';
import 'package:protech_mobile_chat_stream/module/conversation/cubit/conversation_cubit.dart';
import 'package:protech_mobile_chat_stream/utils/string_apis.dart';
import 'package:turms_client_dart/turms_client.dart';

class GroupPermissionScreen extends StatefulWidget {
  const GroupPermissionScreen(
      {super.key, required this.groupId, required this.conversationSettings});
  final String groupId;
  final ConversationSettings conversationSettings;

  @override
  State<GroupPermissionScreen> createState() => _GroupPermissionScreenState();
}

class _GroupPermissionScreenState extends State<GroupPermissionScreen> {
  Map<String, Value> settings = {};

  @override
  initState() {
    super.initState();
    settings = widget.conversationSettings.settings;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BlocBuilder<ConversationCubit, ConversationState>(
          builder: (context, conversationstate) {
            return IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                context.read<GroupPermissionCubit>().updateConversationSettings(
                    widget.groupId.parseInt64(), widget.conversationSettings);
                Navigator.pop(context);
              },
            );
          },
        ),
      ),
      body: BlocBuilder<ConversationCubit, ConversationState>(
        builder: (context, conversationState) {
          return SingleChildScrollView(
            child: Column(
              children: [
                ListTile(
                  title: Text(Strings.groupEntryVerification),
                  subtitle: Text(Strings.groupEntryDescription),
                  trailing: CupertinoSwitch(
                      value:
                          settings['NEED_ENTRY_VERIFICATION']?.int32Value == 1
                              ? true
                              : false,
                      onChanged: (value) {
                        setState(() {
                          settings['NEED_ENTRY_VERIFICATION']?.int32Value =
                              value ? 1 : 0;
                        });
                      }),
                ),
                BlocBuilder<GroupPermissionCubit, GroupPermissionState>(
                  builder: (context, state) {
                    return ListTile(
                      title: Text(Strings.screenshot),
                      trailing: CupertinoSwitch(
                          value: settings['CAN_SCREEN_CAPTURE']?.int32Value == 1
                              ? true
                              : false,
                          onChanged: (value) {
                            setState(() {
                              context
                                  .read<GroupPermissionCubit>()
                                  .toggleScreenshot();
                              settings['CAN_SCREEN_CAPTURE']?.int32Value =
                                  value ? 1 : 0;
                            });
                          }),
                    );
                  },
                ),
                // ListTile(
                //   title: const Text("隐藏信息"),
                //   subtitle: const Text("启用后，普通用户将看不见被禁言，移除及有其他用户退群的信息提示"),
                //   trailing: CupertinoSwitch(value: true, onChanged: (value) {}),
                // ),
                ListTile(
                  title: Text(Strings.muteMember),
                  trailing: CupertinoSwitch(
                      value: settings['CAN_MEMBERS_BE_MUTE']?.int32Value == 1
                          ? true
                          : false,
                      onChanged: (value) {
                        setState(() {
                          settings['CAN_MEMBERS_BE_MUTE']?.int32Value =
                              value ? 1 : 0;
                        });
                      }),
                ),
                ListTile(
                  title: Text(Strings.memberInvisible),
                  trailing: CupertinoSwitch(
                      value: settings['IS_MEMBERS_INVISIBLE']?.int32Value == 1
                          ? true
                          : false,
                      onChanged: (value) {
                        setState(() {
                          settings['IS_MEMBERS_INVISIBLE']?.int32Value =
                              value ? 1 : 0;
                        });
                      }),
                ),
                ListTile(
                  title: Text(Strings.memberCanViewPastHistory),
                  trailing: CupertinoSwitch(
                      value: settings['CAN_MEMBERS_LIST_MESSAGE_HISTORY']
                                  ?.int32Value ==
                              1
                          ? true
                          : false,
                      onChanged: (value) {
                        setState(() {
                          settings['CAN_MEMBERS_LIST_MESSAGE_HISTORY']
                              ?.int32Value = value ? 1 : 0;
                        });
                      }),
                ),
                ListTile(
                    title: Text(Strings.memberCanSendNamecard),
                    trailing: CupertinoSwitch(
                        value:
                            settings['CAN_MEMBERS_SEND_CONTACT']?.int32Value ==
                                    1
                                ? true
                                : false,
                        onChanged: (value) {
                          setState(() {
                            settings['CAN_MEMBERS_SEND_CONTACT']?.int32Value =
                                value ? 1 : 0;
                          });
                        })),
                ListTile(
                  title: Text(Strings.memberCanSendPictures),
                  trailing: CupertinoSwitch(
                      value:
                          settings['CAN_MEMBERS_SEND_PICTURES']?.int32Value == 1
                              ? true
                              : false,
                      onChanged: (value) {
                        log("群成员禁发图片 ${settings['CAN_MEMBERS_SEND_PICTURES']?.int32Value}");
                        setState(() {
                          settings['CAN_MEMBERS_SEND_PICTURES']?.int32Value =
                              value ? 1 : 0;
                        });
                      }),
                ),
                ListTile(
                  title: Text(Strings.memberCanSendVideos),
                  trailing: CupertinoSwitch(
                      value:
                          settings['CAN_MEMBERS_SEND_VIDEOS']?.int32Value == 1
                              ? true
                              : false,
                      onChanged: (value) {
                        setState(() {
                          settings['CAN_MEMBERS_SEND_VIDEOS']?.int32Value =
                              value ? 1 : 0;
                        });
                      }),
                ),
                ListTile(
                  title: Text(Strings.memberCanSendFiles),
                  trailing: CupertinoSwitch(
                      value: settings['CAN_MEMBERS_SEND_FILES']?.int32Value == 1
                          ? true
                          : false,
                      onChanged: (value) {
                        setState(() {
                          settings['CAN_MEMBERS_SEND_FILES']?.int32Value =
                              value ? 1 : 0;
                        });
                      }),
                ),
                ListTile(
                  title: Text(Strings.memberCanSeeMemberList),
                  trailing: CupertinoSwitch(
                      value:
                          settings['CAN_MEMBERS_LIST_MEMBERS']?.int32Value == 1
                              ? true
                              : false,
                      onChanged: (value) {
                        setState(() {
                          settings['CAN_MEMBERS_LIST_MEMBERS']?.int32Value =
                              value ? 1 : 0;
                        });
                      }),
                ),
                // ListTile(
                //   title: const Text("群成员不可修改昵称"),
                //   trailing: CupertinoSwitch(
                //       value: widget
                //                   .conversationSettings
                //                   .settings[
                //                       'GROUP_UPDATE_MEMBER_MODIFY_NAME_STATUS']
                //                   ?.int32Value ==
                //               1
                //           ? true
                //           : false,
                //       onChanged: (value) {
                //         setState(() {
                //           widget
                //               .conversationSettings
                //               .settings[
                //                   'GROUP_UPDATE_MEMBER_MODIFY_NAME_STATUS']
                //               ?.int32Value = value ? 1 : 0;
                //         });
                //       }),
                // ),
                ListTile(
                  title: Text(Strings.memberCanAddNewMember),
                  trailing: CupertinoSwitch(
                      value:
                          settings['CAN_MEMBERS_ADD_NEW_MEMBER']?.int32Value ==
                                  1
                              ? true
                              : false,
                      onChanged: (value) {
                        setState(() {
                          settings['CAN_MEMBERS_ADD_NEW_MEMBER']?.int32Value =
                              value ? 1 : 0;
                        });
                      }),
                ),
                // ListTile(
                //   title: const Text("退群提醒管理"),
                //   trailing: CupertinoSwitch(
                //       value: widget
                //                   .conversationSettings
                //                   .settings['GROUP_UPDATE_MANAGEMENT_REMINDER']
                //                   ?.int32Value ==
                //               1
                //           ? true
                //           : false,
                //       onChanged: (value) {
                //         setState(() {
                //           widget
                //               .conversationSettings
                //               .settings['GROUP_UPDATE_MANAGEMENT_REMINDER']
                //               ?.int32Value = value ? 1 : 0;
                //         });
                //       }),
                // ),
                // const ListTile(
                //   title: Text("聊天记录"),
                //   trailing: Icon(Icons.chevron_right),
                // ),
                // const ListTile(
                //   title: Text("特殊发言"),
                //   trailing: Icon(Icons.chevron_right),
                // ),
                // const ListTile(
                //   title: Text("特殊限制"),
                //   trailing: Icon(Icons.chevron_right),
                // ),
                // ListTile(
                //   title: Text(Strings.manageInactiveUsers),
                //   onTap: () => Navigator.of(context).push(MaterialPageRoute(
                //     builder: (context) => GroupManageInactiveUsersScreen(
                //         groupId: widget.groupId.parseInt64()),
                //   )),
                //   trailing: const Icon(Icons.chevron_right),
                // ),
                // const ListTile(
                //   title: Text("聊天敏感词"),
                //   trailing: Icon(Icons.chevron_right),
                // ),
                // const ListTile(
                //   title: Text("管理日志"),
                //   trailing: Icon(Icons.chevron_right),
                // ),
                // const ListTile(
                //   title: Text("群主管理权转让"),
                //   trailing: Icon(Icons.chevron_right),
                // ),
                //TextButton(onPressed: () {}, child: const Text("解散群组")),
                //const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }
}
