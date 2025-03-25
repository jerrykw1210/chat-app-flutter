import 'package:protech_mobile_chat_stream/service/endpoint_service.dart';
import 'package:protech_mobile_chat_stream/utils/service_locator.dart';
import 'package:protech_mobile_chat_stream/utils/shared_preferences.dart';

enum AppEnvironmentEnum {
  production('production'),
  development('development'); // dev

  const AppEnvironmentEnum(this.value);
  final String value;
}

extension AppEnvironmentEnumExtension on AppEnvironmentEnum {
  static bool isLive() {
    if (NetworkConstants.developerModeEnabled) {
      return NetworkConstants.developerModeEnvironment().value ==
          AppEnvironmentEnum.production.value;
    }
    return NetworkConstants.productionEnvironment ==
        AppEnvironmentEnum.production;
  }
}

class NetworkConstants {
  //*** IMPORTANT NOTE ***

  // 1. DON'T CHANGE SETTING HERE. DOUBLE CHECK WHEN YOU COMMIT OR WANT TO BUILD APK.

  // 2. UNCOMMENT BELOW LINE WHEN
  //  a. RELEASE TO APP STORE, TESTFLIGHT, PLAY STORE
  //static const _developerModeEnabled = kDebugMode;

  // 3. UNCOMMENT LINE 55 WHEN
  //  a. YOU BUILD FROM YOUR ANDROID STUDIO, XCODE, VSCODE
  //  b. FOR TESTER
  static const _developerModeEnabled = true;

  //  !!!!!!!!!!!! DON'T  CHANGE ANY SETTING BEYOND THIS LINE !!!!!!!!!!!!
  // ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  static get developerModeEnabled => _developerModeEnabled;

  static get forceUpdateEnabled => false;

  static AppEnvironmentEnum productionEnvironment =
      AppEnvironmentEnum.production;

  static AppEnvironmentEnum developerModeEnvironment() {
    return developerModeEnabled
        ? (PrefsStorage.appEnvironment.stringValue ==
                productionEnvironment.value
            ? productionEnvironment
            : AppEnvironmentEnum.development)
        : productionEnvironment;
  }

  static final EndpointService _endpointService = sl<EndpointService>();

  // 16 characters - 128 bits
  // 24 characters - 196 bits
  // 32 characters - 256 bits
  static String streamPrivateKey = '45tyrvge8ycx'; // api key

// live url
  static String liveUrl =
      "${_endpointService.getEndpoint(ServiceTypeEnum.auth)}/";

  // dev url
  static String devStreamUrl = "https://chat.stream-io-api.com/";
  static String devUrl =
      "${_endpointService.getEndpoint(ServiceTypeEnum.auth)}/";

  static String get mainUrl =>
      AppEnvironmentEnumExtension.isLive() ? liveUrl : devUrl;

  static get channelUrl => "${mainUrl}channels";

  static get loginUrl =>
      "${_endpointService.getEndpoint(ServiceTypeEnum.auth)}/api/auth/login-by-email";

  static get loginByPhoneUrl =>
      "${_endpointService.getEndpoint(ServiceTypeEnum.auth)}/api/auth/login-by-phone";

  static get logoutUrl =>
      "${_endpointService.getEndpoint(ServiceTypeEnum.auth)}/api/auth/logout";

  static get registerUrl =>
      "${_endpointService.getEndpoint(ServiceTypeEnum.auth)}/api/auth/register-by-email";

  static get verifyInvitationCodeUrl =>
      "http://chat-server-01.prosdtech.com.my:8080/api/auth/verify-invitation-code";

  static get sendEmailOtpUrl =>
      "${_endpointService.getEndpoint(ServiceTypeEnum.auth)}/api/auth/send-otp-to-email";

  static get getProfileUrl =>
      "${_endpointService.getEndpoint(ServiceTypeEnum.account)}/api/account/get-profile";

  static get updateProfileUrl =>
      "${_endpointService.getEndpoint(ServiceTypeEnum.account)}/api/account/update-profile";

  static get sendOTPToEmailAccountUrl =>
      "${_endpointService.getEndpoint(ServiceTypeEnum.account)}/api/account/send-otp-to-email";

  static get updateEmailAccountUrl =>
      "${_endpointService.getEndpoint(ServiceTypeEnum.account)}/api/account/update-email";

  static get getDevicesUrl =>
      "${_endpointService.getEndpoint(ServiceTypeEnum.account)}/api/account/get-devices?";

  static get verifyPasswordUrl =>
      "${_endpointService.getEndpoint(ServiceTypeEnum.account)}/api/account/verify-password";

  static get sendOTPToPhoneAccountUrl =>
      "${_endpointService.getEndpoint(ServiceTypeEnum.account)}/api/account/send-otp-to-phone";

  static get updatePhoneAccountUrl =>
      "${_endpointService.getEndpoint(ServiceTypeEnum.account)}/api/account/update-phone";

