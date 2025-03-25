import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:protech_mobile_chat_stream/constants/network_constants.dart';
import 'package:protech_mobile_chat_stream/constants/string_constant.dart';
import 'package:protech_mobile_chat_stream/model/database.dart';
import 'package:protech_mobile_chat_stream/module/chat/model/attachment_model.dart';
import 'package:protech_mobile_chat_stream/module/profile/cubit/profile_cubit.dart';
import 'package:protech_mobile_chat_stream/service/credential_service.dart';
import 'package:protech_mobile_chat_stream/service/database_helper.dart';
import 'package:protech_mobile_chat_stream/service/turms_service.dart';
import 'package:protech_mobile_chat_stream/utils/colors.dart';
import 'package:protech_mobile_chat_stream/utils/helper.dart';
import 'package:protech_mobile_chat_stream/utils/service_locator.dart';
import 'package:protech_mobile_chat_stream/widgets/chat_avatar.dart';
import 'package:protech_mobile_chat_stream/widgets/player_widget.dart';
import 'package:turms_client_dart/turms_client.dart' as turms;
import 'package:video_player/video_player.dart';

class FavoriteDetailsScreen extends StatefulWidget {
  const FavoriteDetailsScreen(
      {super.key,
      required this.message,
      required this.messageSender,
      required this.sendDate});
  final Message message;
  final String messageSender;
  final String sendDate;

  @override
  State<FavoriteDetailsScreen> createState() => _FavoriteDetailsScreenState();
}

