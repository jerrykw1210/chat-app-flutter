import 'dart:developer';
import 'dart:io';

import 'package:chewie/chewie.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get_video_thumbnail/get_video_thumbnail.dart';
import 'package:get_video_thumbnail/index.dart';
import 'package:protech_mobile_chat_stream/constants/string_constant.dart';
import 'package:protech_mobile_chat_stream/model/database.dart';
import 'package:protech_mobile_chat_stream/module/chat/cubit/chat_cubit.dart';
import 'package:protech_mobile_chat_stream/module/chat/cubit/chat_trigger_cubit.dart';
import 'package:image_picker/image_picker.dart';
import 'package:protech_mobile_chat_stream/utils/colors.dart';
import 'package:protech_mobile_chat_stream/utils/helper.dart';
import 'package:protech_mobile_chat_stream/utils/toast_utils.dart';
import 'package:turms_client_dart/turms_client.dart' as turms;
import 'package:video_player/video_player.dart';

class AttachmentPreviewWidget extends StatefulWidget {
  const AttachmentPreviewWidget(
      {super.key,
      required this.image,
      required this.fileType,
      required this.conversation});
  final List<XFile> image;
  final Conversation conversation;
  final String fileType;

  @override
  State<AttachmentPreviewWidget> createState() =>
      _AttachmentPreviewWidgetState();
}

class _AttachmentPreviewWidgetState extends State<AttachmentPreviewWidget> {
  int? bufferDelay;
  TextEditingController captionController = TextEditingController();
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<Uint8List> thumbnailForVideo(int index) async {
    log("video paath ${widget.image[index].path}");
    final uint8list = await VideoThumbnail.thumbnailData(
      video: widget.image[index].path,
      maxHeight: MediaQuery.sizeOf(context).width.toInt(),
      maxWidth:
          300, // specify the width of the thumbnail, let the height auto-scaled to keep the source aspect ratio
      quality: 25,
    );
    return uint8list;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocBuilder<ChatTriggerCubit, ChatTriggerState>(
          builder: (context, state) {
            return SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Align(
                    alignment: Alignment.topLeft,
                    child: IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),

                  // hide until phase 2
                  SizedBox(
                    height: MediaQuery.sizeOf(context).height * 0.5,
                    width: double.infinity,
                    child: ListView.builder(
                        itemCount: widget.image.length,
                        scrollDirection: Axis.horizontal,
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          return Center(
                              child: widget.fileType == "file"
                                  ? Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const SizedBox(
                                          width: 10,
                                        ),
                                        const Icon(Icons.edit_document),
                                        const SizedBox(
                                          width: 10,
                                        ),
                                        SizedBox(
                                            width: MediaQuery.sizeOf(context)
                                                    .width *
                                                0.8,
                                            child: Text(
                                              widget.image[index].name,
                                              softWrap: true,
                                            ))
                                      ],
                                    )
                                  : widget.fileType == "video"
                                      ? FutureBuilder<Uint8List>(
                                          future: thumbnailForVideo(index),
                                          builder: (context, snapshot) {
                                            if (snapshot.hasData) {
                                              return SizedBox(
                                                  width:
                                                      MediaQuery.sizeOf(context)
                                                          .width,
                                                  height: 300,
                                                  child: Image.memory(
                                                      snapshot.data!));
                                            } else if (snapshot.hasError) {
                                              return Container(
                                                padding:
                                                    const EdgeInsets.all(8),
                                                color: Colors.red,
                                                child: Text(
                                                    'Error:\n${snapshot.error}\n\n${snapshot.stackTrace}'),
                                              );
                                            }
                                            return const SizedBox();
                                          },
                                        )
                                      : Image.file(
                                          File(widget.image[index].path),
                                          width:
                                              MediaQuery.sizeOf(context).width,
                                          height: 300,
                                          fit: BoxFit.contain,
                                        ));
                        }),
                  ),

