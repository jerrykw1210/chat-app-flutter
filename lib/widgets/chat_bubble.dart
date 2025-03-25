import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:chewie/chewie.dart';
import 'package:fixnum/fixnum.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_video_thumbnail/get_video_thumbnail.dart';
import 'package:path_provider/path_provider.dart';
import 'package:protech_mobile_chat_stream/constants/network_constants.dart';
import 'package:protech_mobile_chat_stream/constants/string_constant.dart';
import 'package:protech_mobile_chat_stream/model/message_status_enum.dart';
import 'package:protech_mobile_chat_stream/module/chat/cubit/chat_cubit.dart';

import 'package:intl/intl.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:protech_mobile_chat_stream/module/chat/cubit/chat_trigger_cubit.dart';
import 'package:protech_mobile_chat_stream/module/chat/cubit/group_cubit.dart';
import 'package:protech_mobile_chat_stream/module/chat/model/attachment_model.dart';
import 'package:protech_mobile_chat_stream/module/chat/screen/chat_screen.dart';
import 'package:protech_mobile_chat_stream/module/friend/cubit/user_cubit.dart';
import 'package:protech_mobile_chat_stream/module/profile/cubit/profile_cubit.dart';
import 'package:protech_mobile_chat_stream/route/routes.dart';
import 'package:protech_mobile_chat_stream/service/credential_service.dart';
import 'package:protech_mobile_chat_stream/service/database_helper.dart';
import 'package:protech_mobile_chat_stream/service/turms_service.dart';
import 'package:protech_mobile_chat_stream/utils/colors.dart';
import 'package:protech_mobile_chat_stream/utils/helper.dart';
import 'package:protech_mobile_chat_stream/utils/iterable_apis.dart';
import 'package:protech_mobile_chat_stream/utils/service_locator.dart';
import 'package:protech_mobile_chat_stream/utils/string_apis.dart';
import 'package:protech_mobile_chat_stream/utils/toast_utils.dart';
import 'package:protech_mobile_chat_stream/widgets/chat_avatar.dart';
import 'package:protech_mobile_chat_stream/widgets/player_widget.dart';
import 'package:sticky_grouped_list/sticky_grouped_list.dart';
import 'package:video_player/video_player.dart';
import 'package:protech_mobile_chat_stream/model/database.dart' as db;
import 'package:turms_client_dart/turms_client.dart' as turms;
import 'package:http/http.dart' as http;

class ChatBubbleTurms extends StatefulWidget {
  const ChatBubbleTurms({
    super.key,
    required this.currentMessage,
    required this.displayAvatar,
    required this.isGroup,
    this.itemScrollController,
    this.conversation,
    this.pickedImageToUpload,
    this.conversationSettings,
    this.messageList,
  });
  final db.Message currentMessage;
  final db.Conversation? conversation;
  final bool displayAvatar;
  final GroupedItemScrollController? itemScrollController;
  final bool isGroup;
  final XFile? pickedImageToUpload;
  final turms.ConversationSettings? conversationSettings;
  final List<db.Message>? messageList;

  @override
  State<ChatBubbleTurms> createState() => _ChatBubbleTurmsState();
}

class _ChatBubbleTurmsState extends State<ChatBubbleTurms> {
  VideoPlayerController? videoPlayerController;
  int? bufferDelay;
  bool downloading = false;
  String? downloadedImgPath;
  bool errorLoadingVideo = false;
  @override
  void initState() {
    super.initState();

    if (widget.currentMessage.type == "VIDEO_TYPE") {
      // context.read<ChatCubit>().checkVideoExist(
      //     (jsonDecode(widget.currentMessage.url.toString()) as List<dynamic>)
      //         .map((e) => AttachmentModel.fromJson(
      //             jsonDecode(e) as Map<String, dynamic>))
      //         .toList()
      //         .first,
      //     widget.currentMessage);

      //initLocalVideoPlayer();
    }
    if (widget.currentMessage.type == "IMAGE_TYPE" ||
        widget.currentMessage.type == "FILE_TYPE") {
      // imgExist();
      // context.read<ChatCubit>().checkImageExist(
      //       widget.currentMessage,
      //     );
    }
    if (widget.currentMessage.type == "NAMECARD_TYPE") {
      context.read<UserCubit>().getUserSettings(
          targetUserId: widget.currentMessage.extraInfo?.parseInt64());
    }
  }

  @override
  void dispose() {
    videoPlayerController?.dispose();
    super.dispose();
  }

  Future<void> imgExist() async {
    final directory = Platform.isIOS
        ? await getApplicationDocumentsDirectory()
        : await getDownloadsDirectory();

    final urls = jsonDecode(widget.currentMessage.url ?? "[]");

    final isSender =
        widget.currentMessage.senderId == sl<CredentialService>().turmsId!;

    AttachmentModel urlsAttachment =
        AttachmentModel.fromJson(jsonDecode(urls[0]));

    if (isSender) {
      if (urlsAttachment.localPath != null) {
        final file = File(urlsAttachment.localPath!);
        if (file.existsSync()) {
          setState(() {
            downloadedImgPath = file.path;
          });
          return;
        }
      }
    }

    final file = File('${directory!.path}/${urlsAttachment.fileUrl}');
    if (file.existsSync()) {
      setState(() {
        downloadedImgPath = file.path;
      });
    }
  }

  Future<void> downloadVideoToLocal(
      {required String url, required String fileName}) async {
    log("download video $url");
    setState(() {
      downloading = true;
    });
    try {
      final res = await http.get(Uri.parse(url));
      if (res.statusCode == 200) {
        log("status ${res.statusCode}");
        final directory = Helper.directory;
        final file = File('${directory!.path}/$fileName');

        // Write the downloaded bytes to a file
        file.writeAsBytes(res.bodyBytes).then((File file) {
          setState(() {
            downloading = false;
          });
          initLocalVideoPlayer(reinitialize: true);
        });
      } else {
        setState(() {
          downloading = false;
        });
        throw Exception("Failed to get video. Status code: ${res.statusCode}");
      }
    } on Exception catch (e) {
      setState(() {
        downloading = false;
      });
      throw Exception("Failed to get video. Error: $e");
    }
  }

