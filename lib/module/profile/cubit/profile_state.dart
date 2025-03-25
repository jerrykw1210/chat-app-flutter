part of 'profile_cubit.dart';

enum GetLoggedInUserStatus { initial, success, fail, loading, empty }

enum GetProfileStatus { initial, success, fail, loading, empty }

enum EditProfileStatus { initial, success, fail, loading, empty }

enum GetDevicesStatus { initial, success, fail, loading, empty }

enum VerifyPasswordStatus { initial, success, fail, loading, empty }

enum UpdateEmailStatus { initial, success, fail, loading, empty }

enum SendOtpEmailStatus { initial, success, fail, loading, empty }

enum UpdatePhoneStatus { initial, success, fail, loading, empty }

enum RemoveDeviceStatus { initial, success, fail, loading, empty }

enum UpdatePasswordStatus { initial, success, fail, loading, empty }

enum DeleteAccountStatus { initial, success, fail, loading, empty }

enum UploadProfileImageStatus { initial, success, fail, loading, empty }

enum UpdateGenderStatus { initial, success, fail, loading, empty }

enum UpdateNameStatus { initial, success, fail, loading, empty }

enum UpdateSignatureStatus { initial, success, fail, loading, empty }

class ProfileState extends Equatable {
  final String gender;
  final String feedbackType;
  final List<XFile> imageList;
  final String? errorMessage;
  final String? updatePasswordError;

  final GetLoggedInUserStatus? getLoggedInUserStatus;
  final GetProfileStatus? getProfileStatus;
  final EditProfileStatus? editProfileStatus;
  final GetDevicesStatus? getDevicesStatus;
  final VerifyPasswordStatus? verifyPasswordStatus;
  final UpdateEmailStatus? updateEmailStatus;
  final SendOtpEmailStatus? sendOtpEmailStatus;
  final UpdatePhoneStatus? updatePhoneStatus;
  final RemoveDeviceStatus? removeDeviceStatus;
  final UpdatePasswordStatus? updatePasswordStatus;
  final DeleteAccountStatus? deleteAccountStatus;
  final UploadProfileImageStatus? uploadProfileImageStatus;
  final UpdateGenderStatus? updateGenderStatus;
  final UpdateNameStatus? updateNameStatus;
  final UpdateSignatureStatus? updateSignatureStatus;
  final UserProfile? userProfile;
  final List<LinkedDevice> linkedDevices;
  const ProfileState(
      {this.gender = "MALE",
      this.errorMessage,
      this.updatePasswordError,
      this.feedbackType = "suggestion",
      this.imageList = const [],
      this.getLoggedInUserStatus = GetLoggedInUserStatus.initial,
      this.getProfileStatus = GetProfileStatus.initial,
      this.editProfileStatus = EditProfileStatus.initial,
      this.getDevicesStatus = GetDevicesStatus.initial,
      this.verifyPasswordStatus = VerifyPasswordStatus.initial,
      this.updateEmailStatus = UpdateEmailStatus.initial,
      this.sendOtpEmailStatus = SendOtpEmailStatus.initial,
      this.updatePhoneStatus = UpdatePhoneStatus.initial,
      this.removeDeviceStatus = RemoveDeviceStatus.initial,
      this.updatePasswordStatus = UpdatePasswordStatus.initial,
      this.deleteAccountStatus = DeleteAccountStatus.initial,
      this.uploadProfileImageStatus = UploadProfileImageStatus.initial,
      this.updateGenderStatus = UpdateGenderStatus.initial,
      this.updateNameStatus = UpdateNameStatus.initial,
      this.updateSignatureStatus = UpdateSignatureStatus.initial,
      this.userProfile,
      this.linkedDevices = const []});
  ProfileState copyWith(
      {String? gender,
      String? errorMessage,
      String? updatePasswordError,
      String? feedbackType,
      List<XFile>? imageList,
      UserProfile? userProfile,
      GetLoggedInUserStatus? getLoggedInUserStatus,
      GetProfileStatus? getProfileStatus,
      EditProfileStatus? editProfileStatus,
      GetDevicesStatus? getDevicesStatus,
      VerifyPasswordStatus? verifyPasswordStatus,
      UpdateEmailStatus? updateEmailStatus,
      SendOtpEmailStatus? sendOtpEmailStatus,
      UpdatePhoneStatus? updatePhoneStatus,
      RemoveDeviceStatus? removeDeviceStatus,
      UpdatePasswordStatus? updatePasswordStatus,
      DeleteAccountStatus? deleteAccountStatus,
      UploadProfileImageStatus? uploadProfileImageStatus,
      UpdateGenderStatus? updateGenderStatus,
      UpdateNameStatus? updateNameStatus,
      UpdateSignatureStatus? updateSignatureStatus,
      List<LinkedDevice>? linkedDevices}) {
    return ProfileState(
        gender: gender ?? this.gender,
        errorMessage: errorMessage ?? this.errorMessage,
        updatePasswordError: updatePasswordError ?? this.updatePasswordError,
        feedbackType: feedbackType ?? this.feedbackType,
        imageList: imageList ?? this.imageList,
        getLoggedInUserStatus:
            getLoggedInUserStatus ?? this.getLoggedInUserStatus,
        getProfileStatus: getProfileStatus ?? this.getProfileStatus,
        editProfileStatus: editProfileStatus ?? this.editProfileStatus,
        getDevicesStatus: getDevicesStatus ?? this.getDevicesStatus,
        verifyPasswordStatus: verifyPasswordStatus ?? this.verifyPasswordStatus,
        updateEmailStatus: updateEmailStatus ?? this.updateEmailStatus,
        sendOtpEmailStatus: sendOtpEmailStatus ?? this.sendOtpEmailStatus,
        updatePhoneStatus: updatePhoneStatus ?? this.updatePhoneStatus,
        removeDeviceStatus: removeDeviceStatus ?? this.removeDeviceStatus,
        updatePasswordStatus: updatePasswordStatus ?? this.updatePasswordStatus,
        deleteAccountStatus: deleteAccountStatus ?? this.deleteAccountStatus,
        uploadProfileImageStatus:
            uploadProfileImageStatus ?? this.uploadProfileImageStatus,
        updateGenderStatus: updateGenderStatus ?? this.updateGenderStatus,
        updateNameStatus: updateNameStatus ?? this.updateNameStatus,
        updateSignatureStatus: updateSignatureStatus ?? this.updateSignatureStatus,
        userProfile: userProfile ?? this.userProfile,
        linkedDevices: linkedDevices ?? this.linkedDevices);
  }

  @override
  List<Object?> get props => [
        gender,
        errorMessage,
        updatePasswordError,
        feedbackType,
        imageList,
        getLoggedInUserStatus,
        getProfileStatus,
        editProfileStatus,
        getDevicesStatus,
        verifyPasswordStatus,
        updateEmailStatus,
        sendOtpEmailStatus,
        updatePhoneStatus,
        removeDeviceStatus,
        updatePasswordStatus,
        deleteAccountStatus,
        uploadProfileImageStatus,
        updateGenderStatus,
        updateNameStatus,
        updateSignatureStatus,
        userProfile,
        linkedDevices
      ];
}

