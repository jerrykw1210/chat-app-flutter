import 'package:fixnum/fixnum.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:protech_mobile_chat_stream/constants/string_constant.dart';
import 'package:protech_mobile_chat_stream/module/chat/cubit/chat_cubit.dart';
import 'package:protech_mobile_chat_stream/module/chat/cubit/group_cubit.dart';
import 'package:protech_mobile_chat_stream/module/conversation/cubit/conversation_cubit.dart';
import 'package:protech_mobile_chat_stream/module/friend/cubit/user_cubit.dart';
import 'package:protech_mobile_chat_stream/route/routes.dart';
import 'package:protech_mobile_chat_stream/utils/colors.dart';
import 'package:protech_mobile_chat_stream/utils/service_locator.dart';
import 'package:protech_mobile_chat_stream/utils/string_apis.dart';
import 'package:turms_client_dart/turms_client.dart';

class AddGroupScreen extends StatefulWidget {
  AddGroupScreen(
      {super.key,
      this.groupId = "",
      this.isAddMember = false,
      this.requiredEntryVerification = false});
  String groupId;
  bool isAddMember;
  bool requiredEntryVerification;
  @override
  State<AddGroupScreen> createState() => _AddGroupScreenState();
}

class _AddGroupScreenState extends State<AddGroupScreen> {
  final TextEditingController _groupNameController = TextEditingController();
  final TextEditingController _groupDescriptionController =
      TextEditingController();

  bool isSpecialCharacter(String text) {
    return RegExp(r'[!@#$%^&*()_+{}\[\]:;<>,.?~]').hasMatch(text);
  }

  @override
  void dispose() {
    super.dispose();
    _groupNameController.dispose();
  }

  @override
  initState() {
    context.read<UserCubit>().fetchUsers();
    super.initState();
  }

