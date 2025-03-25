import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:protech_mobile_chat_stream/constants/network_constants.dart';
import 'package:protech_mobile_chat_stream/module/chat/cubit/group_cubit.dart';
import 'package:protech_mobile_chat_stream/module/profile/model/user_profile.dart';
import 'package:protech_mobile_chat_stream/service/credential_service.dart';
import 'package:protech_mobile_chat_stream/utils/helper.dart';
import 'package:protech_mobile_chat_stream/utils/service_locator.dart';
import 'package:http/http.dart' as http;

class ChatAvatar extends StatefulWidget {
  ChatAvatar(
      {super.key,
      required this.errorWidget,
      required this.targetId,
      this.radius = 30,
      this.isGroup = false});
  String targetId;
  bool isGroup;
  Widget errorWidget;
  double radius;

  @override
  State<ChatAvatar> createState() => _ChatAvatarState();
}

class _ChatAvatarState extends State<ChatAvatar> {
  String? profileImagePath;
  Future<File>? _downloadFuture;

  @override
  void initState() {
    // TODO: implement initState
    // getProfileImage(widget.targetId);
    super.initState();
    _fetchProfileImage();
  }

  @override
  void didUpdateWidget(covariant ChatAvatar oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.targetId != widget.targetId ||
        oldWidget.isGroup != widget.isGroup) {
      // final directory = Helper.directory;
      // setState(() {
      //   profileImagePath =
      //       "${directory?.path}/${sl<CredentialService>().turmsId}_${widget.targetId}";
      // });
      // getProfileImage(widget.targetId);
      _fetchProfileImage();
    }
  }

  void _fetchProfileImage() {
    final directory = Helper.directory;
    final filePath =
        "${directory?.path}/${sl<CredentialService>().turmsId}_${widget.targetId}.jpg";

    // Check if file exists
    File(filePath).exists().then((exists) {
      if (exists) {
        setState(() => profileImagePath = filePath);
      } else {
        _downloadFuture =
            downloadFile(widget.targetId, isGroup: widget.isGroup);
        _downloadFuture?.then((file) {
          if (mounted &&
              widget.targetId ==
                  file.path.split('_').last.split('.jpg').first) {
            setState(() => profileImagePath = file.path);
          }
        });
      }
    });
  }

  // void getProfileImage(String targetId) async {
  //   log("chat avatar targetId $targetId ${widget.isGroup}");
  //   final directory = Helper.directory;

  //   final profileImgFile =
  //       File("${directory?.path}/${sl<CredentialService>().turmsId}_$targetId");

  //   bool fileExist = await profileImgFile.exists();

  //   if (!fileExist) {
  //     final downloadProfileImgFile =
  //         await downloadFile(targetId, isGroup: widget.isGroup);
  //     setState(() {
  //       profileImagePath = downloadProfileImgFile.path;
  //     });
  //   } else {
  //     setState(() {
  //       profileImagePath = profileImgFile.path;
  //     });
  //   }
  // }

// Function to download the file
  Future<File> downloadFile(String targetId, {bool isGroup = false}) async {
    // final response = await http.get(Uri.parse(url));
    // final directory = await getTemporaryDirectory();
    // final file = File('${directory.path}/$fileName');

    // // Write the downloaded bytes to a file
    // return file.writeAsBytes(response.bodyBytes);

    String? jwtToken = sl<CredentialService>().jwtToken;
    Map<String, String> headers = {"Authorization": "Bearer $jwtToken"};
    try {
      final url = isGroup
          ? "${NetworkConstants.getGroupImgUrl}$targetId"
          : "${NetworkConstants.getProfileImgUrl}$targetId";
      final res = await http.get(Uri.parse(url), headers: headers);
      log("fetch chat avatar image url $url status ${res.statusCode}");
      if (res.statusCode == 200) {
        final directory = Helper.directory;
        final file = File(
            '${directory?.path}/${sl<CredentialService>().turmsId}_$targetId.jpg');

        // Write the downloaded bytes to a file
        return file.writeAsBytes(res.bodyBytes);
      } else {
        throw Exception(
            "Failed to get profile image. Status code: ${res.statusCode}");
      }
    } on Exception catch (e) {
      throw Exception("Failed to get profile image. Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<GroupCubit, GroupState>(
      buildWhen: (previous, current) {
        if (widget.isGroup) {
          return true;
        }

        return false;
      },
      listener: (context, state) {
        if (widget.isGroup) {
          _fetchProfileImage();
        }
      },
      builder: (context, state) {
        return CircleAvatar(
          radius: widget.radius,
          child: ClipOval(
            child: Image.file(
              File(profileImagePath ?? ""),
              fit: BoxFit.cover,
              width: 40,
              height: 40,
              errorBuilder: (context, error, stackTrace) => widget.errorWidget,
            ),
          ),
        );
      },
    );
  }
}
