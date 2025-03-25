import 'dart:developer';

import 'package:protech_mobile_chat_stream/module/profile/service/profile_service.dart';
import 'package:protech_mobile_chat_stream/service/response.dart';
import 'package:protech_mobile_chat_stream/utils/service_locator.dart';

class ProfileRepository {
  final ProfileService _profileService = sl<ProfileService>();

  Future<Response> getAvailableLanguage() async {
    Response res = await _profileService.getAvailableLanguage();

    return res;
  }

  Future<Response> getProfile() async {
    Response res = await _profileService.getProfile();

    return res;
  }

  Future<Response> sendOTPEmailAccount(String email) async {
    Response res = await _profileService.sendOTPtoVerifyEmail(email);

    return res;
  }

  Future<Response> updateEmail(
      String otp, String password, String email) async {
    Response res = await _profileService.updateEmail(otp, password, email);

    return res;
  }

  Future<Response> getDevices() async {
    Response res = await _profileService.getDevices();

    return res;
  }

  Future<Response> removeDevice(String deviceId) async {
    Response res = await _profileService.removeDevice(deviceId);

    return res;
  }

  Future<Response> verifyPassword(String password) async {
    Response res = await _profileService.verifyPassword(password);
    log("res verify password $res");
    return res;
  }

  Future<Response> sendOTPPhoneAccount(String phone) async {
    Response res = await _profileService.sendOTPtoVerifyPhone(phone);

    return res;
  }

  Future<Response> updatePhone(
      String otp, String password, String phone) async {
    Response res = await _profileService.updatePhone(otp, password, phone);

    return res;
  }

  Future<Response> updatePassword(
      String oldPassword, String newPassword) async {
    Response res =
        await _profileService.updatePassword(oldPassword, newPassword);
    log("res update password $res");
    return res;
  }

  Future<Response> deleteAccount(
    String password,
  ) async {
    Response res = await _profileService.deleteAccount(password);
    return res;
  }

  Future<Response> uploadProfileImage(String imgUrl,
      {required String name}) async {
    Response res = await _profileService.uploadProfileImage(imgUrl, name: name);
    return res;
  }

  Future<Response> updateName({required String name}) async {
    Response res = await _profileService.updateName(name: name);
    return res;
  }


  Future<Response> updateSignature({required String signature}) async {
    Response res = await _profileService.updateSignature(signature: signature);
    return res;
  }

  Future<Response> updateGender({required String gender}) async {
    Response res = await _profileService.updateGender(gender: gender);
    return res;
  }
}