  Widget buildMessageContainerTurms() {
    final isSender =
        widget.currentMessage.senderId == sl<CredentialService>().turmsId!;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isSender && !widget.displayAvatar && widget.isGroup)
            const SizedBox(
              width: 40,
            ),
          Column(
            crossAxisAlignment:
                isSender ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.isGroup && !isSender) buildGroupSenderInfo(),
                  //if (widget.currentMessage.parentMessageId == "0")
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8.0,
                    ),
                    child: Text(
                      DateFormat("HH:mm").format(
                        widget.currentMessage.sentAt.toLocal(),
                      ),
                      style: Theme.of(context)
                          .textTheme
                          .labelSmall
                          ?.copyWith(color: Colors.grey),
                    ),
                  ),

                  if (widget.currentMessage.isPinned)
                    Image.asset(
                      "assets/icons/pin-msg.png",
                      height: 15,
                      color: Colors.orange,
                    ),
                  const SizedBox(width: 5),
                  if (widget.currentMessage.isFavourite)
                    const Icon(Icons.star, size: 15, color: Colors.grey),
                  // Icon(
                  //   Icons.done_all,
                  //   size: 15,
                  //   color: widget.currentMessage.isRead
                  //       ? Colors.green
                  //       : Colors.grey,
                  // )
                ],
              ),
              Row(
                children: [
                  if (isSender &&
                      widget.currentMessage.status !=
                          MessageStatusEnum.sent.value)
                    Row(children: [
                      widget.currentMessage.status ==
                              MessageStatusEnum.failed.value
                          ? const Icon(Icons.error, color: Colors.red)
                          : SizedBox(
                              height: 12,
                              width: 12,
                              child: Center(
                                child: CircularProgressIndicator(
                                    strokeWidth: 1,
                                    color: Theme.of(context).primaryColorLight),
                              ),
                            ),
                      const SizedBox(width: 5),
                    ]),
                  StreamBuilder(
                      stream: sl<DatabaseHelper>().fetchRelationship(
                          widget.conversation?.targetId.toString() ?? "0"),
                      builder: (context, snapshot) {
                        return InkWell(
                          splashFactory:
                              widget.currentMessage.type == "NAMECARD_TYPE"
                                  ? NoSplash.splashFactory
                                  : Theme.of(context).splashFactory,
                          splashColor:
                              widget.currentMessage.type == "NAMECARD_TYPE"
                                  ? Colors.transparent
                                  : Theme.of(context).splashColor,
                          onLongPress: () {
                            if (snapshot.data?.status == "deleted" ||
                                widget.currentMessage.type == "NAMECARD_TYPE" ||
                                (widget.currentMessage.extraInfo != "" &&
                                    (jsonDecode(widget.currentMessage.extraInfo
                                                .toString())
                                            is Map<String, dynamic> &&
                                        jsonDecode(widget
                                                .currentMessage.extraInfo
                                                .toString())
                                            .containsKey('isDeleted') &&
                                        jsonDecode(widget
                                            .currentMessage.extraInfo
                                            .toString())['isDeleted']))) {
                              return;
                            }

                            final renderBox =
                                context.findRenderObject() as RenderBox;
                            final offset = renderBox.localToGlobal(Offset.zero);

                            showPopupMenu(
                                context, offset, renderBox, !isSender);
                          },
                          child: widget.currentMessage.type == "STICKER_TYPE"
                              ? Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10.0, vertical: 3.0),
                                  child: getMessageWidgetTurm(isSender),
                                )
                              : AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  clipBehavior: Clip.hardEdge,
                                  decoration: BoxDecoration(
                                    borderRadius:
                                        BorderRadius.circular(15.0).subtract(
                                      isSender
                                          ? const BorderRadius.only(
                                              bottomRight:
                                                  Radius.circular(12.0))
                                          : const BorderRadius.only(
                                              topLeft: Radius.circular(12.0)),
                                    ),
                                    color: isSender
                                        ? AppColor.chatSenderBubbleColor
                                        : AppColor.chatReceiverBubbleColor,
                                  ),
                                  constraints: BoxConstraints(
                                    minWidth: 50,
                                    maxWidth:
                                        MediaQuery.sizeOf(context).width * 0.7,
                                  ),
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 10.0, vertical: 3.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        widget.currentMessage.parentMessageId !=
                                                "0"
                                            ? isSender
                                                ? CrossAxisAlignment.end
                                                : CrossAxisAlignment.start
                                            : CrossAxisAlignment.center,
                                    children: [
                                      if (widget
                                              .currentMessage.parentMessageId !=
                                          "0")
                                        buildParentMessage(),
                                      getMessageWidgetTurm(isSender),
                                    ],
                                  ),
                                ),
                        );
                      }),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> initPlayer() async {
    if (videoPlayerController != null) {
      if (videoPlayerController!.value.isInitialized) {
        return;
      }
    }

    Directory? dir;
    if (Platform.isIOS) {
      dir = await getApplicationDocumentsDirectory();
    } else {
      dir = await getDownloadsDirectory();
    }
    AttachmentModel attachmentModel =
        (jsonDecode(widget.currentMessage.url.toString()) as List<dynamic>)
            .map((e) =>
                AttachmentModel.fromJson(jsonDecode(e) as Map<String, dynamic>))
            .toList()
            .first;
    try {
      if (await File("${dir?.path}/${attachmentModel.fileName}").exists()) {
        videoPlayerController = VideoPlayerController.file(
            File("${dir?.path}/${attachmentModel.fileName}"));
      }
      await videoPlayerController?.initialize().then((_) {
        setState(() {});
      });
      log("initialize ${videoPlayerController?.dataSource},");
    } catch (error) {
      log("Error initializing video player: $error");
    }
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
      final urls = jsonDecode(widget.currentMessage.url ?? "[]");

      AttachmentModel attachmentModel =
          AttachmentModel.fromJson(jsonDecode(urls[0]));

      if (widget.currentMessage.status == MessageStatusEnum.sent.value) {
        attachmentModel = AttachmentModel.fromJson(jsonDecode(urls[0]));
      }

      if (widget.currentMessage.status != MessageStatusEnum.sent.value) {
        if (File("${attachmentModel.localPath}").existsSync()) {
          videoPlayerController =
              VideoPlayerController.file(File("${attachmentModel.localPath}"));

          await videoPlayerController?.initialize().then((_) {
            setState(() {
              errorLoadingVideo = false;
            });
          });

          log("initialize local when sending ${videoPlayerController?.dataSource},");
          return;
        }
      }

      if (File("${dir?.path}/${attachmentModel.fileUrl}").existsSync()) {
        videoPlayerController = VideoPlayerController.file(
            File("${dir?.path}/${attachmentModel.fileUrl}"));
        await videoPlayerController?.initialize().then((_) {
          setState(() {
            errorLoadingVideo = false;
          });
        });
        log("initialize local ${videoPlayerController?.dataSource}");
      }
    } catch (error) {
      log("Error initializing video player: $error");
      setState(() {
        errorLoadingVideo = true;
      });
    }
  }

  // Widget imgWidget(bool isSender) {
  //   final urls = jsonDecode(widget.currentMessage.url ?? "[]");
  //   final imageCaption = widget.currentMessage.content;
  //   AttachmentModel urlsAttachment =
  //       AttachmentModel.fromJson(jsonDecode(urls[0]));

  //   String thumbnailUrl =
  //       "${NetworkConstants.getThumbFileWithTokenUrl}${urlsAttachment.thumbnailPath}?token=${sl<CredentialService>().jwtToken}";
  //   log("thimbnailUrl $thumbnailUrl");
  //   String imgUrl =
  //       "${NetworkConstants.getFileWithTokenUrl}${urlsAttachment.fileUrl}?token=${sl<CredentialService>().jwtToken}";

  //   File localImgFile =
  //       File("${Helper.directory?.path}/${urlsAttachment.fileUrl}");
  //   return ClipRRect(
  //     child: Stack(alignment: AlignmentDirectional.center, children: [
  //       if (localImgFile.existsSync())
  //         Column(
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           children: [
  //             Image.file(
  //               localImgFile,
  //               errorBuilder: (context, error, stackTrace) {
  //                 log("erorr loading image $error");
  //                 return const SizedBox(
  //                   height: 50,
  //                   width: 70,
  //                   child: Center(
  //                       child: Icon(Icons.broken_image_outlined,
  //                           color: Colors.white)),
  //                 );
  //               },
  //               frameBuilder: (context, child, frame, wasSynchronouslyLoaded) =>
  //                   child,
  //             ),
  //             if (imageCaption.isNotEmpty)
  //               Padding(
  //                 padding: const EdgeInsets.symmetric(
  //                     horizontal: 15.0, vertical: 8.0),
  //                 child: Text(
  //                   imageCaption,
  //                   style: Theme.of(context).textTheme.bodyMedium?.copyWith(
  //                       color: isSender ? Colors.white : Colors.black),
  //                 ),
  //               )
  //           ],
  //         )
  //       else
  //         Column(
  //           children: [
  //             Image.network(
  //               thumbnailUrl,
  //               errorBuilder: (context, error, stackTrace) {
  //                 return Image.file(
  //                   localImgFile,
  //                   errorBuilder: (context, error, stackTrace) =>
  //                       const SizedBox(
  //                     height: 50,
  //                     width: 70,
  //                     child: Center(
  //                         child: Icon(Icons.delete, color: Colors.white)),
  //                   ),
  //                   frameBuilder:
  //                       (context, child, frame, wasSynchronouslyLoaded) =>
  //                           child,
  //                 );
  //               },
  //             ),
  //             if (imageCaption.isNotEmpty)
  //               Padding(
  //                 padding: const EdgeInsets.symmetric(
  //                     horizontal: 15.0, vertical: 8.0),
  //                 child: Text(imageCaption,
  //                     style: Theme.of(context).textTheme.bodyMedium?.copyWith(
  //                         color: isSender ? Colors.white : Colors.black)),
  //               )
  //           ],
  //         ),
  //       if (!localImgFile.existsSync())
  //         Positioned.fill(
  //           child: ClipRRect(
  //             child: BackdropFilter(
  //               filter: ui.ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
  //               child: Container(
  //                 decoration: BoxDecoration(
  //                     borderRadius: BorderRadius.only(
  //                       topLeft: isSender
  //                           ? const Radius.circular(15.0)
  //                           : const Radius.circular(3.0),
  //                       topRight: const Radius.circular(15.0),
  //                       bottomLeft: const Radius.circular(15.0),
  //                       bottomRight: isSender
  //                           ? const Radius.circular(3.0)
  //                           : const Radius.circular(15.0),
  //                     ),
  //                     color: Colors.grey.withOpacity(0.1)),
  //               ),
  //             ),
  //           ),
  //         ),
  //       if (!localImgFile.existsSync())
  //         GestureDetector(
  //           onTap: () async {
  //             await downloadImgToLocal(
  //                 url: imgUrl, fileName: urlsAttachment.fileUrl);
  //             Future.delayed(Durations.extralong2).then((_) {
  //               setState(() {});
  //             });
  //           },
  //           child: Align(
  //             alignment: Alignment.center,
  //             child: downloading
  //                 ? CircularProgressIndicator(
  //                     color: isSender
  //                         ? Colors.white
  //                         : Theme.of(context).primaryColorLight)
  //                 : Container(
  //                     width: 50,
  //                     height: 50,
  //                     decoration: const BoxDecoration(
  //                         shape: BoxShape.circle, color: Colors.grey),
  //                     child: const Center(
  //                         child: Icon(
  //                       Icons.download,
  //                       color: Colors.white,
  //                     )),
  //                   ),
  //           ),
  //         ),
  //     ]),
  //   );
  // }

  Future<Uint8List> thumbnailForVideo(String videoPath) async {
    final uint8list = await VideoThumbnail.thumbnailData(
      video: videoPath,
      maxWidth: 300,
      maxHeight: 600,
      // maxHeight: 80,
      // maxWidth:
      //     80, // specify the width of the thumbnail, let the height auto-scaled to keep the source aspect ratio
      quality: 40,
    );
    return uint8list;
  }

  Widget videoWidget(bool isSender) {
    final urls = jsonDecode(widget.currentMessage.url ?? "[]");

    Directory? dir = Helper.directory;

    AttachmentModel? attachmentModel;

    if (widget.currentMessage.status == MessageStatusEnum.sent.value) {
      attachmentModel = AttachmentModel.fromJson(jsonDecode(urls[0]));
    }

    String? localFilePath = "${dir?.path}/${attachmentModel?.fileUrl}";

    String videoUrl =
        "${NetworkConstants.getFileWithTokenUrl}${attachmentModel?.fileUrl}?token=${sl<CredentialService>().jwtToken}";

    File(localFilePath).existsSync();

    return ClipRRect(
        child: Stack(
      alignment: AlignmentDirectional.center,
      children: [
        ClipRRect(
          child: !File(localFilePath).existsSync()
              ? const SizedBox(
                  height: 170,
                  child: Text("Video not found"),
                )
              : videoPlayerController == null ||
                      !videoPlayerController!.value.isInitialized
                  ? FutureBuilder<Uint8List>(
                      future: thumbnailForVideo(localFilePath),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          return Stack(
                              alignment: AlignmentDirectional.center,
                              children: [
                                SizedBox(
                                    width: MediaQuery.sizeOf(context).width,
                                    height: 300,
                                    child: Image.memory(snapshot.data!)),
                                Positioned.fill(
                                  child: ClipRRect(
                                    child: BackdropFilter(
                                      filter: ui.ImageFilter.blur(
                                          sigmaX: 5.0, sigmaY: 5.0),
                                      child: Container(
                                        decoration: BoxDecoration(
                                            borderRadius: BorderRadius.only(
                                                topLeft: isSender
                                                    ? const Radius.circular(
                                                        15.0)
                                                    : const Radius.circular(
                                                        3.0),
                                                topRight:
                                                    const Radius.circular(15.0),
                                                bottomLeft:
                                                    const Radius.circular(15.0),
                                                bottomRight: isSender
                                                    ? const Radius.circular(3.0)
                                                    : const Radius.circular(
                                                        15.0)),
                                            color:
                                                Colors.grey.withOpacity(0.1)),
                                      ),
                                    ),
                                  ),
                                ),
                                Container(
                                  width: 50,
                                  height: 50,
                                  decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.grey),
                                  child: Center(
                                      child: IconButton(
                                    onPressed: () => initLocalVideoPlayer(),
                                    icon: const Icon(Icons.play_arrow),
                                    color: Colors.white,
                                  )),
                                )
                              ]);
                        } else if (snapshot.hasError) {
                          return Container(
                            padding: const EdgeInsets.all(8),
                            color: Colors.red,
                            child: Text(
                                'Error:\n${snapshot.error}\n\n${snapshot.stackTrace}'),
                          );
                        }
                        return SizedBox(
                          width: 200,
                          height: 200,
                          child: Center(
                            child: CircularProgressIndicator(
                              color:
                                  isSender ? Colors.white : Colors.blueAccent,
                            ),
                          ),
                        );
                      },
                    )
                  : Column(
                      children: [
                        AspectRatio(
                          aspectRatio: 3 / 4,
                          child: Chewie(
                            controller: ChewieController(
                              videoPlayerController: videoPlayerController!,
                              autoPlay: true,
                              autoInitialize: true,
                              aspectRatio: 3 / 4,
                              bufferingBuilder: (context) => const Center(
                                child: CircularProgressIndicator(),
                              ),
                              showControlsOnInitialize:
                                  (!File(localFilePath).existsSync())
                                      ? false
                                      : true,
                              progressIndicatorDelay: bufferDelay != null
                                  ? Duration(milliseconds: bufferDelay!)
                                  : null,
                              placeholder: SizedBox(
                                height: videoPlayerController
                                            ?.value.aspectRatio !=
                                        null
                                    ? MediaQuery.sizeOf(context).height * 0.2
                                    : 200,
                              ),
                              errorBuilder: (context, errorMessage) {
                                return const Center(
                                  child: SizedBox(
                                    height: 50,
                                    width: 70,
                                    child: Center(
                                        child: Icon(Icons.music_video,
                                            color: Colors.white)),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        if (widget.currentMessage.content != "")
                          Text(widget.currentMessage.content)
                      ],
                    ),
        ),
        if (!File(localFilePath).existsSync())
          Positioned.fill(
            child: ClipRRect(
              child: BackdropFilter(
                filter: ui.ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                child: Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                          topLeft: isSender
                              ? const Radius.circular(15.0)
                              : const Radius.circular(3.0),
                          topRight: const Radius.circular(15.0),
                          bottomLeft: const Radius.circular(15.0),
                          bottomRight: isSender
                              ? const Radius.circular(3.0)
                              : const Radius.circular(15.0)),
                      color: Colors.grey.withOpacity(0.1)),
                ),
              ),
            ),
          ),
        if (!File(localFilePath).existsSync())
          GestureDetector(
            onTap: () {
              downloadVideoToLocal(
                  url: videoUrl, fileName: attachmentModel!.fileUrl);
            },
            child: Align(
              alignment: Alignment.center,
              child: downloading
                  ? CircularProgressIndicator(
                      color: isSender
                          ? Colors.white
                          : Theme.of(context).primaryColorLight)
                  : Container(
                      width: 50,
                      height: 50,
                      decoration: const BoxDecoration(
                          shape: BoxShape.circle, color: Colors.grey),
                      child: const Center(
                          child: Icon(
                        Icons.download,
                        color: Colors.white,
                      )),
                    ),
            ),
          ),
      ],
    ));
  }

  Widget getMessageWidgetTurm(bool isSender) {
    switch (widget.currentMessage.type) {
      case "IMAGE_TYPE":
        final urls = jsonDecode(widget.currentMessage.url ?? "[]");

        if (widget.currentMessage.status != MessageStatusEnum.sent.value) {
          if ((urls as List).isNotEmpty) {
            AttachmentModel attachment =
                AttachmentModel.fromJson(jsonDecode(urls[0]));

            if (attachment.localPath != null) {
              // return Image.file(
              //   File(
              //     "${attachment.localPath}",
              //   ),
              //   height: 200,
              //   errorBuilder: (context, error, stackTrace) => const SizedBox(
              //     height: 50,
              //     width: 70,
              //     child: Center(
              //         child: Icon(Icons.broken_image_outlined,
              //             color: Colors.white)),
              //   ),
              //   frameBuilder: (context, child, frame, wasSynchronouslyLoaded) =>
              //       child,
              // );
            }
          }
        }

        // AttachmentModel urlsAttachment =
        //     AttachmentModel.fromJson(jsonDecode(urls[0]));

        // String thumbnailUrl =
        //     "${NetworkConstants.getThumbFileWithTokenUrl}${urlsAttachment.thumbnailPath}?token=${sl<CredentialService>().jwtToken}";

        // String imgUrl =
        //     "${NetworkConstants.getFileWithTokenUrl}${urlsAttachment.fileUrl}?token=${sl<CredentialService>().jwtToken}";

        // AttachmentModel attachment =
        //     AttachmentModel.fromJson(extraInfo["attachments"][0]);

        // if (isSender) {
        //   return Image.file(
        //     File("${attachment.localPath}"),
        //     errorBuilder: (context, error, stackTrace) => imgWidget(isSender),
        //     frameBuilder: (context, child, frame, wasSynchronouslyLoaded) =>
        //         child,
        //   );
        // }

        return ImageWidget(
          currentMessage: widget.currentMessage,
        );

      // return BlocBuilder<ChatCubit, ChatState>(
      //   builder: (context, state) {
      //     if (state.uploadAttachmentStatus ==
      //             UploadAttachmentStatus.uploading &&
      //         state.fileToUpload == widget.pickedImageToUpload) {
      //       return Container(
      //           width: 200,
      //           height: 250,
      //           decoration: const BoxDecoration(
      //               color: AppColor.greyButtonBorderColor),
      //           child: const Center(child: CircularProgressIndicator()));
      //     }
      //     bool hasMatchingAttachment = checkMatchingAttachment(state);

      // if (widget.currentMessage.status != MessageStatusEnum.sent.value) {
      //   final extraInfo = jsonDecode(
      //       widget.currentMessage.extraInfo?.toString() ?? "{}");

      //   if (extraInfo.containsKey("attachments")) {
      //     if ((extraInfo["attachments"] as List).isNotEmpty) {
      //       AttachmentModel attachment =
      //           AttachmentModel.fromJson(extraInfo["attachments"][0]);

      //       if (attachment.localPath != null) {
      //         return Image.file(
      //           File("${attachment.localPath}"),
      //           errorBuilder: (context, error, stackTrace) =>
      //               const SizedBox(
      //             height: 50,
      //             width: 70,
      //             child: Center(
      //                 child: Icon(Icons.broken_image_outlined,
      //                     color: Colors.white)),
      //           ),
      //           frameBuilder:
      //               (context, child, frame, wasSynchronouslyLoaded) =>
      //                   child,
      //         );
      //       }
      //     }
      //   }
      // }

      //     if (hasMatchingAttachment) {
      //       AttachmentModel attachment = getMatchingAttachment(
      //           state.attachmentList,
      //           widget.currentMessage.extraInfo.toString())!;

      //       return Image.file(
      //         File("${Helper.directory?.path}/${attachment.name}"),
      //         errorBuilder: (context, error, stackTrace) =>
      //             Text("error $error"),
      //         frameBuilder: (context, child, frame, wasSynchronouslyLoaded) =>
      //             child,
      //       );
      //     } else if (state.thumbnailList?.isNotEmpty ?? false) {
      //     return SizedBox(
      //       height: 300,
      //       child: Stack(alignment: AlignmentDirectional.center, children: [
      //         Image.memory(state.thumbnailList?.firstWhere((thumbnail) {
      //           return thumbnail['thumbnailUrl'] ==
      //               jsonDecode(widget.currentMessage.extraInfo.toString())[
      //                   "attachments"][0]['thumbnailPath'];
      //         })['thumbnailBytes']),
      //         ClipRRect(
      //           child: BackdropFilter(
      //             filter: ui.ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
      //             child: Container(
      //               decoration: BoxDecoration(
      //                   borderRadius: BorderRadius.only(
      //                       topLeft: isSender
      //                           ? const Radius.circular(15.0)
      //                           : const Radius.circular(3.0),
      //                       topRight: const Radius.circular(15.0),
      //                       bottomLeft: const Radius.circular(15.0),
      //                       bottomRight: isSender
      //                           ? const Radius.circular(3.0)
      //                           : const Radius.circular(15.0)),
      //                   color: Colors.grey.withOpacity(0.1)),
      //             ),
      //           ),
      //         ),
      //         GestureDetector(
      //           onTap: () {
      //             if (widget.currentMessage.id != null) {
      //               context.read<ChatCubit>().getImage(
      //                   jsonDecode(widget.currentMessage.url.toString())[0],
      //                   attachment?.name.toString() ?? "",
      //                   widget.currentMessage.id!.parseInt64());
      //             }
      //           },
      //           child: Align(
      //             alignment: Alignment.center,
      //             child: Container(
      //               width: 50,
      //               height: 50,
      //               decoration: const BoxDecoration(
      //                   shape: BoxShape.circle, color: Colors.grey),
      //               child: const Center(
      //                   child: Icon(
      //                 Icons.download,
      //                 color: Colors.white,
      //               )),
      //             ),
      //           ),
      //         ),
      //         if (state.downloadImageStatus ==
      //             DownloadImageStatus.downloading)
      //           const Center(
      //             child: CircularProgressIndicator(),
      //           ),
      //       ]),
      //     );
      //   } else {
      //     return const SizedBox();
      //   }
      //   //return Image.memory(state.image ?? Uint8List(0));
      // },
      // );
      case "NAMECARD_TYPE":
        return BlocConsumer<UserCubit, UserState>(
          listener: (context, userstate) {
            if (userstate.createRelationshipStatus ==
                CreateRelationshipStatus.success) {
              ToastUtils.showToast(
                context: context,
                msg: Strings.friendAddedSuccessfully,
                type: Type.success,
              );
              context.read<UserCubit>().resetAllUserStatus();
              // Navigator.pop(context);
              // Navigator.pushNamedAndRemoveUntil(context,
              //     AppPage.navBar.routeName, (_) => false,
              //     arguments: 1);
            }
            if (userstate.sendFriendRequestStatus ==
                SendFriendRequestStatus.success) {
              ToastUtils.showToast(
                context: context,
                msg: Strings.friendRequestSentSuccessfully,
                type: Type.success,
              );
              context.read<UserCubit>().resetAllUserStatus();
              //  Navigator.pop(context);

              // Navigator.pushNamedAndRemoveUntil(context,
              //     AppPage.navBar.routeName, (_) => false,
              //     arguments: 1);
            }
          },
          builder: (context, userstate) {
            log("user state get get ${userstate.getUsersStatus}");

            return Container(
              width: MediaQuery.sizeOf(context).width * 0.6,
              decoration:
                  BoxDecoration(borderRadius: BorderRadius.circular(15.0)),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Row(
                      children: [
                        Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: widget.currentMessage.extraInfo ==
                                    sl<CredentialService>().userId
                                ? CircleAvatar(
                                    child: Image.file(
                                      File(
                                          "${Helper.directory?.path}/${sl<CredentialService>().turmsId}_${context.read<ProfileCubit>().state.userProfile?.profileUrl}"),
                                      fit: BoxFit.cover,
                                      width: 40,
                                      height: 40,
                                      errorBuilder:
                                          (context, error, stackTrace) =>
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
                                      child: Text(
                                          widget.currentMessage.content[0]),
                                    ),
                                    targetId: widget.currentMessage.extraInfo
                                            ?.toString() ??
                                        "",
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
                          child: Text(widget.currentMessage.content.toString(),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                      color: isSender
                                          ? Colors.white
                                          : Colors.black)),
                        )
                      ],
                    ),
                  ),
                  Divider(
                    indent: 10,
                    endIndent: 10,
                    height: 0,
                    color: !isSender
                        ? AppColor.conversationBackgroundColor
                        : AppColor.blueDividerColor,
                  ),
                  if (widget.currentMessage.extraInfo !=
                      sl<CredentialService>().turmsId)
                    BlocBuilder<UserCubit, UserState>(
                      builder: (context, state) {
                        return TextButton(
                            onPressed: () async {
                              if (userstate.usersList.any((user) =>
                                  user.id ==
                                  widget.currentMessage.extraInfo
                                      ?.parseInt64())) {
                                db.Conversation? conversation =
                                    await sl<DatabaseHelper>().getConversation(
                                        DatabaseHelper.conversationId(
                                            targetId: widget
                                                    .currentMessage.extraInfo
                                                    ?.toString() ??
                                                "",
                                            myId: sl<CredentialService>()
                                                    .turmsId ??
                                                ""));
                                log("conversation namecard $conversation");
                                if (conversation == null) {
                                  await sl<DatabaseHelper>().upsertConversation(
                                      friendId: widget.currentMessage.extraInfo
                                              ?.toString() ??
                                          "",
                                      members: [
                                        widget.currentMessage.extraInfo
                                                ?.toString() ??
                                            "",
                                        sl<CredentialService>().turmsId ?? ""
                                      ],
                                      isGroup: false,
                                      targetId: widget.currentMessage.extraInfo
                                              ?.toString() ??
                                          "",
                                      title: widget.currentMessage.content,
                                      ownerId:
                                          sl<CredentialService>().turmsId ??
                                              "");

                                  conversation = await sl<DatabaseHelper>()
                                      .getConversation(
                                          DatabaseHelper.conversationId(
                                              targetId: widget
                                                      .currentMessage.extraInfo
                                                      ?.toString() ??
                                                  "",
                                              myId: sl<CredentialService>()
                                                      .turmsId ??
                                                  ""));

                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                        builder: (context) => MessageScreen(
                                            conversation: conversation,
                                            isGroup: false)),
                                  );

                                  return;
                                }
                                Navigator.pop(context);
                                Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => MessageScreen(
                                    conversation: conversation,
                                    isGroup: conversation?.isGroup ?? false,
                                  ),
                                ));
                              } else {
                                if (state
                                        .userSettings[
                                            'ADD_ME_NEED_VERIFICATION']
                                        ?.int32Value ==
                                    1) {
                                  context.read<UserCubit>().sendFriendRequest(
                                      widget.currentMessage.extraInfo
                                              ?.parseInt64() ??
                                          Int64(0));
                                } else {
                                  context
                                      .read<UserCubit>()
                                      .addFriendWithoutRequest(widget
                                              .currentMessage.extraInfo
                                              ?.parseInt64() ??
                                          Int64(0));
                                }
                              }
                            },
                            child: Text(
                              userstate.usersList.any((user) =>
                                      user.id ==
                                      widget.currentMessage.extraInfo
                                          ?.parseInt64())
                                  ? Strings.message
                                  : !widget.conversation!.id.contains(
                                          widget.currentMessage.extraInfo ??
                                              "0")
                                      ? Strings.addFriend
                                      : widget.currentMessage.extraInfo ==
                                              sl<CredentialService>().turmsId
                                          ? Strings.you
                                          : "",
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.copyWith(
                                      color: isSender
                                          ? Colors.white
                                          : AppColor.blueText),
                            ));
                      },
                    )
                ],
              ),
            );
          },
        );

      case "VIDEO_TYPE":
        return videoWidget(isSender);

      // return BlocConsumer<ChatCubit, ChatState>(
      //   listenWhen: (previous, current) =>
      //       previous.attachmentList
      //               .where((attachment) => attachment.type == "video")
      //               .length !=
      //           current.attachmentList
      //               .where((attachment) => attachment.type == "video")
      //               .length ||
      //       previous.videoThumbnail.length != current.videoThumbnail.length,
      //   listener: (context, state) async {
      //     if (checkMatchingAttachment(state)) {
      //       await initPlayer();
      //     }
      //   },
      //   builder: (context, state) {
      //     if (state.videoThumbnail.isNotEmpty) {}
      //     if (state.videoThumbnail.isNotEmpty &&
      //         state.videoThumbnail.any((thumb) => p
      //             .basenameWithoutExtension(thumb)
      //             .contains(
      //                 p.basenameWithoutExtension(attachment?.name ?? "")))) {
      //       return SizedBox(
      //         height: 200,
      //         child: Stack(
      //           children: [
      //             Image.file(
      //               width: double.infinity,
      //               File(state.videoThumbnail.firstWhere((thumbnail) {
      //                 return p.basenameWithoutExtension(thumbnail).contains(
      //                     p.basenameWithoutExtension(attachment?.name ?? ""));
      //               })),
      //               fit: BoxFit.cover,
      //             ),
      //             ClipRRect(
      //               child: BackdropFilter(
      //                 filter: ui.ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
      //                 child: Container(
      //                   decoration: BoxDecoration(
      //                       borderRadius: BorderRadius.only(
      //                           topLeft: isSender
      //                               ? const Radius.circular(15.0)
      //                               : const Radius.circular(3.0),
      //                           topRight: const Radius.circular(15.0),
      //                           bottomLeft: const Radius.circular(15.0),
      //                           bottomRight: isSender
      //                               ? const Radius.circular(3.0)
      //                               : const Radius.circular(15.0)),
      //                       color: Colors.grey.withOpacity(0.1)),
      //                 ),
      //               ),
      //             ),
      //             GestureDetector(
      //               onTap: () => widget.currentMessage.id != null
      //                   ? context.read<ChatCubit>().getVideo(
      //                       jsonDecode(
      //                           widget.currentMessage.url.toString())[0],
      //                       attachment?.name.toString() ?? "",
      //                       widget.currentMessage.id!.parseInt64())
      //                   : null,
      //               child: Align(
      //                 alignment: Alignment.center,
      //                 child: Container(
      //                   width: 50,
      //                   height: 50,
      //                   decoration: const BoxDecoration(
      //                       shape: BoxShape.circle, color: Colors.grey),
      //                   child: const Center(
      //                       child: Icon(
      //                     Icons.download,
      //                     color: Colors.white,
      //                   )),
      //                 ),
      //               ),
      //             ),
      //             if (state.downloadStatus == DownloadStatus.downloading &&
      //                 state.videoThumbnail.singleWhere((thumb) => p
      //                         .basenameWithoutExtension(thumb)
      //                         .contains(p.basenameWithoutExtension(
      //                             attachment?.name ?? ""))) ==
      //                     attachment?.name)
      //               const Center(
      //                 child: CircularProgressIndicator(),
      //               ),
      //           ],
      //         ),
      //       );
      //     } else if (checkMatchingAttachment(state)) {
      //       if ((videoPlayerController != null &&
      //           videoPlayerController!.value.isInitialized)) {
      //         return ClipRRect(
      //           child: AspectRatio(
      //             aspectRatio: videoPlayerController!.value.aspectRatio,
      //             child: Chewie(
      //               controller: ChewieController(
      //                 videoPlayerController: videoPlayerController!,
      //                 autoInitialize: false,
      //                 showControlsOnInitialize: false,
      //                 progressIndicatorDelay: bufferDelay != null
      //                     ? Duration(milliseconds: bufferDelay!)
      //                     : null,
      //               ),
      //             ),
      //           ),
      //         );
      //       }
      //     }
      //     return GestureDetector(
      //       onTap: () {
      //         // context.read<ChatCubit>().downloadFile(
      //         //     jsonDecode(widget.currentMessage.url.toString())[0],
      //         //     "try video.mp4");
      //       },
      //       child: const SizedBox(
      //           // width: 300,
      //           // height: 200,
      //           // child: Chewie(
      //           //   controller: ChewieController(
      //           //     videoPlayerController: videoPlayerController!,
      //           //     progressIndicatorDelay: bufferDelay != null
      //           //         ? Duration(milliseconds: bufferDelay!)
      //           //         : null,
      //           //   ),
      //           // ),
      //           ),
      //     );
      //   },
      // );
      case "STICKER_TYPE":
        return (jsonDecode(widget.currentMessage.url.toString()) as List)
                .isEmpty
            ? const SizedBox()
            : Image.network(
                "${NetworkConstants.getStickerWithTokenUrl}${jsonDecode(widget.currentMessage.url ?? "")[0]}?token=${sl<CredentialService>().jwtToken}",
                width: 100,
                height: 100,
                errorBuilder: (context, error, stackTrace) => SizedBox(
                      height: 50,
                      child: Center(
                          child: Row(
                        children: [
                          const Icon(Icons.broken_image_outlined,
                              color: Colors.grey),
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
      case "FILE_TYPE":
        return buildFileWidget(context, isSender);
      case "CALL_TYPE":
        final content = widget.currentMessage.content.toString();
        final extraInfo =
            jsonDecode(widget.currentMessage.extraInfo?.toString() ?? "{}");
        final eventType = extraInfo["eventType"];
        final callId = extraInfo["callId"];

        return Padding(
          padding: const EdgeInsets.all(15.0),
          child: Text(
            content,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: isSender ? Colors.white : Colors.black),
          ),
        );
      case "VOICE_TYPE":
        if (widget.currentMessage.status != MessageStatusEnum.sent.value) {
          final extraInfo =
              jsonDecode(widget.currentMessage.url?.toString() ?? "{}");

          if ((extraInfo as List).isNotEmpty) {
            AttachmentModel attachment =
                AttachmentModel.fromJson(jsonDecode(extraInfo[0]));

            if (attachment.localPath != null) {
              return PlayerWidget(
                  isReceiver: !isSender, voiceSource: attachment.localPath!);
            }
          }
        }

        final extraInfo =
            jsonDecode(widget.currentMessage.url?.toString() ?? "{}");

        AttachmentModel? attachment;

        if ((extraInfo as List).isNotEmpty) {
          attachment = AttachmentModel.fromJson(jsonDecode(extraInfo[0]));

          // return PlayerWidget(
          //     isReceiver: !isSender, voiceSource: attachment.fileUrl);
        }

        if (attachment == null) {
          return PlayerWidget(
              isReceiver: !isSender, voiceSource: "", isLocal: false);
        }

        return PlayerWidget(
            isReceiver: !isSender,
            voiceSource: attachment.fileUrl,
            isLocal: false);
      default:
    }
    return Padding(
      padding: widget.currentMessage.parentMessageId != "0"
          ? const EdgeInsets.symmetric(horizontal: 15.0, vertical: 5.0)
          : const EdgeInsets.all(
              15.0,
            ),
      child: BlocBuilder<ChatCubit, ChatState>(
        builder: (context, state) {
          final content = widget.currentMessage.content.toString();
          final isExpanded =
              state.expandTextId.contains(widget.currentMessage.id);
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                content.length > 1600 && !isExpanded
                    ? '${content.substring(0, 1600)}...' // Truncate the text and add ellipsis
                    : content, // Show the full content if expanded
                softWrap: true,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: isSender ? Colors.white : Colors.black),
              ),
              if (content.length > 1600) // Assume overflow if content is long
                GestureDetector(
                  onTap: () => widget.currentMessage.id != null
                      ? context
                          .read<ChatCubit>()
                          .expandText(widget.currentMessage.id!)
                      : null,
                  child: Text(
                    isExpanded ? Strings.showLess : Strings.showMore,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: Colors.blue),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  bool checkMatchingAttachment(ChatState state) {
    final List<dynamic> extraInfoDecoded =
        jsonDecode(widget.currentMessage.url.toString());

    // Map extraInfoDecoded to a list of AttachmentModel
    final List<AttachmentModel> extraInfoAttachments = extraInfoDecoded
        .map((e) => AttachmentModel.fromJson(e as Map<String, dynamic>))
        .toList();

    // Check if any attachment name matches
    final hasMatchingAttachment = extraInfoAttachments.any((attachment) =>
        state.attachmentList.any((stateAttachment) =>
            stateAttachment.fileName == attachment.fileName));
    return hasMatchingAttachment;
  }

  AttachmentModel? getMatchingAttachment(
      List<AttachmentModel> stateAttachments, String extraInfo) {
    final List<dynamic> extraInfoDecoded = jsonDecode(extraInfo);
    final List<AttachmentModel> extraInfoAttachments = extraInfoDecoded
        .map((e) => AttachmentModel.fromJson(e as Map<String, dynamic>))
        .toList();
    log("load attachment");
    return stateAttachments.firstWhere(
      (attachment) => extraInfoAttachments.any(
          (stateAttachment) => stateAttachment.fileName == attachment.fileName),
    );
  }

  Future<void> favouriteMessage({required String messageId}) async {
    await sl<DatabaseHelper>().favouriteMessage(messageId);
    await sl<TurmsService>().favouriteMessage(messageId: messageId);
  }

  Future<void> unfavouriteMessage({required String messageId}) async {
    await sl<DatabaseHelper>().unFavouriteMessage(messageId);
    await sl<TurmsService>().unfavouriteMessage(messageId: messageId);
  }

  /// Show a popup menu for the given message.
  /// This popup menu will contain options to reply, edit, pin, select, translate,
  /// copy, and delete the message.
  void showPopupMenu(BuildContext context, Offset offset, RenderBox renderBox,
      bool isReceiver) {
    final chatTriggerCubit = context.read<ChatTriggerCubit>();
    final chatCubit = context.read<ChatCubit>();
    final message = widget.currentMessage;
    showGeneralDialog(
      context: context,
      transitionBuilder: (context, a1, a2, x) {
        return Transform.scale(
          scale: a1.value,
          child: Opacity(
              opacity: a1.value,
              child: BackdropFilter(
                filter: ui.ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                child: SimpleDialog(
                  insetPadding: const EdgeInsets.all(10.0),
                  backgroundColor: Colors.transparent,
                  alignment:
                      isReceiver ? Alignment.centerLeft : Alignment.centerRight,
                  children: [
                    widget.currentMessage.type == "VIDEO_TYPE"
                        ? SizedBox(
                            width: MediaQuery.sizeOf(context).width * 0.6,
                            child: Column(
                              crossAxisAlignment: isReceiver
                                  ? CrossAxisAlignment.start
                                  : CrossAxisAlignment.end,
                              children: [
                                buildMessageContainerTurms(),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5.0),
                                      color: Colors.white,
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        buildPopupItem(context, Strings.reply,
                                            () {
                                          chatTriggerCubit.toggleReplyMessage(
                                              message: message);
                                          if (chatTriggerCubit
                                              .state.isEditing) {
                                            chatTriggerCubit.toggleEditing();
                                          }
                                        }, Icons.message),
                                        buildPopupItem(context, Strings.edit,
                                            () {
                                          chatTriggerCubit.toggleEditing(
                                              message: message);
                                          if (chatTriggerCubit.state.isReply) {
                                            chatTriggerCubit
                                                .toggleReplyMessage();
                                          }
                                        }, Icons.edit),
                                        buildPopupItem(
                                            context,
                                            widget.currentMessage.isPinned
                                                ? Strings.unpin
                                                : Strings.pin, () async {
                                          chatCubit.savePinnedMessages(
                                              message.id.toString(),
                                              widget.currentMessage.isPinned
                                                  ? false
                                                  : true);
                                        }, Icons.push_pin),
                                        buildPopupItem(context, Strings.select,
                                            () {
                                          chatTriggerCubit.toggleSelect();
                                        }, Icons.done),
                                        buildPopupItem(context, Strings.forward,
                                            () {
                                          Navigator.of(context).pushNamed(
                                              AppPage.friendSelection.routeName,
                                              arguments: [
                                                widget.currentMessage
                                              ]);
                                        }, Icons.forward),
                                        buildPopupItem(
                                            context,
                                            widget.currentMessage.isFavourite
                                                ? Strings.unFavourite
                                                : Strings.favourite, () {
                                          String? messageId =
                                              widget.currentMessage.id;
                                          if (messageId != null) {
                                            if (widget
                                                .currentMessage.isFavourite) {
                                              unfavouriteMessage(
                                                  messageId: messageId);
                                            } else {
                                              favouriteMessage(
                                                  messageId: messageId);
                                            }
                                          }
                                        }, Icons.star),
                                        buildPopupItem(context, Strings.copy,
                                            () async {
                                          await Clipboard.setData(
                                            ClipboardData(
                                                text: message.content),
                                          );
                                        }, Icons.copy),
                                        buildPopupItem(context, Strings.delete,
                                            () {
                                          showDialog(
                                            context: context,
                                            builder: (dialogContext) {
                                              return BlocListener<ChatCubit,
                                                  ChatState>(
                                                listener: (context, state) {
                                                  if (state
                                                          .recallMessageStatus ==
                                                      RecallMessageStatus
                                                          .recallTimeout) {
                                                    showDialog(
                                                      context: context,
                                                      builder: (context) {
                                                        return AlertDialog(
                                                          title: Row(
                                                            children: [
                                                              const Icon(
                                                                  Icons
                                                                      .error_outline,
                                                                  color: Colors
                                                                      .red),
                                                              const SizedBox(
                                                                width: 5,
                                                              ),
                                                              Text(Strings
                                                                  .recallMessageFailed),
                                                            ],
                                                          ),
                                                          content: Text(state
                                                              .recallErrorMessage),
                                                          actions: [
                                                            TextButton(
                                                              onPressed: () =>
                                                                  Navigator.pop(
                                                                      context),
                                                              child: Text(
                                                                  Strings.ok),
                                                            )
                                                          ],
                                                        );
                                                      },
                                                    );
                                                  }
                                                },
                                                child: AlertDialog(
                                                  title: Text(
                                                      Strings.deleteMessage),
                                                  content: Text(Strings
                                                      .deleteMessageDescription),
                                                  actions: [
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        TextButton(
                                                          onPressed: () =>
                                                              Navigator.pop(
                                                                  dialogContext),
                                                          child: Text(
                                                              Strings.cancel),
                                                        ),
                                                        TextButton(
                                                          onPressed: () {
                                                            chatCubit
                                                                .deleteMessage(
                                                                    [message]);
                                                            Navigator.pop(
                                                                dialogContext);
                                                          },
                                                          child: Text(Strings
                                                              .deleteForMe),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                  actionsAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                ),
                                              );
                                            },
                                          );
                                        }, Icons.delete),
                                        buildPopupItem(context, Strings.recall,
                                            () {
                                          showDialog(
                                            context: context,
                                            builder: (dialogContext) {
                                              return BlocListener<ChatCubit,
                                                  ChatState>(
                                                listener: (context, state) {
                                                  if (state
                                                          .recallMessageStatus ==
                                                      RecallMessageStatus
                                                          .recallTimeout) {
                                                    showDialog(
                                                      context: context,
                                                      builder: (context) {
                                                        return AlertDialog(
                                                          title: Row(
                                                            children: [
                                                              const Icon(
                                                                  Icons
                                                                      .error_outline,
                                                                  color: Colors
                                                                      .red),
                                                              const SizedBox(
                                                                width: 5,
                                                              ),
                                                              Text(Strings
                                                                  .recallMessageFailed),
                                                            ],
                                                          ),
                                                          content: Text(state
                                                              .recallErrorMessage),
                                                          actions: [
                                                            TextButton(
                                                              onPressed: () =>
                                                                  Navigator.pop(
                                                                      context),
                                                              child: Text(
                                                                  Strings.ok),
                                                            )
                                                          ],
                                                        );
                                                      },
                                                    );
                                                  }
                                                },
                                                child: AlertDialog(
                                                  title: Text(
                                                      Strings.recallMessage),
                                                  content: Text(Strings
                                                      .recallMessageDesc),
                                                  actions: [
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        TextButton(
                                                          onPressed: () =>
                                                              Navigator.pop(
                                                                  dialogContext),
                                                          child: Text(
                                                              Strings.cancel),
                                                        ),
                                                        TextButton(
                                                          onPressed: () async {
                                                            await chatCubit
                                                                .recallMessage(
                                                                    message,
                                                                    widget.messageList ??
                                                                        []);

                                                            Navigator.pop(
                                                                dialogContext);
                                                          },
                                                          child:
                                                              Text(Strings.ok),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                  actionsAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                ),
                                              );
                                            },
                                          );
                                        }, Icons.delete_forever)
                                      ],
                                    ),
                                  ),
                                )
                              ],
                            ),
                          )
                        : Column(
                            crossAxisAlignment: isReceiver
                                ? CrossAxisAlignment.start
                                : CrossAxisAlignment.end,
                            children: [
                              buildMessageContainerTurms(),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 12),
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5.0),
                                    color: Colors.white,
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      buildPopupItem(context, Strings.reply,
                                          () {
                                        chatTriggerCubit.toggleReplyMessage(
                                            message: message);
                                        if (chatTriggerCubit.state.isEditing) {
                                          chatTriggerCubit.toggleEditing();
                                        }
                                      }, Icons.message),
                                      buildPopupItem(context, Strings.edit, () {
                                        chatTriggerCubit.toggleEditing(
                                            message: message);
                                        if (chatTriggerCubit.state.isReply) {
                                          chatTriggerCubit.toggleReplyMessage();
                                        }
                                      }, Icons.edit),
                                      buildPopupItem(
                                          context,
                                          widget.currentMessage.isPinned
                                              ? Strings.unpin
                                              : Strings.pin, () async {
                                        chatCubit.savePinnedMessages(
                                            message.id.toString(),
                                            widget.currentMessage.isPinned
                                                ? false
                                                : true);
                                      }, Icons.push_pin),
                                      buildPopupItem(context, Strings.select,
                                          () {
                                        chatTriggerCubit.toggleSelect();
                                      }, Icons.done),
                                      buildPopupItem(context, Strings.forward,
                                          () {
                                        Navigator.of(context).pushNamed(
                                            AppPage.friendSelection.routeName,
                                            arguments: [widget.currentMessage]);
                                      }, Icons.forward),
                                      buildPopupItem(
                                          context,
                                          widget.currentMessage.isFavourite
                                              ? Strings.unFavourite
                                              : Strings.favourite, () {
                                        String? messageId =
                                            widget.currentMessage.id;
                                        if (messageId != null) {
                                          if (widget
                                              .currentMessage.isFavourite) {
                                            unfavouriteMessage(
                                                messageId: messageId);
                                          } else {
                                            favouriteMessage(
                                                messageId: messageId);
                                          }
                                        }
                                      }, Icons.star),
                                      buildPopupItem(context, Strings.copy,
                                          () async {
                                        await Clipboard.setData(
                                          ClipboardData(text: message.content),
                                        );
                                      }, Icons.copy),
                                      buildPopupItem(context, Strings.delete,
                                          () {
                                        showDialog(
                                          context: context,
                                          builder: (dialogContext) {
                                            return BlocListener<ChatCubit,
                                                ChatState>(
                                              listener: (context, state) {
                                                if (state.recallMessageStatus ==
                                                    RecallMessageStatus
                                                        .recallTimeout) {
                                                  showDialog(
                                                    context: context,
                                                    builder: (context) {
                                                      return AlertDialog(
                                                        title: Row(
                                                          children: [
                                                            const Icon(
                                                                Icons
                                                                    .error_outline,
                                                                color:
                                                                    Colors.red),
                                                            const SizedBox(
                                                              width: 5,
                                                            ),
                                                            Text(Strings
                                                                .recallMessageFailed),
                                                          ],
                                                        ),
                                                        content: Text(state
                                                            .recallErrorMessage),
                                                        actions: [
                                                          TextButton(
                                                            onPressed: () =>
                                                                Navigator.pop(
                                                                    context),
                                                            child: Text(
                                                                Strings.ok),
                                                          )
                                                        ],
                                                      );
                                                    },
                                                  );
                                                }
                                              },
                                              child: AlertDialog(
                                                title:
                                                    Text(Strings.deleteMessage),
                                                content: Text(Strings
                                                    .deleteMessageDescription),
                                                actions: [
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      TextButton(
                                                        onPressed: () =>
                                                            Navigator.pop(
                                                                dialogContext),
                                                        child: Text(
                                                            Strings.cancel),
                                                      ),
                                                      TextButton(
                                                        onPressed: () {
                                                          chatCubit
                                                              .deleteMessage(
                                                                  [message]);
                                                          Navigator.pop(
                                                              dialogContext);
                                                        },
                                                        child: Text(Strings
                                                            .deleteForMe),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                                actionsAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                              ),
                                            );
                                          },
                                        );
                                      }, Icons.delete),
                                      buildPopupItem(context, Strings.recall,
                                          () {
                                        showDialog(
                                          context: context,
                                          builder: (dialogContext) {
                                            return BlocListener<ChatCubit,
                                                ChatState>(
                                              listener: (context, state) {
                                                if (state.recallMessageStatus ==
                                                    RecallMessageStatus
                                                        .recallTimeout) {
                                                  showDialog(
                                                    context: context,
                                                    builder: (context) {
                                                      return AlertDialog(
                                                        title: Row(
                                                          children: [
                                                            const Icon(
                                                                Icons
                                                                    .error_outline,
                                                                color:
                                                                    Colors.red),
                                                            const SizedBox(
                                                              width: 5,
                                                            ),
                                                            Text(Strings
                                                                .recallMessageFailed),
                                                          ],
                                                        ),
                                                        content: Text(state
                                                            .recallErrorMessage),
                                                        actions: [
                                                          TextButton(
                                                            onPressed: () =>
                                                                Navigator.pop(
                                                                    context),
                                                            child: Text(
                                                                Strings.ok),
                                                          )
                                                        ],
                                                      );
                                                    },
                                                  );
                                                }
                                              },
                                              child: AlertDialog(
                                                title:
                                                    Text(Strings.recallMessage),
                                                content: Text(
                                                    Strings.recallMessageDesc),
                                                actions: [
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      TextButton(
                                                        onPressed: () =>
                                                            Navigator.pop(
                                                                dialogContext),
                                                        child: Text(
                                                            Strings.cancel),
                                                      ),
                                                      TextButton(
                                                        onPressed: () async {
                                                          await chatCubit
                                                              .recallMessage(
                                                                  message,
                                                                  widget.messageList ??
                                                                      []);

                                                          Navigator.pop(
                                                              dialogContext);
                                                        },
                                                        child: Text(Strings.ok),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                                actionsAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                              ),
                                            );
                                          },
                                        );
                                      }, Icons.delete_forever)
                                    ],
                                  ),
                                ),
                              )
                            ],
                          )
                  ],
                ),
              )),
        );
      },
      barrierDismissible: true,
      barrierLabel: '',
      transitionDuration: const Duration(milliseconds: 100),
      pageBuilder: (dialogContext, animation1, animation2) {
        return Container();
      },
    );
  }

  /// Builds a PopupMenuItem with the given label, icon, and onTap function.
  ///
  /// The onTap function is called when the menu item is tapped.
  ///
  /// The menu item is designed to be used in a PopupMenuButton.
  ///
  PopupMenuItem buildPopupItem(
      BuildContext context, String label, Function function, IconData icon) {
    return PopupMenuItem(
      padding: EdgeInsets.zero,
      height: 0,
      onTap: () => function(),
      child: buildMenuItemRow(context, label, icon),
    );
  }

  /// This is a helper function to create a reusable row for menu items.
  Widget buildMenuItemRow(BuildContext context, String label, IconData icon,
      {Color color = Colors.black}) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style:
                Theme.of(context).textTheme.bodyMedium?.copyWith(color: color),
          ),
          Icon(
            icon,
            color: color,
          ),
        ],
      ),
    );
  }

  /// Builds the parent message of the current message if it exists.
  /// The parent message is the message that the current message is replying to.
  Widget buildParentMessage() {
    final parentMessageJson = widget.currentMessage.parentMessage?.toString();
    if (parentMessageJson == null || parentMessageJson.isEmpty) {
      return const SizedBox.shrink();
    }

    final parentMessage = db.Message.fromJson(jsonDecode(parentMessageJson));
    final isSender =
        parentMessage.senderId.toString() == sl<CredentialService>().turmsId;

    AttachmentModel? attachment;
    File? localImgFile;
    String? thumbnailUrl;

    if (parentMessage.type == "IMAGE_TYPE") {
      final extraInfoJson = parentMessage.url?.toString();
      if (extraInfoJson != null && extraInfoJson.isNotEmpty) {
        final extraInfo = jsonDecode(extraInfoJson);

        if ((extraInfo as List).isNotEmpty) {
          attachment = AttachmentModel.fromJson(jsonDecode(extraInfo[0]));

          if (attachment.fileUrl.isNotEmpty) {
            localImgFile =
                File("${Helper.directory?.path}/${attachment.fileUrl}");
          }

          if (attachment.thumbnailPath?.isNotEmpty ?? false) {
            thumbnailUrl =
                "${NetworkConstants.getThumbFileWithTokenUrl}${attachment.thumbnailPath}?token=${sl<CredentialService>().jwtToken}";
          }
        }
      }
    } else if (parentMessage.type == "FILE_TYPE" ||
        parentMessage.type == "VOICE_TYPE" ||
        parentMessage.type == "VIDEO_TYPE") {
      attachment = AttachmentModel.fromJson(
          jsonDecode(jsonDecode(parentMessage.url.toString())[0]));
    }
    return Column(
      crossAxisAlignment:
          isSender ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Text(
            //   DateFormat("HH:mm").format(
            //     widget.currentMessage.sentAt.toLocal(),
            //   ),
            //   style: Theme.of(context)
            //       .textTheme
            //       .labelSmall
            //       ?.copyWith(color: Colors.grey),
            // ),

            if (widget.currentMessage.isPinned)
              Image.asset(
                "assets/icons/pin-msg.png",
                height: 15,
                color: Colors.orange,
              ),
            const SizedBox(width: 5),
            if (widget.currentMessage.isFavourite)
              const Icon(Icons.star, size: 15, color: Colors.grey)
          ],
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: GestureDetector(
            onTap: () {
              widget.itemScrollController?.scrollToElement(
                  identifier: parentMessage.messageId,
                  duration: const Duration(milliseconds: 300));
            },
            child: Container(
              constraints: const BoxConstraints(maxWidth: 300),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: isSender
                      ? const Radius.circular(15.0)
                      : const Radius.circular(3.0),
                  topRight: const Radius.circular(15.0),
                  bottomLeft: const Radius.circular(15.0),
                  bottomRight: isSender
                      ? const Radius.circular(3.0)
                      : const Radius.circular(15.0),
                ),
              ),
              child: Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                    color: const ui.Color.fromARGB(255, 220, 227, 255),
                    border: const Border(
                        left: BorderSide(
                            width: 4.0,
                            color: ui.Color.fromARGB(255, 16, 50, 220))),
                    borderRadius: BorderRadius.circular(8)),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    parentMessage.type == "VOICE_TYPE"
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              BlocBuilder<UserCubit, UserState>(
                                builder: (context, userstate) {
                                  return Text(
                                    parentMessage.senderId ==
                                                sl<CredentialService>()
                                                    .turmsId ||
                                            widget.currentMessage.extraInfo ==
                                                sl<CredentialService>().turmsId
                                        ? Strings.you
                                        : widget.isGroup
                                            ? context
                                                .read<GroupCubit>()
                                                .state
                                                .memberList
                                                .singleWhere((member) =>
                                                    member.id ==
                                                    parentMessage.senderId
                                                        .parseInt64())
                                                .name
                                            : userstate.userProfile?.name ?? "",
                                    overflow: TextOverflow.clip,
                                    softWrap: true,
                                    style:
                                        Theme.of(context).textTheme.bodyMedium,
                                  );
                                },
                              ),
                              Row(
                                children: [
                                  const Icon(Icons.mic),
                                  Text(Strings.audio),
                                ],
                              ),
                            ],
                          )
                        : parentMessage.type == "VIDEO_TYPE"
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  BlocBuilder<UserCubit, UserState>(
                                    builder: (context, userstate) {
                                      return Text(
                                        parentMessage.senderId ==
                                                    sl<CredentialService>()
                                                        .turmsId ||
                                                widget.currentMessage
                                                        .extraInfo ==
                                                    sl<CredentialService>()
                                                        .turmsId
                                            ? Strings.you
                                            : widget.isGroup
                                                ? context
                                                    .read<GroupCubit>()
                                                    .state
                                                    .memberList
                                                    .singleWhere((member) =>
                                                        member.id ==
                                                        parentMessage.senderId
                                                            .parseInt64())
                                                    .name
                                                : userstate.userProfile?.name ??
                                                    "",
                                        overflow: TextOverflow.clip,
                                        softWrap: true,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium,
                                      );
                                    },
                                  ),
                                  Row(
                                    children: [
                                      const Icon(Icons.video_camera_back),
                                      Text(Strings.video),
                                    ],
                                  ),
                                ],
                              )
                            : parentMessage.type == "FILE_TYPE"
                                ? Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      BlocBuilder<UserCubit, UserState>(
                                        builder: (context, userstate) {
                                          return Text(
                                            parentMessage.senderId ==
                                                        sl<CredentialService>()
                                                            .turmsId ||
                                                    widget.currentMessage
                                                            .extraInfo ==
                                                        sl<CredentialService>()
                                                            .turmsId
                                                ? Strings.you
                                                : widget.isGroup
                                                    ? context
                                                        .read<GroupCubit>()
                                                        .state
                                                        .memberList
                                                        .singleWhere((member) =>
                                                            member.id ==
                                                            parentMessage
                                                                .senderId
                                                                .parseInt64())
                                                        .name
                                                    : userstate.userProfile
                                                            ?.name ??
                                                        "",
                                            overflow: TextOverflow.clip,
                                            softWrap: true,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium,
                                          );
                                        },
                                      ),
                                      Row(
                                        children: [
                                          CircleAvatar(
                                            backgroundColor: Colors.white,
                                            child: Image.asset(
                                              "assets/icons/file-default.png",
                                            ),
                                          ),
                                          const SizedBox(
                                            width: 10,
                                          ),
                                          SizedBox(
                                            width: MediaQuery.sizeOf(context)
                                                    .width *
                                                0.45,
                                            child: Text(
                                              attachment?.fileName ?? "",
                                              overflow: TextOverflow.clip,
                                              softWrap: true,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium,
                                            ),
                                          )
                                        ],
                                      ),
                                    ],
                                  )
                                : Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      BlocBuilder<UserCubit, UserState>(
                                        builder: (context, userstate) {
                                          return Text(
                                            parentMessage.senderId ==
                                                        sl<CredentialService>()
                                                            .turmsId ||
                                                    widget.currentMessage
                                                            .extraInfo ==
                                                        sl<CredentialService>()
                                                            .turmsId
                                                ? Strings.you
                                                : widget.isGroup
                                                    ? context
                                                        .read<GroupCubit>()
                                                        .state
                                                        .memberList
                                                        .singleWhere((member) =>
                                                            member.id ==
                                                            parentMessage
                                                                .senderId
                                                                .parseInt64())
                                                        .name
                                                    : userstate.userProfile
                                                            ?.name ??
                                                        "",
                                            overflow: TextOverflow.clip,
                                            softWrap: true,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium,
                                          );
                                        },
                                      ),
                                      SizedBox(
                                        width:
                                            MediaQuery.sizeOf(context).width *
                                                0.45,
                                        child: Text(
                                          parentMessage.type == "FILE_TYPE"
                                              ? attachment?.fileName ?? ""
                                              : parentMessage.content,
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 2,
                                          softWrap: true,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium,
                                        ),
                                      ),
                                    ],
                                  ),
                    const SizedBox(width: 10),
                    if (parentMessage.type == "IMAGE_TYPE")
                      Stack(children: [
                        if (localImgFile != null && !localImgFile.existsSync())
                          Column(
                            children: [
                              if (thumbnailUrl != null)
                                Image.network(
                                  thumbnailUrl,
                                  width: 50,
                                  height: 50,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const SizedBox(
                                      height: 50,
                                      width: 50,
                                      child: Center(
                                          child: Icon(
                                              Icons.broken_image_outlined,
                                              color: Colors.white)),
                                    );
                                  },
                                ),
                            ],
                          ),
                        if (localImgFile != null && !localImgFile.existsSync())
                          Positioned.fill(
                            child: ClipRRect(
                              child: BackdropFilter(
                                filter: ui.ImageFilter.blur(
                                    sigmaX: 5.0, sigmaY: 5.0),
                                child: Container(
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.only(
                                        topLeft: isSender
                                            ? const Radius.circular(15.0)
                                            : const Radius.circular(3.0),
                                        topRight: const Radius.circular(15.0),
                                        bottomLeft: const Radius.circular(15.0),
                                        bottomRight: isSender
                                            ? const Radius.circular(3.0)
                                            : const Radius.circular(15.0),
                                      ),
                                      color: Colors.grey.withOpacity(0.1)),
                                ),
                              ),
                            ),
                          ),
                        if (localImgFile != null && localImgFile.existsSync())
                          Image.file(
                            localImgFile,
                            fit: BoxFit.cover,
                            height: 50,
                            width: 50,
                          )
                      ])
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Returns a checkbox that is checked if the current message is selected
  /// and unchecked otherwise. When the checkbox is toggled, it adds or removes
  /// the current message from the list of selected messages in the cubit.
  Widget buildCheckbox() {
    return BlocBuilder<ChatCubit, ChatState>(
      builder: (context, state) => Checkbox(
          value: state.selectedMessages.any(
              (messageInList) => messageInList.id == widget.currentMessage.id),
          onChanged: (value) {
            context.read<ChatCubit>().selectMessage(widget.currentMessage);
          }),
    );
  }

  bool checkPermission(String settingsKey,
      {bool reverseBool = false, bool? customOutputWhenOwnerIdEqualsUserId}) {
    final settings = widget.conversationSettings;
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

  Widget buildGroupSenderInfo() {
    String? memberName;

    memberName = context
        .read<GroupCubit>()
        .state
        .memberList
        .firstWhereOrNull(
            (user) => user.id == widget.currentMessage.senderId.parseInt64())
        ?.name;

    return BlocBuilder<GroupCubit, GroupState>(
      builder: (context, state) {
        if (state.getGroupMemberStatus == GetGroupMemberStatus.success) {
          return Padding(
            padding: const EdgeInsets.only(
              left: 5.0,
              right: 5,
            ),
            child: Text(
              checkPermission("IS_MEMBERS_INVISIBLE",
                      customOutputWhenOwnerIdEqualsUserId: false)
                  ? Strings.anonymous
                  : memberName ?? "",
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: Colors.orange),
            ),
          );
        }
        return const SizedBox();
      },
    );
  }

  Widget buildFileWidget(BuildContext context, bool isSender) {
    AttachmentModel attachmentModel =
        (jsonDecode(widget.currentMessage.url.toString()) as List<dynamic>)
            .map((e) =>
                AttachmentModel.fromJson(jsonDecode(e) as Map<String, dynamic>))
            .toList()
            .first;
    final file = File(
        '${Helper.directory?.path}/${attachmentModel.fileName}'); // Include user ID
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 10.0),
        child: BlocBuilder<ChatCubit, ChatState>(
          builder: (context, state) {
            return Column(
              children: [
                ListTile(
                  leading: state.downloadStatus == DownloadStatus.downloading &&
                          (state.fileToDownload?.fileName ==
                              attachmentModel.fileName)
                      ? Stack(
                          alignment: Alignment.center,
                          children: [
                            CircleAvatar(
                              backgroundColor: Colors.white,
                              child: Image.asset(
                                "assets/Buttons/download-03.png",
                              ),
                            ),
                            const CircularProgressIndicator()
                          ],
                        )
                      : CircleAvatar(
                          backgroundColor: Colors.white,
                          child: Image.asset(
                            !file.existsSync()
                                ? "assets/Buttons/download-03.png"
                                : "assets/icons/file-default.png",
                          ),
                        ),
                  onTap: () {
                    if (widget.currentMessage.id != null) {
                      context.read<ChatCubit>().downloadFile(
                          widget.currentMessage.url.toString(),
                          attachmentModel.fileName,
                          widget.currentMessage.id!.parseInt64());
                    }
                  },
                  visualDensity: const VisualDensity(vertical: -4),
                  title: Text(
                    attachmentModel.fileName,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: isSender ? Colors.white : Colors.black),
                  ),
                  subtitle: !file.existsSync()
                      ? Text(
                          Helper.formatFileSize(attachmentModel.fileSize ?? 0),
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(
                                  color:
                                      isSender ? Colors.white : Colors.black))
                      : const SizedBox(),
                ),
                if (widget.currentMessage.content != '')
                  Text(widget.currentMessage.content)
              ],
            );
          },
        ));
  }

  @override
  Widget build(BuildContext context) {
    final isSender =
        widget.currentMessage.senderId == sl<CredentialService>().turmsId!;
    return BlocBuilder<ChatTriggerCubit, ChatTriggerState>(
      builder: (context, state) {
        return Row(
          mainAxisAlignment:
              isSender ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: [
            if (state.isSelect)
              Flexible(
                  child: Align(
                      alignment: Alignment.centerLeft, child: buildCheckbox())),
            if ((widget.isGroup) && (!isSender && widget.displayAvatar))
              Flexible(
                flex: 5,
                child: Padding(
                  padding: const EdgeInsets.only(
                    left: 5.0,
                  ),
                  child: ChatAvatar(
                      errorWidget: CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.blue,
                        child: Image.network(
                          widget.currentMessage.senderId[0].toString(),
                          errorBuilder: (context, error, stackTrace) => Text(
                              widget.currentMessage.senderId[0].toString()),
                        ),
                      ),
                      targetId: widget.conversation?.targetId ?? "",
                      isGroup: widget.isGroup,
                      radius: 20),
                ),
              ),
            buildMessageContainerTurms(),
          ],
        );
      },
    );
  }
}

