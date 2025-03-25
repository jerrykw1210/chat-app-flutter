// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:math' as math;

//import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:file_picker/file_picker.dart';
import 'package:fixnum/fixnum.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_svg/svg.dart';
import 'package:no_screenshot/no_screenshot.dart';
import 'package:path_provider/path_provider.dart';
import 'package:protech_mobile_chat_stream/constants/string_constant.dart';
import 'package:protech_mobile_chat_stream/model/database.dart' as db;
import 'package:protech_mobile_chat_stream/model/database.dart';
import 'package:protech_mobile_chat_stream/module/chat/cubit/chat_cubit.dart';
import 'package:protech_mobile_chat_stream/module/chat/cubit/chat_trigger_cubit.dart';
import 'package:protech_mobile_chat_stream/module/chat/cubit/group_cubit.dart';
import 'package:protech_mobile_chat_stream/module/chat/cubit/sticker_cubit.dart';
import 'package:protech_mobile_chat_stream/module/chat/model/attachment_model.dart';
import 'package:protech_mobile_chat_stream/module/chat/screen/group_profile_screen.dart';
import 'package:protech_mobile_chat_stream/module/friend/cubit/user_cubit.dart';
import 'package:protech_mobile_chat_stream/module/search/screen/search_screen.dart';
import 'package:protech_mobile_chat_stream/module/webview/cubit/toggle_webview_cubit.dart';
import 'package:protech_mobile_chat_stream/route/routes.dart';
import 'package:protech_mobile_chat_stream/service/credential_service.dart';
import 'package:protech_mobile_chat_stream/service/database_helper.dart';
import 'package:protech_mobile_chat_stream/service/stream_service.dart';
import 'package:protech_mobile_chat_stream/service/turms_response.dart';
import 'package:protech_mobile_chat_stream/service/turms_service.dart';
import 'package:protech_mobile_chat_stream/utils/colors.dart';
import 'package:protech_mobile_chat_stream/utils/custom_message_manager.dart';
import 'package:protech_mobile_chat_stream/utils/helper.dart';
import 'package:protech_mobile_chat_stream/utils/service_locator.dart';
import 'package:protech_mobile_chat_stream/utils/string_apis.dart';
import 'package:protech_mobile_chat_stream/utils/toast_utils.dart';
import 'package:protech_mobile_chat_stream/widgets/attachment_preview.dart';
import 'package:protech_mobile_chat_stream/widgets/chat_avatar.dart';
import 'package:protech_mobile_chat_stream/widgets/chat_bubble.dart';
import 'package:image_picker/image_picker.dart';
import 'package:protech_mobile_chat_stream/widgets/player_widget.dart';
import 'package:protech_mobile_chat_stream/widgets/text_input_bar.dart';
import 'package:rxdart/rxdart.dart';

import 'package:sticky_grouped_list/sticky_grouped_list.dart';

import 'package:http/http.dart' show get;
import 'package:turms_client_dart/turms_client.dart' as turms;
import 'package:easy_localization/easy_localization.dart';
import 'package:volume_controller/volume_controller.dart';

/// A list of messages sent in the current channel.
/// When a user taps on a channel in [HomeScreen], a navigator push
/// [MessageScreen] to display the list of messages in the selected channel.
///
/// This is implemented using [MessageListCore], a convenience builder with
/// callbacks for building UIs based on different api results.
class MessageScreen extends StatefulWidget {
  /// Build a MessageScreen
  const MessageScreen(
      {super.key,
      this.conversation,
      this.isGroup = false,
      this.conversationSettings,
      this.searchedMessage});
  final db.Conversation? conversation;
  final bool isGroup;
  final turms.ConversationSettings? conversationSettings;
  final db.Message? searchedMessage;
  @override
  // ignore: library_private_types_in_public_api
  _MessageScreenState createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController messageInputController = TextEditingController();
  late final RecorderController recorderController;
  final GroupedItemScrollController itemScrollController =
      GroupedItemScrollController();
  late ScrollController _scrollController = ScrollController();
  FilePickerResult? filePickerResult;
  final ImagePicker _picker = ImagePicker();
  final GetStreamService _getStreamService = sl<GetStreamService>();
  bool firstLoad = true;
  late TabController emojiTabController;
  bool isRecording = false;
  bool isRecordingCompleted = false;
  String? path;
  TextEditingController searchGifController = TextEditingController();
  String? currentUserId;
  DateTime? filterDate;
  Stream<List<db.Message>>? messageStream;
  FocusNode focusNode = FocusNode();
  TurmsService turmsService = sl<TurmsService>();
  String? recordedAudioPath;
  NoScreenshot noScreenshot = NoScreenshot.instance;
  Stream<Conversation>? groupSettingsStream;
  bool isFriendDeleted = false;
  bool isKicked = false;
  int totalMessageCount = 0;
  final _compositeSubscription = CompositeSubscription();
  double currentVolume = 0.0;
  VolumeController volumeController = VolumeController();

