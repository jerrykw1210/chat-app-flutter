import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:protech_mobile_chat_stream/constants/network_constants.dart';
import 'package:protech_mobile_chat_stream/module/profile/model/user_profile.dart';
import 'package:protech_mobile_chat_stream/service/credential_service.dart';
import 'package:protech_mobile_chat_stream/utils/helper.dart';
import 'package:protech_mobile_chat_stream/utils/service_locator.dart';
import 'package:http/http.dart' as http;

class UserAvatar extends StatefulWidget {
  UserAvatar({super.key, this.userInfo});
  UserProfile? userInfo;

  @override
  State<UserAvatar> createState() => _UserAvatarState();
}

class _UserAvatarState extends State<UserAvatar> {
  String? profileImagePath;

  @override
  void initState() {
    super.initState();
    getProfileImage(widget.userInfo);
  }

  @override
  void didUpdateWidget(covariant UserAvatar oldWidget) {
    super.didUpdateWidget(oldWidget);

    getProfileImage(widget.userInfo);
  }

  void getProfileImage(UserProfile? userInfo) async {
    final directory = Helper.directory;

    final profileImgFile = File(
        "${directory?.path}/${sl<CredentialService>().turmsId}_${userInfo?.profileUrl}");

    bool fileExist = await profileImgFile.exists();

    if (!fileExist) {
      final downloadProfileImgFile = await downloadFile(userInfo?.profileUrl);
      setState(() {
        profileImagePath = downloadProfileImgFile.path;
      });
    } else {
      setState(() {
        profileImagePath = profileImgFile.path;
      });
    }
  }

// Function to download the file
  Future<File> downloadFile(String? fileName) async {
    // final response = await http.get(Uri.parse(url));
    // final directory = await getTemporaryDirectory();
    // final file = File('${directory.path}/$fileName');

    // // Write the downloaded bytes to a file
    // return file.writeAsBytes(response.bodyBytes);

    String? jwtToken = sl<CredentialService>().jwtToken;
    String? turmsId = sl<CredentialService>().turmsId;
    Map<String, String> headers = {"Authorization": "Bearer $jwtToken"};
    try {
      final res = await http.get(
          Uri.parse("${NetworkConstants.getProfileImgUrl}$turmsId"),
          headers: headers);
      if (res.statusCode == 200) {
        log("status ${res.statusCode}");
        final directory = Helper.directory;
        final file = File(
            '${directory?.path}/${sl<CredentialService>().turmsId}_$fileName');

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
    return CircleAvatar(
      child: ClipOval(
        child: Image.memory(
          File(profileImagePath!).readAsBytesSync(),
          fit: BoxFit.cover,
          width: 40,
          height: 40,
          errorBuilder: (context, error, stackTrace) {
            return Image.asset(
              'assets/default-img/default-user.png',
              fit: BoxFit.cover,
              width: 40,
              height: 40,
            );
          },
        ),
      ),
    );
  }
}