class ImageWidget extends StatefulWidget {
  const ImageWidget({super.key, required this.currentMessage});
  final db.Message currentMessage;
  @override
  State<ImageWidget> createState() => _ImageWidgetState();
}

class _ImageWidgetState extends State<ImageWidget> {
  bool downloading = false;
  File? localImgFile;
  bool isSender = false;
  String imageCaption = "";
  String thumbnailUrl = "";
  AttachmentModel? urlsAttachment;
  String imgUrl = "";
  bool imageLoaded = false;
  @override
  void initState() {
    super.initState();
    isSender =
        widget.currentMessage.senderId == sl<CredentialService>().turmsId!;

    final urls = jsonDecode(widget.currentMessage.url ?? "[]");

    imageCaption = widget.currentMessage.content;

    urlsAttachment = AttachmentModel.fromJson(jsonDecode(urls[0]));

    thumbnailUrl =
        "${NetworkConstants.getThumbFileWithTokenUrl}${urlsAttachment?.thumbnailPath}?token=${sl<CredentialService>().jwtToken}";

    log("thimbnailUrl $thumbnailUrl");
    imgUrl =
        "${NetworkConstants.getFileWithTokenUrl}${urlsAttachment?.fileUrl}?token=${sl<CredentialService>().jwtToken}";

    _loadImage();
  }

