import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:no_screenshot/no_screenshot.dart';
import 'package:protech_mobile_chat_stream/constants/string_constant.dart';
import 'package:protech_mobile_chat_stream/model/database.dart';
import 'package:protech_mobile_chat_stream/module/chat/cubit/chat_cubit.dart';
import 'package:protech_mobile_chat_stream/module/chat/cubit/group_cubit.dart';
import 'package:protech_mobile_chat_stream/module/chat/cubit/sticker_cubit.dart';
import 'package:protech_mobile_chat_stream/module/chat/screen/chat_screen.dart';
import 'package:protech_mobile_chat_stream/module/conversation/cubit/conversation_cubit.dart';
import 'package:protech_mobile_chat_stream/module/friend/cubit/user_cubit.dart';
import 'package:protech_mobile_chat_stream/module/general/cubit/navigator_cubit.dart';
import 'package:protech_mobile_chat_stream/module/profile/cubit/profile_cubit.dart';
import 'package:protech_mobile_chat_stream/route/routes.dart';
import 'package:protech_mobile_chat_stream/service/credential_service.dart';
import 'package:protech_mobile_chat_stream/service/database_helper.dart';
import 'package:protech_mobile_chat_stream/service/turms_service.dart';
import 'package:protech_mobile_chat_stream/utils/helper.dart';
import 'package:protech_mobile_chat_stream/utils/service_locator.dart';
import 'package:protech_mobile_chat_stream/utils/string_apis.dart';
import 'package:protech_mobile_chat_stream/utils/tap_handler.dart';
import 'package:protech_mobile_chat_stream/widgets/chat_avatar.dart';
import 'package:protech_mobile_chat_stream/widgets/user_avatar.dart';
import 'package:rxdart/rxdart.dart';
import 'package:turms_client_dart/turms_client.dart' as turms;

class ConversationsScreen extends StatefulWidget {
  const ConversationsScreen({super.key});

  @override
  State<ConversationsScreen> createState() => _ConversationsScreenState();
}

class _ConversationsScreenState extends State<ConversationsScreen> {
  NoScreenshot noScreenshot = NoScreenshot.instance;
  final _compositeSubscription = CompositeSubscription();

  @override
  void initState() {
    sl<turms.TurmsClient>().userService.addOnOnlineListener(() {
      sl<TurmsService>().updateSync();
      log("login success on online");
      context.read<ConversationCubit>().getConversations();
      context
          .read<ConversationCubit>()
          .stream
          .listen((ConversationState state) {
        if (state.getConversationStatus == GetConversationStatus.success) {
          context.read<ChatCubit>().queryMessages();
          // context.read<ChatCubit>().queryMessages(areGroupMessage: true);
          context.read<ChatCubit>().queryGroupMessages();
        }
      });
    });

    _compositeSubscription.add(sl<DatabaseHelper>()
        .getOwnConversationStream(sl<CredentialService>().turmsId ?? "")
        .listen((data) {
      if (mounted) {
        // setState(() {});
      }
    }));

    // context.read<ConversationCubit>().getConversations();
    // context.read<ConversationCubit>().stream.listen((ConversationState state) {
    //   if (state.getConversationStatus == GetConversationStatus.success) {
    //     if (mounted) {
    //       context.read<ChatCubit>().queryMessages();
    //       // context.read<ChatCubit>().queryMessages(areGroupMessage: true);
    //       context.read<ChatCubit>().queryGroupMessages();
    //     }
    //   }
    // });
    // context.read<ChatCubit>().sendMessage(3026949183553892352,
    //     3035956383179350016, "hello", "3026949183553892352");
    // channelListController.doInitialLoad();
    // fetch();
    super.initState();
  }

  @override
  void dispose() {
    _compositeSubscription.cancel();
    super.dispose();
  }

  // Future<void> fetch() async {

  //   dynamic data = db.select(db.conversations).get().asStream().listen((data) {
  //     log("conversation fetch local $data");
  //   });

  //   // log("msg data $data");
  // }

  Future<void> pinConversation(String conversationId, String targetId,
      {bool isGroup = false}) async {
    await sl<DatabaseHelper>().pinConversation(conversationId);
    await sl<TurmsService>()
        .pinConversation(targetId: targetId, isGroup: isGroup);
  }

