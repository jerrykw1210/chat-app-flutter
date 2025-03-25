import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:protech_mobile_chat_stream/constants/string_constant.dart';
import 'package:protech_mobile_chat_stream/module/friend/cubit/user_cubit.dart';
import 'package:turms_client_dart/turms_client.dart';

class FriendRequestScreen extends StatefulWidget {
  const FriendRequestScreen({super.key});

  @override
  State<FriendRequestScreen> createState() => _FriendRequestScreenState();
}

class _FriendRequestScreenState extends State<FriendRequestScreen> {
  final PageController _pageController = PageController();
  int activePageIndex = 0;

  @override
  initState() {
    super.initState();
    context.read<UserCubit>().getFriendRequest();
    context.read<UserCubit>().getSentFriendRequest();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: Text(Strings.friendRequest),
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 32, left: 16, right: 16),
        child: Column(
          children: [
            _menuBar(context),
            const SizedBox(height: 30),
            Expanded(
              flex: 2,
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (int i) {
                  FocusScope.of(context).requestFocus(FocusNode());
                  setState(() {
                    activePageIndex = i;
                  });
                },
                children: [
                  friendRequestList(context),
                  sentFriendRequestList(context)
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget friendRequestList(BuildContext context) {
    return BlocBuilder<UserCubit, UserState>(
      builder: (context, state) {
        if (state.friendRequests.isNotEmpty) {
          return ListView.builder(
              itemCount: state.friendRequests.length,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                String? userName;
                UserFriendRequest? userFriendRequest;

                if (state.friendRequests[index].containsKey("userInfo") &&
                    state.friendRequests[index]
                        .containsKey("userFriendRequest")) {
                  if (state.friendRequests[index]["userInfo"] != null &&
                      state.friendRequests[index]["userFriendRequest"] !=
                          null) {
                    if (state.friendRequests[index]["userInfo"] is UserInfo) {
                      userName =
                          (state.friendRequests[index]["userInfo"] as UserInfo)
                              .name;
                    }

                    if (state.friendRequests[index]["userFriendRequest"]
                        is UserFriendRequest) {
                      userFriendRequest = (state.friendRequests[index]
                          ["userFriendRequest"] as UserFriendRequest);
                    }
                  }
                }

                return ListTile(
                  tileColor: Colors.white,
                  leading: const CircleAvatar(
                    backgroundColor: Colors.blue,
                    child: Icon(Icons.person),
                  ),
                  title: Text(userName ?? "${userFriendRequest?.requesterId}",
                      style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black,
                          fontWeight: FontWeight.w500)),
                  subtitle: Text("${userFriendRequest?.requesterId}",
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
                          if (userFriendRequest == null) return;
                          context.read<UserCubit>().respondFriendRequest(
                              userFriendRequest.id.toInt(),
                              ResponseAction.ACCEPT);
                        },
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.cancel,
                          color: Colors.red,
                        ),
                        onPressed: () {
                          if (userFriendRequest == null) return;
                          context.read<UserCubit>().respondFriendRequest(
                              userFriendRequest.id.toInt(),
                              ResponseAction.DECLINE);
                        },
                      ),
                    ],
                  ),
                );
              });
        }

        return Center(child: Text(Strings.noFriendRequestYet));
      },
    );
  }

  Widget sentFriendRequestList(BuildContext context) {
    return BlocBuilder<UserCubit, UserState>(
      builder: (context, state) {
        if (state.sentFriendRequests.isNotEmpty) {
          return ListView.builder(
              itemCount: state.sentFriendRequests.length,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                String? userName;
                UserFriendRequest? userFriendRequest;

                if (state.sentFriendRequests[index].containsKey("userInfo") &&
                    state.sentFriendRequests[index]
                        .containsKey("userFriendRequest")) {
                  if (state.sentFriendRequests[index]["userInfo"] != null &&
                      state.sentFriendRequests[index]["userFriendRequest"] !=
                          null) {
                    if (state.sentFriendRequests[index]["userInfo"]
                        is UserInfo) {
                      userName = (state.sentFriendRequests[index]["userInfo"]
                              as UserInfo)
                          .name;
                    }

                    if (state.sentFriendRequests[index]["userFriendRequest"]
                        is UserFriendRequest) {
                      userFriendRequest = (state.sentFriendRequests[index]
                          ["userFriendRequest"] as UserFriendRequest);
                    }
                  }
                }

                return ListTile(
                  tileColor: Colors.white,
                  leading: const CircleAvatar(
                    backgroundColor: Colors.blue,
                    child: Icon(Icons.person),
                  ),
                  title: Text(userName ?? "${userFriendRequest?.requesterId}",
                      style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black,
                          fontWeight: FontWeight.w500)),
                  subtitle: Text("${userFriendRequest?.recipientId}",
                      style: const TextStyle(
                          fontSize: 14,
                          color: Color.fromRGBO(71, 84, 103, 1),
                          fontWeight: FontWeight.w400)),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 14),
                    decoration: BoxDecoration(
                      color: const Color.fromRGBO(233, 234, 235, 1),
                      border: Border.all(
                          color: const Color.fromRGBO(208, 213, 221, 1),
                          width: 0.5),
                      borderRadius: const BorderRadius.all(Radius.circular(8)),
                    ),
                    child: Text(
                      Strings.pendingFriendRequest,
                      style: const TextStyle(
                          color: Color.fromRGBO(164, 167, 174, 1),
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                );
              });
        }

        return Center(child: Text(Strings.noSentFriendRequestYet));
      },
    );
  }

  Widget _menuBar(BuildContext context) {
    const double borderRadius = 8.0;

    return Container(
      width: MediaQuery.of(context).size.width,
      height: 52.0,
      decoration: const BoxDecoration(
        color: Color.fromRGBO(249, 250, 251, 1),
        border: Border.fromBorderSide(
            BorderSide(color: Color.fromRGBO(228, 231, 236, 1))),
        borderRadius: BorderRadius.all(Radius.circular(borderRadius)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Expanded(
            child: InkWell(
              borderRadius:
                  const BorderRadius.all(Radius.circular(borderRadius)),
              onTap: _onSwitchFriendRequest,
              child: Container(
                width: MediaQuery.of(context).size.width,
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                alignment: Alignment.center,
                decoration: (activePageIndex == 0)
                    ? const BoxDecoration(
                        color: Colors.white,
                        border: Border(
                            top: BorderSide(
                                width: 0.5,
                                color: Color.fromRGBO(208, 213, 221, 1)),
                            right: BorderSide(
                                width: 1,
                                color: Color.fromRGBO(208, 213, 221, 1)),
                            left: BorderSide(
                                width: 0.5,
                                color: Color.fromRGBO(208, 213, 221, 1)),
                            bottom: BorderSide(
                                width: 0.5,
                                color: Color.fromRGBO(208, 213, 221, 1))),
                        borderRadius:
                            BorderRadius.all(Radius.circular(borderRadius)),
                      )
                    : null,
                child: Text(
                  Strings.friendRequest,
                  style: (activePageIndex == 0)
                      ? const TextStyle(
                          color: Color.fromRGBO(52, 64, 84, 1),
                          fontWeight: FontWeight.w600,
                          fontFamily: "Inter",
                          fontSize: 14)
                      : const TextStyle(
                          color: Color.fromRGBO(102, 112, 133, 1),
                          fontWeight: FontWeight.w600,
                          fontFamily: "Inter",
                          fontSize: 14),
                ),
              ),
            ),
          ),
          Expanded(
            child: InkWell(
              borderRadius:
                  const BorderRadius.all(Radius.circular(borderRadius)),
              onTap: _onSwitchSentFriendRequest,
              child: Container(
                width: MediaQuery.of(context).size.width,
                padding:
                    const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                alignment: Alignment.center,
                decoration: (activePageIndex == 1)
                    ? const BoxDecoration(
                        color: Colors.white,
                        border: Border(
                            top: BorderSide(
                                width: 0.5,
                                color: Color.fromRGBO(208, 213, 221, 1)),
                            right: BorderSide(
                                width: 0.5,
                                color: Color.fromRGBO(208, 213, 221, 1)),
                            left: BorderSide(
                                width: 1,
                                color: Color.fromRGBO(208, 213, 221, 1)),
                            bottom: BorderSide(
                                width: 0.5,
                                color: Color.fromRGBO(208, 213, 221, 1))),
                        borderRadius:
                            BorderRadius.all(Radius.circular(borderRadius)))
                    : null,
                child: Text(
                  Strings.sentFriendRequest,
                  style: (activePageIndex == 1)
                      ? const TextStyle(
                          color: Color.fromRGBO(52, 64, 84, 1),
                          fontWeight: FontWeight.w600,
                          fontFamily: "Inter",
                          fontSize: 14)
                      : const TextStyle(
                          color: Color.fromRGBO(102, 112, 133, 1),
                          fontWeight: FontWeight.w600,
                          fontFamily: "Inter",
                          fontSize: 14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onSwitchFriendRequest() {
    _pageController.jumpToPage(0);
    // _pageController.animateToPage(0,
    //     duration: const Duration(milliseconds: 500), curve: Curves.decelerate);
  }

  void _onSwitchSentFriendRequest() {
    _pageController.jumpToPage(1);
    // _pageController.animateToPage(1,
    //     duration: const Duration(milliseconds: 500), curve: Curves.decelerate);
  }
}