  @override
  void didUpdateWidget(covariant ImageWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentMessage != widget.currentMessage) {
      // Message has changed, update image if needed.
      _loadImage();
    }
  }

  _loadImage() {
    final directory = Helper.directory;
    if (directory != null && urlsAttachment?.fileUrl != null) {
      final file = File(
          '${directory.path}/${sl<CredentialService>().turmsId}_${urlsAttachment!.fileUrl}'); // Include user ID
      if (file.existsSync()) {
        setState(() {
          localImgFile = file;
          imageLoaded = true;
        });
      } else {
        // await downloadImgToLocal(
        //   url: imgUrl,
        //   fileName: urlsAttachment!.fileUrl,
        // );
      }
    } else {
      log("Error: Could not determine directory or file URL");
    }
  }

  @override
  Widget build(BuildContext context) {
    isSender =
        widget.currentMessage.senderId == sl<CredentialService>().turmsId!;

    final urls = jsonDecode(widget.currentMessage.url ?? "[]");

    imageCaption = widget.currentMessage.content;

    urlsAttachment = AttachmentModel.fromJson(jsonDecode(urls[0]));

    thumbnailUrl =
        "${NetworkConstants.getThumbFileWithTokenUrl}${urlsAttachment?.thumbnailPath}?token=${sl<CredentialService>().jwtToken}";

    log("thimbnailUrl $thumbnailUrl");
    imgUrl =
        "${NetworkConstants.getFileWithTokenUrl}${urlsAttachment?.fileUrl}?token=${sl<CredentialService>().jwtToken}";
    localImgFile = File(
        '${Helper.directory?.path}/${sl<CredentialService>().turmsId}_${urlsAttachment!.fileUrl}');

    return ClipRRect(
      child: Stack(alignment: AlignmentDirectional.center, children: [
        if (localImgFile != null && localImgFile!.existsSync() && imageLoaded)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.file(
                localImgFile!,
                errorBuilder: (context, error, stackTrace) {
                  log("erorr loading image $error");
                  return const SizedBox(
                    height: 50,
                    width: 70,
                    child: Center(
                        child: Icon(Icons.broken_image_outlined,
                            color: Colors.white)),
                  );
                },
                frameBuilder: (context, child, frame, wasSynchronouslyLoaded) =>
                    child,
              ),
              if (imageCaption.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 15.0, vertical: 8.0),
                  child: Text(
                    imageCaption,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: isSender ? Colors.white : Colors.black),
                  ),
                )
            ],
          )
        else
          Column(
            children: [
              Image.network(thumbnailUrl,
                  errorBuilder: (context, error, stackTrace) {
                return const SizedBox(
                  height: 50,
                  width: 70,
                  child: Center(
                    child: Icon(Icons.image_not_supported,
                        color: Colors.white), // Better placeholder
                  ),
                );
              }),
              if (imageCaption.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 15.0, vertical: 8.0),
                  child: Text(imageCaption,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: isSender ? Colors.white : Colors.black)),
                )
            ],
          ),
        if (!imageLoaded &&
            widget.currentMessage.status == MessageStatusEnum.sent.value)
          Positioned.fill(
            child: ClipRRect(
              child: BackdropFilter(
                filter: ui.ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                child: Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: isSender
                            ? const Radius.circular(15.0)
                            : const Radius.circular(3.0),
                        topRight: const Radius.circular(15.0),
                        bottomLeft: const Radius.circular(15.0),
                        bottomRight: isSender
                            ? const Radius.circular(3.0)
                            : const Radius.circular(15.0),
                      ),
                      color: Colors.grey.withOpacity(0.1)),
                ),
              ),
            ),
          ),
        if (!imageLoaded &&
            widget.currentMessage.status == MessageStatusEnum.sent.value)
          GestureDetector(
            onTap: () async {
              await downloadImgToLocal(
                  url: imgUrl, fileName: urlsAttachment?.fileUrl ?? "");
            },
            child: Align(
              alignment: Alignment.center,
              child: downloading
                  ? CircularProgressIndicator(
                      color: isSender
                          ? Colors.white
                          : Theme.of(context).primaryColorLight)
                  : Container(
                      width: 50,
                      height: 50,
                      decoration: const BoxDecoration(
                          shape: BoxShape.circle, color: Colors.grey),
                      child: const Center(
                          child: Icon(
                        Icons.download,
                        color: Colors.white,
                      )),
                    ),
            ),
          ),
      ]),
    );
  }

  Future<void> downloadImgToLocal(
      {required String url, required String fileName}) async {
    log("download image $url");
    setState(() {
      downloading = true;
    });
    try {
      final res = await http.get(Uri.parse(url));
      if (res.statusCode == 200) {
        log("status ${res.statusCode}");
        final directory = Platform.isIOS
            ? await getApplicationDocumentsDirectory()
            : await getDownloadsDirectory();
        final file = File(
            '${directory!.path}/${sl<CredentialService>().turmsId}_$fileName');

        // Write the downloaded bytes to a file
        await file.writeAsBytes(res.bodyBytes);
        if (mounted) {
          setState(() {
            downloading = false;
            localImgFile = file;
            log("downloadedImgPath $localImgFile");
          });
        }
      } else {
        if (mounted) {
          setState(() {
            downloading = false;
          });
        }

        throw Exception("Failed to get image. Status code: ${res.statusCode}");
      }
    } on Exception catch (e) {
      if (mounted) {
        setState(() {
          downloading = false;
        });
      }

      throw Exception("Failed to get image. Error: $e");
    }
  }
}
// // class ChatBubble extends StatefulWidget {
// //   const ChatBubble(
// //       {super.key,
// //       this.previousMessage,
// //       required this.currentMessage,
// //       required this.messageList,
// //       required this.channel,
// //       required this.displayAvatar,
// //       this.imageList,
// //       this.scrollController,
// //       this.readOnly = false // for pinned message
// //       });
// //   final Message? previousMessage;
// //   final Message currentMessage;
// //   final List<Message> messageList;
// //   final Channel channel;
// //   final bool displayAvatar;
// //   final List<Attachment>? imageList;
// //   final ScrollController? scrollController;
// //   final bool readOnly;

