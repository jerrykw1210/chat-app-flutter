import 'dart:developer';
import 'dart:io';

import 'package:fixnum/fixnum.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:no_screenshot/no_screenshot.dart';
import 'package:protech_mobile_chat_stream/constants/string_constant.dart';
import 'package:protech_mobile_chat_stream/model/database.dart' as db;
import 'package:protech_mobile_chat_stream/model/database.dart';
import 'package:protech_mobile_chat_stream/module/chat/cubit/chat_cubit.dart';
import 'package:protech_mobile_chat_stream/module/chat/cubit/group_cubit.dart';
import 'package:protech_mobile_chat_stream/module/chat/screen/chat_screen.dart';
import 'package:protech_mobile_chat_stream/module/conversation/cubit/conversation_cubit.dart';
import 'package:protech_mobile_chat_stream/module/friend/cubit/user_cubit.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:protech_mobile_chat_stream/module/general/cubit/navigator_cubit.dart';
import 'package:protech_mobile_chat_stream/module/search/cubit/search_cubit.dart';
import 'package:protech_mobile_chat_stream/module/webview/cubit/toggle_webview_cubit.dart';
import 'package:protech_mobile_chat_stream/route/routes.dart';
import 'package:protech_mobile_chat_stream/service/credential_service.dart';
import 'package:protech_mobile_chat_stream/service/database_helper.dart';
import 'package:protech_mobile_chat_stream/service/turms_response.dart';
import 'package:protech_mobile_chat_stream/service/turms_service.dart';
import 'package:protech_mobile_chat_stream/utils/colors.dart';
import 'package:protech_mobile_chat_stream/utils/service_locator.dart';
import 'package:protech_mobile_chat_stream/utils/string_apis.dart';
import 'package:protech_mobile_chat_stream/utils/toast_utils.dart';
import 'package:protech_mobile_chat_stream/widgets/chat_avatar.dart';
import 'package:turms_client_dart/turms_client.dart' as turms;

class FriendListScreen extends StatefulWidget {
  const FriendListScreen({super.key});

  @override
  State<FriendListScreen> createState() => _FriendListScreenState();
}

