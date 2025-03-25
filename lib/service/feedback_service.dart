import 'dart:convert';
import 'dart:io';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:protech_mobile_chat_stream/constants/network_constants.dart';
import 'package:protech_mobile_chat_stream/constants/storagekey_constants.dart';
import 'package:protech_mobile_chat_stream/service/data.dart';
import 'package:protech_mobile_chat_stream/utils/service_locator.dart';

class FeedbackService extends ApiBaseHelper {
  Future<Response> submitFeedback(
      {required String content,
      required String category,
      required List<String> attachment}) async {
    final FlutterSecureStorage storage = sl<FlutterSecureStorage>();

    String? jwtToken = await storage.read(key: StoragekeyConstants.jwtTokenKey);
    Map<String, String> headers = {"Authorization": "Bearer $jwtToken"};
    Map<String, dynamic> body = {
      "category": category,
      "content": content,
      "attachments": attachment
    };

    return post(
        url: NetworkConstants.uploadFeedbackUrl,
        body: body,
        headers: headers,
        mapper: (resBody) => MapSuccessResponse(jsonRes: jsonDecode(resBody)));
  }

  Future<Response> uploadFeedbackImage(XFile imageFile) async {
    Map<String, String> body = {
      "serviceType": "FEEDBACK",
    };
    final FlutterSecureStorage storage = sl<FlutterSecureStorage>();

    String? jwtToken = await storage.read(key: StoragekeyConstants.jwtTokenKey);

    Map<String, String> headers = {"Authorization": "Bearer $jwtToken"};

    List<File> files = [File(imageFile.path)];
    return upload(
        url: NetworkConstants.getOtherImageUrl,
        headers: headers,
        mapper: (resBody) => MapSuccessResponse(jsonRes: jsonDecode(resBody)),
        body: body,
        files: files,
        fieldName: "file");
    //SERVICE TYPE ENUM : FEEDBACK, OTHERS
  }
}