// //   @override
// //   State<ChatBubble> createState() => _ChatBubbleState();
// // }

// // class _ChatBubbleState extends State<ChatBubble> {
// //   late final AudioPlayer player;
// //   VideoPlayerController? videoPlayerController;
// //   int? bufferDelay;

// //   @override
// //   void initState() {
// //     player = AudioPlayer();
// //     if (widget.currentMessage.attachments
// //         .any((attachment) => attachment.type == "video")) {
// //       log("should check");

// //       context.read<ChatTriggerCubit>().checkVideoExist(
// //           widget.currentMessage.attachments.single.title.toString(),
// //           widget.currentMessage.attachments.single.assetUrl.toString());
// //     }
// //     // Set the release mode to keep the source after playback has completed.
// //     player.setReleaseMode(ReleaseMode.stop);

// //     super.initState();
// //   }

// //   // Regex to detect URLs in the message
// //   final RegExp urlRegExp = RegExp(
// //     r"(https?:\/\/[^\s]+)", // A simple URL matching regex
// //     caseSensitive: false,
// //   );
// //   // Function to scroll to the parent message
// //   // void scrollToParentMessage(String parentMessageId) {
// //   //   List<Message> reversedList = widget.messageList.reversed.toList();
// //   //   int index = reversedList.indexWhere((msg) => msg.id == parentMessageId);
// //   //   log("index parent msg ${index}");
// //   //   widget.scrollController?.animateTo(
// //   //     index.toDouble() * 70,
// //   //     duration: const Duration(seconds: 1),
// //   //     curve: Curves.easeInOut,
// //   //   );
// //   // }
// //   Future<void> initPlayer() async {
// //     Directory? dir;
// //     if (Platform.isIOS) {
// //       dir = await getApplicationDocumentsDirectory();
// //     } else {
// //       dir = await getDownloadsDirectory();
// //     }
// //     String path =
// //         '${dir?.path}/${widget.currentMessage.attachments.single.title}';
// //     try {
// //       if (await File(path).exists()) {
// //         log("path file exist $path");
// //         videoPlayerController = VideoPlayerController.file(File(path));
// //       } else {
// //         videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(
// //             "${widget.currentMessage.attachments.single.assetUrl}.mp4"));
// //       }
// //       await videoPlayerController?.initialize().then((_) {
// //         setState(() {});
// //       });
// //     } catch (error) {
// //       log("Error initializing video player: $error");
// //     }
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     final userUID = StreamChatCore.of(context).currentUser?.id.toString() ?? "";