class _FriendListScreenState extends State<FriendListScreen>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late final TabController tabController;
  final ScrollController scrollController = ScrollController();

  TextEditingController searchFriendController = TextEditingController();
  TextEditingController searchGroupController = TextEditingController();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    tabController = TabController(
        length: context.read<ChatCubit>().state.sendNamecard ? 1 : 2,
        vsync: this);

    sl<turms.TurmsClient>().userService.addOnOnlineListener(() {
      // context.read<UserCubit>().fetchUsers();
      // context.read<UserCubit>().getFriendRequest();
      // context.read<UserCubit>().getSentFriendRequest();
      // context.read<GroupCubit>().fetchGroup();
    });
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  List<PopupMenuItem> popupMenuItem(BuildContext context) {
    List<PopupMenuItem> popupMenuItem = [
      PopupMenuItem(
          onTap: () {
            context.read<ChatCubit>().resetSelectedUser();
            Navigator.pushNamed(context, AppPage.addGroup.routeName);
          },
          child: Row(
            children: [
              const Icon(
                Icons.group_add,
                color: Colors.black,
              ),
              const SizedBox(width: 5),
              Text(Strings.createGroup)
            ],
          )),
      PopupMenuItem(
          onTap: () {
            context.read<UserCubit>().resetSearchUser();
            Navigator.pushNamed(context, AppPage.addFriend.routeName);
          },
          child: Row(
            children: [
              const Icon(Icons.add, color: Colors.black),
              const SizedBox(width: 5),
              Text(Strings.addFriend)
            ],
          )),
      PopupMenuItem(
          onTap: () {
            Navigator.pushNamed(context, AppPage.qrScanner.routeName);
          },
          child: Row(
            children: [
              const Icon(Icons.qr_code, color: Colors.black),
              const SizedBox(width: 5),
              Text(Strings.scanQRCode)
            ],
          )),
    ];

    return popupMenuItem;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(Strings.contact),
        actions: [
          IconButton(
              onPressed: () {
                context.read<UserCubit>().fetchUsers();
                context.read<UserCubit>().getFriendRequest();
                context.read<UserCubit>().getSentFriendRequest();
                context.read<GroupCubit>().fetchGroup();
              },
              icon: const Icon(Icons.refresh)),
          IconButton(onPressed: () {
            Navigator.pushNamed(context, AppPage.friendRequest.routeName);
          }, icon: BlocBuilder<UserCubit, UserState>(
            builder: (context, state) {
              return Stack(
                clipBehavior: Clip.none,
                children: [
                  SvgPicture.asset("assets/Buttons/user-plus-02.svg"),
                  if (state.friendRequests.isNotEmpty)
                    Positioned(
                        top: -2,
                        right: -4,
                        child: CircleAvatar(
                            backgroundColor: Colors.red,
                            radius: 8,
                            child: Center(
                              child: Text(
                                  state.friendRequests.length > 99
                                      ? "99"
                                      : state.friendRequests.length.toString(),
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 10)),
                            ))),
                ],
              );
            },
          )),
          PopupMenuButton(
            padding: const EdgeInsets.only(left: 5, right: 16),
            icon: const Icon(Icons.more_vert, color: Colors.white),
            itemBuilder: (context) {
              return popupMenuItem(context);
            },
          )
        ],
      ),
      // floatingActionButton: FloatingActionButton(
      //     mini: true,
      //     onPressed: () {},
      //     shape: const CircleBorder(),
      //     child: const Align(
      //       alignment: Alignment.center,
      //       child: Icon(Icons.add_rounded, size: 30),
      //     )),
      body: BlocBuilder<UserCubit, UserState>(
        builder: (context, state) {
          return Column(
            children: [
              TabBar(
                  controller: tabController,
                  dividerColor: Colors.transparent,
                  onTap: (value) {
                    context.read<SearchCubit>().resetSearchState();
                    searchFriendController.clear();
                    searchGroupController.clear();
                  },
                  tabs: [
                    Tab(
                      text: Strings.friends,
                    ),
                    BlocBuilder<ChatCubit, ChatState>(
                      builder: (context, chatstate) {
                        if (!chatstate.sendNamecard) {
                          return Tab(text: Strings.groups);
                        } else {
                          return const SizedBox();
                        }
                      },
                    )
                  ]),
              Expanded(
                child: TabBarView(
                    physics: const NeverScrollableScrollPhysics(),
                    controller: tabController,
                    children: [
                      FriendsTab(
                        userState: state,
                        textController: searchFriendController,
                      ),
                      BlocBuilder<ChatCubit, ChatState>(
                        builder: (context, chatstate) {
                          if (!chatstate.sendNamecard) {
                            return BlocBuilder<GroupCubit, GroupState>(
                              builder: (context, groupState) {
                                return GroupTab(
                                    groupState: groupState,
                                    textController: searchGroupController);
                              },
                            );
                          } else {
                            return const SizedBox();
                          }
                        },
                      )
                    ]),
              )
            ],
          );
        },
      ),
      // floatingActionButton: BlocListener<GroupCubit, GroupState>(
      //   listener: (context, groupState) {
      //     if (groupState.addGroupMemberStatus == AddGroupMemberStatus.success) {
      //       ScaffoldMessenger.of(context)
      //           .showSnackBar(const SnackBar(content: Text("Member added")));

      //       //context.read<ConversationCubit>().getConversations();
      //       context.read<GroupCubit>().reset();
      //       Navigator.of(context)
      //           .popUntil(ModalRoute.withName(AppPage.navBar.routeName));
      //     }
      //   },
      //   child: BlocListener<ConversationCubit, ConversationState>(
      //     listenWhen: (previous, current) =>
      //         previous.createConversationStatus !=
      //         current.createConversationStatus,
      //     listener: (context, state) {
      //       // state.createConversationStatus == CreateConversationStatus.loading
      //       //     ? context.loaderOverlay.show()
      //       //     : context.loaderOverlay.hide();

      //       if (state.createConversationStatus ==
      //           CreateConversationStatus.fail) {
      //         ScaffoldMessenger.of(context).showSnackBar(
      //             const SnackBar(content: Text("Failed to create Group")));
      //         return;
      //       }

      //       if (state.createConversationStatus ==
      //           CreateConversationStatus.success) {
      //         ScaffoldMessenger.of(context).showSnackBar(
      //             const SnackBar(content: Text("Chat created successfully")));

      //         //context.read<ConversationCubit>().getConversations();
      //         context.read<ChatCubit>().resetSelectedUser();
      //         Navigator.of(context)
      //             .popUntil(ModalRoute.withName(AppPage.navBar.routeName));
      //       }
      //     },
      //     child: BlocBuilder<ChatCubit, ChatState>(
      //       builder: (context, state) {
      //         return BlocBuilder<ConversationCubit, ConversationState>(
      //           builder: (context, conversationState) => FloatingActionButton(
      //             onPressed: () {
      //               if (conversationState.createConversationStatus ==
      //                   CreateConversationStatus.loading) {
      //                 return;
      //               }
      //               // if (widget.isAddMember) {
      //               //   context.read<GroupCubit>().addGroupMember(
      //               //       channel: StreamChannel.of(context).channel,
      //               //       userList: state.selectedUsers);
      //               // } else {
      //               Navigator.pushNamed(context, AppPage.addGroup.routeName);
      //             },
      //             shape: const CircleBorder(),
      //             child: const Icon(Icons.add),
      //           ),
      //         );
      //       },
      //     ),
      //   ),
      // ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.read<UserCubit>().resetSearchUser();
          Navigator.pushNamed(context, AppPage.addFriend.routeName);
        },
        shape: const CircleBorder(),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class FriendsTab extends StatefulWidget {
  FriendsTab({
    super.key,
    required this.userState,
    required this.textController,
  });
  UserState userState;
  TextEditingController textController;

  @override
  State<FriendsTab> createState() => _FriendsTabState();
}