  Future<void> unPinConversation(String conversationId, String targetId,
      {bool isGroup = false}) async {
    await sl<DatabaseHelper>().unPinConversation(conversationId);
    await sl<TurmsService>()
        .unPinConversation(targetId: targetId, isGroup: isGroup);
  }

  Future<void> muteConversation(String conversationId, String targetId,
      {bool isGroup = false}) async {
    await sl<DatabaseHelper>().muteConversation(conversationId);
    await sl<TurmsService>()
        .muteConversation(targetId: targetId, isGroup: isGroup);
  }

  Future<void> unMuteConversation(String conversationId, String targetId,
      {bool isGroup = false}) async {
    await sl<DatabaseHelper>().unMuteConversation(conversationId);
    await sl<TurmsService>()
        .unMuteConversation(targetId: targetId, isGroup: isGroup);
  }

  Future<void> deleteConversation(
      {required String conversationId,
      required String targetId,
      required bool isGroup,
      required DateTime endDate}) async {
    await sl<DatabaseHelper>().deleteConversation(conversationId);
    await sl<TurmsService>().deleteConversation(
        targetId: targetId, isGroup: isGroup, endDate: endDate);
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

  Widget conversationItem(Conversation conversation) {
    return Slidable(
        startActionPane: ActionPane(
          motion: const DrawerMotion(),
          extentRatio: 0.25,
          children: [
            SlidableAction(
                onPressed: (context) {
                  //conversation.hide(clearHistory: true);
                  if (!conversation.isGroup) {}

                  if (conversation.isPinned) {
                    String targetId = conversation.targetId ?? "";
                    unPinConversation(conversation.id, targetId,
                        isGroup: conversation.isGroup);
                  } else {
                    String targetId = conversation.targetId ?? "";
                    pinConversation(conversation.id, targetId,
                        isGroup: conversation.isGroup);
                  }
                },
                backgroundColor:
                    conversation.isPinned ? Colors.grey : Colors.orange,
                foregroundColor: Colors.white,
                icon: conversation.isPinned
                    ? Icons.push_pin_outlined
                    : Icons.push_pin,
                label: conversation.isPinned ? Strings.unpin : Strings.pin),
          ],
        ),
        endActionPane: ActionPane(
            motion: const DrawerMotion(),
            extentRatio: 0.50,
            children: [
              SlidableAction(
                  onPressed: (context) {
                    //conversation.hide(clearHistory: true);
                    if (!conversation.isGroup) {}

                    if (conversation.isMuted) {
                      String targetId = conversation.targetId ?? "";
                      unMuteConversation(conversation.id, targetId,
                          isGroup: conversation.isGroup);
                    } else {
                      String targetId = conversation.targetId ?? "";
                      muteConversation(conversation.id, targetId,
                          isGroup: conversation.isGroup);
                    }
                  },
                  backgroundColor:
                      conversation.isMuted ? Colors.grey : Colors.blue,
                  foregroundColor: Colors.white,
                  icon:
                      conversation.isMuted ? Icons.volume_up : Icons.volume_off,
                  label: conversation.isMuted ? Strings.unmute : Strings.mute),
              SlidableAction(
                  onPressed: (context) {
                    //conversation.hide(clearHistory: true);
                    deleteConversation(
                        conversationId: conversation.id,
                        targetId: conversation.targetId ?? "",
                        isGroup: conversation.isGroup,
                        endDate: DateTime.now());
                  },
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  icon: Icons.delete,
                  label: Strings.delete)
            ]),
        child: ListTile(
          leading: ChatAvatar(
              key: Key(
                  'chat_avatar_${conversation.targetId ?? Helper.generateUUID()}_${conversation.isGroup}'),
              errorWidget: CircleAvatar(
                radius: 35,
                child: ClipOval(
                  child: Image.file(
                    File("${Helper.directory?.path}/${conversation.avatar}"),
                    errorBuilder: (context, error, stackTrace) =>
                        Text(conversation.title[0]),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              radius: 25,
              targetId: conversation.targetId ?? "",
              isGroup: conversation.isGroup),
          title: Text(
            conversation.title // receiver name
                .toString(),
            maxLines: 1,
            style: Theme.of(context)
                .textTheme
                .bodyLarge
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          subtitle: StreamBuilder(
            stream:
                sl<DatabaseHelper>().getMessagesByConversation(conversation.id),
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                final lastMsg = snapshot.data?.last;
                String lastMsgContent = lastMsg?.content.toString() ?? "";
                if (lastMsg != null) {
                  if (lastMsg.type == turms.MessageType.IMAGE_TYPE.name) {
                    lastMsgContent = "[${Strings.image}]";
                  }

                  if (lastMsg.type == turms.MessageType.VIDEO_TYPE.name) {
                    lastMsgContent = "[${Strings.video}]";
                  }

                  if (lastMsg.type == turms.MessageType.VOICE_TYPE.name) {
                    lastMsgContent = "[${Strings.audio}]";
                  }

                  if (lastMsg.type == turms.MessageType.FILE_TYPE.name) {
                    lastMsgContent = "[${Strings.file}]";
                  }

                  if (lastMsg.type == turms.MessageType.STICKER_TYPE.name) {
                    lastMsgContent = "[${Strings.sticker}]";
                  }

                  if (lastMsg.type == turms.MessageType.NAMECARD_TYPE.name) {
                    lastMsgContent = "[${Strings.namecard}]";
                  }
                }

                return Text(
                  lastMsgContent,
                  // style: Theme.of(context)
                  //     .textTheme
                  //     .bodyMedium
                  //     ?.copyWith(
                  //       fontWeight:
                  //           channel.state?.unreadCount != 0
                  //               ? FontWeight.bold
                  //               : FontWeight.normal,
                  //     ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      color: Color.fromARGB(255, 116, 116, 116)),
                );
              }
              return const Text("");
            },
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(conversation.lastMessageDate == null
                  ? ""
                  : DateFormat('yyyy-MM-dd')
                              .format(conversation.lastMessageDate!) ==
                          DateFormat('yyyy-MM-dd').format(
                              DateTime.now().subtract(const Duration(days: 1)))
                      ? Strings.yesterday
                      : DateUtils.isSameDay(
                              conversation.lastMessageDate, DateTime.now())
                          ? DateFormat("HH:mm")
                              .format(conversation.lastMessageDate!)
                          : DateFormat('MMM d', 'en_US')
                              .format(conversation.lastMessageDate!)),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (conversation.isPinned)
                    const Icon(Icons.push_pin,
                        color: Color.fromARGB(255, 116, 116, 116), size: 14),
                  if (conversation.isPinned && conversation.isMuted)
                    const SizedBox(width: 5),
                  if (conversation.isMuted)
                    const Icon(Icons.volume_off,
                        color: Color.fromARGB(255, 116, 116, 116), size: 14),
                  const SizedBox(width: 5),
                  StreamBuilder(
                      stream: sl<DatabaseHelper>()
                          .getConversationUnreadCount(conversation.id),
                      builder: (context, snapshot) {
                        if (snapshot.hasData && snapshot.data != 0) {
                          return Container(
                            width: 20,
                            height: 20,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.red,
                            ),
                            child: Center(
                              child: Text(
                                snapshot.data.toString(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      })
                ],
              ),
            ],
          ),
          visualDensity: const VisualDensity(vertical: -4, horizontal: 0),
          // trailing: Column(
          //   mainAxisAlignment:

          //   channel.state!.unreadCount > 0
          //       ? MainAxisAlignment.spaceEvenly
          //       : MainAxisAlignment.start,
          //   crossAxisAlignment: CrossAxisAlignment.end,
          //   children: [
          //     Text(channel.lastMessageAt == null
          //         ? ""
          //         : DateUtils.isSameDay(channel.lastMessageAt,
          //                 DateTime.now())
          //             ? DateFormat("HH:mm")
          //                 .format(channel.lastMessageAt!)
          //             : DateTime.now()
          //                         .difference(
          //                             channel.lastMessageAt!)
          //                         .inDays ==
          //                     1
          //                 ? "Yesterday"
          //                 : DateFormat('MMM d', 'en_US')
          //                     .format(
          //                         channel.lastMessageAt!)),
          //     if (channel.state?.unreadCount != 0)
          //       StreamBuilder(
          //         stream: channel.state?.unreadCountStream,
          //         builder: (context, snapshot) {
          //           if (snapshot.hasData) {
          //             return Container(
          //                 padding: const EdgeInsets.symmetric(
          //                     horizontal: 15.0, vertical: 2),
          //                 decoration: BoxDecoration(
          //                     borderRadius:
          //                         BorderRadius.circular(20.0),
          //                     color: AppColor
          //                         .chatSenderBubbleColor),
          //                 child: Text(
          //                   channel.state?.unreadCount
          //                           .toString() ??
          //                       "",
          //                   style: Theme.of(context)
          //                       .textTheme
          //                       .bodySmall
          //                       ?.copyWith(
          //                           color: Colors.white),
          //                 ));
          //           }
          //           return const SizedBox();
          //         },
          //       )
          //   ],
          // ),
          onTap: () async {
            /// Display a list of messages when the user taps on
            /// an item. We can use [StreamChannel] to wrap our
            /// [MessageScreen] screen with the selected channel.
            ///
            /// This allows us to use a built-in inherited widget
            /// for accessing our `channel` later on.
            TapHandlerClass.instance.onTap(0);
            if (conversation.isGroup) {
              context
                  .read<GroupCubit>()
                  .fetchGroupSettings(conversation.targetId!.parseInt64());
            }

            context
                .read<StickerCubit>()
                .getStickerList(sl<CredentialService>().turmsId.toString());

            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => StreamBuilder<Conversation>(
                    stream:
                        sl<DatabaseHelper>().getGroupSettings(conversation.id),
                    builder: (context, snapshot) {
                      turms.ConversationSettings? settings;

                      if (snapshot.hasData) {
                        if (snapshot.data != null &&
                            snapshot.data!.settings != null) {
                          settings = turms.ConversationSettings.fromJson(
                              snapshot.data!.settings!);
                        }
                      }

                      return BlocBuilder<NavigatorCubit, MyNavigatorState>(
                        builder: (context, state) {
                          if (!state.inMessageScreen) {
                            noScreenshot.screenshotOn();
                          } else {
                            if (conversation.isGroup) {
                              if (settings != null) {
                                if (checkPermission("CAN_SCREEN_CAPTURE",
                                    customOutputWhenOwnerIdEqualsUserId: true,
                                    groupOwnerId: conversation.ownerId,
                                    groupSettings: settings)) {
                                  noScreenshot.screenshotOn();
                                } else {
                                  noScreenshot.screenshotOff();
                                }
                              }
                            }
                          }

                          return MessageScreen(
                              conversation: conversation,
                              isGroup: conversation.isGroup,
                              conversationSettings: settings);
                        },
                      );
                    }),
                settings: RouteSettings(name: AppPage.message.routeName),
              ),
            );
          },
        ));
  }

  @override
  Widget build(BuildContext context) {
    return LoaderOverlay(
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          leading: GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, AppPage.editProfile.routeName);
            },
            child: BlocBuilder<ProfileCubit, ProfileState>(
              builder: (context, state) {
                return UserAvatar(userInfo: state.userProfile);

                // File profileAvatarImg = File(
                //     "${Helper.directory?.path}/${sl<CredentialService>().turmsId}_${state.userProfile?.profileUrl}");

                // Uint8List profileAvatarBytes =
                //     profileAvatarImg.readAsBytesSync();

                // return CircleAvatar(
                //     child: Image.memory(
                //   profileAvatarBytes,
                //   fit: BoxFit.cover,
                //   width: 40,
                //   height: 40,
                //   errorBuilder: (context, error, stackTrace) => Image.asset(
                //     'assets/default-img/default-user.png',
                //     fit: BoxFit.cover,
                //     width: 40,
                //     height: 40,
                //   ),
                // ));
              },
            ),
          ),
          title: Text(Strings.chat),
          actions: [
            IconButton(
              onPressed: () {
                context.read<ChatCubit>().queryMessages();

                // context.read<ChatCubit>().queryMessages(areGroupMessage: true);
                context.read<ChatCubit>().queryGroupMessages();
              },
              icon: const Icon(Icons.refresh),
            ),
            GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, AppPage.search.routeName);
                },
                child: const Padding(
                  padding: EdgeInsets.only(left: 5, right: 5),
                  child: Icon(Icons.search),
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
        body: SafeArea(
            child: StreamBuilder(
                stream: sl<DatabaseHelper>().getOwnConversationStream(
                    sl<CredentialService>().turmsId ?? ""),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    log("conversation ${snapshot.data}");
                    if (snapshot.data!.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset("assets/Illustration.png"),
                            const SizedBox(height: 16),
                            Text(Strings.conversationNotFound,
                                style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    fontFamily: "Inter",
                                    color: Color.fromRGBO(16, 24, 40, 1))),
                            // const SizedBox(height: 10),
                            // Text(Strings.searchTermNotFound,
                            //     style: const TextStyle(
                            //         fontSize: 14,
                            //         fontWeight: FontWeight.w400,
                            //         fontFamily: "Inter",
                            //         color: Color.fromRGBO(71, 84, 103, 1))),
                            const SizedBox(height: 20),
                            Text(Strings.pleaseRetry,
                                style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                    fontFamily: "Inter",
                                    color: Color.fromRGBO(71, 84, 103, 1))),
                            const SizedBox(height: 24),
                            // ElevatedButton(
                            //     style: ElevatedButton.styleFrom(
                            //         padding: const EdgeInsets.symmetric(
                            //             vertical: 10, horizontal: 16)),
                            //     onPressed: () {},
                            //     child: Row(
                            //       mainAxisSize: MainAxisSize.min,
                            //       mainAxisAlignment:
                            //           MainAxisAlignment.spaceBetween,
                            //       children: [
                            //         SvgPicture.asset("assets/Buttons/plus.svg",
                            //             colorFilter: const ColorFilter.mode(
                            //                 Colors.white, BlendMode.srcIn)),
                            //         const SizedBox(width: 6),
                            //         Text(Strings.createChat,
                            //             style: const TextStyle(
                            //                 color: Colors.white,
                            //                 fontSize: 16,
                            //                 fontFamily: "Inter",
                            //                 fontWeight: FontWeight.w600))
                            //       ],
                            //     ))
                          ],
                        ),
                      );
                    }

                    return ListView.separated(
                      itemCount:

                          /// We're using the channels length when there are no more
                          /// pages to load and there are no errors with pagination.
                          /// In case we need to show a loading indicator or and error
                          /// tile we're increasing the count by 1.
                          snapshot.data?.length ?? 0,
                      separatorBuilder: (context, index) => const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: SizedBox(),
                      ),
                      itemBuilder: (context, index) {
                        final conversation = snapshot.data![index];

                        if (index == 0) {
                          return Column(children: [
                            ListTile(
                                leading: const CircleAvatar(
                                  backgroundColor: Colors.purple,
                                  radius: 25,
                                  child: ClipOval(
                                    child: Icon(Icons.star_border_outlined,
                                        size: 20),
                                  ),
                                ),
                                title: Text(Strings.favourite,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyLarge
                                        ?.copyWith(
                                            fontWeight: FontWeight.bold)),
                                subtitle: Text(
                                  Strings.welcomeToMyFavourites,
                                  // style: Theme.of(context)
                                  //     .textTheme
                                  //     .bodyMedium
                                  //     ?.copyWith(
                                  //       fontWeight:
                                  //           channel.state?.unreadCount != 0
                                  //               ? FontWeight.bold
                                  //               : FontWeight.normal,
                                  //     ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      color:
                                          Color.fromARGB(255, 116, 116, 116)),
                                ),
                                visualDensity: const VisualDensity(
                                    vertical: -4, horizontal: 0),
                                onTap: () {
                                  Navigator.pushNamed(
                                      context, AppPage.favoriteList.routeName);
                                }),
                            // const SizedBox(height: 15),
                            conversationItem(conversation)
                          ]);
                        }

                        return conversationItem(conversation);
                      },
                    );
                  }
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                })
            //     child: PagedValueListenableBuilder<int, Channel>(
            //   valueListenable: channelListController,
            //   builder: (context, value, child) {
            //     return value.when((channels, nextPage, error) {
            //       if (channels.isEmpty) {
            //         return Align(
            //           alignment: Alignment.center,
            //           child: Column(
            //             mainAxisSize: MainAxisSize.min,
            //             crossAxisAlignment: CrossAxisAlignment.center,
            //             children: [
            //               Image.asset("assets/Illustration.png"),
            //               const SizedBox(height: 16),
            //               const Text("未找到聊天记录",
            //                   style: TextStyle(
            //                       fontSize: 16,
            //                       fontWeight: FontWeight.w600,
            //                       fontFamily: "Inter",
            //                       color: Color.fromRGBO(16, 24, 40, 1))),
            //               const SizedBox(height: 10),
            //               const Text("您的搜索“聊天记录”未匹配任何项目。",
            //                   style: TextStyle(
            //                       fontSize: 14,
            //                       fontWeight: FontWeight.w400,
            //                       fontFamily: "Inter",
            //                       color: Color.fromRGBO(71, 84, 103, 1))),
            //               const SizedBox(height: 20),
            //               const Text("请重试。",
            //                   style: TextStyle(
            //                       fontSize: 14,
            //                       fontWeight: FontWeight.w400,
            //                       fontFamily: "Inter",
            //                       color: Color.fromRGBO(71, 84, 103, 1))),
            //               const SizedBox(height: 24),
            //               ElevatedButton(
            //                   style: ElevatedButton.styleFrom(
            //                       padding: const EdgeInsets.symmetric(
            //                           vertical: 10, horizontal: 16)),
            //                   onPressed: () {},
            //                   child: Row(
            //                     mainAxisSize: MainAxisSize.min,
            //                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //                     children: [
            //                       SvgPicture.asset("assets/Buttons/plus.svg",
            //                           colorFilter: const ColorFilter.mode(
            //                               Colors.white, BlendMode.srcIn)),
            //                       const SizedBox(width: 6),
            //                       Text(Strings.createChat,
            //                           style: const TextStyle(
            //                               color: Colors.white,
            //                               fontSize: 16,
            //                               fontFamily: "Inter",
            //                               fontWeight: FontWeight.w600))
            //                     ],
            //                   ))
            //             ],
            //           ),
            //         );
            //       }

            //       return LazyLoadScrollView(
            //         onEndOfPage: () async {
            //           if (nextPage != null) {
            //             channelListController.loadMore(nextPage);
            //           }
            //         },
            //         child: ListView.separated(
            //           itemCount:

            //               /// We're using the channels length when there are no more
            //               /// pages to load and there are no errors with pagination.
            //               /// In case we need to show a loading indicator or and error
            //               /// tile we're increasing the count by 1.
            //               (nextPage != null || error != null)
            //                   ? channels.length + 1
            //                   : channels.length,
            //           separatorBuilder: (context, index) => const Padding(
            //             padding: EdgeInsets.all(8.0),
            //             child: Divider(),
            //           ),
            //           itemBuilder: (context, index) {
            //             final channel = channels[index];
            //             return Slidable(
            //               endActionPane:
            //                   ActionPane(motion: const DrawerMotion(), children: [
            //                 SlidableAction(
            //                     onPressed: (context) {
            //                       channel.hide(clearHistory: true);
            //                     },
            //                     backgroundColor: Colors.red,
            //                     foregroundColor: Colors.white,
            //                     icon: Icons.delete,
            //                     label: Strings.delete)
            //               ]),
            //               child: ListTile(
            //                 leading: Stack(children: [
            //                   CircleAvatar(
            //                     radius: 30,
            //                     child: ClipOval(
            //                       child: Image.network(
            //                         channel.memberCount! < 2
            //                             ? "https://picsum.photos/200"
            //                             : channel.memberCount! <= 2 &&
            //                                     !channel.id
            //                                         .toString()
            //                                         .contains("group")
            //                                 ? channel.state!.members
            //                                     .singleWhere(
            //                                       (member) =>
            //                                           member.userId !=
            //                                           channel.state?.currentUserMember
            //                                               ?.userId,
            //                                     )
            //                                     .user!
            //                                     .image
            //                                     .toString()
            //                                 : "https://picsum.photos/200",
            //                         errorBuilder: (context, error, stackTrace) =>
            //                             Text(channel.memberCount! < 2
            //                                 ? "https://picsum.photos/200"
            //                                 : channel.memberCount! <= 2 &&
            //                                         !channel.id
            //                                             .toString()
            //                                             .contains("group")
            //                                     ? channel.state!.members
            //                                         .singleWhere((member) =>
            //                                             member.userId !=
            //                                             channel
            //                                                 .state
            //                                                 ?.currentUserMember
            //                                                 ?.userId)
            //                                         .user!
            //                                         .name[0]
            //                                     : channel.name![0]),
            //                         fit: BoxFit.cover,
            //                       ),
            //                     ),
            //                   ),
            //                   if (channel.memberCount! == 2 &&
            //                       channel.state!.members
            //                           .singleWhere((member) =>
            //                               member.userId !=
            //                               channel.state?.currentUserMember?.userId)
            //                           .user!
            //                           .online)
            //                     Positioned(
            //                       bottom: 5,
            //                       right: 10,
            //                       child: Container(
            //                         width: 10,
            //                         height: 10,
            //                         decoration: const BoxDecoration(
            //                             shape: BoxShape.circle, color: Colors.green),
            //                       ),
            //                     ),
            //                 ]),
            //                 title: Text(
            //                   channel.memberCount! < 2
            //                       ? "Deleted User"
            //                       : channel.memberCount! <= 2 &&
            //                               !channel.id.toString().contains("group")
            //                           ? channel.state!.members
            //                               .singleWhere((member) =>
            //                                   member.userId !=
            //                                   channel
            //                                       .state?.currentUserMember?.userId)
            //                               .user!
            //                               .name // receiver name
            //                               .toString()
            //                           : channel.name.toString(),
            //                   maxLines: 1,
            //                   style: Theme.of(context)
            //                       .textTheme
            //                       .bodyLarge
            //                       ?.copyWith(fontWeight: FontWeight.bold),
            //                 ),
            //                 subtitle: StreamBuilder(
            //                   stream: channel.state?.lastMessageStream,
            //                   builder: (context, snapshot) {
            //                     if (snapshot.hasData) {
            //                       return Text(
            //                         snapshot.data?.text.toString() ?? "",
            //                         style: Theme.of(context)
            //                             .textTheme
            //                             .bodyMedium
            //                             ?.copyWith(
            //                               fontWeight: channel.state?.unreadCount != 0
            //                                   ? FontWeight.bold
            //                                   : FontWeight.normal,
            //                             ),
            //                         maxLines: 1,
            //                         overflow: TextOverflow.ellipsis,
            //                       );
            //                     }
            //                     return const SizedBox();
            //                   },
            //                 ),
            //                 visualDensity: const VisualDensity(vertical: -4),
            //                 trailing: Column(
            //                   mainAxisAlignment: channel.state!.unreadCount > 0
            //                       ? MainAxisAlignment.spaceEvenly
            //                       : MainAxisAlignment.start,
            //                   crossAxisAlignment: CrossAxisAlignment.end,
            //                   children: [
            //                     Text(channel.lastMessageAt == null
            //                         ? ""
            //                         : DateUtils.isSameDay(
            //                                 channel.lastMessageAt, DateTime.now())
            //                             ? DateFormat("HH:mm")
            //                                 .format(channel.lastMessageAt!)
            //                             : DateTime.now()
            //                                         .difference(
            //                                             channel.lastMessageAt!)
            //                                         .inDays ==
            //                                     1
            //                                 ? "Yesterday"
            //                                 : DateFormat('MMM d', 'en_US')
            //                                     .format(channel.lastMessageAt!)),
            //                     if (channel.state?.unreadCount != 0)
            //                       StreamBuilder(
            //                         stream: channel.state?.unreadCountStream,
            //                         builder: (context, snapshot) {
            //                           if (snapshot.hasData) {
            //                             return Container(
            //                                 padding: const EdgeInsets.symmetric(
            //                                     horizontal: 15.0, vertical: 2),
            //                                 decoration: BoxDecoration(
            //                                     borderRadius:
            //                                         BorderRadius.circular(20.0),
            //                                     color:
            //                                         AppColor.chatSenderBubbleColor),
            //                                 child: Text(
            //                                   channel.state?.unreadCount.toString() ??
            //                                       "",
            //                                   style: Theme.of(context)
            //                                       .textTheme
            //                                       .bodySmall
            //                                       ?.copyWith(color: Colors.white),
            //                                 ));
            //                           }
            //                           return const SizedBox();
            //                         },
            //                       )
            //                   ],
            //                 ),
            //                 onTap: () {
            //                   /// Display a list of messages when the user taps on
            //                   /// an item. We can use [StreamChannel] to wrap our
            //                   /// [MessageScreen] screen with the selected channel.
            //                   ///
            //                   /// This allows us to use a built-in inherited widget
            //                   /// for accessing our `channel` later on.
            //                   Navigator.of(context).push(
            //                     MaterialPageRoute(
            //                       builder: (context) => StreamChannel(
            //                         channel: channel,
            //                         child: const MessageScreen(),
            //                       ),
            //                     ),
            //                   );
            //                 },
            //               ),
            //             );
            //           },
            //         ),
            //       );
            //     },
            //         loading: () => const Center(
            //               child: CircularProgressIndicator(),
            //             ),
            //         error: (e) => Center(
            //               child: Text("Something went wrong : $e"),
            //             ));
            //   },
            // )
            ),
      ),
    );
  }
}