// //     return InkWell(
// //       onLongPress: () {
// //         if (widget.readOnly || widget.channel.memberCount! < 2) {
// //           return;
// //         }
// //         final RenderBox renderBox = context.findRenderObject() as RenderBox;
// //         final Offset offset = renderBox.localToGlobal(Offset.zero);
// //         //context.read<ChatTriggerCubit>().toggleblur();
// //         showPopupMenu(context, offset, renderBox, userUID);
// //       },
// //       splashFactory: widget.readOnly
// //           ? NoSplash.splashFactory
// //           : Theme.of(context).splashFactory,
// //       splashColor:
// //           widget.readOnly ? Colors.transparent : Theme.of(context).splashColor,
// //       highlightColor: widget.readOnly
// //           ? Colors.transparent
// //           : Theme.of(context).highlightColor,
// //       child: BlocBuilder<ChatTriggerCubit, ChatTriggerState>(
// //         builder: (context, state) {
// //           final isSender = widget.currentMessage.user?.id == null ||
// //               widget.currentMessage.user?.id == userUID;

// //           return Stack(children: [
// //             if (state.isSelect)
// //               Container(
// //                 // padding: const EdgeInsets.symmetric(horizontal: 5),
// //                 decoration: BoxDecoration(
// //                   borderRadius: BorderRadius.circular(10.0),
// //                 ),
// //                 margin:
// //                     const EdgeInsets.symmetric(horizontal: 5.0, vertical: 3.0),
// //                 child: Row(
// //                   mainAxisAlignment: isSender
// //                       ? MainAxisAlignment.end
// //                       : MainAxisAlignment.start,
// //                   children: [
// //                     buildCheckbox(),
// //                     const SizedBox(
// //                       width: 10,
// //                     ),
//                     if (widget.currentMessage.quotedMessageId != null)
//                       ConstrainedBox(
//                         constraints:
//                             const BoxConstraints(minWidth: 50, maxWidth: 200),
//                         child: buildParentMessage(),
//                       ),
//                     buildMessageContainer(userUID),
// //                   ],
// //                 ),
// //               ),
// //             Container(
// //               // padding: const EdgeInsets.symmetric(horizontal: 5),
// //               decoration: BoxDecoration(
// //                 borderRadius: BorderRadius.circular(10.0),
// //               ),
// //               margin:
// //                   const EdgeInsets.symmetric(horizontal: 5.0, vertical: 3.0),
// //               child: Row(
// //                 mainAxisAlignment:
// //                     isSender ? MainAxisAlignment.end : MainAxisAlignment.start,
// //                 children: [
// //                   if (!isSender && widget.displayAvatar)
// //                     CircleAvatar(
// //                       radius: 20,
// //                       backgroundColor: Colors.white,
// //                       child: Image.network(
// //                         widget.currentMessage.user?.image.toString() ?? "",
// //                         errorBuilder: (context, error, stackTrace) => Text(
// //                             widget.currentMessage.user?.name[0].toString() ??
// //                                 ""),
// //                       ),
// //                     ),
// //                   if (!isSender &&
// //                       !widget.displayAvatar &&
// //                       widget.channel.memberCount! > 2)
// //                     const SizedBox(
// //                       width: 40,
// //                     ),
// //                   if (widget.currentMessage.isSystem)
// //                     Padding(
// //                       padding: const EdgeInsets.all(8.0),
// //                       child: SizedBox(
// //                         width: MediaQuery.sizeOf(context).width * 0.8,
// //                         child: Text(
// //                           widget.currentMessage.text.toString(),
// //                           textAlign: TextAlign.center,
// //                           style: Theme.of(context)
// //                               .textTheme
// //                               .labelMedium
// //                               ?.copyWith(color: AppColor.greyText),
// //                         ),
// //                       ),
// //                     ),
// //                   if (!widget.currentMessage.isSystem)
// //                     Column(
// //                       crossAxisAlignment: isSender
// //                           ? CrossAxisAlignment.end
// //                           : CrossAxisAlignment.start,
// //                       children: [
// //                         // if (widget.channel.isGroup) buildGroupSenderInfo(),
// //                         Padding(
// //                           padding: const EdgeInsets.only(
// //                               left: 10.0, right: 10.0, bottom: 5.0),
// //                           child: Text(
// //                             DateFormat("HH:mm").format(
// //                               widget.currentMessage.createdAt.toLocal(),
// //                             ),
// //                             style: Theme.of(context)
// //                                 .textTheme
// //                                 .labelSmall
// //                                 ?.copyWith(color: Colors.grey),
// //                           ),
// //                         ),
// //                         buildMessageContainer(userUID),
// //                       ],
// //                     ),
// //                 ],
// //               ),
// //             ),
// //           ]);
// //         },
// //       ),
// //     );
// //   }