class _FriendsTabState extends State<FriendsTab> {
  bool isSpecialCharacter(String text) {
    return RegExp(r'[!@#$%^&*()_+{}\[\]:;<>,.?~]').hasMatch(text);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.userState.getUsersStatus == GetUsersStatus.empty) {
      return Center(
        child: Text(Strings.noContactAdded),
      );
    }
    if (widget.userState.getUsersStatus == GetUsersStatus.success) {
      final List<String> alphabet =
          List.generate(26, (index) => String.fromCharCode(index + 65)); // A-Z

      return Column(
        children: [
          Row(
            children: [
              Flexible(
                flex: 8,
                child: ContactSearchBar(
                  searchFriendController: widget.textController,
                  searchType: "user",
                  userState: widget.userState,
                ),
              ),
              Flexible(
                flex: 3,
                child: DropdownButtonHideUnderline(
                    child: DropdownButton(
                  onChanged: (value) => context
                      .read<UserCubit>()
                      .filterUserStatus(value.toString()),
                  value: widget.userState.filterStatus.toUpperCase(),
                  items: [
                    DropdownMenuItem(
                      value: "ALL",
                      child: Text(Strings.all),
                    ),
                    DropdownMenuItem(
                      value: "ONLINE",
                      child: Text(Strings.online),
                    ),
                    DropdownMenuItem(
                      value: "OFFLINE",
                      child: Text(Strings.offline),
                    ),
                  ],
                )),
              )
            ],
          ),
          BlocListener<ConversationCubit, ConversationState>(
            listenWhen: (previous, current) =>
                previous.getConversationStatus != current.getConversationStatus,
            listener: (context, state) {
              if (state.getConversationStatus ==
                  GetConversationStatus.success) {}
            },
            child: Expanded(
              child: BlocBuilder<SearchCubit, SearchState>(
                builder: (context, searchState) {
                  return GroupedListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    elements: searchState.searchUserOrGroupStatus ==
                                SearchUserOrGroupStatus.matchedUsers ||
                            searchState.searchUserOrGroupStatus ==
                                SearchUserOrGroupStatus.empty
                        ? searchState.searchedUserInfo
                        : widget.userState.usersList,
                    groupBy: (turms.UserInfo user) {
                      if (isSpecialCharacter(user.name)) {
                        return "#";
                      }
                      return user.name[0];
                    },
                    shrinkWrap: true,
                    groupComparator: (value1, value2) {
                      if (isSpecialCharacter(value1.toString()) &&
                          !isSpecialCharacter(value2.toString())) {
                        return 1;
                      } else {
                        return value1.toString().compareTo(value2.toString());
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
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: BlocBuilder<ChatCubit, ChatState>(
                          builder: (context, state) {
                            return Slidable(
                              endActionPane: ActionPane(
                                  motion: const DrawerMotion(),
                                  extentRatio: 0.50,
                                  children: [
                                    SlidableAction(
                                        onPressed: (context) {
                                          context
                                              .read<UserCubit>()
                                              .deleteFriend(user.id);
                                        },
                                        backgroundColor: Colors.red,
                                        foregroundColor: Colors.white,
                                        icon: Icons.delete,
                                        label: Strings.delete)
                                  ]),
                              child: ListTile(
                                leading: ChatAvatar(
                                    errorWidget: CircleAvatar(
                                      child: Image.network(
                                        user.name.toString()[0],
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                                Text(user.name.toString()[0]),
                                      ),
                                    ),
                                    targetId: user.id.toString(),
                                    radius: 20),
                                onTap: () async {
                                  if (state.sendNamecard) {
                                    await context.read<ChatCubit>().sendMessage(
                                        state.sendNamecardToId ?? Int64(0),
                                        sl<CredentialService>()
                                                .turmsId
                                                ?.parseInt64() ??
                                            Int64(0),
                                        message: user.name,
                                        isGroupMessage: state.isGroup,
                                        messageType:
                                            turms.MessageType.NAMECARD_TYPE,
                                        extraInfo: user.id.toString());

                                    context
                                        .read<ToggleWebviewCubit>()
                                        .setCurrentIndex(0);
                                    Navigator.popUntil(
                                        context,
                                        ModalRoute.withName(
                                            AppPage.navBar.routeName));
                                    context.read<ChatCubit>().resetNamecard();
                                  } else {
                                    String friendId = user.id.toString();
                                    // String myUserId = sl<TurmsService>()
                                    //     .userService
                                    //     .userInfo!
                                    //     .userId
                                    //     .toString();

                                    String? myUserId =
                                        sl<CredentialService>().turmsId;

                                    final res = await sl<TurmsService>()
                                        .handleTurmsResponse<turms.UserInfo?>(
                                            () async {
                                      turms.UserInfo? friendInfo =
                                          await sl<TurmsService>()
                                              .queryUserProfile(friendId);

                                      return friendInfo;
                                    });

                                    if (res is TurmsMapSuccessResponse<
                                        turms.UserInfo?>) {
                                      turms.UserInfo? friendInfo = res.res;
                                      if (myUserId != null) {
                                        db.Conversation? conversation =
                                            await sl<DatabaseHelper>()
                                                .getConversation(DatabaseHelper
                                                    .conversationId(
                                                        targetId: friendId,
                                                        myId: myUserId));

                                        if (conversation == null) {
                                          await sl<DatabaseHelper>()
                                              .upsertConversation(
                                                  friendId: friendId,
                                                  members: [friendId, myUserId],
                                                  isGroup: false,
                                                  targetId: friendId,
                                                  title: friendInfo?.name ??
                                                      friendId,
                                                  ownerId: myUserId);

                                          conversation = await sl<
                                                  DatabaseHelper>()
                                              .getConversation(
                                                  DatabaseHelper.conversationId(
                                                      targetId: friendId,
                                                      myId: myUserId));

                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    MessageScreen(
                                                        conversation:
                                                            conversation,
                                                        isGroup: false)),
                                          );

                                          return;
                                        }

                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  MessageScreen(
                                                      conversation:
                                                          conversation,
                                                      isGroup: false)),
                                        );
                                      }
                                    }

                                    if (res is TurmsInvalidErrorResponse<
                                        turms.UserInfo?>) {
                                      ToastUtils.showToast(
                                          context: context,
                                          msg: res.reason,
                                          type: Type.warning);
                                    }

                                    // } else {
                                    // Navigator.of(context).push(
                                    //   MaterialPageRoute(
                                    //     builder: (context) => StreamChannel(
                                    //       channel: conversations.singleWhere(
                                    //           (channel) =>
                                    //               channel.state?.members.any(
                                    //                   (member) =>
                                    //                       member.userId == user.id) ??
                                    //               false),
                                    //       child: MessageScreen(),
                                    //     ),
                                    //   ),
                                    // );
                                    // }
                                  }
                                },
                                title: Text(user.name.toString()),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          )
          // Stack(
          //   children: [

          //     // Positioned(
          //     //   right: 0,
          //     //   top: 100,
          //     //   bottom: 100,
          //     //   child: SizedBox(
          //     //     width: 20,
          //     //     //height: 300,
          //     //     child: ListView.builder(
          //     //       itemCount: alphabet.length,
          //     //       shrinkWrap: true,
          //     //       itemBuilder: (context, index) => GestureDetector(
          //     //         // onTap: ()=> ,
          //     //         child: Padding(
          //     //           padding: const EdgeInsets.symmetric(vertical: 2.0),
          //     //           child: Text(alphabet[index]),
          //     //         ),
          //     //       ),
          //     //     ),
          //     //   ),
          //     // )
          //   ],
          // ),
        ],
      );
    }
    if (widget.userState.getUsersStatus == GetUsersStatus.fail) {
      return Center(
        child: Text(Strings.somethingWentWrong),
      );
    } else {
      return const SizedBox();
    }
  }
}

class ContactSearchBar extends StatelessWidget {
  const ContactSearchBar(
      {super.key,
      required this.searchFriendController,
      required this.searchType,
      this.userState,
      this.groupState});

  final TextEditingController searchFriendController;
  final String searchType;
  final UserState? userState;
  final GroupState? groupState;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
      child: TextField(
        controller: searchFriendController,
        maxLength: 200,
        decoration: InputDecoration(
            prefixIcon: const Icon(Icons.search, size: 24),
            hintText: Strings.searchHint,
            counterText: ""),
        onChanged: (value) {
          if (value.isBlank) {
            context.read<SearchCubit>().resetSearchState();
          }
          context.read<SearchCubit>().searchUserOrGroup(value, searchType,
              users: userState?.usersList ?? [],
              groups: groupState?.groupList ?? []);
        },
      ),
    );
  }
}

class GroupTab extends StatefulWidget {
  GroupTab({super.key, required this.groupState, required this.textController});
  GroupState groupState;
  TextEditingController textController;

  @override
  State<GroupTab> createState() => _GroupTabState();
}

class _GroupTabState extends State<GroupTab> {
  NoScreenshot noScreenshot = NoScreenshot.instance;
  bool isSpecialCharacter(String text) {
    return RegExp(r'[!@#$%^&*()_+{}\[\]:;<>,.?~]').hasMatch(text);
  }

  bool checkPermission(String settingsKey,
      {required String? groupOwnerId,
      bool reverseBool = false,
      bool? customOutputWhenOwnerIdEqualsUserId,
      required turms.ConversationSettings groupSettings}) {
    final settings = groupSettings;
    final ownerId = groupOwnerId;
    final userId = sl<CredentialService>().turmsId;
    final trueCondition = reverseBool ? 0 : 1;

    if (userId == null || groupOwnerId == null) {
      return reverseBool;
    }

    if (ownerId == userId) {
      return customOutputWhenOwnerIdEqualsUserId ?? !reverseBool;
    }

    return settings.settings[settingsKey]?.int32Value == trueCondition;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.groupState.fetchGroupStatus == FetchGroupStatus.empty) {
      return Center(
        child: Text(Strings.noGroupAdded),
      );
    }

    if (widget.groupState.fetchGroupStatus == FetchGroupStatus.success) {
      return Column(
        children: [
          ContactSearchBar(
            searchFriendController: widget.textController,
            searchType: "group",
            groupState: widget.groupState,
          ),
          Expanded(
            child: BlocBuilder<SearchCubit, SearchState>(
              builder: (context, searchState) {
                return GroupedListView(
                  elements: searchState.searchUserOrGroupStatus ==
                              SearchUserOrGroupStatus.matchedGroups ||
                          searchState.searchUserOrGroupStatus ==
                              SearchUserOrGroupStatus.empty
                      ? searchState.searchedGroupInfo
                      : widget.groupState.groupList,
                  groupBy: (turms.Group group) {
                    if (isSpecialCharacter(group.name)) {
                      return "#";
                    }
                    return group.name[0];
                  },
                  shrinkWrap: true,
                  groupComparator: (value1, value2) {
                    if (isSpecialCharacter(value1.toString()) &&
                        !isSpecialCharacter(value2.toString())) {
                      return 1;
                    } else {
                      return value1.toString().compareTo(value2.toString());
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
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: BlocBuilder<ChatCubit, ChatState>(
                        builder: (context, state) {
                          return ListTile(
                            leading: ChatAvatar(
                              errorWidget: CircleAvatar(
                                child: Image.network(
                                  group.name.toString()[0],
                                  errorBuilder: (context, error, stackTrace) =>
                                      Text(group.name.toString()[0]),
                                ),
                              ),
                              targetId: group.id.toString(),
                              isGroup: true,
                              radius: 20,
                            ),
                            onTap: () async {
                              String? myUserId =
                                  sl<CredentialService>().turmsId;

                              if (myUserId == null) {
                                return;
                              }

                              // Navigator.of(context).push(
                              //   MaterialPageRoute(
                              //       builder: (context) => MessageScreen(
                              //             conversation: conversation,
                              //             isGroup: true,
                              //             conversationSettings: groupSettings,
                              //           )),
                              // );

                              db.Conversation? conversation =
                                  await sl<DatabaseHelper>().getConversation(
                                      DatabaseHelper.conversationId(
                                          targetId: group.id.toString(),
                                          myId: myUserId));

                              context
                                  .read<GroupCubit>()
                                  .fetchGroupSettings(group.id);
                              log("group conv $conversation");
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => StreamBuilder<
                                          Conversation>(
                                      stream: sl<DatabaseHelper>()
                                          .getGroupSettings(
                                              conversation?.id ?? ""),
                                      builder: (context, snapshot) {
                                        turms.ConversationSettings? settings;

                                        if (snapshot.hasData) {
                                          if (snapshot.data != null &&
                                              snapshot.data!.settings != null) {
                                            settings = turms
                                                    .ConversationSettings
                                                .fromJson(
                                                    snapshot.data!.settings!);
                                          }
                                        }

                                        return BlocBuilder<NavigatorCubit,
                                            MyNavigatorState>(
                                          builder: (context, state) {
                                            if (!state.inMessageScreen) {
                                              noScreenshot.screenshotOn();
                                            } else {
                                              if (settings != null) {
                                                if (checkPermission(
                                                    "CAN_SCREEN_CAPTURE",
                                                    customOutputWhenOwnerIdEqualsUserId:
                                                        true,
                                                    groupOwnerId: group.ownerId
                                                        .toString(),
                                                    groupSettings: settings)) {
                                                  noScreenshot.screenshotOn();
                                                } else {
                                                  noScreenshot.screenshotOff();
                                                }
                                              }
                                            }

                                            return MessageScreen(
                                                conversation: conversation,
                                                isGroup: true,
                                                conversationSettings: settings);
                                          },
                                        );
                                      }),
                                  settings: RouteSettings(
                                      name: AppPage.message.routeName),
                                ),
                              );
                            },
                            title: Text(group.name.toString()),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      );
    }

    if (widget.groupState.fetchGroupStatus == FetchGroupStatus.fail) {
      return Center(
        child: Text(Strings.somethingWentWrong),
      );
    } else {
      return const SizedBox();
    }
  }
}

void _showEnterGroupNameDialog(
    BuildContext context, void Function(String groupName) callback) {
  List<turms.UserInfo> notJoinedUser = [
    // ...context.read<UserCubit>().state.usersList,
    ...context.read<ChatCubit>().state.selectedUsers
  ];
  showDialog(
    barrierDismissible: true,
    context: context,
    builder: (dialogcontext) {
      return Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 20.0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 15.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                          padding: const EdgeInsets.all(12.0),
                          decoration: BoxDecoration(
                              border: Border.all(
                                  color: AppColor.feedbackTypeBorderColor),
                              borderRadius: BorderRadius.circular(10.0)),
                          child: Image.asset("assets/Buttons/users-plus.png")),
                      IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      Strings.addYourGroupMember,
                      style: Theme.of(context)
                          .textTheme
                          .bodyLarge
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                BlocBuilder<ChatCubit, ChatState>(
                  builder: (context, state) {
                    return
                        // SingleChildScrollView(
                        //   child: Column(
                        //       children: state.selectedUsers
                        //           .map((user) => ListTile(
                        //                 leading: CircleAvatar(
                        //                   child: Image.asset(
                        //                       "assets/icon/default-user.png"),
                        //                 ),
                        //                 contentPadding: EdgeInsets.zero,
                        //                 title: Text(user.name),
                        //                 subtitle: Text(user.name),
                        //                 trailing: TextButton(
                        //                     onPressed: () {},
                        //                     child: const Text("移除")),
                        //               ))
                        //           .toList()),
                        // );
                        ListView.builder(
                      shrinkWrap: true,
                      itemCount: state.selectedUsers.length,
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        return ListTile(
                          leading: CircleAvatar(
                            child: Image.asset("assets/icon/default-user.png"),
                          ),
                          contentPadding: EdgeInsets.zero,
                          title: Text(state.selectedUsers[index].name),
                          subtitle: Text(state.selectedUsers[index].name),
                          trailing: TextButton(
                              onPressed: () {
                                context
                                    .read<ChatCubit>()
                                    .selectUser(state.selectedUsers[index]);
                              },
                              child: Text(Strings.remove)),
                        );
                      },
                    );
                  },
                ),
                DropdownButtonFormField(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10.0, vertical: 10.0),
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                          width: 1,
                          color: AppColor
                              .feedbackTypeBorderColor), // Border width and color
                      borderRadius: BorderRadius.circular(8), // Rounded corners
                    ),
                  ),
                  icon: const Icon(Icons.keyboard_arrow_down_outlined),
                  value: notJoinedUser[0].id,
                  isExpanded: true,
                  isDense: true,
                  borderRadius: BorderRadius.circular(8.0),
                  alignment: Alignment.center,
                  items: notJoinedUser
                      .map((user) => DropdownMenuItem(
                            value: user.id,
                            onTap: () =>
                                context.read<ChatCubit>().selectUser(user),
                            child: Text(user.name,
                                style: Theme.of(context).textTheme.bodyMedium),
                          ))
                      .toList(),
                  onChanged: (value) {},
                ),
                SizedBox(
                    width: 200,
                    child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(dialogcontext);
                          _showUploadGroupImageDialog(context);
                        },
                        child: Text(
                          Strings.next,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(color: Colors.white),
                        ))),
                SizedBox(
                    width: 200,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white),
                      child: Text(Strings.cancel,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(color: Colors.black)),
                    ))
              ],
            ),
          ),
        ),
      );
    },
  );
}

