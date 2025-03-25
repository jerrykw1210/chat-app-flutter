import 'package:fixnum/fixnum.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:protech_mobile_chat_stream/constants/string_constant.dart';
import 'package:protech_mobile_chat_stream/module/chat/cubit/group_cubit.dart';
import 'package:protech_mobile_chat_stream/utils/toast_utils.dart';

class GroupManageInactiveUsersScreen extends StatefulWidget {
  const GroupManageInactiveUsersScreen({super.key, required this.groupId});
  final Int64 groupId;
  @override
  State<GroupManageInactiveUsersScreen> createState() =>
      _GroupManageInactiveUsersScreenState();
}

class _GroupManageInactiveUsersScreenState
    extends State<GroupManageInactiveUsersScreen> {
  @override
  void initState() {
    super.initState();
    context.read<GroupCubit>().queryInactiveUsers(widget.groupId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(Strings.inactiveUsers),
        actions: [
          BlocBuilder<GroupCubit, GroupState>(
            builder: (context, state) {
              return PopupMenuButton(
                padding: const EdgeInsets.only(left: 5, right: 16),
                icon: const Icon(Icons.more_vert, color: Colors.white),
                itemBuilder: (context) {
                  return [
                    PopupMenuItem(
                        onTap: () {
                          context.read<GroupCubit>().kickGroupMember(
                              groupId: widget.groupId,
                              userId: state.inactiveUsers
                                  .map((user) => user.id)
                                  .toSet());
                          // context.read<ChatCubit>().resetSelectedUser();
                        },
                        child: Text(Strings.kickAllInactiveUser))
                  ];
                },
              );
            },
          )
        ],
      ),
      body: BlocConsumer<GroupCubit, GroupState>(
        listener: (context, state) {
          if (state.inactiveUsers.isEmpty &&
              state.kickGroupMemberStatus == KickGroupMemberStatus.success) {
            ToastUtils.showToast(
                context: context,
                msg: Strings.memberKicked,
                type: Type.success);
            Navigator.pop(context);
          }
        },
        builder: (context, state) {
          return ListView.builder(
            itemCount: state.inactiveUsers.length,
            itemBuilder: (context, index) => ListTile(
              leading: const CircleAvatar(),
              title: Text(state.inactiveUsers[index].name),
            ),
          );
        },
      ),
    );
  }
}
