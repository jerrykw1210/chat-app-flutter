import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:fixnum/fixnum.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:protech_mobile_chat_stream/constants/network_constants.dart';
import 'package:protech_mobile_chat_stream/constants/storagekey_constants.dart';
import 'package:protech_mobile_chat_stream/network/api_service.dart';
import 'package:protech_mobile_chat_stream/service/credential_service.dart';
import 'package:protech_mobile_chat_stream/service/data.dart';
import 'package:protech_mobile_chat_stream/utils/device_info.dart';
import 'package:protech_mobile_chat_stream/utils/helper.dart';
import 'package:protech_mobile_chat_stream/utils/service_locator.dart';
import 'package:protech_mobile_chat_stream/utils/string_apis.dart';
import 'package:stream_video_flutter/stream_video_flutter.dart';

class AuthenticationService extends ApiBaseHelper {
  String baseUrl = WebserviceClass.devUrl;
  final FlutterSecureStorage _storage = sl<FlutterSecureStorage>();
  final CredentialService _credentialService = sl<CredentialService>();

  /// Logs in with the given [invitationCode], [email] and [password].
  ///
  /// The response body is expected to be a JSON object.
  ///
  /// The [deviceToken] is obtained via [FirebaseMessaging.instance.getToken].
  /// If the token is null, an empty string is used instead.
  ///
  Future<Response> login(
      {required String invitationCode,
      required String email,
      required String password}) async {
    String platform = DeviceInfoClass.osInfo;
    String deviceToken = Helper.generateUUID();

    String deviceModel = DeviceInfoClass.getDeviceModel();
    Map<String, dynamic> body = {
      "invitationCode": invitationCode,
      "email": email,
      "password": password,
      "deviceType": platform,
      "deviceToken": deviceToken,
      "deviceModel": deviceModel
    };

    return post(
        url: NetworkConstants.loginUrl,
        body: body,
        mapper: (resBody) => MapSuccessResponse(jsonRes: jsonDecode(resBody)));
  }

  /// Logs in with the given [invitationCode], [phone] and [password].
  ///
  /// The response body is expected to be a JSON object.
  ///
  /// The [deviceToken] is obtained via [FirebaseMessaging.instance.getToken].
  /// If the token is null, an empty string is used instead.
  Future<Response> loginByPhone(
      {required String invitationCode,
      required String phone,
      required String otp}) async {
    String platform = DeviceInfoClass.osInfo;
    String deviceToken = Helper.generateUUID();
    String deviceModel = DeviceInfoClass.getDeviceModel();
    Map<String, dynamic> body = {
      "invitationCode": invitationCode,
      "phone": phone,
      "otp": otp,
      "deviceType": platform,
      "deviceToken": deviceToken,
      "deviceModel": deviceModel
    };
    return post(
        url: NetworkConstants.loginByPhoneUrl,
        body: body,
        mapper: (resBody) => MapSuccessResponse(jsonRes: jsonDecode(resBody)));
  }

  /// Logs out of the current session.
  ///
  /// The Authorization header is set with the previously stored JWT token.
  /// If the token is null, an empty string is used instead.
  ///
  /// The response body is expected to be a JSON object.
  Future<Response> logout() async {
    String? jwtToken =
        await _storage.read(key: StoragekeyConstants.jwtTokenKey);
    Map<String, String> headers = {"Authorization": "Bearer $jwtToken"};
    return post(
        url: NetworkConstants.logoutUrl,
        headers: headers,
        mapper: (resBody) => MapSuccessResponse(jsonRes: jsonDecode(resBody)));
  }

  /// Checks whether the user is currently logged in.
  ///
  /// This method reads the following from secure storage:
  /// - JWT token
  /// - User ID
  /// - API key
  /// - Auth token
  ///
  /// If any of these values are null, the method returns false.
  /// Otherwise, it returns true.
  Future<bool> isLogin() async {
    String? jwtToken = await _credentialService.getStorageJwtToken;
    String? userId = await _credentialService.getStorageUserId;
    String? apiKey = await _credentialService.getStorageApiKey;
    String? authToken = await _credentialService.getStorageAuthToken;
    String? turmsId = await _credentialService.getStorageTurmsId;
    String? turmsToken = await _credentialService.getStorageTurmsToken;
    String? name = await _credentialService.getStorageUserName;

    if (jwtToken == null ||
        userId == null ||
        apiKey == null ||
        authToken == null ||
        turmsToken == null ||
        turmsId == null ||
        name == null) {
      return false;
    }

    return true;
  }

  /// Automatically logs in the user using stored values.
  ///
  /// This method reads the user ID, API key, and auth token from secure storage.
  /// It then calls `startupStreamVideo` and `startupStreamChat` to log in.
  ///
  /// If any of the values are null, the method does nothing.
  Future<void> autoLogin() async {
    String? jwtToken = await _credentialService.getJwtToken;
    String? userId = await _credentialService.getUserId;
    String? apiKey = await _credentialService.getApiKey;
    String? authToken = await _credentialService.getAuthToken;
    String? turmsUId = await _credentialService.getTurmsId;
    String? turmsToken = await _credentialService.getTurmsToken;
    String? name = await _credentialService.getUserName;

    log("jwtToken $jwtToken");

    Int64 intTurmsUId =
        turmsUId == null ? "0".parseInt64() : turmsUId.parseInt64();

    List<Future> startupFutures = [];

    await startupEndpointService();

    startupFutures.add(startupStreamVideo(
        user: User.regular(userId: userId!, name: name!),
        userToken: authToken!,
        apiKey: apiKey));

    // startupFutures
    //     .add(startupTurms(userId: intTurmsUId, password: turmsToken ?? ""));

    // await Future.wait(startupFutures);

    startupTurms(userId: intTurmsUId, password: turmsToken ?? "");

    // await startupStreamVideo(
    //     user: User.regular(userId: userId!, name: name!),
    //     userToken: authToken!,
    //     apiKey: apiKey);

    // startupTurms(userId: intTurmsUId, password: turmsToken ?? "");
  }