// //   /// Show a popup menu for the given message.
// //   /// This popup menu will contain options to reply, edit, pin, select, translate,
// //   /// copy, and delete the message.
// //   void showPopupMenu(BuildContext context, Offset offset, RenderBox renderBox,
// //       String userUID) {
// //     bool isReceiver = widget.currentMessage.user?.id !=
// //         StreamChatCore.of(context).currentUser?.id;
// //     showDialog(
// //       context: context,
// //       builder: (dialogcontext) {
// //         return BackdropFilter(
// //           filter: ui.ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
// //           child: SimpleDialog(
// //             insetPadding: const EdgeInsets.all(30.0),
// //             backgroundColor: Colors.transparent,
// //             alignment:
// //                 isReceiver ? Alignment.centerLeft : Alignment.centerRight,
// //             children: [
// //               ReactionRow(
// //                 currentMessage: widget.currentMessage,
// //                 channel: widget.channel,
// //               ),
// //               const SizedBox(height: 10),
// //               SizedBox(width: 100, child: buildMessageContainer(userUID)),
// //               const SizedBox(height: 10),
// //               Container(
// //                 decoration: BoxDecoration(
// //                   borderRadius: BorderRadius.circular(5.0),
// //                   color: Colors.white,
// //                 ),
// //                 child: Column(
// //                   children: [
// //                     buildPopupItem(context, "Reply", () {
// //                       final chatTriggerCubit = context.read<ChatTriggerCubit>();
// //                       chatTriggerCubit.toggleReplyMessage(
// //                           message: widget.currentMessage);
// //                       if (chatTriggerCubit.state.isEditing) {
// //                         chatTriggerCubit.toggleEditing();
// //                       }
// //                     }, Icons.message),
// //                     if (widget.currentMessage.user?.id == userUID)
// //                       buildPopupItem(context, "Edit", () {
// //                         final chatTriggerCubit =
// //                             context.read<ChatTriggerCubit>();
// //                         chatTriggerCubit.toggleEditing(
// //                             message: widget.currentMessage);
// //                         if (chatTriggerCubit.state.isReply) {
// //                           chatTriggerCubit.toggleReplyMessage();
// //                         }
// //                       }, Icons.edit),
                    // buildPopupItem(
                    //     context, widget.currentMessage.pinned ? "Unpin" : "Pin",
                    //     () async {
                    //   final chatCore = StreamChatCore.of(context);
                    //   if (widget.currentMessage.pinned) {
                    //     chatCore.client.unpinMessage(widget.currentMessage.id);
                    //   } else {
                    //     final res = await chatCore.client
                    //         .pinMessage(widget.currentMessage.id);
                    //     if (res.message.pinned && mounted) {
                    //       context.read<ChatCubit>().savePinnedMessages(context);
                    //       widget.channel.sendMessage(Message(
                    //           text:
                    //               "${chatCore.currentUser?.name} pinned a message",
                    //           type: "system"));
                    //     }
                    //   }
                    // }, Icons.push_pin),
// //                     buildPopupItem(context, "Select", () {
// //                       context.read<ChatTriggerCubit>().toggleSelect();
// //                     }, Icons.done),
// //                     buildPopupItem(
// //                         context, "Translate", () {}, Icons.translate),
// //                     buildPopupItem(context, "Copy", () async {
// //                       await Clipboard.setData(
// //                         ClipboardData(
// //                             text: widget.currentMessage.text.toString()),
// //                       );
// //                       ScaffoldMessenger.of(context).showSnackBar(
// //                         const SnackBar(content: Text("Text Copied")),
// //                       );
// //                     }, Icons.copy),
// //                     buildPopupItem(context, "Delete", () {
// //                       showDialog(
// //                         context: context,
// //                         builder: (dialogContext) {
// //                           return AlertDialog(
// //                             title: const Text("Delete Message"),
// //                             content: const Text(
// //                                 "Are you sure to delete this message in the chat?"),
// //                             actions: [
// //                               TextButton(
// //                                 onPressed: () => Navigator.pop(context),
// //                                 child: const Text("Cancel"),
// //                               ),
// //                               TextButton(
// //                                 onPressed: () async {
// //                                   await widget.channel
// //                                       .deleteMessage(widget.currentMessage);
// //                                   if (widget.currentMessage.isDeleted) {
// //                                     StreamChannelListController(
// //                                       client: StreamChatCore.of(context).client,
// //                                     ).refresh();
// //                                   }
// //                                   Navigator.pop(dialogContext);
// //                                 },
// //                                 child: const Text("Ok"),
// //                               ),
// //                             ],
// //                             actionsAlignment: MainAxisAlignment.spaceBetween,
// //                           );
// //                         },
// //                       );
// //                     }, Icons.delete)
// //                   ],
// //                 ),
// //               )
// //             ],
// //           ),
// //         );
// //       },
// //     );
// //   }

// //   /// Helper function to build the message container
// //   Widget buildMessageContainer(String userUID) {
// //     bool isSender = widget.currentMessage.user?.id == null ||
// //         widget.currentMessage.user?.id == userUID;
// //     return Container(
// //       decoration: BoxDecoration(
// //         borderRadius: BorderRadius.only(
// //             topLeft: isSender
// //                 ? const Radius.circular(15.0)
// //                 : const Radius.circular(3.0),
// //             topRight: const Radius.circular(15.0),
// //             bottomLeft: const Radius.circular(15.0),
// //             bottomRight: isSender
// //                 ? const Radius.circular(3.0)
// //                 : const Radius.circular(15.0)),
// //         color: widget.currentMessage.attachments
// //                     .any((attachment) => attachment.type == "image") ||
// //                 widget.currentMessage.attachments
// //                     .any((attachment) => attachment.type == "url_preview")
// //             ? Colors.transparent
// //             : isSender
// //                 ? AppColor.chatSenderBubbleColor
// //                 : AppColor.chatReceiverBubbleColor,
// //       ),
// //       constraints: const BoxConstraints(minWidth: 50, maxWidth: 300),
// //       margin: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 3.0),
// //       child: buildMessageContent(userUID),
// //     );
// //   }

// //   /// Returns the message content based on the type of the message
// //   /// and the userUID.
// //   Widget buildMessageContent(String userUID) {
// //     return getMessageWidget(userUID);
// //   }

// //   /// Helper function to determine the message widget based on its type
// //   Widget getMessageWidget(String userUID) {
// //     bool isReceiver = widget.currentMessage.user!.id != userUID;
// //     if (widget.currentMessage.attachments.isNotEmpty) {
// //       Attachment attachment = widget.currentMessage.attachments.first;
// //       switch (attachment.type) {
// //         case "image":
// //           if (widget.currentMessage.attachments.length > 1) {
// //             return ClipRRect(
// //               borderRadius: BorderRadius.only(
// //                   topLeft: isReceiver
// //                       ? const Radius.circular(3.0)
// //                       : const Radius.circular(15.0),
// //                   topRight: const Radius.circular(15.0),
// //                   bottomLeft: const Radius.circular(15.0),
// //                   bottomRight: isReceiver
// //                       ? const Radius.circular(15.0)
// //                       : const Radius.circular(3.0)),
// //               child: GestureDetector(
// //                 onTap: () => Navigator.of(context).push(
// //                   MaterialPageRoute(
// //                     builder: (context) => ImageListview(
// //                       message: widget.currentMessage,
// //                     ),
// //                   ),
// //                 ),
// //                 child: GridView.builder(
// //                   physics: const NeverScrollableScrollPhysics(),
// //                   gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
// //                     crossAxisCount:
// //                         2, // Adjust for the number of images per row
// //                   ),
// //                   itemCount: widget.currentMessage.attachments.length > 4
// //                       ? 4
// //                       : widget.currentMessage.attachments.length,
// //                   shrinkWrap: true,
// //                   itemBuilder: (context, index) {
// //                     if (widget.currentMessage.attachments.length > 4 &&
// //                         index == 3) {
// //                       return Stack(
// //                           alignment: AlignmentDirectional.center,
// //                           children: [
// //                             CachedNetworkImage(
// //                               width: 300,
// //                               imageUrl: widget.currentMessage.attachments[index]
// //                                       .imageUrl
// //                                       ?.toString() ??
// //                                   "",
// //                               fit: BoxFit.cover,
// //                               placeholder: (context, url) =>
// //                                   const CircularProgressIndicator(),
// //                               errorWidget: (context, url, error) =>
// //                                   const Icon(Icons.error),
// //                             ),
// //                             Container(
// //                               decoration: BoxDecoration(
// //                                   color: Colors.grey.withOpacity(0.8)),
// //                               child: Center(
// //                                 child: Text(
// //                                   "+ ${widget.currentMessage.attachments.length - 4}",
// //                                   style: Theme.of(context)
// //                                       .textTheme
// //                                       .headlineMedium
// //                                       ?.copyWith(color: Colors.white),
// //                                 ),
// //                               ),
// //                             )
// //                           ]);
// //                     } else if (index ==
// //                             widget.currentMessage.attachments.length - 1 &&
// //                         widget.currentMessage.attachments.length % 2 != 0) {
// //                       // Last item and odd number
// //                       return CachedNetworkImage(
// //                         width: double.infinity,
// //                         height: 50,
// //                         imageUrl: widget
// //                                 .currentMessage.attachments[index].imageUrl
// //                                 ?.toString() ??
// //                             "",
// //                         fit: BoxFit.cover,
// //                         placeholder: (context, url) =>
// //                             const Center(child: CircularProgressIndicator()),
// //                         errorWidget: (context, url, error) =>
// //                             const Icon(Icons.error),
// //                       );
// //                     } else {
// //                       return CachedNetworkImage(
// //                         width: 50,
// //                         height: 50,
// //                         imageUrl: widget
// //                                 .currentMessage.attachments[index].imageUrl
// //                                 ?.toString() ??
// //                             "",
// //                         fit: BoxFit.cover,
// //                         placeholder: (context, url) =>
// //                             const Center(child: CircularProgressIndicator()),
// //                         errorWidget: (context, url, error) =>
// //                             const Icon(Icons.error),
// //                       );
// //                     }
// //                   },
// //                 ),
// //               ),
// //             );
// //           }

// //           return ClipRRect(
// //             borderRadius: BorderRadius.only(
// //                 topLeft: isReceiver
// //                     ? const Radius.circular(3.0)
// //                     : const Radius.circular(15.0),
// //                 topRight: const Radius.circular(15.0),
// //                 bottomLeft: const Radius.circular(15.0),
// //                 bottomRight: isReceiver
// //                     ? const Radius.circular(15.0)
// //                     : const Radius.circular(3.0)),
// //             child: CachedNetworkImage(
// //               height: 300,
// //               imageUrl: attachment.imageUrl?.toString() ?? "",
// //               fit: BoxFit.cover,
// //               progressIndicatorBuilder: (context, url, progress) =>
// //                   const SizedBox(
// //                       width: 100,
// //                       child: Center(child: CircularProgressIndicator())),
// //               errorWidget: (context, url, error) => const Icon(Icons.error),
// //             ),
// //           );

