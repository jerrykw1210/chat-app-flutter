import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:protech_mobile_chat_stream/constants/network_constants.dart';
import 'package:protech_mobile_chat_stream/constants/storagekey_constants.dart';
import 'package:protech_mobile_chat_stream/service/credential_service.dart';
import 'package:protech_mobile_chat_stream/service/data.dart';
import 'package:protech_mobile_chat_stream/utils/service_locator.dart';

class ProfileService extends ApiBaseHelper {
  final FlutterSecureStorage _storage = sl<FlutterSecureStorage>();
  final CredentialService _credentialService = sl<CredentialService>();

  /// Get available languages from the server.
  Future<Response> getAvailableLanguage() async {
    Map<String, dynamic> body = {};
    return post(
        url: NetworkConstants.getLanguageFileUrl,
        body: body,
        mapper: (resBody) => MapSuccessResponse(jsonRes: jsonDecode(resBody)));
  }

  /// Get the current user's profile.
  Future<Response> getProfile() async {
    String? jwtToken =
        await _storage.read(key: StoragekeyConstants.jwtTokenKey);
    return get(
        url: NetworkConstants.getProfileUrl,
        headers: {"Authorization": "Bearer $jwtToken"},
        mapper: (resBody) => MapSuccessResponse(jsonRes: jsonDecode(resBody)));
  }

  /// Send an OTP to the email address associated with the currently logged in
  /// user. This should be used to verify the email address of the user.
  Future<Response> sendOTPtoVerifyEmail(String email) async {
    String? jwtToken =
        await _storage.read(key: StoragekeyConstants.jwtTokenKey);
    Map<String, dynamic> body = {"email": email};
    return post(
        url: NetworkConstants.sendOTPToEmailAccountUrl,
        body: body,
        headers: {
          "Authorization": "Bearer $jwtToken",
          "Content-Type": "application/json"
        },
        mapper: (resBody) => MapSuccessResponse(jsonRes: jsonDecode(resBody)));
  }

  /// Updates the email address associated with the currently logged in user.
  Future<Response> updateEmail(
      String otp, String password, String email) async {
    String? jwtToken =
        await _storage.read(key: StoragekeyConstants.jwtTokenKey);
    Map<String, dynamic> body = {
      "otp": otp,
      "password": password,
      "email": email
    };
    return put(
        url: NetworkConstants.updateEmailAccountUrl,
        body: body,
        headers: {
          "Authorization": "Bearer $jwtToken",
          "Content-Type": "application/json"
        },
        mapper: (resBody) => MapSuccessResponse(jsonRes: jsonDecode(resBody)));
  }

  /// Gets the list of devices of the user.
  Future<Response> getDevices() async {
    String? jwtToken =
        await _storage.read(key: StoragekeyConstants.jwtTokenKey);
    return get(
        url: "${NetworkConstants.getDevicesUrl}page=0&size=10",
        headers: {"Authorization": "Bearer $jwtToken"},
        mapper: (resBody) => MapSuccessResponse(jsonRes: jsonDecode(resBody)));
  }

  /// Removes the devices of the user.
  Future<Response> removeDevice(String deviceId) async {
    String? jwtToken =
        await _storage.read(key: StoragekeyConstants.jwtTokenKey);
    return delete(
        url: "${NetworkConstants.deleteDeviceUrl}$deviceId",
        headers: {"Authorization": "Bearer $jwtToken"},
        mapper: (resBody) => MapSuccessResponse(jsonRes: jsonDecode(resBody)));
  }

  Future<Response> verifyPassword(String password) async {
    String? jwtToken =
        await _storage.read(key: StoragekeyConstants.jwtTokenKey);
    Map<String, dynamic> body = {"password": password};
    return post(
        url: "${NetworkConstants.verifyPasswordUrl}",
        body: body,
        headers: {
          "Authorization": "Bearer $jwtToken",
          "Content-Type": "application/json"
        },
        mapper: (resBody) => MapSuccessResponse(jsonRes: jsonDecode(resBody)));
  }

  /// Send an OTP to the phone associated with the currently logged in
  /// user. This should be used to verify the phone number of the user.
  Future<Response> sendOTPtoVerifyPhone(String phone) async {
    String? jwtToken =
        await _storage.read(key: StoragekeyConstants.jwtTokenKey);
    Map<String, dynamic> body = {"phone": phone};
    return post(
        url: NetworkConstants.sendOTPToPhoneAccountUrl,
        body: body,
        headers: {
          "Authorization": "Bearer $jwtToken",
          "Content-Type": "application/json"
        },
        mapper: (resBody) => MapSuccessResponse(jsonRes: jsonDecode(resBody)));
  }

