import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get_video_thumbnail/get_video_thumbnail.dart';
import 'package:protech_mobile_chat_stream/constants/string_constant.dart';
import 'package:protech_mobile_chat_stream/module/chat/model/attachment_model.dart';
import 'package:protech_mobile_chat_stream/service/database_helper.dart';
import 'package:protech_mobile_chat_stream/utils/service_locator.dart';
import 'package:protech_mobile_chat_stream/widgets/video_widget.dart';

class FriendMediaScreen extends StatefulWidget {
  const FriendMediaScreen({
    super.key,
  });
  @override
  State<FriendMediaScreen> createState() => _FriendMediaScreenState();
}

class _FriendMediaScreenState extends State<FriendMediaScreen>
    with SingleTickerProviderStateMixin {
  late final TabController tabController;
  @override
  void initState() {
    tabController = TabController(length: 3, vsync: this);
    super.initState();
  }

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

  @override
  Widget build(BuildContext context) {
    String conversationId =
        ModalRoute.of(context)!.settings.arguments as String;
    return Scaffold(
      appBar: AppBar(
        title: Text(Strings.media),
      ),
      body: Column(
        children: [
          TabBar(
            controller: tabController,
            labelPadding: const EdgeInsets.all(10.0),
            dividerColor: Colors.transparent,
            tabs: [
              Text(Strings.photo),
              Text(Strings.video),
              Text(Strings.file),
              // Text("Link"),
            ],
          ),
          Expanded(
            child: TabBarView(controller: tabController, children: [
              StreamBuilder(
                  stream: sl<DatabaseHelper>()
                      .getMedia(conversationId, "IMAGE_TYPE"),
                  builder: (context, attachment) {
                    if (attachment.hasData && attachment.data!.isNotEmpty) {
                      return GridView.builder(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 2,
                            mainAxisSpacing: 2,
                          ),
                          itemCount: attachment.data!.length,
                          itemBuilder: (context, index) {
                            return Image.file(
                              File(
                                "${AttachmentModel.fromJson(jsonDecode(jsonDecode(attachment.data![index].url.toString())[0])).localPath}",
                              ),
                              height: 200,
                              errorBuilder: (context, error, stackTrace) =>
                                  const SizedBox(
                                height: 50,
                                width: 70,
                                child: Center(
                                    child: Icon(Icons.broken_image_outlined,
                                        color: Colors.white)),
                              ),
                              frameBuilder: (context, child, frame,
                                      wasSynchronouslyLoaded) =>
                                  child,
                            );
                          });
                    }
                    return Center(child: Text(Strings.nothingHereYet));
                  }),
              StreamBuilder(
                  stream: sl<DatabaseHelper>()
                      .getMedia(conversationId, "VIDEO_TYPE"),
                  builder: (context, attachment) {
                    if (attachment.hasData && attachment.data!.isNotEmpty) {
                      return GridView.builder(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 2,
                            mainAxisSpacing: 2,
                          ),
                          itemCount: attachment.data!.length,
                          itemBuilder: (context, index) {
                            log("video in media ${attachment.data?[index]}");

                            return FutureBuilder<Uint8List>(
                              future: thumbnailForVideo(jsonDecode(jsonDecode(
                                  attachment.data![index].url
                                      .toString())![0])['localPath']),
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  return GestureDetector(
                                    onTap: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => VideoViewWidget(
                                          videoPath: jsonDecode(jsonDecode(
                                                  attachment.data![index].url
                                                      .toString())![0])[
                                              'localPath'],
                                        ),
                                      ),
                                    ),
                                    child: SizedBox(
                                        width: MediaQuery.sizeOf(context).width,
                                        height: 300,
                                        child: Image.memory(snapshot.data!)),
                                  );
                                } else if (snapshot.hasError) {
                                  return Container(
                                    padding: const EdgeInsets.all(8),
                                    color: Colors.red,
                                    child: Text(
                                        'Error:\n${snapshot.error}\n\n${snapshot.stackTrace}'),
                                  );
                                }
                                return const SizedBox(
                                  width: 200,
                                  height: 200,
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      color: Colors.blueAccent,
                                    ),
                                  ),
                                );
                              },
                            );
                          });
                    }
                    return Center(child: Text(Strings.nothingHereYet));
                  }),
              StreamBuilder(
                  stream: sl<DatabaseHelper>()
                      .getMedia(conversationId, "FILE_TYPE"),
                  builder: (context, attachment) {
                    if (attachment.hasData && attachment.data!.isNotEmpty) {
                      return GridView.builder(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 2,
                            mainAxisSpacing: 2,
                          ),
                          padding: const EdgeInsets.all(5),
                          itemCount: attachment.data!.length,
                          itemBuilder: (context, index) {
                            return Column(
                              children: [
                                Text(
                                  AttachmentModel.fromJson(jsonDecode(
                                          jsonDecode(attachment.data![index].url
                                              .toString())[0]))
                                      .fileName,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const Icon(
                                  Icons.picture_as_pdf,
                                  color: Colors.red,
                                )
                              ],
                            );
                            // Image.file(
                            //   File(
                            //     "${AttachmentModel.fromJson(jsonDecode(jsonDecode(attachment.data![index].url.toString())[0])).localPath}",
                            //   ),
                            //   height: 200,
                            //   errorBuilder: (context, error, stackTrace) =>
                            //       const SizedBox(
                            //     height: 50,
                            //     width: 70,
                            //     child: Center(
                            //         child: Icon(Icons.broken_image_outlined,
                            //             color: Colors.white)),
                            //   ),
                            //   frameBuilder: (context, child, frame,
                            //           wasSynchronouslyLoaded) =>
                            //       child,
                            // );
                          });
                    }
                    return Center(child: Text(Strings.nothingHereYet));
                  }),
              // GridView.builder(
              //     gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              //       crossAxisCount: 3,
              //       crossAxisSpacing: 2,
              //       mainAxisSpacing: 2,
              //     ),
              //     itemCount: 24,
              //     itemBuilder: (context, index) {
              //       return Image.network(
              //         "https://picsum.photos/500",
              //       );
              //     }),
              // GridView.builder(
              //     gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              //       crossAxisCount: 3,
              //       crossAxisSpacing: 2,
              //       mainAxisSpacing: 2,
              //     ),
              //     itemCount: 24,
              //     itemBuilder: (context, index) {
              //       return Image.network(
              //         "https://picsum.photos/500",
              //       );
              //     }),
            ]),
          )
        ],
      ),
    );
  }
}