void _showUploadGroupImageDialog(BuildContext context) {
  final ImagePicker picker = ImagePicker();
  final TextEditingController groupNameController = TextEditingController();

  showDialog(
    barrierDismissible: true,
    context: context,
    builder: (context) {
      return Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 20.0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SingleChildScrollView(
            child: BlocBuilder<GroupCubit, GroupState>(
              builder: (context, state) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 15.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            Strings.uploadProfileImage,
                            style: Theme.of(context)
                                .textTheme
                                .bodyLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          IconButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            icon: const Icon(Icons.close),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      Strings.chooseOneImageToUpload,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          if (state.image != null)
                            Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: CircleAvatar(
                                    maxRadius: 30,
                                    backgroundImage: FileImage(
                                      File(
                                        state.image?.path ?? "",
                                      ),
                                    ))),
                          ElevatedButton.icon(
                              onPressed: () async {
                                final image = await picker.pickImage(
                                    source: ImageSource.gallery);
                                if (image != null) {
                                  context.read<GroupCubit>().saveImage(image);
                                }
                              },
                              icon: const Icon(Icons.upload),
                              label: Text(
                                Strings.uploadProfileImage,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(color: Colors.white),
                              )),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: TextFormField(
                        controller: groupNameController,
                        decoration: InputDecoration(
                          border: const OutlineInputBorder(),
                          hintText: Strings.groupName,
                        ),
                      ),
                    ),
                    SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                            onPressed: () {
                              String groupName = groupNameController.text;

                              if (groupName.trim().isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text(
                                            Strings.groupNameCannotBeEmpty)));
                                return;
                              }

                              Navigator.of(context).pop();
                            },
                            child: Text(
                              Strings.createGroup,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(color: Colors.white),
                            ))),
                    SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white),
                          child: Text(Strings.cancel,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(color: Colors.black)),
                        ))
                  ],
                );
              },
            ),
          ),
        ),
      );
    },
  );
}

