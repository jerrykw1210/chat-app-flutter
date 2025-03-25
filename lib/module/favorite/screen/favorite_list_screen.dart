import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:protech_mobile_chat_stream/constants/network_constants.dart';
import 'package:protech_mobile_chat_stream/constants/string_constant.dart';
import 'package:protech_mobile_chat_stream/model/database.dart';
import 'package:protech_mobile_chat_stream/module/chat/model/attachment_model.dart';
import 'package:protech_mobile_chat_stream/module/favorite/screen/favorite_details_screen.dart';
import 'package:protech_mobile_chat_stream/module/friend/cubit/user_cubit.dart';
import 'package:protech_mobile_chat_stream/module/profile/cubit/profile_cubit.dart';
import 'package:protech_mobile_chat_stream/service/credential_service.dart';
import 'package:protech_mobile_chat_stream/service/database_helper.dart';
import 'package:protech_mobile_chat_stream/service/turms_service.dart';
import 'package:protech_mobile_chat_stream/utils/colors.dart';
import 'package:protech_mobile_chat_stream/utils/helper.dart';
import 'package:protech_mobile_chat_stream/utils/iterable_apis.dart';
import 'package:protech_mobile_chat_stream/utils/service_locator.dart';
import 'package:protech_mobile_chat_stream/utils/string_apis.dart';
import 'package:protech_mobile_chat_stream/widgets/chat_avatar.dart';
import 'package:protech_mobile_chat_stream/widgets/player_widget.dart';
import 'package:turms_client_dart/turms_client.dart' as turms;

class FavoriteListScreen extends StatefulWidget {
  const FavoriteListScreen({super.key});

  @override
  State<FavoriteListScreen> createState() => _FavoriteListScreenState();
}

class _FavoriteListScreenState extends State<FavoriteListScreen> {
  @override
  void initState() {
    // TODO: implement initState
    context.read<UserCubit>().fetchUsers();
    super.initState();
  }