                  // hide until phase 2
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () async {
                          final ImagePicker picker = ImagePicker();

                          if (widget.fileType == "image") {
                            final image = await picker.pickImage(
                                source: ImageSource.gallery);
                            if (image != null) {
                              log("selected image name ${image.name} ${image.path}");

                              // Get the file size in bytes
                              int fileSizeInBytes = await image.length();

                              // Define 30 MB in bytes
                              const int maxSizeInBytes = 30 * 1024 * 1024;

                              // Check if the file size exceeds 30 MB
                              if (fileSizeInBytes > maxSizeInBytes) {
                                ToastUtils.showToast(
                                    context: context,
                                    msg: "File size exceeds 30 MB",
                                    type: Type.warning);
                                return;
                              }
                              widget.image.add(image);

                              setState(() {});
                            }
                          } else if (widget.fileType == "video") {
                            final image = await picker.pickVideo(
                                source: ImageSource.gallery);
                            if (image != null) {
                              log("selected video name ${image.name} ${image.path}");

                              // Get the file size in bytes
                              int fileSizeInBytes = await image.length();

                              // Define 30 MB in bytes
                              const int maxSizeInBytes = 30 * 1024 * 1024;

                              // Check if the file size exceeds 5 MB
                              if (fileSizeInBytes > maxSizeInBytes) {
                                ToastUtils.showToast(
                                    context: context,
                                    msg: "File size exceeds 30 MB",
                                    type: Type.warning);
                                return;
                              }
                              log("videossss ${image.name} $fileSizeInBytes");
                              widget.image.add(image);
                              setState(() {});
                            }
                          } else if (widget.fileType == "file") {
                            FilePickerResult? filePickerResult;

                            filePickerResult = await FilePicker.platform
                                .pickFiles(allowMultiple: false);
                            if (filePickerResult == null) {
                              debugPrint("No file selected");
                            } else {
                              log("file selected: ${filePickerResult.files.single.xFile.path}");

                              if (Helper.checkNotMediaFileType(
                                  filePickerResult.files.single.xFile)) {
                                ToastUtils.showToast(
                                    context: context,
                                    msg: "Please select a valid file",
                                    type: Type.warning);
                                return;
                              }

                              int fileSizeInBytes = await filePickerResult
                                  .files.single.xFile
                                  .length();

                              // Define 5 MB in bytes
                              const int maxSizeInBytes = 30 * 1024 * 1024;

                              // Check if the file size exceeds 5 MB
                              if (fileSizeInBytes > maxSizeInBytes) {
                                ToastUtils.showToast(
                                    context: context,
                                    msg: "File size exceeds 30 MB",
                                    type: Type.warning);
                                return;
                              }
                              widget.image
                                  .add(filePickerResult.files.single.xFile);
                              setState(() {});
                            }
                          }
                        },
                        child: Container(
                            width: 80,
                            height: 80,
                            color: Colors.grey,
                            child: const Icon(Icons.add)),
                      ),
                      Expanded(
                        child: SizedBox(
                          height: 80,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 3.0),
                            child: ListView.separated(
                              itemCount: widget.image.length,
                              separatorBuilder: (context, index) =>
                                  const Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 2.0)),
                              scrollDirection: Axis.horizontal,
                              // physics: const AlwaysScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemBuilder: (context, index) {
                                return widget.fileType == "video"
                                    ? FutureBuilder<Uint8List>(
                                        future: thumbnailForVideo(index),
                                        builder: (context, snapshot) {
                                          if (snapshot.hasData) {
                                            return SizedBox(
                                                width: 50,
                                                child: Image.memory(
                                                  snapshot.data!,
                                                  fit: BoxFit.cover,
                                                ));
                                          } else if (snapshot.hasError) {
                                            return Container(
                                              padding: const EdgeInsets.all(8),
                                              color: Colors.red,
                                              child: Text(
                                                  'Error:\n${snapshot.error}\n\n${snapshot.stackTrace}'),
                                            );
                                          }
                                          return const SizedBox();
                                        },
                                      )
                                    : widget.fileType == "file"
                                        ? SizedBox(
                                            width: 80,
                                            height: 80,
                                            child: Text(
                                              widget.image[index].name,
                                              overflow: TextOverflow.ellipsis,
                                            ))
                                        : SizedBox(
                                            width: 80,
                                            height: 80,
                                            child: Image.file(
                                              File(widget.image[index].path),
                                              height: 300,
                                              fit: BoxFit.cover,
                                            ));
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 15),
                    child: Row(
                      children: [
                        textInputBar(captionController),
                        Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: GestureDetector(
                              key: const ValueKey<bool>(true),
                              onTap: () async {
                                context.read<ChatTriggerCubit>().isFirstLoad();

                                String? receiverId =
                                    widget.conversation.targetId;
                                if (receiverId != null) {
                                  if (widget.fileType == "video") {
                                    context.read<ChatCubit>().sendAttachment(
                                        receiverId,
                                        widget.image,
                                        turms.MessageType.VIDEO_TYPE,
                                        isGroup: widget.conversation.isGroup,
                                        caption: captionController.text);
                                  } else if (widget.fileType == "file") {
                                    context.read<ChatCubit>().sendAttachment(
                                        receiverId,
                                        widget.image,
                                        turms.MessageType.FILE_TYPE,
                                        isGroup: widget.conversation.isGroup,
                                        caption: captionController.text);
                                  } else {
                                    context.read<ChatCubit>().uploadImage(
                                        widget.image, receiverId,
                                        isGroup: widget.conversation.isGroup,
                                        caption: captionController.text);
                                  }
                                }

                                context
                                    .read<ChatTriggerCubit>()
                                    .toggleExpandTextFieldBar(true);
                                Navigator.pop(context);
                              },
                              child: Container(
                                padding: const EdgeInsets.all(8.0),
                                decoration: const BoxDecoration(
                                    shape: BoxShape.circle, color: Colors.grey),
                                child: const Icon(Icons.send),
                              )),
                        ),
                      ],
                    ),
                  ),
                  if (state.showEmoji)
                    EmojiPicker(
                      textEditingController: captionController,
                      config: Config(
                        height: 256,
                        checkPlatformCompatibility: true,
                        viewOrderConfig: const ViewOrderConfig(),
                        emojiViewConfig: EmojiViewConfig(
                          // Issue: https://github.com/flutter/flutter/issues/28894
                          emojiSizeMax: 28 *
                              (defaultTargetPlatform == TargetPlatform.iOS
                                  ? 1.2
                                  : 1.0),
                        ),
                        skinToneConfig: const SkinToneConfig(),
                        categoryViewConfig: const CategoryViewConfig(),
                        bottomActionBarConfig: const BottomActionBarConfig(),
                        searchViewConfig: const SearchViewConfig(),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

Widget textInputBar(TextEditingController messageInputController) {
  return BlocBuilder<ChatTriggerCubit, ChatTriggerState>(
    builder: (context, state) {
      return Flexible(
        flex: 7,
        fit: FlexFit.loose,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  decoration: BoxDecoration(
                      color: AppColor.chatReceiverBubbleColor,
                      borderRadius: BorderRadius.circular(30.0)),
                  child: Padding(
                      padding: const EdgeInsets.only(left: 15.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            flex: 3,
                            child: TextFormField(
                              controller: messageInputController,
                              minLines: 1,
                              maxLines: 2,
                              maxLength: 3000,
                              decoration: InputDecoration(
                                  filled: false,
                                  hintText: Strings.typeHere,
                                  counterText: "",
                                  border: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  labelStyle: null,
                                  hintStyle: null,
                                  enabledBorder: InputBorder.none),
                              onChanged: (value) {},
                            ),
                          ),
                          Flexible(
                            child: IconButton(
                                onPressed: () {
                                  context
                                      .read<ChatTriggerCubit>()
                                      .toggleEmoji();
                                },
                                icon: SvgPicture.asset(
                                    "assets/Buttons/emoji.svg")),
                          ),
                        ],
                      )),
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}