  @override
  void initState() {
    super.initState();
    _checkRelationshipStatus();
    _scrollController = ScrollController();
    volumeController.showSystemUI = false;

    _initialiseControllers();
    emojiTabController = TabController(length: 3, vsync: this);
    // _updateList();

    if (widget.isGroup &&
        context.read<GroupCubit>().state.getGroupMemberStatus ==
            GetGroupMemberStatus.initial) {
      context.read<GroupCubit>().getGroupMember(
          groupId: widget.conversation?.targetId?.parseInt64() ?? Int64(0));
      context.read<GroupCubit>().getGroupInfo(
          widget.conversation?.targetId?.parseInt64() ?? Int64(0));
    }
    // if (widget.isGroup) {
    //   if (!checkPermission("CAN_MEMBERS_LIST_MESSAGE_HISTORY")) {
    //     log("I cannot see past history");
    //     getFilteredMessagesStream();
    //     // context.read<ChatCubit>().queryMessages(
    //     //     targetId: conversationId,
    //     //     areGroupMessage: widget.isGroup,
    //     //     groupId: widget.isGroup ? conversationId : null);
    //   } else {
    //     log("I can see past history");
    //     messageStream = sl<DatabaseHelper>()
    //         .getMessagesByConversation(widget.conversation?.id ?? "");
    //   }
    // } else {
    //   messageStream = sl<DatabaseHelper>()
    //       .getMessagesByConversation(widget.conversation?.id ?? "");
    // }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      //updateReadStatus();
      context.read<ChatCubit>().saveAttachment(context);
      //context.read<ChatCubit>().savePinnedMessages(context);
      // sl<DatabaseHelper>()
      //     .getMessagesByConversation(widget.conversation?.id ?? "")
      //     .listen((event) {
      //   if (mounted) {
      //     _updateList(event.length - 1);
      //   }
      // });

      if (!widget.isGroup) {
        context
            .read<UserCubit>()
            .fetchUserOnlineStatus(userId: widget.conversation?.targetId ?? "");
        context
            .read<UserCubit>()
            .fetchUserProfile(userId: widget.conversation?.targetId ?? "");
      }

      _compositeSubscription.add(sl<DatabaseHelper>()
          .getMessagesCount(widget.conversation?.id ?? "")
          .listen((data) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (data > 0) {
            if (totalMessageCount != data) {
              log("total messages count: $data");
              _updateList(data - 1,
                  isInitial: context.read<ChatTriggerCubit>().state.isFirstLoad,
                  searchedMessage: widget.searchedMessage);
              if (mounted) {
                setState(() {
                  totalMessageCount = data;
                });
              }
            }
          }
        });
      }));

      _compositeSubscription.add(sl<DatabaseHelper>()
          .getMessagesByConversation(widget.conversation?.id ?? "")
          .listen((data) {
        setState(() {});
      }));

      // if (widget.isGroup) {
      //   getMyJoinedDateIfGroup();
      // }
    });

    focusNode.addListener(() {
      if (focusNode.hasFocus) {
        if (context.read<ChatTriggerCubit>().state.showEmoji) {
          context.read<ChatTriggerCubit>().toggleEmoji();
        }
        context.read<ChatTriggerCubit>().toggleExpandTextFieldBar(true);
      }
    });

    currentUserId = sl<CredentialService>().turmsId;
  }

  Future<void> _checkRelationshipStatus() async {
    try {
      if (widget.isGroup) {
        try {
          await sl<turms.TurmsClient>().groupService.queryGroupMembers(
                widget.conversation?.targetId?.parseInt64() ?? Int64(0),
              );
        } catch (e) {
          if ((e as turms.ResponseException).code == 3421) {
            // only group members can query group member
            setState(() {
              isKicked = true;
            });
            return;
          }
        }
      } else {
        final friendRes =
            await sl<turms.TurmsClient>().userService.queryFriends();
        if (friendRes.code == 1000 &&
            friendRes.data!.userRelationships.isNotEmpty) {
          if (friendRes.data!.userRelationships.every((relationship) =>
              relationship.relatedUserId !=
              widget.conversation?.targetId!.parseInt64())) {
            // CustomMessageManager.showConnectionStatus(
            //     message: "Cannot send message to deleted friend");
            setState(() {
              isFriendDeleted = true;
            });
          }
        } else if (friendRes.code == 1001) {
          setState(() {
            isFriendDeleted = true;
          });
        }
      }

      // bool isDeleted = await sl<DatabaseHelper>()
      //     .getSingleRelationship(
      //         widget.conversation?.id.replaceFirst("c_", "r_") ?? "")
      //     .then((relationship) {
      //   if (relationship.status == "deleted" ||
      //       relationship.status == "pending") {
      //     return true;
      //   }
      //   return false;
      // });
    } catch (e) {
      log('Error fetching relationship status: $e');
    }
  }

  void updateReadStatus() async {
    int unReadCount = await sl<DatabaseHelper>()
        .getUnreadCount(widget.conversation!.id, DateTime.now());

    if (unReadCount > 0) {
      final updateReadStatusRes =
          await turmsService.handleTurmsResponse(() async {
        if (widget.conversation!.isGroup) {
          await sl<turms.TurmsClient>()
              .conversationService
              .updateGroupConversationReadDate(
                  widget.conversation!.targetId!.parseInt64());
        } else {
          await sl<turms.TurmsClient>()
              .conversationService
              .updatePrivateConversationReadDate(
                  widget.conversation!.targetId!.parseInt64());
        }
      });

      log("update read status : $updateReadStatusRes");

      await sl<DatabaseHelper>()
          .updateReadStatus(widget.conversation!.id, DateTime.now());
    }
  }

  void getFilteredMessagesStream() async {
    List<turms.GroupMember> groupMembers =
        context.read<GroupCubit>().state.groupMemberList;

    final groupMemberRes = await turmsService
        .handleTurmsResponse<List<turms.GroupMember>?>(() async {
      widget.conversation?.targetId?.parseInt64() ?? Int64(0);

      final res = await sl<turms.TurmsClient>().groupService.queryGroupMembers(
          widget.conversation?.targetId?.parseInt64() ?? Int64(0));

      return res.data?.groupMembers;
    });

    if (groupMemberRes is TurmsMapSuccessResponse<List<turms.GroupMember>?>) {
      log("group member list ${groupMemberRes.res}");
      groupMembers = groupMemberRes.res ?? [];
    }

    if (groupMembers.isNotEmpty) {
      for (turms.GroupMember groupMember in groupMembers) {
        if (groupMember.userId.toString() == sl<CredentialService>().turmsId) {
          // messageStream = sl<DatabaseHelper>().getMessagesByConversation(
          //     widget.conversation?.id ?? "",
          //     filteredDateTime: DateTime.fromMillisecondsSinceEpoch(
          //         groupMember.joinDate.toInt()));
          log("join date ${DateTime.fromMillisecondsSinceEpoch(groupMember.joinDate.toInt())}");
          messageStream?.listen((data) {
            log("message stream $data");
          });
          return;
        }
      }
    }
  }

  @override
  void dispose() {
    messageInputController.dispose();
    recorderController.dispose();
    _compositeSubscription.cancel();
    //_scrollController.dispose();
    noScreenshot.screenshotOn();
    super.dispose();
  }

  void _initialiseControllers() {
    recorderController = RecorderController()
      ..androidEncoder = AndroidEncoder.aac
      ..androidOutputFormat = AndroidOutputFormat.mpeg4
      ..iosEncoder = IosEncoder.kAudioFormatMPEG4AAC
      ..sampleRate = 44100;
  }

  void _updateList(int index,
      {bool isInitial = true, db.Message? searchedMessage}) {
    if (itemScrollController.isAttached) {
      try {
        if (searchedMessage != null) {
          log("searched message ${searchedMessage.messageId}");
          itemScrollController.scrollToElement(
              identifier: searchedMessage.messageId,
              duration: Durations.short4);
        } else {
          if (isInitial) {
            itemScrollController.jumpTo(
              index: index,
            );
          } else {
            itemScrollController.scrollTo(
              index: index,
              duration: Durations.short4,
            );
          }
        }

        // itemScrollController.animateTo(
        //   itemScrollController..maxScrollExtent,
        //   duration: const Duration(milliseconds: 200),
        //   curve: Curves.easeInOut,
        // );
      } catch (e) {
        print('error on scroll $e');
      }
    }
  }

  bool checkPermission(String settingsKey,
      {bool reverseBool = false,
      bool? customOutputWhenOwnerIdEqualsUserId,
      turms.ConversationSettings? groupSettings}) {
    final settings = groupSettings ?? widget.conversationSettings;
    final ownerId = widget.conversation?.ownerId;
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

  List<PopupMenuItem> popupMenuItem(BuildContext context) {
    List<PopupMenuItem> popupMenuItem = [
      PopupMenuItem(
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => SearchScreen(
                        conversationId: widget.conversation?.id,
                        isGroup: widget.isGroup)));
          },
          child: Row(
            children: [
              const Icon(
                Icons.group_add,
                color: Colors.black,
              ),
              const SizedBox(width: 5),
              Text(Strings.searchChat)
            ],
          )),

      // PopupMenuItem(
      //     onTap: () {
      //       Navigator.pushNamed(context, AppPage.qrScanner.routeName);
      //     },
      //     child: const Row(
      //       children: [
      //         Icon(Icons.qr_code, color: Colors.black),
      //         SizedBox(width: 5),
      //         Text("Scan QR Code")
      //       ],
      //     )),
    ];

    return popupMenuItem;
  }

  @override
  Widget build(BuildContext context) {
    /// To access the current channel, we can use the `.of()` method on
    /// [StreamChannel] to fetch the closest instance.
    //final channel = StreamChannel.of(context).channel;

    return Scaffold(
      backgroundColor: AppColor.chatBackgroundColor,
      appBar: AppBar(
        leading: BlocBuilder<ChatTriggerCubit, ChatTriggerState>(
          builder: (context, state) {
            return IconButton(
                onPressed: () async {
                  context.read<ChatTriggerCubit>().toggleSelect();
                  context.read<ChatTriggerCubit>().resetState();
                  context.read<ChatCubit>().resetSelectedMessageList();
                  context.read<GroupCubit>().reset();
                  context.read<GroupCubit>().resetGroupInfo(null);
                  context.read<GroupCubit>().resetGroupImageStatus();

                  if (context.read<ChatTriggerCubit>().state.showEmoji) {
                    context.read<ChatTriggerCubit>().toggleEmoji();
                  }
                  if (!state.isSelect) {
                    Navigator.pop(context);
                  }
                },
                icon: Icon(
                  state.isSelect ? Icons.close : Icons.arrow_back_ios,
                  color: Colors.white,
                ));
          },
        ),

        title: ListTile(
          leading: ChatAvatar(
              errorWidget: CircleAvatar(
                  backgroundColor: const Color.fromARGB(255, 6, 62, 141),
                  radius: 25,
                  child: BlocBuilder<GroupCubit, GroupState>(
                    builder: (context, state) {
                      return Image.file(
                        widget.isGroup
                            ? File(
                                "${Helper.directory?.path}/${state.groupProfileImage == "" ? widget.conversation?.avatar : state.groupProfileImage}")
                            : File(""),
                        errorBuilder: (context, error, stackTrace) => Text(
                          widget.conversation?.title.toString()[0] ?? "",
                        ),
                      );
                    },
                  )),
              targetId: widget.conversation?.targetId ?? "",
              isGroup: widget.conversation?.isGroup ?? false),
          contentPadding: EdgeInsets.zero,
          onTap: () {
            if (widget.isGroup) {
              if (context.read<GroupCubit>().state.getGroupMemberStatus ==
                  GetGroupMemberStatus.success) {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => StreamBuilder<Conversation>(
                      stream: sl<DatabaseHelper>()
                          .getGroupSettings(widget.conversation!.id),
                      builder: (context, snapshot) {
                        turms.ConversationSettings? settings;

                        if (snapshot.hasData) {
                          if (snapshot.data != null &&
                              snapshot.data!.settings != null) {
                            settings = turms.ConversationSettings.fromJson(
                                snapshot.data!.settings!);
                          }
                        }

                        log("have group settings if click on chat details? $settings ${widget.conversation}");

                        return GroupProfileScreen(
                          group: widget.conversation!,
                          conversationSettings:
                              settings ?? widget.conversationSettings,
                        );
                      }),
                ));
              }
            } else {
              // Map<String, dynamic> userAndChannel = {
              //   "user": receiver?.user,
              //   "channel": channel
              // };

              Navigator.of(context).pushNamed(AppPage.friendProfile.routeName,
                  arguments: widget.conversation?.id ?? "");
            }
          },
          title: BlocBuilder<UserCubit, UserState>(
            builder: (context, userState) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  BlocBuilder<GroupCubit, GroupState>(
                    builder: (context, groupstate) {
                      return Text(
                        widget.isGroup
                            ? groupstate.groupInfo?.name ??
                                widget.conversation?.title.toString() ??
                                ""
                            : widget.conversation?.title.toString() ?? "",
                        maxLines: 1,
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(color: Colors.white),
                      );
                    },
                  ),
                  Text(
                    widget.isGroup
                        ? ""
                        : userState.userOnlineStatus?.userStatus
                                .toString()
                                .toLowerCase()
                                .tr() ??
                            "",
                    maxLines: 1,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              );
            },
          ),
          // subtitle: snapshot.hasData && snapshot.data!.isNotEmpty
          //     ? Text(
          //         '${snapshot.data!.first.name} ${Strings.isTyping}',
          //         style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          //             color: Colors.white, fontStyle: FontStyle.italic),
          //       )
          //     : Text(
          //         channel.memberCount! > 2
          //             ? "${channel.memberCount} ${Strings.members}"
          //             : receiver?.user?.online ?? false
          //                 ? Strings.online
          //                 : DateUtils.isSameDay(receiver?.user!.lastActive,
          //                         DateTime.now())
          //                     ? "${Strings.lastSeenTodayAt} ${receiver?.user!.lastActive!.hour}:${receiver?.user!.lastActive!.minute}"
          //                     : receiver?.user!.lastActive == null
          //                         ? ""
          //                         : '${Strings.lastSeen} ${DateFormat("d MMMM yyyy").format(receiver!.user!.lastActive!)}',
          //         style: Theme.of(context)
          //             .textTheme
          //             .bodySmall
          //             ?.copyWith(color: Colors.white),
          //       )
        ),

        actions: [
          IconButton(
              onPressed: () {
                if ((isFriendDeleted && !widget.isGroup) ||
                    (widget.isGroup && isKicked)) {
                  CustomMessageManager.showConnectionStatus(
                      message: Strings.youHaveBeenKickedOut);
                  return;
                }
                // List<Member> memberList = channel.state!.members;

                try {
                  List<String> targetUserId = [];

                  String targetId = "";

                  List<dynamic> memberIdList =
                      jsonDecode(widget.conversation!.members);

                  for (String memberId in memberIdList) {
                    if (memberId.parseInt64() !=
                        sl<CredentialService>().turmsId!.parseInt64()) {
                      targetUserId.add(memberId);
                      targetId = memberId;
                    }
                  }

                  bool isgroup = memberIdList.length > 2;

                  if (isgroup) {
                    targetId = widget.conversation!.targetId!;
                  }

                  _getStreamService.initiateCall(
                      targetUserId: targetUserId,
                      video: false,
                      targetId: targetId,
                      isGroup: isgroup);
                } catch (e) {
                  log(e.toString());
                }
              },
              icon: const Icon(Icons.call)),
          IconButton(
              onPressed: () {
                if ((isFriendDeleted && !widget.isGroup) ||
                    (widget.isGroup && isKicked)) {
                  CustomMessageManager.showConnectionStatus(
                      message: Strings.youHaveBeenKickedOut);
                  return;
                }
                // List<Member> memberList = channel.state!.members;
                List<String> targetUserId = [];

                String targetId = "";

                List<dynamic> memberIdList =
                    jsonDecode(widget.conversation!.members);

                for (String memberId in memberIdList) {
                  if (memberId.parseInt64() !=
                      sl<CredentialService>().turmsId!.parseInt64()) {
                    targetUserId.add(memberId);
                    targetId = memberId;
                  }
                }

                bool isgroup = memberIdList.length > 2;

                if (isgroup) {
                  targetId = widget.conversation!.targetId!;
                }

                // String targetId = memberIdList.singleWhere((element) =>
                //     element != sl<CredentialService>().turmsId!.parseInt64());

                _getStreamService.initiateCall(
                    targetUserId: targetUserId,
                    targetId: targetId,
                    isGroup: isgroup);
              },
              icon: const Icon(Icons.videocam)),
          PopupMenuButton(
            padding: const EdgeInsets.only(left: 5, right: 16),
            icon: const Icon(Icons.more_vert, color: Colors.white),
            itemBuilder: (context) {
              return popupMenuItem(context);
            },
          )
        ],
        titleSpacing: 0,
        toolbarHeight: 80,
        // title:
        //     // typing indicator
        //     StreamBuilder<Iterable<User>>(
        //   initialData: channel.state?.typingEvents.keys,
        //   stream: channel.state?.typingEventsStream.map((it) => it.keys),
        //   builder: (context, snapshot) {
        //     Member? receiver;
        //     if (channel.memberCount! == 2) {
        //       receiver = channel.state!.members.singleWhere((user) =>
        //           user.userId != StreamChatCore.of(context).currentUser?.id);
        //     }
        //     if (channel.memberCount == 1) {
        //       return ListTile(
        //         leading: CircleAvatar(
        //           child: Image.asset("assets/default-img/default-user.png"),
        //         ),
        //         title: const Text("Deleted User"),
        //       );
        //     }
        //     return ListTile(
        //         leading: CircleAvatar(
        //           backgroundColor: const Color.fromARGB(255, 6, 62, 141),
        //           radius: 25,
        //           child: Image.network(
        //               channel.memberCount! <= 2 &&
        //                       !channel.id.toString().contains("group")
        //                   ? receiver?.user?.image ?? ""
        //                   : "https://picsum.photos/200",
        //               errorBuilder: (context, error, stackTrace) => Text(
        //                   channel.state!.members
        //                       .singleWhere((member) =>
        //                           member.userId !=
        //                           channel.state?.currentUserMember?.userId)
        //                       .user!
        //                       .name[0])),
        //         ),
        //         contentPadding: EdgeInsets.zero,
        //         onTap: () {
        //           if (channel.memberCount! > 2) {
        //             Navigator.of(context).pushNamed(
        //                 AppPage.groupProfile.routeName,
        //                 arguments: channel);
        //           } else {
        //             Map<String, dynamic> userAndChannel = {
        //               "user": receiver?.user,
        //               "channel": channel
        //             };

        //             Navigator.of(context).pushNamed(
        //                 AppPage.friendProfile.routeName,
        //                 arguments: userAndChannel);
        //           }
        //         },
        //         title: Text(
        //           channel.memberCount! > 2
        //               ? channel.name.toString()
        //               : receiver?.user?.name.toString() ?? "",
        //           maxLines: 1,
        //           style: Theme.of(context)
        //               .textTheme
        //               .titleMedium
        //               ?.copyWith(color: Colors.white),
        //         ),
        //         subtitle: snapshot.hasData && snapshot.data!.isNotEmpty
        //             ? Text(
        //                 '${snapshot.data!.first.name} ${Strings.isTyping}',
        //                 style: Theme.of(context)
        //                     .textTheme
        //                     .bodyMedium
        //                     ?.copyWith(
        //                         color: Colors.white,
        //                         fontStyle: FontStyle.italic),
        //               )
        //             : Text(
        //                 channel.memberCount! > 2
        //                     ? "${channel.memberCount} ${Strings.members}"
        //                     : receiver?.user?.online ?? false
        //                         ? Strings.online
        //                         : DateUtils.isSameDay(
        //                                 receiver?.user!.lastActive,
        //                                 DateTime.now())
        //                             ? "${Strings.lastSeenTodayAt} ${receiver?.user!.lastActive!.hour}:${receiver?.user!.lastActive!.minute}"
        //                             : receiver?.user!.lastActive == null
        //                                 ? ""
        //                                 : '${Strings.lastSeen} ${DateFormat("d MMMM yyyy").format(receiver!.user!.lastActive!)}',
        //                 style: Theme.of(context)
        //                     .textTheme
        //                     .bodySmall
        //                     ?.copyWith(color: Colors.white),
        //               ));
        //   },
        // ),
        // TODO: add lazy load
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () {
                  FocusManager.instance.primaryFocus?.unfocus();
                  if (context.read<ChatTriggerCubit>().state.showEmoji) {
                    context.read<ChatTriggerCubit>().toggleEmoji();
                  }
                  context
                      .read<ChatTriggerCubit>()
                      .toggleExpandTextFieldBar(true);
                },
                child: StreamBuilder(
                    stream: sl<DatabaseHelper>().getMessagesByConversation(
                        widget.conversation?.id ?? ""),
                    builder: (context, snapshot) {
                      // log("message stream ${snapshot.data}");
                      updateReadStatus();
                      if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                        List<db.Message> messages =
                            snapshot.data as List<db.Message>;
                        // WidgetsBinding.instance.addPostFrameCallback((_) {
                        //   _updateList(messages.indexOf(messages.last) - 1,
                        //       isInitial: context
                        //           .read<ChatTriggerCubit>()
                        //           .state
                        //           .isFirstLoad,
                        //       searchedMessage: widget.searchedMessage);
                        // });
                        return BlocBuilder<ChatCubit, ChatState>(
                          builder: (context, state) {
                            return CustomScrollView(
                              cacheExtent: 99999,
                              slivers: [
                                if (state.querySearchStatus ==
                                    QuerySearchStatus.success)
                                  SliverPersistentHeader(
                                      delegate: SearchedResultViewDelegate()),
                                SliverFillRemaining(
                                  child: StickyGroupedListView<db.Message,
                                      DateTime>(
                                    // initialScrollIndex: messages.length - 1,
                                    elements: messages,
                                    stickyHeaderBackgroundColor:
                                        Colors.transparent,
                                    groupBy: (db.Message message) => DateTime(
                                      message.sentAt.year,
                                      message.sentAt.month,
                                      message.sentAt.day,
                                    ),
                                    itemScrollController: itemScrollController,
                                    elementIdentifier: (element) =>
                                        element.messageId,
                                    itemComparator: (element1, element2) =>
                                        element1.sentAt
                                            .compareTo(element2.sentAt),

                                    groupSeparatorBuilder: (db.Message value) =>
                                        SizedBox(
                                      height: 50,
                                      child: Align(
                                        alignment: Alignment.topCenter,
                                        child: Container(
                                          padding: const EdgeInsets.all(8.0),
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(8.0),
                                            color: AppColor.chatBackgroundColor,
                                          ),
                                          margin: const EdgeInsets.all(8.0),
                                          child: Text(
                                            DateUtils.isSameDay(value.sentAt,
                                                    DateTime.now())
                                                ? Strings.today
                                                : DateTime(
                                                            value.sentAt.year,
                                                            value.sentAt.month,
                                                            value.sentAt.day) ==
                                                        DateTime(
                                                          DateTime.now().year,
                                                          DateTime.now().month,
                                                          DateTime.now().day -
                                                              1,
                                                        )
                                                    ? Strings.yesterday
                                                    : DateFormat("d MMMM yyyy")
                                                        .format(value.sentAt),
                                            textAlign: TextAlign.center,
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleSmall
                                                ?.copyWith(
                                                    color: AppColor.greyText),
                                          ),
                                        ),
                                      ),
                                    ),
                                    itemBuilder: (
                                      context,
                                      currentMessage,
                                    ) {
                                      bool displayAvatar = true;

                                      return BlocBuilder<ChatTriggerCubit,
                                          ChatTriggerState>(
                                        builder: (context, state) {
                                          // log("message bubble ${currentMessage.type}");
                                          if (state.isFirstLoad) {
                                            // checkAndCombineAttachmentIntoSameMessage(
                                            //     previousMessage,
                                            //     currentMessage,
                                            //     client,
                                            //     state);
                                          }
                                          // if ((currentMessage.senderId ==
                                          //             previousMessage
                                          //                 ?.senderId &&
                                          //         (currentMessage.senderId !=
                                          //                 currentUserId ||
                                          //             previousMessage
                                          //                     ?.senderId !=
                                          //                 currentUserId)) ||
                                          //     !widget.isGroup) {
                                          //   displayAvatar = false;
                                          // }

                                          return ChatBubbleTurms(
                                            currentMessage: currentMessage,
                                            displayAvatar: displayAvatar,
                                            isGroup: widget.isGroup,
                                            conversation: widget.conversation,
                                            itemScrollController:
                                                itemScrollController,
                                            conversationSettings:
                                                widget.conversationSettings,
                                            messageList: messages,
                                          );
                                          // ChatBubble(
                                          //   previousMessage: previousMessage,
                                          //   currentMessage: currentMessage,
                                          //   messageList: messages,
                                          //   channel: channel,
                                          //   displayAvatar: displayAvatar,
                                          //   imageList: imagesList,
                                          //   scrollController:
                                          //       _scrollController,
                                          // );
                                        },
                                      );
                                    },
                                  ),
                                ),
                              ],
                            );
                          },
                        );
                      }
                      return Center(
                        child: Text(Strings.nothingHereYet),
                      );
                    }),
              ),
            ),
            StreamBuilder(
                stream: sl<DatabaseHelper>().fetchRelationship(widget
                        .conversation?.id
                        .toString()
                        .replaceFirst("c_", "r_") ??
                    "0"),
                builder: (context, snapshot) {
                  if (snapshot.hasData && !widget.isGroup) {
                    log("relationship snapshot ${snapshot.data}");
                    if (snapshot.data?.status == "deleted" ||
                        snapshot.data?.status == "pending") {
                      return Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Text(Strings.cantSendToDeletedFriend),
                      );
                    }
                  }
                  return BlocBuilder<ChatTriggerCubit, ChatTriggerState>(
                    builder: (context, state) {
                      return widget.isGroup &&
                              checkPermission("CAN_MEMBERS_BE_MUTE",
                                  customOutputWhenOwnerIdEqualsUserId: false)
                          ? Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                Strings.onlyAdminAbleToSendMessage,
                                textAlign: TextAlign.center,
                              ),
                            )
                          : Column(
                              children: [
                                if (state.isReply || state.isEditing)
                                  editReplyPreview(state, context),
                                isRecording
                                    ? Row(
                                        mainAxisSize: MainAxisSize.max,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          const SizedBox(width: 10),
                                          IconButton(
                                            onPressed: () {
                                              setState(() {
                                                recordedAudioPath = null;
                                              });
                                              _startOrStopRecording(
                                                  reset: true);
                                            },
                                            icon: const Icon(
                                              Icons.close,
                                            ),
                                          ),
                                          Expanded(
                                            child: Container(
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(30),
                                                color: Theme.of(context)
                                                    .primaryColorLight,
                                              ),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 5),
                                              child: AudioWaveforms(
                                                enableGesture: false,
                                                size: Size(
                                                    MediaQuery.of(context)
                                                            .size
                                                            .width /
                                                        2,
                                                    50),
                                                recorderController:
                                                    recorderController,
                                                waveStyle: const WaveStyle(
                                                    waveColor: Colors.white,
                                                    extendWaveform: true,
                                                    scaleFactor: 15,
                                                    showMiddleLine: false,
                                                    waveThickness: 2,
                                                    spacing: 5),
                                                padding: const EdgeInsets.only(
                                                    left: 18,
                                                    top: 5,
                                                    bottom: 5),
                                                margin:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 15),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 5),
                                          IconButton(
                                            onPressed: _startOrStopRecording,
                                            icon: Icon(isRecording
                                                ? Icons.stop
                                                : Icons.mic),
                                          ),
                                          const SizedBox(width: 20)
                                        ],
                                      )
                                    : recordedAudioPath != null
                                        ? Row(
                                            mainAxisSize: MainAxisSize.max,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Flexible(
                                                flex: 1,
                                                child: IconButton(
                                                  onPressed: () {
                                                    setState(() {
                                                      recordedAudioPath = null;
                                                    });
                                                  },
                                                  icon: const Icon(
                                                    Icons.close,
                                                  ),
                                                ),
                                              ),
                                              Flexible(
                                                flex: 7,
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            30),
                                                    color: Theme.of(context)
                                                        .primaryColorLight,
                                                  ),
                                                  child: PlayerWidget(
                                                      isReceiver: false,
                                                      voiceSource:
                                                          recordedAudioPath!),
                                                ),
                                              ),
                                              Flexible(
                                                child: IconButton(
                                                  onPressed:
                                                      _startOrStopRecording,
                                                  padding:
                                                      const EdgeInsets.all(2),
                                                  constraints:
                                                      const BoxConstraints(),
                                                  icon: const Icon(
                                                    Icons.refresh,
                                                  ),
                                                ),
                                              ),
                                              Flexible(
                                                child: IconButton(
                                                  onPressed: () {
                                                    _sendRecording(
                                                        path:
                                                            recordedAudioPath ??
                                                                "");
                                                  },
                                                  padding:
                                                      const EdgeInsets.all(2),
                                                  constraints:
                                                      const BoxConstraints(),
                                                  icon: const Icon(Icons.send),
                                                ),
                                              ),
                                            ],
                                          )
                                        : state.isSelect
                                            ? const ForwardMessageWidget()
                                            : Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  if (state.recordingStatus ==
                                                      RecordingStatus.recording)
                                                    DragTarget(
                                                      builder: (context,
                                                          acceptData,
                                                          rejectedData) {
                                                        return InkWell(
                                                          child: Container(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(10.0),
                                                            // width: 50,
                                                            // height: 50,

                                                            child:
                                                                const IgnorePointer(
                                                              child: Icon(
                                                                Icons.delete,
                                                                color:
                                                                    Colors.red,
                                                              ),
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                      onAcceptWithDetails:
                                                          (details) {
                                                        //  stopStopwatch();

                                                        context
                                                            .read<
                                                                ChatTriggerCubit>()
                                                            .isRecording(false);
                                                      },
                                                    ),
                                                  IconButton(
                                                      onPressed: () {
                                                        context
                                                            .read<
                                                                ChatTriggerCubit>()
                                                            .toggleExpandTextFieldBar(
                                                                state
                                                                    .isExpandedTextField);
                                                        if (state.showEmoji) {
                                                          context
                                                              .read<
                                                                  ChatTriggerCubit>()
                                                              .toggleEmoji();
                                                        }
                                                        FocusScope.of(context)
                                                            .unfocus();
                                                      },
                                                      icon: SvgPicture.asset(
                                                        "assets/Buttons/attachment-more.svg",
                                                      )),
                                                  TextInputBar(
                                                    messageInputController:
                                                        messageInputController,
                                                    focusNode: focusNode,
                                                  ),
                                                  // audioButton(context),
                                                  IconButton(
                                                    onPressed:
                                                        _startOrStopRecording,
                                                    icon: Icon(isRecording
                                                        ? Icons.stop
                                                        : Icons.mic),
                                                  ),
                                                  IconButton(
                                                      onPressed: () async {
                                                        XFile? pickedImage =
                                                            await ImagePicker()
                                                                .pickImage(
                                                          source: ImageSource
                                                              .camera,
                                                        );
                                                        if (pickedImage !=
                                                            null) {
                                                          Navigator.push(
                                                              context,
                                                              PageRouteBuilder(
                                                                pageBuilder: (context,
                                                                        animation1,
                                                                        animation2) =>
                                                                    AttachmentPreviewWidget(
                                                                  image: [
                                                                    pickedImage
                                                                  ],
                                                                  fileType:
                                                                      "image",
                                                                  conversation:
                                                                      widget
                                                                          .conversation!,
                                                                ),
                                                              ));
                                                        }
                                                      },
                                                      icon: SvgPicture.asset(
                                                        "assets/Buttons/camera.svg",
                                                      )),
                                                  GestureDetector(
                                                      onTap: () {
                                                        sendMessage(
                                                            context, state);
                                                      },
                                                      child: Container(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(8.0),
                                                          child: const Icon(
                                                              Icons.send))),
                                                ],
                                              ),
                                AnimatedPadding(
                                  duration: Durations.short2,
                                  curve: Curves.easeIn,
                                  padding: EdgeInsets.only(
                                      left: 10,
                                      right: 10,
                                      top: 5,
                                      bottom:
                                          state.isExpandedTextField ? 50 : 0),
                                  child: Visibility(
                                    visible: state.isExpandedTextField,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        if (!widget.isGroup ||
                                            checkPermission(
                                                'CAN_MEMBERS_SEND_PICTURES'))
                                          Column(
                                            children: [
                                              Container(
                                                  decoration: BoxDecoration(
                                                      color: Colors.deepOrange,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10.0)),
                                                  child: IconButton(
                                                      onPressed: () async {
                                                        final image = await _picker
                                                            .pickImage(
                                                                source:
                                                                    ImageSource
                                                                        .gallery);
                                                        if (image != null) {
                                                          log("selected image name ${image.name} ${image.path}");
                                                          // Get the file size in bytes
                                                          int fileSizeInBytes =
                                                              await image
                                                                  .length();

                                                          // Define 30 MB in bytes
                                                          const int
                                                              maxSizeInBytes =
                                                              30 * 1024 * 1024;

                                                          // Check if the file size exceeds 5 MB
                                                          if (fileSizeInBytes >
                                                              maxSizeInBytes) {
                                                            ToastUtils.showToast(
                                                                context:
                                                                    context,
                                                                msg: Strings
                                                                    .fileSizeExceed30MB,
                                                                type: Type
                                                                    .warning);
                                                            return;
                                                          }

                                                          Navigator.push(
                                                              context,
                                                              PageRouteBuilder(
                                                                pageBuilder: (context,
                                                                        animation1,
                                                                        animation2) =>
                                                                    AttachmentPreviewWidget(
                                                                  image: [
                                                                    image
                                                                  ],
                                                                  fileType:
                                                                      "image",
                                                                  conversation:
                                                                      widget
                                                                          .conversation!,
                                                                ),
                                                              ));
                                                        }
                                                      },
                                                      icon: const Icon(
                                                        Icons.photo,
                                                        color: Colors.white,
                                                      ))),
                                              Text(Strings.photo)
                                            ],
                                          ),
                                        if (!widget.isGroup ||
                                            checkPermission(
                                                "CAN_MEMBERS_SEND_FILES"))
                                          Column(
                                            children: [
                                              Container(
                                                  decoration: BoxDecoration(
                                                      color: Colors.blueAccent,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10.0)),
                                                  child: IconButton(
                                                      onPressed: () async {
                                                        filePickerResult =
                                                            await FilePicker
                                                                .platform
                                                                .pickFiles(
                                                                    allowMultiple:
                                                                        false);
                                                        if (filePickerResult ==
                                                            null) {
                                                          debugPrint(
                                                              "No file selected");
                                                        } else {
                                                          log("file selected: ${filePickerResult?.files.single.xFile.path}");

                                                          if (Helper
                                                              .checkNotMediaFileType(
                                                                  filePickerResult!
                                                                      .files
                                                                      .single
                                                                      .xFile)) {
                                                            ToastUtils.showToast(
                                                                context:
                                                                    context,
                                                                msg: Strings
                                                                    .pleaseSelectValidFile,
                                                                type: Type
                                                                    .warning);
                                                            return;
                                                          }

                                                          int fileSizeInBytes =
                                                              await filePickerResult!
                                                                  .files
                                                                  .single
                                                                  .xFile
                                                                  .length();

                                                          // Define 5 MB in bytes
                                                          const int
                                                              maxSizeInBytes =
                                                              30 * 1024 * 1024;

                                                          // Check if the file size exceeds 5 MB
                                                          if (fileSizeInBytes >
                                                              maxSizeInBytes) {
                                                            ToastUtils.showToast(
                                                                context:
                                                                    context,
                                                                msg: Strings
                                                                    .fileSizeExceed30MB,
                                                                type: Type
                                                                    .warning);
                                                            return;
                                                          }

                                                          Navigator.push(
                                                              context,
                                                              PageRouteBuilder(
                                                                pageBuilder: (context,
                                                                        animation1,
                                                                        animation2) =>
                                                                    AttachmentPreviewWidget(
                                                                  image:
                                                                      filePickerResult!
                                                                          .xFiles,
                                                                  fileType:
                                                                      "file",
                                                                  conversation:
                                                                      widget
                                                                          .conversation!,
                                                                ),
                                                              ));
                                                        }
                                                      },
                                                      icon: SvgPicture.asset(
                                                        "assets/Buttons/file-shield-02.svg",
                                                      ))),
                                              Text(Strings.file)
                                            ],
                                          ),
                                        if (!widget.isGroup ||
                                            checkPermission(
                                                "CAN_MEMBERS_SEND_VIDEOS"))
                                          Column(
                                            children: [
                                              Container(
                                                  decoration: BoxDecoration(
                                                      color:
                                                          Colors.purpleAccent,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10.0)),
                                                  child: IconButton(
                                                      onPressed: () async {
                                                        final video = await _picker
                                                            .pickVideo(
                                                                source:
                                                                    ImageSource
                                                                        .gallery);
                                                        if (video == null) {
                                                          debugPrint(
                                                              "No file selected");
                                                        } else {
                                                          // int fileSizeInBytes =
                                                          //     await filePickerResult!
                                                          //         .files
                                                          //         .single
                                                          //         .xFile
                                                          //         .length();

                                                          int fileSizeInBytes =
                                                              await video
                                                                  .length();

                                                          // Define 30 MB in bytes
                                                          const int
                                                              maxSizeInBytes =
                                                              30 * 1024 * 1024;

                                                          // Check if the file size exceeds 30 MB
                                                          if (fileSizeInBytes >
                                                              maxSizeInBytes) {
                                                            ToastUtils.showToast(
                                                                context:
                                                                    context,
                                                                msg:
                                                                    "File size exceeds 30 MB",
                                                                type: Type
                                                                    .warning);
                                                            return;
                                                          }

                                                          Navigator.push(
                                                              context,
                                                              PageRouteBuilder(
                                                                pageBuilder: (context,
                                                                        animation1,
                                                                        animation2) =>
                                                                    AttachmentPreviewWidget(
                                                                  image: [
                                                                    video
                                                                  ],
                                                                  fileType:
                                                                      "video",
                                                                  conversation:
                                                                      widget
                                                                          .conversation!,
                                                                ),
                                                              ));
                                                        }
                                                      },
                                                      icon: const Icon(
                                                          Icons.videocam_sharp,
                                                          color:
                                                              Colors.white))),
                                              Text(Strings.video)
                                            ],
                                          ),
                                        if (!widget.isGroup ||
                                            checkPermission(
                                                "CAN_MEMBERS_SEND_CONTACT"))
                                          Column(
                                            children: [
                                              Container(
                                                  decoration: BoxDecoration(
                                                      color: Colors.red,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10.0)),
                                                  child: IconButton(
                                                      onPressed: () {
                                                        context
                                                            .read<ChatCubit>()
                                                            .sendNamecard(
                                                                widget.conversation!
                                                                        .targetId
                                                                        ?.parseInt64() ??
                                                                    Int64(0),
                                                                isGroup: widget
                                                                    .isGroup);
                                                        context
                                                            .read<
                                                                ChatTriggerCubit>()
                                                            .toggleExpandTextFieldBar(
                                                                true);

                                                        context
                                                            .read<
                                                                ToggleWebviewCubit>()
                                                            .setCurrentIndex(1);
                                                        Navigator.popUntil(
                                                            context,
                                                            ModalRoute.withName(
                                                                AppPage.navBar
                                                                    .routeName));
                                                        // Navigator.pushNamed(
                                                        //     context,
                                                        //     AppPage
                                                        //         .navBar.routeName,
                                                        //     arguments: 1);
                                                      },
                                                      icon: SvgPicture.asset(
                                                        "assets/Buttons/layout-alt-01.svg",
                                                      ))),
                                              Text(Strings.namecard)
                                            ],
                                          )
                                      ],
                                    ),
                                  ),
                                ),
                                if (state.showEmoji)
                                  Column(
                                    children: [
                                      SizedBox(
                                          height: 300,
                                          child: TabBarView(
                                              controller: emojiTabController,
                                              children: [
                                                EmojiPicker(
                                                  textEditingController:
                                                      messageInputController,
                                                  scrollController:
                                                      _scrollController,
                                                  config: Config(
                                                    height: 256,
                                                    checkPlatformCompatibility:
                                                        true,
                                                    viewOrderConfig:
                                                        const ViewOrderConfig(),
                                                    emojiViewConfig:
                                                        EmojiViewConfig(
                                                      // Issue: https://github.com/flutter/flutter/issues/28894
                                                      emojiSizeMax: 28 *
                                                          (defaultTargetPlatform ==
                                                                  TargetPlatform
                                                                      .iOS
                                                              ? 1.2
                                                              : 1.0),
                                                    ),
                                                    skinToneConfig:
                                                        const SkinToneConfig(),
                                                    categoryViewConfig:
                                                        const CategoryViewConfig(),
                                                    bottomActionBarConfig:
                                                        const BottomActionBarConfig(),
                                                    searchViewConfig:
                                                        const SearchViewConfig(),
                                                  ),
                                                ),
                                                SingleChildScrollView(
                                                  child: Wrap(
                                                    spacing:
                                                        10, // Space between items
                                                    runSpacing:
                                                        10, // Space between rows
                                                    children: [
                                                      GestureDetector(
                                                        onTap: () async {
                                                          XFile? pickedImage =
                                                              await ImagePicker()
                                                                  .pickImage(
                                                            source: ImageSource
                                                                .gallery,
                                                          );

                                                          if (pickedImage !=
                                                              null) {
                                                            final String
                                                                targetPath =
                                                                "${Helper.directory?.path}/sticker-${pickedImage.name}";
                                                            XFile?
                                                                compressedImage;
                                                            CompressFormat
                                                                compressFormat =
                                                                CompressFormat
                                                                    .jpeg;
                                                            if (pickedImage.name
                                                                .endsWith(
                                                                    '.png')) {
                                                              compressFormat =
                                                                  CompressFormat
                                                                      .png;
                                                              compressedImage =
                                                                  await FlutterImageCompress
                                                                      .compressAndGetFile(
                                                                pickedImage
                                                                    .path,
                                                                format:
                                                                    compressFormat,
                                                                targetPath,
                                                                quality: 15,
                                                              );
                                                            } else if (pickedImage
                                                                .name
                                                                .endsWith(
                                                                    'heic')) {
                                                              compressFormat =
                                                                  CompressFormat
                                                                      .heic;
                                                              compressedImage =
                                                                  await FlutterImageCompress
                                                                      .compressAndGetFile(
                                                                pickedImage
                                                                    .path,
                                                                format:
                                                                    CompressFormat
                                                                        .heic,
                                                                targetPath,
                                                                quality: 15,
                                                              );
                                                            } else if (pickedImage
                                                                .name
                                                                .endsWith(
                                                                    'webp')) {
                                                              compressFormat =
                                                                  CompressFormat
                                                                      .webp;
                                                              compressedImage =
                                                                  await FlutterImageCompress
                                                                      .compressAndGetFile(
                                                                pickedImage
                                                                    .path,
                                                                format:
                                                                    CompressFormat
                                                                        .webp,
                                                                targetPath,
                                                                quality: 15,
                                                              );
                                                            } else {
                                                              compressedImage =
                                                                  await FlutterImageCompress
                                                                      .compressAndGetFile(
                                                                pickedImage
                                                                    .path,
                                                                targetPath,
                                                                quality: 15,
                                                              );
                                                            }

                                                            if (compressedImage ==
                                                                null) {
                                                              throw ("Failed to compress the image");
                                                            }
                                                            context
                                                                .read<
                                                                    StickerCubit>()
                                                                .addSticker(
                                                                    compressedImage);
                                                            log("Image compressed: ${compressedImage.path}, Size: ${await compressedImage.length()}");
                                                          }
                                                        },
                                                        child: Container(
                                                          width: 80,
                                                          height: 80,
                                                          color: Colors.grey,
                                                          child: const Icon(
                                                              Icons.add),
                                                        ),
                                                      ),
                                                      // Sticker Images
                                                      StreamBuilder(
                                                          stream:
                                                              sl<DatabaseHelper>()
                                                                  .getStickers(),
                                                          builder: (context,
                                                              snapshot) {
                                                            log("stickers data??? ${snapshot.data}");
                                                            // snapshot.data?.add(
                                                            //     const Sticker(
                                                            //         id: "",
                                                            //         path: "",
                                                            //         name: "",
                                                            //         userId: ""));
                                                            return snapshot
                                                                        .data ==
                                                                    null
                                                                ? const SizedBox()
                                                                : GridView
                                                                    .builder(
                                                                        shrinkWrap:
                                                                            true,
                                                                        physics:
                                                                            const NeverScrollableScrollPhysics(),
                                                                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                                                            crossAxisCount:
                                                                                4,
                                                                            mainAxisSpacing:
                                                                                5,
                                                                            crossAxisSpacing:
                                                                                5),
                                                                        itemCount: snapshot
                                                                            .data!
                                                                            .length,
                                                                        itemBuilder:
                                                                            (context,
                                                                                index) {
                                                                          log("sticker in chat screen ${snapshot.data![index].path}");

                                                                          return InkWell(
                                                                              onLongPress: () => showModalBottomSheet(
                                                                                    context: context,
                                                                                    builder: (context) {
                                                                                      return Center(
                                                                                        child: TextButton(
                                                                                            onPressed: () {
                                                                                              context.read<StickerCubit>().deleteSticker(snapshot.data![index].id);
                                                                                              Navigator.pop(context);
                                                                                            },
                                                                                            child: Text(Strings.delete)),
                                                                                      );
                                                                                    },
                                                                                  ),
                                                                              child: Image.file(
                                                                                File(snapshot.data![index].path),
                                                                                width: 180,
                                                                                height: 180,
                                                                                fit: BoxFit.cover,
                                                                              ),
                                                                              onTap: () {
                                                                                context.read<ChatCubit>().sendSticker(snapshot.data![index].id, widget.conversation!.targetId.toString(), isGroup: widget.isGroup);
                                                                              });
                                                                        });
                                                            // Wrap(
                                                            //     children: snapshot
                                                            //         .data!
                                                            //         .map((sticker) =>
                                                            //             InkWell(
                                                            //               onLongPress:
                                                            //                   () {
                                                            //                 showModalBottomSheet(
                                                            //                   context: context,
                                                            //                   builder: (context) {
                                                            //                     return Container(
                                                            //                         width: 100,
                                                            //                         height: 100,
                                                            //                         child: Center(
                                                            //                           child: TextButton(
                                                            //                               onPressed: () {
                                                            //                                 // sl<DatabaseHelper>().deleteSticker(snapshot.data![0].id);
                                                            //                                 context.read<StickerCubit>().deleteSticker(sticker.fileUrl);
                                                            //                                 Navigator.pop(context);
                                                            //                               },
                                                            //                               child: Text(Strings.delete)),
                                                            //                         ));
                                                            //                   },
                                                            //                 );
                                                            //               },
                                                            //               child:
                                                            //                   Image.file(
                                                            //                 File(sticker.path),
                                                            //                 width: 80,
                                                            //                 height: 80,
                                                            //                 fit: BoxFit.cover,
                                                            //               ),
                                                            //             ))
                                                            //         .toList())
                                                          }),
                                                    ],
                                                  ),
                                                ),
                                                Column(
                                                  children: [
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 8.0,
                                                              right: 8.0,
                                                              bottom: 8.0),
                                                      child: TextField(
                                                        controller:
                                                            searchGifController,
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .bodyMedium,
                                                        onSubmitted: (value) =>
                                                            context
                                                                .read<
                                                                    ChatCubit>()
                                                                .searchGif(
                                                                    value),
                                                      ),
                                                    ),
                                                    BlocBuilder<ChatCubit,
                                                            ChatState>(
                                                        builder:
                                                            (context, state) {
                                                      return Expanded(
                                                          child:
                                                              GridView.builder(
                                                        gridDelegate:
                                                            const SliverGridDelegateWithFixedCrossAxisCount(
                                                                crossAxisCount:
                                                                    2),
                                                        itemCount:
                                                            state.gifUrl.length,
                                                        itemBuilder:
                                                            (context, index) {
                                                          return GestureDetector(
                                                            onTap: () async {
                                                              XFile image =
                                                                  await getImageXFileByUrl(
                                                                "${state.gifUrl[index]['images']['original']['url']}.gif",
                                                              );
                                                              Navigator.push(
                                                                  context,
                                                                  PageRouteBuilder(
                                                                    pageBuilder: (context, animation1, animation2) => AttachmentPreviewWidget(
                                                                        image: [
                                                                          image
                                                                        ],
                                                                        fileType:
                                                                            "image",
                                                                        conversation:
                                                                            widget.conversation!),
                                                                  ));
                                                            },
                                                            child: Image.network(
                                                                state.gifUrl[index]
                                                                            [
                                                                            'images']
                                                                        [
                                                                        'original']
                                                                    ['url']),
                                                          );
                                                        },
                                                      ));
                                                    }),

                                                    // ListView.builder(
                                                    //   shrinkWrap: true,
                                                    //   itemCount: state.gifs.length,
                                                    //   itemBuilder: (context, index) =>
                                                    //       InkWell(
                                                    //         onTap: () {
                                                    //           context
                                                    //               .read<ChatCubit>()
                                                    //               .sendGif(

                                                    //   )})
                                                    // )
                                                  ],
                                                ),
                                              ])),
                                      TabBar(
                                        controller: emojiTabController,
                                        onTap: (value) async {
                                          if (value == 2) {
                                            context.read<ChatCubit>().getGif();
                                          }
                                        },
                                        padding: const EdgeInsets.all(5.0),
                                        dividerColor: Colors.transparent,
                                        tabs: const [
                                          Icon(Icons.emoji_emotions),
                                          Icon(Icons.sticky_note_2_rounded),
                                          Icon(Icons.gif)
                                        ],
                                      ),
                                    ],
                                  )
                              ],
                            );
                    },
                  );
                }),
          ],
        ),
      ),
    );
  }

  Widget editReplyPreview(ChatTriggerState state, BuildContext context) {
    final messageType = state.messageToReply?.type ?? "";
    File? localImgFile;
    final imageCaption = state.messageToReply?.content;

    AttachmentModel? attachment;

    Widget? trailingImage;
    if (messageType == "IMAGE_TYPE") {
      // Parse necessary data
      final extraInfo = jsonDecode(state.messageToReply?.url ?? "{}");
      log("extra info url ${extraInfo[0]}");
      attachment = AttachmentModel.fromJson(jsonDecode(extraInfo[0]));
      localImgFile = File("${Helper.directory?.path}/${attachment.fileUrl}");
      trailingImage = _getReplyTrailingImage(messageType, localImgFile);
    }

    // Determine message content
    final messageContent = _getReplyMessageContent(
        messageType, imageCaption, state.messageToReply?.content);

    // Configure leading and trailing widgets
    final leadingIcon = state.isEditing
        ? const Icon(Icons.edit)
        : Transform(
            alignment: Alignment.center,
            transform: Matrix4.rotationY(math.pi),
            child: const Icon(Icons.reply),
          );

    return Container(
      decoration: const BoxDecoration(color: AppColor.chatReceiverBubbleColor),
      child: ListTile(
        leading: leadingIcon,
        title: BlocBuilder<UserCubit, UserState>(
          builder: (context, userstate) {
            return Text(
              state.isEditing
                  ? Strings.editMessage
                  : "${state.messageToReply?.senderId == (sl<CredentialService>().turmsId ?? "0") ? Strings.me : widget.conversation?.title}:",
            );
          },
        ),
        subtitle: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _getReplyMessageIcon(messageType),
            SizedBox(
                width: MediaQuery.sizeOf(context).width * 0.6,
                child: Text(messageContent, overflow: TextOverflow.ellipsis)),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (messageType == "IMAGE_TYPE")
              _getReplyTrailingImage(messageType, localImgFile!),
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                if (state.isReply) {
                  context.read<ChatTriggerCubit>().toggleReplyMessage();
                } else {
                  context.read<ChatTriggerCubit>().toggleEditing();
                }
              },
            ),
          ],
        ),
      ),
    );
  }

