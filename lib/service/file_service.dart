import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:protech_mobile_chat_stream/constants/network_constants.dart';
import 'package:protech_mobile_chat_stream/constants/storagekey_constants.dart';
import 'package:protech_mobile_chat_stream/service/credential_service.dart';
import 'package:protech_mobile_chat_stream/service/data.dart';
import 'package:protech_mobile_chat_stream/utils/service_locator.dart';

class FileService extends ApiBaseHelper {
  /// Upload an image to the server.
  ///
  /// This function will upload the image specified by [imageFile] to the
  /// server, and return a [Response] containing the response body from the
  /// server.
  ///
  /// The [imageFile] parameter should be a [XFile] object containing the image
  /// data and path to the image file.
  ///
  /// The function will return a [Response] containing the response body from the
  /// server. The response body should be a JSON object, which will be
  /// automatically decoded into a [Map<String, dynamic>] by the [Response]
  /// object.
  ///
  /// The function will throw a [NetworkException] if there is an error with the
  /// network request.
  Future<Response> uploadImage({required XFile imageFile}) async {
    final FlutterSecureStorage storage = sl<FlutterSecureStorage>();

    String? jwtToken = await storage.read(key: StoragekeyConstants.jwtTokenKey);
    Map<String, String> headers = {"Authorization": "Bearer $jwtToken"};
    Map<String, String> body = {"receiverId": "1", "groupId": "1"};
    List<File> files = [File(imageFile.path)];
    return upload(
        url: NetworkConstants.uploadImageUrl,
        body: body,
        files: files,
        fieldName: "file",
        headers: headers,
        mapper: (resBody) => MapSuccessResponse(jsonRes: jsonDecode(resBody)));
  }

  /// Upload a file to the server.
  ///
  /// This function will upload the file specified by [attachment] to the
  /// server, and return a [Response] containing the response body from the
  /// server.
  ///
  /// The [attachment] parameter should be a [XFile] object containing the file
  /// data and path to the file.
  ///
  /// The function will return a [Response] containing the response body from the
  /// server. The response body should be a JSON object, which will be
  /// automatically decoded into a [Map<String, dynamic>] by the [Response]
  /// object.
  ///
  /// The function will throw a [NetworkException] if there is an error with the
  /// network request.
  Future<Response> uploadFile({required XFile attachment}) async {
    final FlutterSecureStorage storage = sl<FlutterSecureStorage>();

    String? jwtToken = await storage.read(key: StoragekeyConstants.jwtTokenKey);
    Map<String, String> headers = {
      'Accept-Encoding': 'gzip, deflate, br',
      "Authorization": "Bearer $jwtToken"
    };
    Map<String, String> body = {
      "receiverId": "1",
    };
    List<File> files = [File(attachment.path)];
    log("attachment fiel path ${attachment.path}");
    return upload(
        url: NetworkConstants.uploadFileUrl,
        body: body,
        files: files,
        fieldName: "file",
        headers: headers,
        mapper: (resBody) => MapSuccessResponse(jsonRes: jsonDecode(resBody)));
  }

  /// Fetches an image from the server.
  ///
  /// This function retrieves the image specified by [fileUrl] from the server.
  /// It returns a [Uint8List] containing the bytes of the image.
  ///
  /// The [fileUrl] parameter is the URL of the image to be fetched.
  ///
  /// The function uses a JWT token for authorization, which is stored securely
  /// and retrieved using [FlutterSecureStorage].
  ///
  /// Throws an [Exception] if the JWT token cannot be retrieved or if the
  /// request fails.
  Future<Uint8List> getImage({required String fileUrl}) async {
    final FlutterSecureStorage storage = sl<FlutterSecureStorage>();
    String? jwtToken = await storage.read(key: StoragekeyConstants.jwtTokenKey);
    Map<String, String> headers = {"Authorization": "Bearer $jwtToken"};
    try {
      log("got image $fileUrl");

      final res = await http.get(
          Uri.parse(
              "${NetworkConstants.getFileWithTokenUrl}$fileUrl?token=$jwtToken"),
          headers: headers);
      if (res.statusCode == 200) {
        log("status ${res.statusCode}");
        return res.bodyBytes;
      } else {
        throw Exception(
            "Failed to get image. Status code: ${res.statusCode}, body: ${res.body}");
      }
    } on Exception catch (e) {
      throw Exception("Failed to get image. Error: $e");
    }
  }

  /// Get image from server.
  ///
  /// Throws exception if cannot get jwt token, or failed to get image.
  ///
  /// [fileUrl] is the url of the image on the server.
  ///
  Future<Uint8List> getThumbnailImage({required String fileUrl}) async {
    final FlutterSecureStorage storage = sl<FlutterSecureStorage>();
    String? jwtToken = await storage.read(key: StoragekeyConstants.jwtTokenKey);
    Map<String, String> headers = {"Authorization": "Bearer $jwtToken"};
    try {
      final res = await http.get(
          Uri.parse("${NetworkConstants.getThumbnailUrl}?fileUrl=$fileUrl"),
          headers: headers);
      if (res.statusCode == 200) {
        log("got image $fileUrl");
        return res.bodyBytes;
      } else {
        throw Exception("Failed to get image. Status code: ${res.statusCode}");
      }
    } on Exception catch (e) {
      throw Exception("Failed to get image. Error: $e");
    }
  }

  Future<Response> uploadGroupProfileImage(
      {required XFile imageFile, required String groupId}) async {
    final FlutterSecureStorage storage = sl<FlutterSecureStorage>();

    String? jwtToken = await storage.read(key: StoragekeyConstants.jwtTokenKey);
    Map<String, String> headers = {"Authorization": "Bearer $jwtToken"};
    Map<String, String> body = {"groupId": groupId};
    List<File> files = [File(imageFile.path)];

    return upload(
        url: NetworkConstants.uploadGroupProfileImageUrl,
        body: body,
        files: files,
        fieldName: "file",
        headers: headers,
        mapper: (resBody) => MapSuccessResponse(jsonRes: jsonDecode(resBody)));
  }

  Future<Response> uploadProfileImage({required XFile imageFile}) async {
    final FlutterSecureStorage storage = sl<FlutterSecureStorage>();
    final CredentialService credentialService = sl<CredentialService>();

    String? jwtToken = await storage.read(key: StoragekeyConstants.jwtTokenKey);
    Map<String, String> headers = {"Authorization": "Bearer $jwtToken"};
    Map<String, String> body = {"userId": credentialService.turmsId ?? ""};
    List<File> files = [File(imageFile.path)];

    return upload(
        url: NetworkConstants.uploadProfileImageUrl,
        body: body,
        files: files,
        fieldName: "file",
        headers: headers,
        mapper: (resBody) => MapSuccessResponse(jsonRes: jsonDecode(resBody)));
  }
}
