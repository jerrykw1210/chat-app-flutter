import 'dart:convert';
import 'dart:developer';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:protech_mobile_chat_stream/constants/network_constants.dart';
import 'package:protech_mobile_chat_stream/constants/storagekey_constants.dart';
import 'package:protech_mobile_chat_stream/service/data.dart';
import 'package:protech_mobile_chat_stream/utils/service_locator.dart';
import 'package:http/http.dart' as http;

class LanguageService extends ApiBaseHelper {
  Future<Response> getLanguageFile(String path) async {
    String? jwtToken = await sl<FlutterSecureStorage>()
        .read(key: StoragekeyConstants.jwtTokenKey);
    return get(
        url: "${NetworkConstants.getLanguageFileUrl}/$path",
        headers: {"Authorization": "Bearer $jwtToken"},
        mapper: (resBody) => MapSuccessResponse(jsonRes: jsonDecode(resBody)));
  }

  Future<dynamic> uploadLanguageFile({
    required String attachment,
  }) async {
    String? jwtToken = await sl<FlutterSecureStorage>()
        .read(key: StoragekeyConstants.jwtTokenKey);

    //create multipart request
    http.MultipartRequest request = http.MultipartRequest(
        "POST", Uri.parse("${NetworkConstants.uploadJSONUrl}zh"));

    // multipart that takes file
    http.MultipartFile multipartFile = await http.MultipartFile.fromPath(
      'file',
      attachment,
    );

    // Add fields to the request
    // add multipart to request
    request.files.add(multipartFile);
    try {
      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        Map<String, dynamic> decodedApiResponse = {};
        await response.stream.transform(utf8.decoder).forEach((apiResponse) {
          log("the file api response $apiResponse");

          decodedApiResponse = jsonDecode(apiResponse)['data'];
        });
      }
    } catch (e) {
      log("error upload file $e");
    }
    return "";
  }

  Future<Response> getLanguageList() async {
    final FlutterSecureStorage storage = sl<FlutterSecureStorage>();

    String? jwtToken = await storage.read(key: StoragekeyConstants.jwtTokenKey);
    return get(
        url: "${NetworkConstants.getLanguageListUrl}",
        headers: {"Authorization": "Bearer $jwtToken"},
        mapper: (resBody) => MapSuccessResponse(jsonRes: jsonDecode(resBody)));
  }
}
