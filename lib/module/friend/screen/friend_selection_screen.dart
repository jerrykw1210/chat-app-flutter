import 'dart:developer';

import 'package:fixnum/fixnum.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:protech_mobile_chat_stream/constants/string_constant.dart';
import 'package:protech_mobile_chat_stream/model/database.dart' as db;
import 'package:protech_mobile_chat_stream/module/chat/cubit/chat_cubit.dart';
import 'package:protech_mobile_chat_stream/module/chat/cubit/group_cubit.dart';
import 'package:protech_mobile_chat_stream/module/friend/cubit/user_cubit.dart';
import 'package:protech_mobile_chat_stream/route/routes.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:protech_mobile_chat_stream/utils/colors.dart';
import 'package:turms_client_dart/turms_client.dart' as turms;

class FriendSelectionScreen extends StatefulWidget {
  const FriendSelectionScreen({super.key});

  @override
  State<FriendSelectionScreen> createState() => _FriendSelectionScreenState();
}

class _FriendSelectionScreenState extends State<FriendSelectionScreen> {
  bool isSpecialCharacter(String text) {
    return RegExp(r'[!@#$%^&*()_+{}\[\]:;<>,.?~]').hasMatch(text);
  }

  @override
  void initState() {
    super.initState();
    context.read<UserCubit>().fetchUsers();
    context.read<GroupCubit>().fetchGroup();
  }

  @override
  Widget build(BuildContext context) {
    List<db.Message> selectedMessages =
        ModalRoute.of(context)!.settings.arguments as List<db.Message>;

    return Scaffold(
      appBar: AppBar(
        // backgroundColor: Colors.blue,
        centerTitle: true,
        title: Column(
          children: [
            Text(
              Strings.selectFriends,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            BlocBuilder<ChatCubit, ChatState>(
              builder: (context, state) {
                return Text(
                  "${Strings.selected}: ${state.selectedUsers.length}",
                  style: Theme.of(context).textTheme.bodySmall,
                );
              },
            ),
          ],
        ),
        actions: [IconButton(onPressed: () {}, icon: const Icon(Icons.search))],
      ),
      body: BlocBuilder<ChatCubit, ChatState>(
        builder: (context, state) {
          return CustomScrollView(
            slivers: [
              if (state.selectedUsers.isNotEmpty)
                SliverPersistentHeader(
                    pinned: true, delegate: SelectedUserListDelegate()),
              SliverToBoxAdapter(
                child: BlocBuilder<UserCubit, UserState>(
                  builder: (context, userstate) {
                    return Column(
                      children: [
                        ExpansionTile(
                          title: Text(Strings.friends),
                          children: [
                            GroupedListView(
                              elements: userstate.usersList,
                              groupBy: (turms.UserInfo user) {
                                if (isSpecialCharacter(
                                    user.name.toString()[0])) {
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
                              itemBuilder: (context, turms.UserInfo user) {
                                return InkWell(
                                  onTap: () {
                                    context.read<ChatCubit>().selectUser(user);
                                    // BlocProvider.of<ChatBloc>(context)
                                    //     .add(SelectUser(user));
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: ListTile(
                                      // leading: Image.network(
                                      //   user.image.toString(),
                                      //   errorBuilder: (context, error,
                                      //           stackTrace) =>
                                      //       Image.asset(
                                      //           "assets/default-img/default-user.png"),
                                      // ),
                                      title: Text(user.name.toString()),
                                    ),
                                  ),
                                );
                              },
                            )
                          ],
                        ),
                        ExpansionTile(
                          title: Text(Strings.groups),
                          children: [
                            BlocBuilder<GroupCubit, GroupState>(
                              builder: (context, groupstate) {
                                return GroupedListView(
                                  elements: groupstate.groupList,
                                  groupBy: (turms.Group group) {
                                    if (isSpecialCharacter(group.name[0])) {
                                      return "#";
                                    }
                                    return group.name[0];
                                  },
                                  shrinkWrap: true,
                                  groupComparator: (value1, value2) {
                                    if (isSpecialCharacter(value1.toString()) &&
                                        !isSpecialCharacter(
                                            value2.toString())) {
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
                                  itemBuilder: (context, turms.Group group) {
                                    return InkWell(
                                      onTap: () {
                                        context
                                            .read<ChatCubit>()
                                            .selectUser(group);
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: ListTile(
                                          // leading:
                                          //     Image.network(group.toString()),
                                          title: Text(group.name),
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                            )
                          ],
                        ),
                      ],
                    );
                  },
                ),
              )
            ],
          );
        },
      ),
      floatingActionButton: BlocConsumer<ChatCubit, ChatState>(
        listener: (context, state) {
          if (state.forwardMessageStatus == ForwardMessageStatus.success) {
            context.read<UserCubit>().resetAllUserStatus();
            context.read<ChatCubit>().resetSelectedUser();
            Navigator.of(context)
                .popUntil(ModalRoute.withName(AppPage.navBar.routeName));
            // Navigator.pushNamedAndRemoveUntil(
            //     context,
            //     AppPage.navBar.routeName,
            //     arguments: 0,
            //     (route) => false);
          } else if (state.forwardMessageStatus ==
              ForwardMessageStatus.failed) {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                content: Text(state.forwardError),
              ),
            );
          }
        },
        builder: (context, state) {
          if (state.selectedUsers.isNotEmpty) {
            return Stack(children: [
              FloatingActionButton(
                onPressed: () {
                  log("selected users issss ${state.selectedUsers}");
                  for (var selectedUser in state.selectedUsers) {
                    if (selectedUser is turms.UserInfo) {
                      context
                          .read<ChatCubit>()
                          .forwardMessage([selectedUser.id], selectedMessages);
                    } else if (selectedUser is turms.Group) {
                      context.read<ChatCubit>().forwardMessage(
                          [selectedUser.id], selectedMessages,
                          isGroupMessage: true);
                    }
                    log("selected u ${selectedUser.runtimeType}");
                  }
                  // List<Int64> selectedUserIds = state.selectedUsers
                  //     .map((user) => user.id)
                  //     .toList()
                  //     .cast<Int64>();

                  // context
                  //     .read<ChatCubit>()
                  //     .forwardMessage(selectedUserIds, selectedMessages);

                  // BlocProvider.of<ChatBloc>(context).add(
                  //     ForwardMessage(state.selectedUsers, selectedMessages));
                },
                shape: const CircleBorder(),
                child: const Icon(Icons.send),
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