  /// Updates the phone number associated with the currently logged in user.
  Future<Response> updatePhone(
      String otp, String password, String phone) async {
    String? jwtToken =
        await _storage.read(key: StoragekeyConstants.jwtTokenKey);
    Map<String, dynamic> body = {
      "otp": otp,
      "password": password,
      "phone": phone
    };
    return put(
        url: NetworkConstants.updatePhoneAccountUrl,
        body: body,
        headers: {
          "Authorization": "Bearer $jwtToken",
          "Content-Type": "application/json"
        },
        mapper: (resBody) => MapSuccessResponse(jsonRes: jsonDecode(resBody)));
  }

  Future<Response> updateName({required String name}) async {
    String? jwtToken = _credentialService.jwtToken;
    Map<String, dynamic> body = {
      "name": name,
    };
    return put(
        url: NetworkConstants.updateProfileUrl,
        body: body,
        headers: {
          "Authorization": "Bearer $jwtToken",
          "Content-Type": "application/json"
        },
        mapper: (resBody) => MapSuccessResponse(jsonRes: jsonDecode(resBody)));
  }

  Future<Response> updateSignature({required String signature}) async {
    String? jwtToken = _credentialService.jwtToken;
    Map<String, dynamic> body = {
      "statusMessage": signature,
    };
    return put(
        url: NetworkConstants.updateProfileUrl,
        body: body,
        headers: {
          "Authorization": "Bearer $jwtToken",
          "Content-Type": "application/json"
        },
        mapper: (resBody) => MapSuccessResponse(jsonRes: jsonDecode(resBody)));
  }

  Future<Response> updateGender({required String gender}) async {
    String? jwtToken = _credentialService.jwtToken;
    Map<String, dynamic> body = {"gender": gender};
    return put(
        url: NetworkConstants.updateProfileUrl,
        body: body,
        headers: {
          "Authorization": "Bearer $jwtToken",
          "Content-Type": "application/json"
        },
        mapper: (resBody) => MapSuccessResponse(jsonRes: jsonDecode(resBody)));
  }

  /// Updates the password associated with the currently logged in user.
  ///
  /// The [oldPassword] is the current password of the user.
  /// The [newPassword] is the new password to be set.
  ///
  /// Returns a [Response] object containing the server's response to the update password request.
  Future<Response> updatePassword(
      String oldPassword, String newPassword) async {
    String? jwtToken =
        await _storage.read(key: StoragekeyConstants.jwtTokenKey);
    Map<String, dynamic> body = {
      "password": oldPassword,
      "newPassword": newPassword,
    };
    return put(
        url: NetworkConstants.updatePasswordAccountUrl,
        body: body,
        headers: {
          "Authorization": "Bearer $jwtToken",
          "Content-Type": "application/json"
        },
        mapper: (resBody) => MapSuccessResponse(jsonRes: jsonDecode(resBody)));
  }

  /// Deletes the currently logged in user's account.
  ///
  /// The [password] is the current password of the user.
  ///
  /// Returns a [Response] object containing the server's response to the delete account request.
  Future<Response> deleteAccount(
    String password,
  ) async {
    String? jwtToken =
        await _storage.read(key: StoragekeyConstants.jwtTokenKey);
    Map<String, dynamic> body = {
      "password": password,
    };
    return delete(
        url: NetworkConstants.deleteAccountUrl,
        body: body,
        headers: {
          "Authorization": "Bearer $jwtToken",
          "Content-Type": "application/json"
        },
        mapper: (resBody) => MapSuccessResponse(jsonRes: jsonDecode(resBody)));
  }

  Future<Response> uploadProfileImage(String imageUrl,
      {required String name}) async {
    String? jwtToken =
        await _storage.read(key: StoragekeyConstants.jwtTokenKey);
    Map<String, dynamic> body = {"profileUrl": imageUrl, "name": name};
    return put(
        url: NetworkConstants.updateProfileUrl,
        body: body,
        headers: {
          "Authorization": "Bearer $jwtToken",
          "Content-Type": "application/json"
        },
        mapper: (resBody) => MapSuccessResponse(jsonRes: jsonDecode(resBody)));
  }
}