  /// Registers a user with the given [invitationCode], [username], [email], [password], and [otp].
  ///
  /// The response body is expected to be a JSON object.
  ///
  /// The [invitationCode] is obtained entered by the user.
  /// The [username] is the desired username of the user.
  /// The [email] is the email address of the user.
  /// The [password] is the desired password of the user.
  /// The [otp] is the one-time password sent to the user's email address.
  Future<Response> register(
      {required String invitationCode,
      required String username,
      required String email,
      required String otp,
      required String password}) async {
    Map<String, dynamic> body = {
      "invitationCode": invitationCode,
      "email": email,
      "name": username,
      "password": password,
      "otp": otp
      // "phone": phoneNo
    };
    return post(
        url: NetworkConstants.registerUrl,
        body: body,
        mapper: (resBody) => MapSuccessResponse(jsonRes: jsonDecode(resBody)));
  }

  /// Verifies an invitation code.
  ///
  /// The response body is expected to be a JSON object containing a [message] key.
  ///
  /// The [invitationCode] is the code entered by the user.
  Future<Response> verifyInvitationCode({required invitationCode}) async {
    Map<String, dynamic> body = {"invitationCode": invitationCode};

    return post(
        url: "${NetworkConstants.verifyInvitationCodeUrl}",
        body: body,
        mapper: (resBody) => MapSuccessResponse(jsonRes: jsonDecode(resBody)));
  }

  /// Sends a request to generate and send an OTP to the specified email.
  ///
  /// The [email] is the email address to which the OTP will be sent.
  /// The [invitationCode] is associated with the request for OTP.
  ///
  /// Returns a [Response] object containing the server's response to the OTP request.
  Future<Response> getOtp(
      {required String email,
      required String invitationCode,
      String type = "REGISTER"}) async {
    Map<String, dynamic> body = {
      "email": email,
      "invitationCode": invitationCode,
      "type": type
    };
    return post(
        url: NetworkConstants.sendEmailOtpUrl,
        body: body,
        mapper: (resBody) => MapSuccessResponse(jsonRes: jsonDecode(resBody)));
  }

  /// Sends a request to generate and send an OTP to the specified phone number.
  ///
  /// The [phone] is the phone number to which the OTP will be sent.
  /// The [invitationCode] is associated with the request for OTP.
  ///
  /// Returns a [Response] object containing the server's response to the OTP request.
  Future<Response> getPhoneOtp(
      {required String phone,
      required String invitationCode,
      String type = "LOGIN"}) async {
    Map<String, dynamic> body = {
      "phone": phone,
      "invitationCode": invitationCode,
      "type": type
    };
    return post(
        url: NetworkConstants.sendPhoneOtpUrl,
        body: body,
        mapper: (resBody) => MapSuccessResponse(jsonRes: jsonDecode(resBody)));
  }

  /// Resets the user's password using the given OTP.
  ///
  /// The [email] is the email associated with the user's account.
  /// The [invitationCode] is associated with the user's account.
  /// The [password] is the new password to be set.
  /// The [otp] is the one-time password sent to the user's email address.
  ///
  /// Returns a [Response] object containing the server's response to the password reset request.
  Future<Response> resetPassword(
      {required String email,
      required String invitationCode,
      required String password,
      required String otp}) async {
    Map<String, dynamic> body = {
      "email": email,
      "invitationCode": invitationCode,
      "password": password,
      "otp": otp
    };
    return post(
        url: NetworkConstants.resetPasswordUrl,
        body: body,
        mapper: (resBody) => MapSuccessResponse(jsonRes: jsonDecode(resBody)));
  }

  /// Resets the user's password using the given OTP sent to their phone.
  ///
  /// The [phone] is the phone number associated with the user's account.
  /// The [invitationCode] is associated with the user's account.
  /// The [password] is the new password to be set.
  /// The [otp] is the one-time password sent to the user's phone number.
  ///
  /// Returns a [Response] object containing the server's response to the password reset request.
  Future<Response> resetPasswordbyPhone(
      {required String phone,
      required String invitationCode,
      required String password,
      required String otp}) async {
    Map<String, dynamic> body = {
      "phone": phone,
      "invitationCode": invitationCode,
      "password": password,
      "otp": otp
    };
    return post(
        url: NetworkConstants.resetPasswordUrlByPhone,
        body: body,
        mapper: (resBody) => MapSuccessResponse(jsonRes: jsonDecode(resBody)));
  }

  Future<Response> linkDevice({required Map<String, dynamic> body}) async {
    String? jwtToken =
        await _storage.read(key: StoragekeyConstants.jwtTokenKey);
    Map<String, String> headers = {"Authorization": "Bearer $jwtToken"};
    return post(
        url: NetworkConstants.linkDeviceUrl,
        body: body,
        headers: headers,
        mapper: (resBody) => MapSuccessResponse(jsonRes: jsonDecode(resBody)));
  }
}