// Helper function to determine message content
  String _getReplyMessageContent(
      String messageType, String? imageCaption, String? defaultContent) {
    switch (messageType) {
      case "IMAGE_TYPE":
        return imageCaption?.isNotEmpty ?? false ? imageCaption! : "Image";
      case "VIDEO_TYPE":
        return "Video";
      case "VOICE_TYPE":
        return "Audio";
      case "FILE_TYPE":
        return "File";
      case "NAMECARD_TYPE":
        return "Contact";
      case "STICKER_TYPE":
        return "Sticker";
      default:
        return defaultContent ?? "";
    }
  }

// Helper function to get the trailing image widget
  Widget _getReplyTrailingImage(String messageType, File localImgFile) {
    if (messageType == "IMAGE_TYPE" || messageType == "VIDEO_TYPE") {
      return Image.file(localImgFile, width: 50, height: 70);
    }
    return Container(); // Return empty container if no image
  }

// Helper function to get the message type icon
  Widget _getReplyMessageIcon(String messageType) {
    switch (messageType) {
      case "IMAGE_TYPE":
        return const Icon(Icons.image);
      case "VIDEO_TYPE":
        return const Icon(Icons.videocam);
      case "VOICE_TYPE":
        return const Icon(Icons.voice_chat);
      default:
        return const SizedBox.shrink(); // Return nothing if no specific icon
    }
  }

  void sendMessage(BuildContext context, ChatTriggerState state) {
    if (messageInputController.text.isNotEmpty) {
      List<dynamic> members = jsonDecode(widget.conversation?.members ?? "[]");
      Int64 senderId = (sl<CredentialService>().turmsId ?? "0").parseInt64();
      Int64 receiverId = widget.isGroup
          ? widget.conversation!.targetId!.parseInt64()
          : Int64(0);
      for (String membersId in members) {
        if (senderId != membersId.parseInt64()) {
          receiverId = membersId.parseInt64();
        }
      }
      if (context.read<ChatTriggerCubit>().state.isReply) {
        if (context.read<ChatTriggerCubit>().state.messageToReply?.id != null) {
          context.read<ChatCubit>().sendMessage(
              widget.isGroup
                  ? widget.conversation?.targetId?.parseInt64() ?? Int64(0)
                  : receiverId,
              senderId,
              message: messageInputController.text.toString(),
              parentMessage:
                  context.read<ChatTriggerCubit>().state.messageToReply,
              isGroupMessage: widget.isGroup,
              messageType: turms.MessageType.TEXT_TYPE,
              groupId: widget.isGroup
                  ? widget.conversation?.targetId?.parseInt64()
                  : null);

          context.read<ChatTriggerCubit>().toggleReplyMessage();
        }

        //channel.sendMessage(message);
      } else if (state.isEditing) {
        if (state.messageToReply?.id != null) {
          db.Message editedMessage = state.messageToReply!
              .copyWith(content: messageInputController.text.toString());
          context.read<ChatCubit>().editMessage(editedMessage);
          //channel.updateMessage(updatedMessage);

          context.read<ChatTriggerCubit>().toggleEditing(message: null);
        }
      } else {
        context.read<ChatCubit>().sendMessage(
            widget.isGroup
                ? widget.conversation?.targetId?.parseInt64() ?? Int64(0)
                : receiverId,
            senderId,
            message: messageInputController.text.toString(),
            isGroupMessage: widget.isGroup,
            groupId: widget.isGroup
                ? widget.conversation?.targetId?.parseInt64()
                : null);
        // channel.sendMessage(
        //   messageInputController.message
        //       .copyWith(text: messageInputController.text.trim()),
        // );
      }
      messageInputController.clear();
      if (mounted) {
        context.read<ChatTriggerCubit>().isFirstLoad();
        // _updateList(messages.indexOf(messages.last) - 1,
        //     isInitial: context.read<ChatTriggerCubit>().state.isFirstLoad,
        //     searchedMessage: widget.searchedMessage);
      }
    }
  }

  Future<XFile> getImageXFileByUrl(String url) async {
    Directory tempDir = await getTemporaryDirectory();
    String tempPath = tempDir.path;
    String fileName = "gif${DateTime.now().millisecondsSinceEpoch}.gif";
    File fileWrite = File("$tempPath/$fileName");
    Uri uri = Uri.parse(url);
    final response = await get(uri);
    fileWrite.writeAsBytesSync(response.bodyBytes);
    return XFile(fileWrite.path);
  }

  // void checkAndCombineAttachmentIntoSameMessage(
  //     db.Message? previousMessage,
  //     db.Message currentMessage,
  //     StreamChatClient client,
  //     ChatTriggerState state) async {
  //   if (previousMessage != null &&
  //       previousMessage.attachments.isNotEmpty &&
  //       currentMessage.attachments.isNotEmpty) {
  //     // Check if both previous and current messages contain only image attachments
  //     bool previousHasImages = previousMessage.attachments
  //         .every((attachment) => attachment.type == "image");
  //     bool currentHasImages = currentMessage.attachments
  //         .every((attachment) => attachment.type == "image");

  //     // Proceed only if both have image attachments
  //     if (previousHasImages && currentHasImages) {
  //       // Check if messages were sent within a minute of each other
  //       if (currentMessage.createdAt
  //               .difference(previousMessage.createdAt)
  //               .inMinutes <=
  //           1) {
  //         // Initialize a new list to hold the merged attachments
  //         final List<Attachment> combinedAttachments = {
  //           ...previousMessage.attachments,
  //           ...currentMessage.attachments
  //         }.toList();

  //         // // Merge current message attachments if they aren't already in previous
  //         // combinedAttachments.addAll(currentMessage.attachments
  //         //     .where((attachment) => !combinedAttachments.any((existing) {
  //         //           log("existing ${existing.id}, attachment ${attachment.id}");
  //         //           return existing.id == attachment.id;
  //         //         })));
  //         // Update previous message with the new attachments
  //         try {
  //           if (state.isFirstLoad) {
  //             await client.updateMessage(
  //               previousMessage.copyWith(
  //                 attachments: combinedAttachments,
  //               ),
  //             );
  //             log("Previous message updated with new attachments");

  //             // After updating, delete the current message
  //             await client.deleteMessage(currentMessage.id, hard: true);
  //           }
  //           log("Current message deleted after merging");
  //         } catch (e) {
  //           log("Error while updating/deleting message: $e");
  //         }
  //       }
  //     }
  //   }
  // }

  Future<String?> _getDir() async {
    final Directory? downloadDir;
    if (Platform.isAndroid) {
      downloadDir = await getDownloadsDirectory();
    } else {
      downloadDir = await getApplicationDocumentsDirectory();
    }

    if (downloadDir == null) return null;

    String? path = downloadDir.path;

    return path;
  }

  void _sendRecording({required String path}) async {
    File audioFile = File(path);
    log("file path ${audioFile.path}");
    audioFile.length().then((fileSize) {
      // log("file length $fileSize");
      // StreamChannel.of(context).channel.sendMessage(Message(attachments: [
      //       Attachment(
      //           type: "audio",
      //           file: AttachmentFile(size: fileSize, path: downloadPath)),
      //     ]));
      if (widget.conversation != null) {
        if (widget.conversation!.targetId != null) {
          log("message ppppp ${context.read<ChatTriggerCubit>().state.messageToReply?.id}");
          context.read<ChatCubit>().sendAttachment(
              widget.conversation!.targetId!,
              [XFile(path, length: fileSize)],
              turms.MessageType.VOICE_TYPE,
              parentMessage:
                  context.read<ChatTriggerCubit>().state.messageToReply,
              isGroup: widget.isGroup);
          if (context.read<ChatTriggerCubit>().state.isReply) {
            context.read<ChatTriggerCubit>().toggleReplyMessage();
          }
          setState(() {
            recordedAudioPath = null;
          });
        }
      }
    });
  }

  void _startOrStopRecording({bool reset = false}) async {
    try {
      if (isRecording) {
        volumeController.setVolume(currentVolume);

        recorderController.reset();

        String? downloadPath = await recorderController.stop(false);

        if (downloadPath != null) {
          isRecordingCompleted = true;

          if (reset) {
            return;
          }

          setState(() {
            recordedAudioPath = downloadPath;
          });

          //send audio recording

          // File audioFile = File(downloadPath.toString());
          // log("file path ${audioFile.path}");
          // audioFile.length().then((fileSize) {
          //   // log("file length $fileSize");
          //   // StreamChannel.of(context).channel.sendMessage(Message(attachments: [
          //   //       Attachment(
          //   //           type: "audio",
          //   //           file: AttachmentFile(size: fileSize, path: downloadPath)),
          //   //     ]));
          //   if (widget.conversation != null) {
          //     if (widget.conversation!.targetId != null) {
          //       context.read<ChatCubit>().sendAttachment(
          //           widget.conversation!.targetId!,
          //           [XFile(downloadPath, length: fileSize)],
          //           turms.MessageType.VOICE_TYPE);
          //     }
          //   }
          // });
        }
      } else {
        String? path = await _getDir();

        if (path == null) return;

        String downloadPath =
            "$path/${DateTime.now().millisecondsSinceEpoch}.m4a";

        double currVolume = await VolumeController().getVolume();

        setState(() {
          currentVolume = currVolume;
        });

        volumeController.muteVolume();

        await recorderController.record(path: downloadPath); // Path is optional
      }
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      setState(() {
        isRecording = !isRecording;
      });
    }
  }

  void _refreshWave() {
    if (isRecording) recorderController.refresh();

    setState(() {});
  }
}