// //         case "file":
// //           return buildFileWidget(context, attachment, userUID);
// //         case "video":
// //           return BlocConsumer<ChatTriggerCubit, ChatTriggerState>(
// //             listenWhen: (previous, current) =>
// //                 previous.video.length != current.video.length ||
// //                 previous.videoThumbnail.length != current.videoThumbnail.length,
// //             listener: (context, state) async {
// //               if (state.video
// //                   .any((video) => video.videoName == '${attachment.title}')) {
// //                 if (state.video
// //                     .firstWhere((video) => video.videoName == attachment.title)
// //                     .isDownloaded) {
// //                   await initPlayer();
// //                 }
// //               }
// //             },
// //             builder: (context, state) {
// //               log('state thumbnail ${state.videoThumbnail} ${attachment.title} ${state.videoStatus}');
// //               if (state.videoThumbnail.isNotEmpty) {
// //                 log("video ${state.videoThumbnail[0].split(p.extension(state.videoThumbnail[0])).first.split('.').last}");
// //               }
// //               if (state.videoThumbnail.any((thumb) => thumb
// //                   .split(p.extension(thumb))
// //                   .first
// //                   .split('.')
// //                   .last
// //                   .contains(
// //                       '${attachment.title?.split(p.extension(attachment.title.toString())).first}'))) {
// //                 return SizedBox(
// //                   height: 200,
// //                   child: Stack(
// //                     children: [
// //                       Image.file(
// //                         width: double.infinity,
// //                         File(state.videoThumbnail.firstWhere((thumbnail) {
// //                           log("thumba $thumbnail");
// //                           return thumbnail
// //                               .split(p.extension(thumbnail))
// //                               .first
// //                               .split('.')
// //                               .last
// //                               .contains(
// //                                   '${attachment.title?.split(p.extension(attachment.title.toString())).first}');
// //                         })),
// //                         fit: BoxFit.cover,
// //                       ),
// //                       ClipRRect(
// //                         child: BackdropFilter(
// //                           filter: ui.ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
// //                           child: Container(
// //                             decoration: BoxDecoration(
// //                                 borderRadius: BorderRadius.only(
// //                                     topLeft: isReceiver
// //                                         ? const Radius.circular(3.0)
// //                                         : const Radius.circular(15.0),
// //                                     topRight: const Radius.circular(15.0),
// //                                     bottomLeft: const Radius.circular(15.0),
// //                                     bottomRight: isReceiver
// //                                         ? const Radius.circular(15.0)
// //                                         : const Radius.circular(3.0)),
// //                                 color: Colors.grey.withOpacity(0.1)),
// //                           ),
// //                         ),
// //                       ),
// //                       GestureDetector(
// //                         onTap: () {
// //                           context.read<ChatTriggerCubit>().downloadFile(
// //                                 attachment.assetUrl.toString(),
// //                                 attachment.title.toString(),
// //                               );
// //                         },
// //                         child: Align(
// //                           alignment: Alignment.center,
// //                           child: Container(
// //                             width: 50,
// //                             height: 50,
// //                             decoration: const BoxDecoration(
// //                                 shape: BoxShape.circle, color: Colors.grey),
// //                             child: const Center(
// //                                 child: Icon(
// //                               Icons.download,
// //                               color: Colors.white,
// //                             )),
// //                           ),
// //                         ),
// //                       ),
// //                       if (state.downloadStatus == DownloadStatus.downloading)
// //                         const Center(
// //                           child: CircularProgressIndicator(),
// //                         ),
// //                     ],
// //                   ),
// //                 );
// //               } else if (state.video
// //                   .any((video) => video.videoName == '${attachment.title}')) {
// //                 if (state.video
// //                         .firstWhere(
// //                             (video) => video.videoName == attachment.title)
// //                         .isDownloaded &&
// //                     (videoPlayerController != null &&
// //                         videoPlayerController!.value.isInitialized)) {
// //                   return SizedBox(
// //                     width: 300,
// //                     height: 200,
// //                     child: Chewie(
// //                       controller: ChewieController(
// //                         videoPlayerController: videoPlayerController!,
// //                         progressIndicatorDelay: bufferDelay != null
// //                             ? Duration(milliseconds: bufferDelay!)
// //                             : null,
// //                       ),
// //                     ),
// //                   );
// //                 }
// //               }
// //               bool isSender = widget.currentMessage.user?.id == null ||
// //                   widget.currentMessage.user?.id == userUID;
// //               return Container(
// //                 height: 100,
// //                 decoration: BoxDecoration(
// //                   borderRadius: BorderRadius.only(
// //                       topLeft: isSender
// //                           ? const Radius.circular(15.0)
// //                           : const Radius.circular(3.0),
// //                       topRight: const Radius.circular(15.0),
// //                       bottomLeft: const Radius.circular(15.0),
// //                       bottomRight: isSender
// //                           ? const Radius.circular(3.0)
// //                           : const Radius.circular(15.0)),
// //                   color: widget.currentMessage.attachments.any(
// //                               (attachment) => attachment.type == "image") ||
// //                           widget.currentMessage.attachments.any(
// //                               (attachment) => attachment.type == "url_preview")
// //                       ? Colors.transparent
// //                       : isSender
// //                           ? AppColor.chatSenderBubbleColor
// //                           : AppColor.chatReceiverBubbleColor,
// //                 ),
// //                 constraints: const BoxConstraints(minWidth: 50, maxWidth: 300),
// //                 margin:
// //                     const EdgeInsets.symmetric(horizontal: 10.0, vertical: 3.0),
// //                 child: Center(
// //                   child: CircularProgressIndicator(
// //                     color: isSender
// //                         ? AppColor.chatReceiverBubbleColor
// //                         : AppColor.chatSenderBubbleColor,
// //                   ),
// //                 ),
// //               );
// //               return const SizedBox();
// //               //else {

// //               //}
// //             },
// //           );
// //         case "audio":
// //           return PlayerWidget(
// //             isReceiver: isReceiver,
// //             voiceSource: attachment.assetUrl ?? "",
// //           );
// //         case "card":
// //           return Container(
// //             decoration:
// //                 BoxDecoration(borderRadius: BorderRadius.circular(15.0)),
// //             child: Column(
// //               children: [
// //                 Padding(
// //                   padding: const EdgeInsets.all(15.0),
// //                   child: Row(
// //                     children: [
// //                       Padding(
// //                         padding: const EdgeInsets.only(right: 8.0),
// //                         child: CircleAvatar(
// //                           radius: 20,
// //                           child: ClipRRect(
// //                             borderRadius: BorderRadius.circular(20),
// //                             child: CachedNetworkImage(
// //                                 imageUrl: "https://picsum.photos/200"),
// //                           ),
// //                         ),
// //                       ),
// //                       Text(attachment.title.toString(),
// //                           style: Theme.of(context)
// //                               .textTheme
// //                               .bodyMedium
// //                               ?.copyWith(
// //                                   color:
// //                                       isReceiver ? Colors.black : Colors.white))
// //                     ],
// //                   ),
// //                 ),
// //                 const Divider(
// //                   height: 0,
// //                 ),
// //                 TextButton(
// //                     onPressed: () {},
// //                     child: Text(
// //                       "Message",
// //                       style: Theme.of(context).textTheme.bodyLarge?.copyWith(
// //                           color: isReceiver ? AppColor.blueText : Colors.white),
// //                     ))
// //               ],
// //             ),
// //           );
// //         case "url_preview":
// //           return Container(
// //             width: 300,
// //             padding: const EdgeInsets.only(bottom: 5.0),
// //             decoration: BoxDecoration(
// //                 color: Colors.transparent,
// //                 borderRadius: BorderRadius.only(
// //                     topLeft: isReceiver
// //                         ? const Radius.circular(3.0)
// //                         : const Radius.circular(15.0),
// //                     topRight: const Radius.circular(15.0),
// //                     bottomLeft: const Radius.circular(15.0),
// //                     bottomRight: isReceiver
// //                         ? const Radius.circular(15.0)
// //                         : const Radius.circular(3.0))),
// //             child: AnyLinkPreview(
// //               backgroundColor: !isReceiver
// //                   ? AppColor.chatSenderBubbleColor
// //                   : AppColor.chatReceiverBubbleColor,
// //               boxShadow: const [],
// //               borderRadius: 15,
// //               titleStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
// //                     color: !isReceiver ? Colors.white : Colors.black,
// //                   ),
// //               bodyStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
// //                     color: !isReceiver ? Colors.white : Colors.black,
// //                   ),
// //               displayDirection: UIDirection.uiDirectionVertical,
// //               link:
// //                   widget.currentMessage.attachments.single.titleLink.toString(),
// //             ),
// //           );
// //         default:
// //           return const Text("audio");
// //         // PlayerWidget(
// //         //   isReceiver: widget.currentElement.sender!.uid != userUID,
// //         //   player: player,
// //         //   voiceSource: mediaMessage.attachment?.fileUrl ?? "",
// //         // );
// //       }
// //     }
// //     return Padding(
// //       padding: const EdgeInsets.all(15.0),
// //       child: BlocBuilder<ChatCubit, ChatState>(
// //         builder: (context, state) {
// //           bool isOverflowing = false;
// //           return SizedBox(
// //             child: LayoutBuilder(
// //               builder: (context, constraints) {
// //                 final textSpan =
// //                     TextSpan(text: widget.currentMessage.text.toString());
// //                 final textPainter = TextPainter(
// //                     text: textSpan,
// //                     maxLines: 1,
// //                     textDirection: ui.TextDirection.ltr);
// //                 textPainter.layout(maxWidth: constraints.maxWidth);
// //                 isOverflowing = textPainter.didExceedMaxLines;
// //                 return Column(
// //                   crossAxisAlignment: CrossAxisAlignment.start,
// //                   children: [
// //                     Text(
// //                         state.expandTextId.contains(widget.currentMessage.id)
// //                             ? widget.currentMessage.text.toString()
// //                             : _getTrimmedText(
// //                                 widget.currentMessage.text.toString(), 30),
// //                         overflow: state.expandTextId
// //                                 .contains(widget.currentMessage.id)
// //                             ? TextOverflow.visible
// //                             : TextOverflow.ellipsis,
// //                         style: Theme.of(context)
// //                             .textTheme
// //                             .bodyMedium
// //                             ?.copyWith(color: getMessageTextColor())),
// //                     if (isOverflowing)
// //                       GestureDetector(
// //                         onTap: () => context
// //                             .read<ChatCubit>()
// //                             .expandText(widget.currentMessage.id),
// //                         child: Text(
// //                           state.expandTextId.contains(widget.currentMessage.id)
// //                               ? 'Show less'
// //                               : 'Show more',
// //                           style: Theme.of(context)
// //                               .textTheme
// //                               .bodyMedium
// //                               ?.copyWith(color: Colors.blue),
// //                         ),
// //                       ),
// //                   ],
// //                 );
// //               },
// //             ),
// //           );
// //         },
// //       ),
// //     );
// //   }

// //   /// Trims a given text to a maximum number of characters.
// //   ///
// //   /// If the given text is longer than the given maxWord, it will be trimmed
// //   /// to the maxWord length. Otherwise, the original text is returned.
// //   String _getTrimmedText(String text, int maxWord) {
// //     if (text.length > maxWord) {
// //       return text.substring(0, maxWord);
// //     } else {
// //       return text;
// //     }
// //   }

// //   /// Builds a PopupMenuItem with the given label, icon, and onTap function.
// //   ///
// //   /// The onTap function is called when the menu item is tapped.
// //   ///
// //   /// The menu item is designed to be used in a PopupMenuButton.
// //   ///
// //   PopupMenuItem buildPopupItem(
// //       BuildContext context, String label, Function function, IconData icon) {
// //     return PopupMenuItem(
// //       padding: EdgeInsets.zero,
// //       height: 0,
// //       onTap: () => function(),
// //       child: buildMenuItemRow(context, label, icon),
// //     );
// //   }

// //   /// This is a helper function to create a reusable row for menu items.
// //   Widget buildMenuItemRow(BuildContext context, String label, IconData icon,
// //       {Color color = Colors.black}) {
// //     return Padding(
// //       padding: const EdgeInsets.all(8.0),
// //       child: Row(
// //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //         children: [
// //           Text(
// //             label,
// //             style:
// //                 Theme.of(context).textTheme.bodyMedium?.copyWith(color: color),
// //           ),
// //           Icon(
// //             icon,
// //             color: color,
// //           ),
// //         ],
// //       ),
// //     );
// //   }

// //   // Widget buildGroupSenderInfo() {
// //   //   return Padding(
// //   //     padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 8.0),
// //   //     child: Text(
// //   //       widget.currentMessage.user!.name.toString(),
// //   //       style: Theme.of(context)
// //   //           .textTheme
// //   //           .bodyMedium
// //   //           ?.copyWith(color: Colors.orange),
// //   //     ),
// //   //   );
// //   // }


// //   /// Returns the text color for the message.
// //   /// The color is determined by whether the message is sent by the current user.
// //   Color getMessageTextColor() {
// //     final isOwnMessage = widget.currentMessage.user?.id == null ||
// //         widget.currentMessage.user?.id ==
// //             StreamChatCore.of(context).currentUser?.id;

// //     return isOwnMessage ? Colors.white : Colors.black;
// //   }

// //   /// Builds a widget for displaying a file attachment in a chat message.
// //   Widget buildFileWidget(
// //       BuildContext context, Attachment attachment, String uid) {
// //     return SizedBox(
// //       width: 200,
// //       child: Padding(
// //           padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 10.0),
// //           child: GestureDetector(
// //               onTap: () {
// //                 context.read<ChatTriggerCubit>().downloadFile(
// //                     attachment.assetUrl.toString(),
// //                     attachment.title.toString());
// //               },
// //               child: ListTile(
// //                 leading: CircleAvatar(
// //                   backgroundColor: Colors.white,
// //                   child: Image.asset(
// //                     "assets/icons/file-default.png",
// //                   ),
// //                 ),
// //                 visualDensity: const VisualDensity(vertical: -4),
// //                 title: Text(
// //                   attachment.title.toString(),
// //                   style: Theme.of(context)
// //                       .textTheme
// //                       .bodyMedium
// //                       ?.copyWith(color: getMessageTextColor()),
// //                 ),
// //                 subtitle: Text(Helper.formatFileSize(attachment.fileSize ?? 0),
// //                     style: Theme.of(context)
// //                         .textTheme
// //                         .bodySmall
// //                         ?.copyWith(color: getMessageTextColor())),
// //               ))),
// //     );
// //   }

 
// }
