import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:protech_mobile_chat_stream/constants/string_constant.dart';
import 'package:protech_mobile_chat_stream/module/chat/cubit/group_cubit.dart';
import 'package:protech_mobile_chat_stream/utils/string_apis.dart';
import 'package:turms_client_dart/turms_client.dart';

class GroupJoinRequestScreen extends StatefulWidget {
  const GroupJoinRequestScreen({super.key, required this.groupId});
  final String groupId;

  @override
  State<GroupJoinRequestScreen> createState() => _GroupJoinRequestScreenState();
}

class _GroupJoinRequestScreenState extends State<GroupJoinRequestScreen> {
  int activePageIndex = 0;

  @override
  initState() {
    super.initState();
    context
        .read<GroupCubit>()
        .queryJoinGroupRequest(widget.groupId.parseInt64());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(Strings.groupJoinRequest),
      ),
      body: BlocBuilder<GroupCubit, GroupState>(
        builder: (context, state) {
          if (state.groupJoinRequestList.isNotEmpty) {
            return ListView.builder(
              itemCount: state.groupJoinRequestList.length,
              itemBuilder: (context, index) {
                String? userName;
                GroupJoinRequest? groupJoinRequest;

                if (state.groupJoinRequestList[index].containsKey("userInfo") &&
                    state.groupJoinRequestList[index]
                        .containsKey("groupJoinRequest")) {
                  if (state.groupJoinRequestList[index]["userInfo"] != null &&
                      state.groupJoinRequestList[index]["groupJoinRequest"] !=
                          null) {
                    if (state.groupJoinRequestList[index]["userInfo"]
                        is UserInfo) {
                      userName = (state.groupJoinRequestList[index]["userInfo"]
                              as UserInfo)
                          .name;
                    }

                    if (state.groupJoinRequestList[index]["groupJoinRequest"]
                        is GroupJoinRequest) {
                      groupJoinRequest = (state.groupJoinRequestList[index]
                          ["groupJoinRequest"] as GroupJoinRequest);
                    }
                  }
                }

                return ListTile(
                  tileColor: Colors.white,
                  leading: const CircleAvatar(
                    backgroundColor: Colors.blue,
                    child: Icon(Icons.person),
                  ),
                  title: Text(userName ?? "${groupJoinRequest?.targetId}",
                      style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black,
                          fontWeight: FontWeight.w500)),
                  subtitle: Text("${groupJoinRequest?.targetId}",
                      style: const TextStyle(
                          fontSize: 14,
                          color: Color.fromRGBO(71, 84, 103, 1),
                          fontWeight: FontWeight.w400)),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.done,
                          color: Colors.green,
                        ),
                        onPressed: () {
                          if (groupJoinRequest == null) return;
                          context.read<GroupCubit>().respondGroupRequest(
                              groupJoinRequest.id.toInt(),
                              ResponseAction.ACCEPT,
                              widget.groupId.parseInt64());
                        },
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.cancel,
                          color: Colors.red,
                        ),
                        onPressed: () {
                          if (groupJoinRequest == null) return;
                          context.read<GroupCubit>().respondGroupRequest(
                              groupJoinRequest.id.toInt(),
                              ResponseAction.DECLINE,
                              widget.groupId.parseInt64());
                        },
                      ),
                    ],
                  ),
                );
              },
            );
          }

          return Center(child: Text(Strings.noGroupJoinRequestYet));
        },
      ),
    );
  }
}
