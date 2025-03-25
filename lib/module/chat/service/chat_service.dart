import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:protech_mobile_chat_stream/constants/network_constants.dart';
import 'package:protech_mobile_chat_stream/constants/storagekey_constants.dart';
import 'package:protech_mobile_chat_stream/service/data.dart';
import 'package:http/http.dart' as http;
import 'package:protech_mobile_chat_stream/utils/service_locator.dart';
import 'package:http_parser/http_parser.dart';

class ChatService extends ApiBaseHelper {
  final FlutterSecureStorage _storage = sl<FlutterSecureStorage>();

  Future<Response> getGif() async {
    return get(
        url:
            "https://${NetworkConstants.thirdPartyGifUrl}trending?api_key=eBHyCAHELvZXZ1RlfJLhDJLeli4pHxhw&limit=25&offset=0&rating=g&lang=en&bundle=messaging_non_clips",
        mapper: (resBody) => MapSuccessResponse(jsonRes: jsonDecode(resBody)));
  }

  Future<Response> searchGif(String keyword) async {
    return get(
        url:
            "https://${NetworkConstants.thirdPartyGifUrl}search?api_key=eBHyCAHELvZXZ1RlfJLhDJLeli4pHxhw&q=$keyword&limit=25&offset=0&rating=g&bundle=messaging_non_clips",
        mapper: (resBody) => MapSuccessResponse(jsonRes: jsonDecode(resBody)));
  }

  Future<dynamic> uploadImage(String attachment, String receiverId,
      {String? groupId = ""}) async {
    String? jwtToken =
        await _storage.read(key: StoragekeyConstants.jwtTokenKey);
    //create multipart request
    http.MultipartRequest request = http.MultipartRequest(
        "POST", Uri.parse(NetworkConstants.uploadImageUrl));

    // multipart that takes file
    http.MultipartFile multipartFile = await http.MultipartFile.fromPath(
        'file', attachment,
        contentType: MediaType('image', 'jpg'));
    Map<String, String> body = {"receiverId": receiverId, "groupId": "0"};

    // Add fields to the request
    request.fields.addAll(body);
    request.headers.addAll({"Authorization": "Bearer $jwtToken"});
    // add multipart to request
    request.files.add(multipartFile);
    log("the request ${request.fields}, ${request.files[0].filename}");
    try {
      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        Map<String, dynamic> decodedApiResponse = {};
        await response.stream.transform(utf8.decoder).forEach((apiResponse) {
          log("the image api response $apiResponse");

          decodedApiResponse = jsonDecode(apiResponse)['data'];
          log("file url ${decodedApiResponse['fileUrl']}");
          getFile(decodedApiResponse['fileUrl']);
        });
      }
    } catch (e) {
      log("error upload image $e");
    }

    return "";
    // return post(
    //     url: NetworkConstants.uploadImageUrl,
    //     mapper: (resBody) => MapSuccessResponse(jsonRes: jsonDecode(resBody)));
  }

  Future<Response> getFile(String fileUrl) async {
    String? jwtToken =
        await _storage.read(key: StoragekeyConstants.jwtTokenKey);

    return get(
        url: "${NetworkConstants.getFileUrl}?fileUrl=$fileUrl",
        headers: {"Authorization": "Bearer $jwtToken"},
        mapper: (resBody) => MapSuccessResponse(jsonRes: jsonDecode(resBody)));
  }

  Future<Response> addSticker(XFile imageFile) async {
    String? jwtToken =
        await _storage.read(key: StoragekeyConstants.jwtTokenKey);
    Map<String, String> body = {"description": ""};

    return upload(
        url: NetworkConstants.addStickerUrl,
        files: [File(imageFile.path)],
        fieldName: "sticker",
        body: body,
        headers: {"Authorization": "Bearer $jwtToken"},
        mapper: (resBody) => MapSuccessResponse(jsonRes: jsonDecode(resBody)));
  }

  Future<Response> getStickerList(String userId) async {
    String? jwtToken =
        await _storage.read(key: StoragekeyConstants.jwtTokenKey);

    return get(
        url: "${NetworkConstants.getStickerListUrl}/$userId",
        headers: {"Authorization": "Bearer $jwtToken"},
        mapper: (resBody) => MapSuccessResponse(jsonRes: jsonDecode(resBody)));
  }

  Future<Response> deleteSticker(String stickerUrl) async {
    String? jwtToken =
        await _storage.read(key: StoragekeyConstants.jwtTokenKey);

    return delete(
        url: "${NetworkConstants.deleteStickerUrl}?stickerUrl=$stickerUrl",
        headers: {"Authorization": "Bearer $jwtToken"},
        mapper: (resBody) => MapSuccessResponse(jsonRes: jsonDecode(resBody)));
  }
}