class _FavoriteDetailsScreenState extends State<FavoriteDetailsScreen> {
  bool errorLoadingVideo = false;
  int? bufferDelay;
  VideoPlayerController? videoPlayerController;

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
            constraints:
                BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width),
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
          constraints:
              BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width),
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
      return const Text(
        "[Image]",
        style: TextStyle(
            color: Colors.black, fontSize: 16, fontWeight: FontWeight.w500),
      );
    }

    return const Text(
      "[Image]",
      style: TextStyle(
          color: Colors.black, fontSize: 16, fontWeight: FontWeight.w500),
    );
  }

  Widget textWidget(Message message) {
    return Text(
      message.content,
      style: const TextStyle(
          color: Colors.black, fontSize: 16, fontWeight: FontWeight.w400),
    );
  }

  Widget videoWidget(Message message) {
    try {
      if (videoPlayerController != null) {
        return AspectRatio(
          aspectRatio: videoPlayerController!.value.aspectRatio,
          child: Chewie(
            controller: ChewieController(
              videoPlayerController: videoPlayerController!,
              autoInitialize: false,
              showControlsOnInitialize: false,
              progressIndicatorDelay: bufferDelay != null
                  ? Duration(milliseconds: bufferDelay!)
                  : null,
              placeholder: SizedBox(
                height: videoPlayerController?.value.aspectRatio != null
                    ? double.infinity
                    : 200,
              ),
              errorBuilder: (context, errorMessage) {
                return const SizedBox(
                  height: 50,
                  width: 70,
                  child: Center(
                      child: Icon(Icons.music_video, color: Colors.white)),
                );
              },
            ),
          ),
        );
      } else {
        return const Text(
          "[Video]",
          style: TextStyle(
              color: Colors.black, fontSize: 16, fontWeight: FontWeight.w500),
        );
      }
    } catch (e) {
      return const Text(
        "[Video]",
        style: TextStyle(
            color: Colors.black, fontSize: 16, fontWeight: FontWeight.w500),
      );
    }
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
            color: AppColor.chatSenderBubbleColor,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 5),
          child: PlayerWidget(
              isReceiver: false,
              voiceSource: urlsAttachment.fileUrl,
              isLocal: false),
        );
      }
    } catch (e) {
      return const Text(
        "[Audio]",
        style: TextStyle(
            color: Colors.black, fontSize: 16, fontWeight: FontWeight.w500),
      );
    }

    return const Text(
      "[Audio]",
      style: TextStyle(
          color: Colors.black, fontSize: 16, fontWeight: FontWeight.w500),
    );
  }

  Widget fileWidget(Message message) {
    try {
      if (message.url != null) {
        final urls = jsonDecode(message.url!);

        AttachmentModel urlsAttachment =
            AttachmentModel.fromJson(jsonDecode(urls[0]));

        File localImgFile =
            File("${Helper.directory?.path}/${urlsAttachment.fileUrl}");

        return GestureDetector(
            onTap: () {
              // if (widget.currentMessage.id != null) {
              //   context.read<ChatCubit>().downloadFile(
              //       widget.currentMessage.url.toString(),
              //       attachmentModel.name,
              //       widget.currentMessage.id!.parseInt64());
              // }
            },
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: AppColor.chatBackgroundColor,
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
      return const Text(
        "[File]",
        style: TextStyle(
            color: Colors.black, fontSize: 16, fontWeight: FontWeight.w500),
      );
    }

    return const Text(
      "[File]",
      style: TextStyle(
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

  Future<void> initLocalVideoPlayer({bool reinitialize = false}) async {
    if (!reinitialize) {
      if (videoPlayerController != null) {
        if (videoPlayerController!.value.isInitialized) {
          return;
        }
      }
    }

    Directory? dir = Helper.directory;

    try {
      if (widget.message.url != null) {
        final urls = jsonDecode(widget.message.url!);

        AttachmentModel urlsAttachment =
            AttachmentModel.fromJson(jsonDecode(urls[0]));

        File localVideoFile = File("${dir?.path}/${urlsAttachment.fileUrl}");

        final extraInfo =
            jsonDecode(widget.message.extraInfo?.toString() ?? "{}");

        AttachmentModel attachmentModel =
            AttachmentModel.fromJson(extraInfo["attachments"][0]);

        if (localVideoFile.existsSync()) {
          videoPlayerController = VideoPlayerController.file(localVideoFile);

          await videoPlayerController?.initialize().then((_) {
            setState(() {
              errorLoadingVideo = false;
            });
          });
          log("initialize local ${videoPlayerController?.dataSource},");
          return;
        }
      }
    } catch (error) {
      log("Error initializing video player: $error");
      setState(() {
        errorLoadingVideo = true;
      });
    }
  }

  @override
  void initState() {
    super.initState();

    if (widget.message.type == turms.MessageType.VIDEO_TYPE.name) {
      initLocalVideoPlayer();
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
        title: Text(Strings.favouriteDetails),
        actions: [
          MenuAnchor(
            builder: (context, controller, child) {
              return IconButton(
                icon: const Icon(Icons.more_vert),
                onPressed: () {
                  if (controller.isOpen) {
                    controller.close();
                  } else {
                    controller.open();
                  }
                },
              );
            },
            menuChildren: [
              MenuItemButton(
                onPressed: () async {
                  await unfavouriteMessage(messageId: widget.message.id!);
                  Navigator.pop(context);
                },
                child: Text(Strings.removeFavourite),
              ),
            ],
          )
        ],
      ),
      body: SingleChildScrollView(
          child: Container(
        width: MediaQuery.sizeOf(context).width,
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                const Expanded(
                    child: Divider(
                  thickness: 0.2,
                  color: Colors.grey,
                )),
                const SizedBox(width: 10),
                Text("From ${widget.messageSender} on ${widget.sendDate}",
                    style: Theme.of(context)
                        .textTheme
                        .labelSmall
                        ?.copyWith(color: Colors.grey)),
                const SizedBox(width: 10),
                const Expanded(
                    child: Divider(
                  thickness: 0.2,
                  color: Colors.grey,
                )),
              ],
            ),
            const SizedBox(height: 15),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: stickerContentWidget(widget.message),
            ),
            const SizedBox(height: 15),
            Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                const Expanded(
                    child: Divider(
                  thickness: 0.2,
                  color: Colors.grey,
                )),
                const SizedBox(width: 10),
                Text(
                  Strings.favourite,
                  style: Theme.of(context)
                      .textTheme
                      .labelSmall
                      ?.copyWith(color: Colors.grey),
                ),
                const SizedBox(width: 10),
                const Expanded(
                    child: Divider(
                  thickness: 0.2,
                  color: Colors.grey,
                ))
              ],
            ),
          ],
        ),
      )),
    );
  }
}