class FriendSearchBar extends SliverPersistentHeaderDelegate {
  TextEditingController searchFriendController = TextEditingController();
  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return // search bar
        Container(
      height: maxExtent, // Ensures it respects the sliver constraints
      color: AppColor.greyBackgroundColor,
      child: Row(
        children: [
          Flexible(
            flex: 8,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
              child: TextField(
                controller: searchFriendController,
                decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search, size: 24),
                    hintText: Strings.searchHint),
                onChanged: (value) {
                  context.read<SearchCubit>().searchUserOrGroup(value, "user");
                },
              ),
            ),
          ),
          Flexible(
            flex: 2,
            child: BlocBuilder<UserCubit, UserState>(
              builder: (context, userState) {
                return DropdownButtonHideUnderline(
                    child: DropdownButton(
                  onChanged: (value) => context
                      .read<UserCubit>()
                      .filterUserStatus(value.toString()),
                  value: userState.filterStatus.toUpperCase(),
                  items: [
                    DropdownMenuItem(
                      value: "ALL",
                      child: Text(Strings.all),
                    ),
                    DropdownMenuItem(
                      value: "ONLINE",
                      child: Text(Strings.online),
                    ),
                    DropdownMenuItem(
                      value: "OFFLINE",
                      child: Text(Strings.offline),
                    ),
                  ],
                ));
              },
            ),
          )
        ],
      ),
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