class ForwardMessageWidget extends StatelessWidget {
  const ForwardMessageWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (dialogContext) {
                  return AlertDialog(
                    title: Text(Strings.deleteMessage),
                    content: Text(Strings.deleteMessageDescription),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text(Strings.cancel),
                      ),
                      TextButton(
                        onPressed: () {
                          // context.read<ChatCubit>().deleteMessage(
                          //     state.selectedMessages);
                          Navigator.pop(dialogContext);
                        },
                        child: Text(Strings.ok),
                      ),
                    ],
                    actionsAlignment: MainAxisAlignment.spaceBetween,
                  );
                },
              );
            },
            icon: const Icon(
              Icons.delete,
              color: Colors.blue,
            )),
        IconButton(
            onPressed: () {
              context.read<ChatTriggerCubit>().toggleSelect();
              Navigator.of(context).pushNamed(AppPage.friendSelection.routeName,
                  arguments: context.read<ChatCubit>().state.selectedMessages);
            },
            icon: const Icon(
              Icons.forward,
              color: Colors.blue,
            ))
      ],
    );
  }
}

class SearchedResultViewDelegate extends SliverPersistentHeaderDelegate {
  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Result View"),
        TextButton(
            onPressed: () {
              context.read<ChatCubit>().resetSearchState();
            },
            child: const Text("Jump to latest message"))
      ],
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