  static get sendPhoneOtpUrl =>
      "${_endpointService.getEndpoint(ServiceTypeEnum.auth)}/api/auth/send-otp-to-phone";

  static get resetPasswordUrl =>
      "${_endpointService.getEndpoint(ServiceTypeEnum.auth)}/api/auth/reset-password-by-email";

  static get resetPasswordUrlByPhone =>
      "${_endpointService.getEndpoint(ServiceTypeEnum.auth)}/api/auth/reset-password-by-phone";

  static get linkDeviceUrl =>
      "${_endpointService.getEndpoint(ServiceTypeEnum.account)}/api/account/link-device";

  static get deleteDeviceUrl =>
      "${_endpointService.getEndpoint(ServiceTypeEnum.account)}/api/account/kick-device/";

  static get updatePasswordAccountUrl =>
      "${_endpointService.getEndpoint(ServiceTypeEnum.account)}/api/account/update-password";

  static get deleteAccountUrl =>
      "${_endpointService.getEndpoint(ServiceTypeEnum.account)}/api/account/delete-account";

  static get uploadImageUrl =>
      "${_endpointService.getEndpoint(ServiceTypeEnum.file)}/api/image/upload";

  static get uploadProfileImageUrl =>
      "${_endpointService.getEndpoint(ServiceTypeEnum.file)}/api/file/profile/upload";

  static get uploadGroupProfileImageUrl =>
      "${_endpointService.getEndpoint(ServiceTypeEnum.file)}/api/file/group_profile/upload";

  static get uploadFeedbackUrl =>
      "${_endpointService.getEndpoint(ServiceTypeEnum.account)}/api/feedback/create";

  static get getFileUrl =>
      "${_endpointService.getEndpoint(ServiceTypeEnum.file)}/api/file";

  static get getLanguageListUrl =>
      "${_endpointService.getEndpoint(ServiceTypeEnum.admin)}/api/language/list-all";

  static get getLanguageFileUrl =>
      "${_endpointService.getEndpoint(ServiceTypeEnum.admin)}/api/locale/retrieve";

  static get uploadJSONUrl =>
      "${_endpointService.getEndpoint(ServiceTypeEnum.file)}/api/locale/upload/";

  static get uploadFileUrl =>
      "${_endpointService.getEndpoint(ServiceTypeEnum.file)}/api/file/upload";

  static get getThumbnailUrl =>
      "${_endpointService.getEndpoint(ServiceTypeEnum.file)}/api/file_thumb";

  static get searchUserUrl =>
      "${_endpointService.getEndpoint(ServiceTypeEnum.user)}/api/user/list";

  static get getFileWithTokenUrl =>
      "${_endpointService.getEndpoint(ServiceTypeEnum.file)}/api/get/file/";

  static get getThumbFileWithTokenUrl =>
      "${_endpointService.getEndpoint(ServiceTypeEnum.file)}/api/get/thumb_file/";

  static get getStickerWithTokenUrl =>
      "${_endpointService.getEndpoint(ServiceTypeEnum.file)}/api/sticker/getStickerDirect/";

  static get getProfileImgUrl =>
      "${_endpointService.getEndpoint(ServiceTypeEnum.file)}/api/file/profile/";

  static get getGroupImgUrl =>
      "${_endpointService.getEndpoint(ServiceTypeEnum.file)}/api/file/group_profile/";

  static get addStickerUrl =>
      "${_endpointService.getEndpoint(ServiceTypeEnum.file)}/api/sticker/upload";

  static get getStickerListUrl =>
      "${_endpointService.getEndpoint(ServiceTypeEnum.file)}/api/sticker/packs";

  static get deleteStickerUrl =>
      "${_endpointService.getEndpoint(ServiceTypeEnum.file)}/api/sticker/delete";

  static get getOtherImageUrl =>
      "${_endpointService.getEndpoint(ServiceTypeEnum.file)}/api/file/other_image/upload";


  static get thirdPartyGifUrl => "api.giphy.com/v1/gifs/";

  static const int timeOutInSecond = 30;

  //Return msg
  static const String emailHasBeenUsed = "EMAIL_HAS_BEEN_USED";
  static const String phoneHasBeenUsed = "PHONE_NUMBER_HAS_BEEN_USED";
  static const String otpWrong = "OTP_WRONG";
  static const String otpError = "OTP_ERROR";
  static const String getSuccessMsg = "GET_SUCCESS";
  static const String getFailedMsg = "GET_FAILED";
  static const String pinMatchMsg = "PIN_MATCH";
  static const String fullyRedeem = "FULLY_REDEEM";
  static const String idHasBeenUsed = "ID_HAS_BEEN_USED";
  static const String updateSuccess = "UPDATE_SUCCESS";
  static const String accountAlreadyLoggedIn = "ACCOUNT_ALREADY_LOGGED_IN";
}