  Widget noContentWidget() {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: MediaQuery.sizeOf(context).height * 0.2),
          Image.asset("assets/Illustration.png"),
          const SizedBox(height: 16),
          Text(Strings.noFavouriteMessages,
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  fontFamily: "Inter",
                  color: Color.fromRGBO(16, 24, 40, 1))),
          const SizedBox(height: 10),
          Text(Strings.noFavouriteMessageYet,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  fontFamily: "Inter",
                  color: Color.fromRGBO(71, 84, 103, 1))),
          const SizedBox(height: 20),
          Text(Strings.tapStarIcon,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  fontFamily: "Inter",
                  color: Color.fromRGBO(71, 84, 103, 1))),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget imageWidget(Message message) {
    try {
      if (message.url != null) {
        final urls = jsonDecode(message.url!);

        AttachmentModel urlsAttachment =
            AttachmentModel.fromJson(jsonDecode(urls[0]));

        String thumbnailUrl =
            "${NetworkConstants.getThumbFileWithTokenUrl}${urlsAttachment.thumbnailPath}?token=${sl<CredentialService>().jwtToken}";

        File localImgFile =
            File("${Helper.directory?.path}/${urlsAttachment.fileUrl}");

        if (localImgFile.existsSync()) {
          return Container(
            constraints: BoxConstraints(
                maxWidth: MediaQuery.sizeOf(context).width * 0.3,
                maxHeight: 100),
            child: Image.file(
              localImgFile,
              errorBuilder: (context, error, stackTrace) => const SizedBox(
                height: 50,
                width: 70,
                child: SizedBox(
                  height: 50,
                  width: 70,
                  child: Center(
                      child: Icon(Icons.broken_image_outlined,
                          color: Colors.white)),
                ),
              ),
            ),
          );
        }

        return Container(
          constraints: BoxConstraints(
              maxWidth: MediaQuery.sizeOf(context).width * 0.3, maxHeight: 100),
          child: Image.network(thumbnailUrl,
              errorBuilder: (context, error, stackTrace) => const SizedBox(
                    height: 50,
                    width: 70,
                    child: Center(
                        child: Icon(Icons.broken_image_outlined,
                            color: Colors.white)),
                  ),
              frameBuilder: (context, child, frame, wasSynchronouslyLoaded) =>
                  child),
        );
      }
    } catch (e) {
      return Text(
        "[${Strings.image}]",
        style: const TextStyle(
            color: Colors.black, fontSize: 16, fontWeight: FontWeight.w500),
      );
    }

    return Text(
      "[${Strings.image}]",
      style: const TextStyle(
          color: Colors.black, fontSize: 16, fontWeight: FontWeight.w500),
    );
  }

  Widget textWidget(Message message) {
    return Text(
      message.content,
      maxLines: 2,
      style: const TextStyle(
          overflow: TextOverflow.ellipsis,
          color: Colors.black,
          fontSize: 16,
          fontWeight: FontWeight.w500),
    );
  }

  Widget videoWidget(Message message) {
    return Text(
      "[${Strings.video}]",
      style: const TextStyle(
          color: Colors.black, fontSize: 16, fontWeight: FontWeight.w500),
    );
  }

  Widget audioWidget(Message message) {
    try {
      if (message.url != null) {
        final urls = jsonDecode(message.url!);

        AttachmentModel urlsAttachment =
            AttachmentModel.fromJson(jsonDecode(urls[0]));

        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            color: AppColor.chatReceiverBubbleColor,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 5),
          child: PlayerWidget(
              isReceiver: true,
              voiceSource: urlsAttachment.fileUrl,
              isLocal: false),
        );
      }
    } catch (e) {
      return Text(
        "[${Strings.audio}]",
        style: const TextStyle(
            color: Colors.black, fontSize: 16, fontWeight: FontWeight.w500),
      );
    }

    return Text(
      "[${Strings.audio}]",
      style: const TextStyle(
          color: Colors.black, fontSize: 16, fontWeight: FontWeight.w500),
    );
  }

  Widget fileWidget(Message message) {
    try {
      if (message.url != null) {
        final urls = jsonDecode(message.url!);

        AttachmentModel urlsAttachment =
            AttachmentModel.fromJson(jsonDecode(urls[0]));

        File localFile =
            File("${Helper.directory?.path}/${urlsAttachment.fileUrl}");

        return GestureDetector(
            onTap: () async {
              // if (widget.currentMessage.id != null) {
              //   context.read<ChatCubit>().downloadFile(
              //       widget.currentMessage.url.toString(),
              //       attachmentModel.name,
              //       widget.currentMessage.id!.parseInt64());
              // }
              if (localFile.existsSync()) {
                await OpenFile.open(localFile.path);
              }
            },
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: AppColor.chatReceiverBubbleColor,
              ),
              padding: const EdgeInsets.only(right: 15),
              child: IntrinsicWidth(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.white,
                    child: Image.asset(
                      "assets/icons/file-default.png",
                    ),
                  ),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  visualDensity: const VisualDensity(vertical: -4),
                  title: Text(
                    urlsAttachment.fileName,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: Colors.black),
                  ),
                  subtitle: Text(
                      Helper.formatFileSize(urlsAttachment.fileSize ?? 0),
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: Colors.black)),
                ),
              ),
            ));
      }
    } catch (e) {
      return Text(
        "[${Strings.file}]",
        style: const TextStyle(
            color: Colors.black, fontSize: 16, fontWeight: FontWeight.w500),
      );
    }

    return Text(
      "[${Strings.file}]",
      style: const TextStyle(
          color: Colors.black, fontSize: 16, fontWeight: FontWeight.w500),
    );
  }

  Widget stickerWidget(Message message) {
    return Image.network(
        "${NetworkConstants.getStickerWithTokenUrl}${jsonDecode(message.url ?? "")[0]}?token=${sl<CredentialService>().jwtToken}",
        width: 100,
        height: 100,
        errorBuilder: (context, error, stackTrace) => SizedBox(
              height: 50,
              child: Center(
                  child: Row(
                children: [
                  const Icon(Icons.broken_image_outlined, color: Colors.grey),
                  Text(
                    Strings.stickerNotFound,
                    style: Theme.of(context)
                        .textTheme
                        .labelMedium
                        ?.copyWith(color: Colors.grey),
                  )
                ],
              )),
            ),
        fit: BoxFit.contain);
  }

  Widget namecardWidget(Message message) {
    final isSender = message.senderId == sl<CredentialService>().turmsId!;
    return Container(
      width: MediaQuery.sizeOf(context).width * 0.6,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15.0),
          color: isSender
              ? AppColor.chatSenderBubbleColor
              : AppColor.chatReceiverBubbleColor),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Row(
              children: [
                Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: message.extraInfo == sl<CredentialService>().userId
                        ? CircleAvatar(
                            child: Image.file(
                              File(
                                  "${Helper.directory?.path}/${sl<CredentialService>().turmsId}_${context.read<ProfileCubit>().state.userProfile?.profileUrl}"),
                              fit: BoxFit.cover,
                              width: 40,
                              height: 40,
                              errorBuilder: (context, error, stackTrace) =>
                                  Image.asset(
                                'assets/default-img/default-user.png',
                                fit: BoxFit.cover,
                                width: 40,
                                height: 40,
                              ),
                            ),
                          )
                        : ChatAvatar(
                            errorWidget: CircleAvatar(
                              child: Text(message.content[0]),
                            ),
                            targetId: message.extraInfo?.toString() ?? "",
                            radius: 30)
                    // CircleAvatar(
                    //     radius: 30,
                    //     child: ClipOval(
                    //       child: Image.network(
                    //         userstate.usersList
                    //             .singleWhere((user) =>
                    //                 user.id ==
                    //                 widget.currentMessage.extraInfo
                    //                     ?.parseInt64())
                    //             .profilePicture,
                    //         errorBuilder:
                    //             (context, error, stackTrace) => Text(
                    //                 userstate.userProfile?.name[0] ??
                    //                     ""),
                    //         fit: BoxFit.cover,
                    //       ),
                    //     ),
                    //   ),
                    // ChatAvatar(
                    //     errorWidget:
                    //     targetId:
                    //         userstate.userProfile?.id.toString() ??
                    //             "",
                    //     isGroup: widget.isGroup)
                    ),
                Flexible(
                  child: Text(message.content.toString(),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: isSender ? Colors.white : Colors.black)),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget stickerContentWidget(Message message) {
    String messageContent = message.content;

    if (message.type == turms.MessageType.IMAGE_TYPE.name) {
      return imageWidget(message);
    }

    if (message.type == turms.MessageType.FILE_TYPE.name) {
      return fileWidget(message);
    }

    if (message.type == turms.MessageType.VIDEO_TYPE.name) {
      return videoWidget(message);
    }

    if (message.type == turms.MessageType.VOICE_TYPE.name) {
      return audioWidget(message);
    }

    if (message.type == turms.MessageType.STICKER_TYPE.name) {
      return stickerWidget(message);
    }
    if (message.type == turms.MessageType.NAMECARD_TYPE.name) {
      return namecardWidget(message);
    }

    return textWidget(message);
  }

  void openFile(Message message) async {
    try {
      if (message.url != null) {
        final urls = jsonDecode(message.url!);

        AttachmentModel urlsAttachment =
            AttachmentModel.fromJson(jsonDecode(urls[0]));

        File localFile =
            File("${Helper.directory?.path}/${urlsAttachment.fileUrl}");
        if (localFile.existsSync()) {
          await OpenFile.open(localFile.path);
        }
      }
    } catch (e) {
      log(e.toString());
    }
  }

  Future<void> unfavouriteMessage({required String messageId}) async {
    await sl<DatabaseHelper>().unFavouriteMessage(messageId);
    await sl<TurmsService>().unfavouriteMessage(messageId: messageId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(Strings.favouriteList),
      ),
      body: StreamBuilder(
          stream: sl<DatabaseHelper>().getOwnFavouriteMessagesStream(
              sl<CredentialService>().turmsId ?? ""),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return noContentWidget();
            }

            List<Message> messageList = snapshot.data ?? [];

            return BlocBuilder<UserCubit, UserState>(
              builder: (context, state) {
                List<turms.UserInfo> friendList = state.usersList;

                if (messageList.isEmpty) {
                  return noContentWidget();
                }

                return ListView.separated(
                    itemBuilder: (context, index) {
                      Message message = messageList[index];

                      turms.UserInfo? userInfo;

                      if (friendList.isNotEmpty) {
                        userInfo = friendList.firstWhereOrNull((element) {
                          return element.id.toString() == message.senderId;
                        });
                      }

                      String? myId = sl<CredentialService>().turmsId;

                      String username = userInfo?.name ?? message.senderId;

                      if (message.senderId == myId) {
                        username = Strings.sentByMe;
                      }

                      return MenuAnchor(
                          alignmentOffset: Offset(
                              MediaQuery.sizeOf(context).width * 0.5, -50),
                          menuChildren: [
                            MenuItemButton(
                              onPressed: () {
                                unfavouriteMessage(messageId: message.id!);
                              },
                              child: Text(Strings.removeFavourite),
                            ),
                          ],
                          builder: (BuildContext context,
                              MenuController controller, Widget? widget) {
                            return InkWell(
                              onTap: () {
                                if (message.type ==
                                    turms.MessageType.FILE_TYPE.name) {
                                  openFile(message);
                                  return;
                                }

                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            FavoriteDetailsScreen(
                                                message: message,
                                                messageSender:
                                                    username == Strings.sentByMe
                                                        ? Strings.you
                                                        : username,
                                                sendDate: DateFormat(
                                                        'dd MMM yyyy')
                                                    .format(message.sentAt))));
                              },
                              onLongPress: () {
                                if (controller.isOpen) {
                                  controller.close();
                                } else {
                                  controller.open();
                                }
                              },
                              child: Container(
                                width: MediaQuery.sizeOf(context).width,
                                margin: const EdgeInsets.only(
                                    left: 20, right: 20, top: 15, bottom: 5),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 20),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.5),
                                      spreadRadius: 1,
                                      blurRadius: 5,
                                      offset: const Offset(
                                          0, 2), // changes position of shadow
                                    ),
                                  ],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      stickerContentWidget(message),
                                      const SizedBox(height: 20),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        mainAxisSize: MainAxisSize.max,
                                        children: [
                                          Text(
                                            username,
                                            style: const TextStyle(
                                                color: Colors.black,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w400),
                                          ),
                                          Text(
                                            DateFormat('dd MMM yyyy')
                                                .format(message.sentAt),
                                            style: const TextStyle(
                                                color: Colors.black,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w400),
                                          ),
                                        ],
                                      )
                                    ]),
                              ),
                            );
                          });
                    },
                    separatorBuilder: (context, index) {
                      return const Divider(height: 0, thickness: 0.5);
                    },
                    itemCount: messageList.length);
              },
            );
          }),
    );
  }
}