  void _showEnterGroupNameDialog(
    BuildContext context,
  ) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return AlertDialog(
            title: Text(Strings.enterGroupName,
                style: const TextStyle(fontSize: 20)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _groupNameController,
                  decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      labelText: Strings.groupName,
                      counterText: ""),
                  maxLength: 50,
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _groupDescriptionController,
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    labelText: Strings.groupDescription,
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: MediaQuery.sizeOf(context).width * 0.8,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10))),
                    onPressed: () {
                      String groupName = _groupNameController.text;
                      String groupDescription =
                          _groupDescriptionController.text;

                      if (groupName.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text(Strings.groupNameCannotBeEmpty)));
                        return;
                      }
                      context.read<GroupCubit>().createGroup(
                          groupName,
                          context
                              .read<ChatCubit>()
                              .state
                              .selectedUsers
                              .cast<UserInfo>(),
                          description: groupDescription);
                      Navigator.of(context).pop();
                    },
                    child: Text(Strings.createGroup),
                  ),
                ),
                const SizedBox(height: 10),
                Center(
                    child: TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text(Strings.cancel)))
              ],
            ));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return LoaderOverlay(
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          automaticallyImplyLeading: false,
          leading: IconButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.read<UserCubit>().resetAllUserStatus();
              },
              icon: const Icon(Icons.arrow_back_ios, color: Colors.white)),
          title: Column(
            children: [
              Text(
                Strings.selectGroupMembers,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium!
                    .copyWith(color: Colors.white),
              ),
              BlocBuilder<ChatCubit, ChatState>(
                builder: (context, state) {
                  return Text(
                    "${Strings.selected}: ${state.selectedUsers.length}",
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall!
                        .copyWith(color: Colors.white),
                  );
                },
              ),
            ],
          ),
          actions: [
            IconButton(
                onPressed: () {},
                icon: const Icon(Icons.search, color: Colors.white))
          ],
        ),
        body: BlocBuilder<ChatCubit, ChatState>(
          builder: (context, state) {
            return CustomScrollView(
              slivers: [
                if (state.selectedUsers.isNotEmpty)
                  SliverPersistentHeader(
                      pinned: true, delegate: SelectedUserListDelegate()),
                SliverToBoxAdapter(
                  child: BlocBuilder<ChatCubit, ChatState>(
                    builder: (context, chatstate) {
                      return BlocBuilder<UserCubit, UserState>(
                        builder: (context, userstate) {
                          List<UserInfo> userList = userstate.usersList;
                          List<UserInfo> notJoinedUser = [];

                          notJoinedUser = userList.where((user) {
                            if (widget.isAddMember) {
                              final groupMemberIds = context
                                  .read<GroupCubit>()
                                  .state
                                  .groupMemberList
                                  .map((member) => member.userId)
                                  .toList();
                              return !groupMemberIds.contains(user.id);
                            }
                            return true;
                          }).toList();

                          return GroupedListView(
                            elements: notJoinedUser,
                            groupBy: (UserInfo user) {
                              if (isSpecialCharacter(user.name.toString()[0])) {
                                return "#";
                              }
                              return user.name.toString()[0];
                            },
                            shrinkWrap: true,
                            groupComparator: (value1, value2) {
                              if (isSpecialCharacter(value1.toString()) &&
                                  !isSpecialCharacter(value2.toString())) {
                                return 1;
                              } else {
                                return value1
                                    .toString()
                                    .compareTo(value2.toString());
                              }
                            },
                            groupSeparatorBuilder: (value) {
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 30),
                                decoration: const BoxDecoration(
                                    color: AppColor.greyBackgroundColor),
                                child: Text(value),
                              );
                            },
                            itemBuilder: (context, UserInfo user) {
                              bool selected = false;

                              if (chatstate.selectedUsers.isNotEmpty) {
                                if (chatstate.selectedUsers.contains(user)) {
                                  selected = true;
                                }
                              }

                              return InkWell(
                                onTap: () {
                                  context.read<ChatCubit>().selectUser(user);
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: ListTile(
                                    selected: selected,
                                    selectedTileColor:
                                        Theme.of(context).highlightColor,
                                    leading: CircleAvatar(
                                      child: Image.network(
                                          user.name.toString()[0],
                                          errorBuilder: (context, error,
                                                  stackTrace) =>
                                              Text(user.name.toString()[0])),
                                    ),
                                    title: Text(user.name.toString()),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
                )
              ],
            );
          },
        ),
        floatingActionButton: BlocListener<GroupCubit, GroupState>(
          listener: (context, groupState) {
            if (groupState.addGroupMemberStatus ==
                AddGroupMemberStatus.success) {
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text(Strings.memberAdded)));

              //context.read<ConversationCubit>().getConversations();
              //context.read<GroupCubit>().reset();
              context.read<ChatCubit>().resetSelectedUser();
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            }
            if (groupState.joinGroupStatus == JoinGroupStatus.success) {
              ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(Strings.joinRequestSent)));

              //context.read<ConversationCubit>().getConversations();
              //context.read<GroupCubit>().reset();
              context.read<ChatCubit>().resetSelectedUser();
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            }
          },
          child: BlocListener<GroupCubit, GroupState>(
            listener: (context, state) {
              state.createGroupStatus == CreateGroupStatus.loading
                  ? context.loaderOverlay.show()
                  : context.loaderOverlay.hide();

              if (state.createGroupStatus == CreateGroupStatus.fail) {
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(Strings.failToCreateGroup)));
                return;
              }

              if (state.createGroupStatus == CreateGroupStatus.success) {
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(Strings.chatCreatedSuccessful)));

                //context.read<ConversationCubit>().getConversations();
                context.read<GroupCubit>().reset();
                context.read<ChatCubit>().resetSelectedUser();
                Navigator.of(context).popUntil(ModalRoute.withName(
                  AppPage.navBar.routeName,
                ));
              }
            },
            child: BlocBuilder<ChatCubit, ChatState>(
              builder: (context, state) {
                if (state.selectedUsers.isNotEmpty) {
                  return Stack(children: [
                    BlocBuilder<ConversationCubit, ConversationState>(
                      builder: (context, conversationState) =>
                          FloatingActionButton(
                        onPressed: () {
                          if (conversationState.createConversationStatus ==
                              CreateConversationStatus.loading) {
                            return;
                          }
                          if (widget.isAddMember) {
                            if (widget.requiredEntryVerification) {
                              for (UserInfo user in state.selectedUsers) {
                                context.read<GroupCubit>().joinGroupRequest(
                                    widget.groupId.parseInt64(),
                                    user.id.toString());
                              }
                              return;
                            } else {
                              context.read<GroupCubit>().addGroupMember(
                                  groupId: widget.groupId.parseInt64(),
                                  userList:
                                      state.selectedUsers.cast<UserInfo>());
                              return;
                            }
                          } else {
                            List<Int64> selectedUserIds = state.selectedUsers
                                .map((user) => user.id)
                                .toList()
                                .cast<Int64>();
                            selectedUserIds.add(sl<TurmsClient>()
                                    .userService
                                    .userInfo
                                    ?.userId ??
                                Int64(0));
                            _showEnterGroupNameDialog(
                              context,
                            );
                          }
                        },
                        shape: const CircleBorder(),
                        child: const Icon(Icons.add),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(5.0),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Text(state.selectedUsers.length.toString()),
                      ),
                    )
                  ]);
                } else {
                  return const SizedBox();
                }
              },
            ),
          ),
        ),
      ),
    );
  }
}

class SelectedUserListDelegate extends SliverPersistentHeaderDelegate {
  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return BlocBuilder<ChatCubit, ChatState>(
      builder: (context, state) {
        if (state.selectedUsers.isNotEmpty) {
          return Container(
            alignment: Alignment.centerLeft,
            width: double.infinity,
            height: 80,
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            decoration: const BoxDecoration(
                color: Colors.white,
                border:
                    Border(bottom: BorderSide(color: AppColor.dividerColor))),
            child: ListView.separated(
              shrinkWrap: true,
              scrollDirection: Axis.horizontal,
              separatorBuilder: (context, index) => const SizedBox(
                width: 10,
              ),
              itemCount: state.selectedUsers.length,
              itemBuilder: (context, index) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Stack(
                      children: [
                        CircleAvatar(
                          child: Image.asset(
                              "assets/default-img/default-user.png"),
                        ),
                        const Positioned(
                            top: 10, left: 0, child: Icon(Icons.close))
                      ],
                    ),
                    Text(state.selectedUsers[index].name)
                  ],
                );
              },
            ),
          );
        } else {
          return const SizedBox();
        }
      },
    );
  }

  @override
  double get maxExtent => 80;

  @override
  double get minExtent => 80;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) {
    return false;
  }
}
