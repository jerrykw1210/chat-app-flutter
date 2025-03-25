import 'dart:developer';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:image_picker/image_picker.dart';
import 'package:protech_mobile_chat_stream/constants/string_constant.dart';
import 'package:protech_mobile_chat_stream/module/file/repository/file_repository.dart';
import 'package:protech_mobile_chat_stream/module/profile/model/linked_devices.dart';
import 'package:protech_mobile_chat_stream/module/profile/model/user_profile.dart';
import 'package:protech_mobile_chat_stream/module/profile/repository/profile_repository.dart';
import 'package:protech_mobile_chat_stream/service/response.dart';
import 'package:protech_mobile_chat_stream/utils/app_exception.dart';
import 'package:protech_mobile_chat_stream/utils/helper.dart';
import 'package:protech_mobile_chat_stream/utils/service_locator.dart';
import 'package:protech_mobile_chat_stream/utils/status_code.dart';

part 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit() : super(const ProfileState());
  final ProfileRepository _profileRepository = sl<ProfileRepository>();
  final FileRepository _fileRepository = sl<FileRepository>();

  changeGender(String gender) async {
    emit(state.copyWith(updateGenderStatus: UpdateGenderStatus.loading));

    final res = await _profileRepository.updateGender(gender: gender);
    if (res is MapSuccessResponse) {
      emit(state.copyWith(updateGenderStatus: UpdateGenderStatus.success));
      getProfile();
      return;
    }

    if (res is ConnectionRefusedResponse ||
        res is TimeoutResponse ||
        res is NoInternetResponse) {
      emit(state.copyWith(
          updateGenderStatus: UpdateGenderStatus.fail,
          errorMessage: Strings.unableToConnectToServer));
      return;
    }

    emit(state.copyWith(updateGenderStatus: UpdateGenderStatus.fail));
  }

  selectFeedbackType(String feedbackType) {
    emit(state.copyWith(feedbackType: feedbackType));
  }

  reset() {
    emit(state.copyWith(
        updateEmailStatus: UpdateEmailStatus.initial,
        updateGenderStatus: UpdateGenderStatus.initial,
        updateNameStatus: UpdateNameStatus.initial,
        updatePasswordStatus: UpdatePasswordStatus.initial,
        updatePhoneStatus: UpdatePhoneStatus.initial,
        updateSignatureStatus: UpdateSignatureStatus.initial,
        uploadProfileImageStatus: UploadProfileImageStatus.initial));
  }

  addFeedbackScreenshot(XFile image) {
    List<XFile> tempImageList = List.from(state.imageList);
    tempImageList.add(image);
    emit(state.copyWith(imageList: tempImageList));
  }

  removeFeedbackScreenshot(XFile image) {
    List<XFile> tempImageList = List.from(state.imageList);
    tempImageList.remove(image);
    emit(state.copyWith(imageList: tempImageList));
  }

  resetFeedback() {
    emit(state.copyWith(imageList: [], feedbackType: "suggestion"));
  }

  getLoggedInUser() {
    emit(state.copyWith(
        getLoggedInUserStatus: GetLoggedInUserStatus.loading,
        editProfileStatus: EditProfileStatus.initial));

    // CometChat.getLoggedInUser(onSuccess: (User user) {
    //   emit(state.copyWith(
    //       getLoggedInUserStatus: GetLoggedInUserStatus.success, user: user));
    // }, onError: (CometChatException err) {
    //   emit(state.copyWith(getLoggedInUserStatus: GetLoggedInUserStatus.fail));
    // });
  }

  /// get the profile of the currently logged in user.
  Future<void> getProfile() async {
    emit(state.copyWith(
        getProfileStatus: GetProfileStatus.loading,
        updateGenderStatus: UpdateGenderStatus.initial,
        updateNameStatus: UpdateNameStatus.initial,
        uploadProfileImageStatus: UploadProfileImageStatus.initial));
    try {
      final res = await _profileRepository.getProfile();

      if (res is MapSuccessResponse) {
        log("json res ${res.jsonRes}");
        UserProfile userProfile = UserProfile.fromJson(res.jsonRes['data']);

        emit(state.copyWith(
            getProfileStatus: GetProfileStatus.success,
            userProfile: userProfile));
      } else {
        emit(state.copyWith(getProfileStatus: GetProfileStatus.fail));
      }
    } catch (e) {
      log("profile error $e");
    }
  }

  /// Send OTP to the email address associated with the currently logged in user.
  /// This should be used to verify the email address of the user.
  bool sendOTPEmailAccount(String email) {
    bool status = false;
    _profileRepository.sendOTPEmailAccount(email).then((res) {
      if (res is MapSuccessResponse) {
        log("email otp ${res.jsonRes['data']}");
        status = true;
        log("otp status $status");
      } else {
        status = false;
      }
    });

    return status;
  }

  /// Updates the email address associated with the currently logged in user.
  Future<void> updateEmail(String otp, String password, String email) async {
    emit(state.copyWith(updateEmailStatus: UpdateEmailStatus.loading));
    final res = await _profileRepository.updateEmail(otp, password, email);
    if (res is MapSuccessResponse) {
      log("succes update email ${res.jsonRes['data']}");
      emit(state.copyWith(updateEmailStatus: UpdateEmailStatus.success));
      getProfile();
    } else {
      emit(state.copyWith(updateEmailStatus: UpdateEmailStatus.fail));
    }
  }

  /// Send OTP to the phone associated with the currently logged in user.
  /// This should be used to verify the phone number of the user.
  bool sendOTPPhoneAccount(String phone) {
    bool status = false;
    _profileRepository.sendOTPPhoneAccount(phone).then((res) {
      if (res is MapSuccessResponse) {
        log("phone otp ${res.jsonRes['data']}");
        status = true;
        log("otp status $status");
      } else {
        status = false;
      }
    });

    return status;
  }

  /// Updates the phone associated with the currently logged in user.
  Future<void> updatePhone(String otp, String password, String phone) async {
    emit(state.copyWith(updatePhoneStatus: UpdatePhoneStatus.loading));
    final res = await _profileRepository.updatePhone(otp, password, phone);
    if (res is MapSuccessResponse) {
      log("succes update phone ${res.jsonRes['data']}");
      emit(state.copyWith(updatePhoneStatus: UpdatePhoneStatus.success));
      getProfile();
    } else {
      emit(state.copyWith(updatePhoneStatus: UpdatePhoneStatus.fail));
    }
  }

  /// Gets the list of devices of the user.
  Future<void> getDevices() async {
    try {
      final res = await _profileRepository.getDevices();
      if (res is MapSuccessResponse) {
        log("linked devices ${res.jsonRes['data']}");
        final devicesJson = LinkedDevices.fromJson(res.jsonRes['data']);
        String fcmToken = Helper.generateUUID();
        final status = devicesJson.devices.isNotEmpty
            ? GetDevicesStatus.success
            : GetDevicesStatus.empty;
        if (devicesJson.devices.isNotEmpty) {
          devicesJson.devices.removeWhere((device) =>
              device.token.toString().trim() == fcmToken.toString().trim());
        }
        if (devicesJson.devices.isNotEmpty &&
            devicesJson.devices.any((device) => device.status == "DELETED")) {
          devicesJson.devices
              .removeWhere((device) => device.status == "DELETED");
        }
        emit(state.copyWith(
            getDevicesStatus: status, linkedDevices: devicesJson.devices));
        log("get devices $devicesJson");
      }
    } catch (e) {
      log("get devices error $e");
      emit(state.copyWith(getDevicesStatus: GetDevicesStatus.fail));
    }
  }

  /// Removes the device of the user with the given [deviceId].
  /// Also calls [getDevices] to refresh the list of devices.
  Future<void> removeDevice(String deviceId) async {
    try {
      final res = await _profileRepository.removeDevice(deviceId);
      if (res is MapSuccessResponse) {
        log("messages ${res.jsonRes['data']}");
        emit(state.copyWith(removeDeviceStatus: RemoveDeviceStatus.success));
        getDevices();
        // final devicesJson = LinkedDevices.fromJson(res.jsonRes['data']);

        // final status = devicesJson.devices.isNotEmpty
        //     ? GetDevicesStatus.success
        //     : GetDevicesStatus.empty;
        // if (devicesJson.devices.isNotEmpty &&
        //     devicesJson.devices.any((device) => device.isOnline)) {
        //   devicesJson.devices.removeWhere((device) => device.isOnline);
        // }
        // emit(state.copyWith(
        //     getDevicesStatus: status, linkedDevices: devicesJson.devices));
        // log("get devices $devicesJson");
      }
    } catch (e) {
      log("get devices error $e");
      emit(state.copyWith(getDevicesStatus: GetDevicesStatus.fail));
    }
  }

  /// Verifies the password of the user.
  Future<void> verifyPassword(String password) async {
    emit(state.copyWith(verifyPasswordStatus: VerifyPasswordStatus.loading));
    final res = await _profileRepository.verifyPassword(password);
    final status = res is MapSuccessResponse && res.jsonRes['data']['result']
        ? VerifyPasswordStatus.success
        : VerifyPasswordStatus.fail;
    emit(state.copyWith(verifyPasswordStatus: status));
  }

  /// Updates the password associated with the currently logged in user.
  Future<void> updatePassword(String oldPassword, String newPassword) async {
    emit(state.copyWith(updatePasswordStatus: UpdatePasswordStatus.loading));
    final res =
        await _profileRepository.updatePassword(oldPassword, newPassword);
    if (res is MapSuccessResponse) {
      log("succes update password ${res.jsonRes['data']}");
      emit(state.copyWith(updatePasswordStatus: UpdatePasswordStatus.success));
    } else {
      if (res is BadRequestException) {
        log("update password erorr $res");
        StatusCode.checkErrorCode(res.message, (String? errorMsg) {
          log("error message: $errorMsg");
          emit(state.copyWith(
              updatePasswordStatus: UpdatePasswordStatus.fail,
              errorMessage: errorMsg));
        });

        return;
        // emit(state.copyWith(
        //     updatePasswordStatus: UpdatePasswordStatus.fail,
        //     updatePasswordError: res.message));
      }
    }
  }

  /// Deletes the currently logged in user's account using the provided password.
  Future<void> deleteAccount(String password) async {
    emit(state.copyWith(deleteAccountStatus: DeleteAccountStatus.loading));
    final res = await _profileRepository.deleteAccount(password);
    if (res is MapSuccessResponse) {
      log("succes delete account ${res.jsonRes['data']}");
      emit(state.copyWith(deleteAccountStatus: DeleteAccountStatus.success));
    } else {
      emit(state.copyWith(deleteAccountStatus: DeleteAccountStatus.fail));
    }
  }

  Future<void> uploadProfileImage(XFile file, {required String name}) async {
    emit(state.copyWith(
        uploadProfileImageStatus: UploadProfileImageStatus.loading));

    final uploadRes = await _fileRepository.uploadProfileImage(file: file);

    if (uploadRes is ConnectionRefusedResponse ||
        uploadRes is TimeoutResponse ||
        uploadRes is NoInternetResponse) {
      emit(state.copyWith(
          uploadProfileImageStatus: UploadProfileImageStatus.fail,
          errorMessage: "无法连接到服务器，请重新尝试"));
      return;
    }

    if (uploadRes is MapSuccessResponse) {
      // ['data']['fileUrl']
      String imgUrl = uploadRes.jsonRes['data']?['fileUrl'] ?? "";

      final res =
          await _profileRepository.uploadProfileImage(imgUrl, name: name);

    if (res is MapSuccessResponse) {
        emit(state.copyWith(
            uploadProfileImageStatus: UploadProfileImageStatus.success));
        return;
      }

      if (res is ConnectionRefusedResponse ||
          res is TimeoutResponse ||
          res is NoInternetResponse) {
        emit(state.copyWith(
            uploadProfileImageStatus: UploadProfileImageStatus.fail,
            errorMessage: Strings.unableToConnectToServer));
        return;
      }
    }

    // if (res is MapSuccessResponse) {
    //   emit(state.copyWith(submitFeedbackStatus: SubmitFeedbackStatus.success));
    //   return;
    // }

    emit(state.copyWith(
        uploadProfileImageStatus: UploadProfileImageStatus.fail));
  }

  Future<void> updateName({required String name}) async {
    emit(state.copyWith(updateNameStatus: UpdateNameStatus.loading));

    final res = await _profileRepository.updateName(name: name);
    if (res is MapSuccessResponse) {
      emit(state.copyWith(updateNameStatus: UpdateNameStatus.success));
      getProfile();
      return;
    }

    if (res is ConnectionRefusedResponse ||
        res is TimeoutResponse ||
        res is NoInternetResponse) {
      emit(state.copyWith(
          updateNameStatus: UpdateNameStatus.fail,
          errorMessage: Strings.unableToConnectToServer));
      return;
    }

    emit(state.copyWith(updateNameStatus: UpdateNameStatus.fail));
  }

  Future<void> updateSignature({required String signature}) async {
    emit(state.copyWith(updateSignatureStatus: UpdateSignatureStatus.loading));

    final res = await _profileRepository.updateSignature(signature: signature);
    if (res is MapSuccessResponse) {
      emit(
          state.copyWith(updateSignatureStatus: UpdateSignatureStatus.success));
      getProfile();
      return;
    }

    if (res is ConnectionRefusedResponse ||
        res is TimeoutResponse ||
        res is NoInternetResponse) {
      emit(state.copyWith(
          updateSignatureStatus: UpdateSignatureStatus.fail,
          errorMessage: Strings.unableToConnectToServer));
      return;
    }

    emit(state.copyWith(updateSignatureStatus: UpdateSignatureStatus.fail));
  }
}
