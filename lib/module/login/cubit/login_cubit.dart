import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:protech_mobile_chat_stream/constants/storagekey_constants.dart';
import 'package:protech_mobile_chat_stream/module/login/repository/login_repository.dart';
import 'package:protech_mobile_chat_stream/module/profile/repository/profile_repository.dart';
import 'package:protech_mobile_chat_stream/service/credential_service.dart';
import 'package:protech_mobile_chat_stream/service/data.dart';
import 'package:protech_mobile_chat_stream/service/turms_service.dart';
import 'package:protech_mobile_chat_stream/utils/app_exception.dart';
import 'package:protech_mobile_chat_stream/utils/browser_minimised_manager.dart';
import 'package:protech_mobile_chat_stream/utils/connection_status_manager.dart';
import 'package:protech_mobile_chat_stream/utils/service_locator.dart';
import 'package:protech_mobile_chat_stream/utils/status_code.dart';
import 'package:protech_mobile_chat_stream/utils/string_apis.dart';
import 'package:stream_video_flutter/stream_video_flutter.dart';
import 'package:turms_client_dart/turms_client.dart' as turms;

import '../../../constants/string_constant.dart';

part 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  LoginCubit() : super(const LoginState());

  final LoginRepository _loginRepository = sl<LoginRepository>();
  final CredentialService _credentialService = sl<CredentialService>();
  final FlutterSecureStorage _storage = sl<FlutterSecureStorage>();

  login(
      {required String email,
      required String password,
      required String invitationCode}) async {
    emit(state.copyWith(loginStatus: LoginStatus.loading));

    Response res = await _loginRepository.login(
        invitationCode: invitationCode, email: email, password: password);

    log("login result $res");

    if (res is MapSuccessResponse) {
      Map<String, dynamic> result = res.jsonRes["data"];
      String jwtToken = result["jwt"];
      String turmsToken = result["turmsJWT"];
      String userId = result["thirdPartyUserId"];
      String apiKey = result["thirdPartyAPIKey"];
      String authToken = result["thirdPartyAuthToken"];
      String turmsId = result["turmsUId"];
      String name = result["name"] ?? "Guest";

      List<Future> startupFutures = [];

      // _storage.write(key: StoragekeyConstants.jwtTokenKey, value: jwtToken);
      // _storage.write(key: StoragekeyConstants.userIdKey, value: userId);
      // _storage.write(key: StoragekeyConstants.apiKeyKey, value: apiKey);
      // _storage.write(key: StoragekeyConstants.authTokenKey, value: authToken);
      // _storage.write(
      //     key: StoragekeyConstants.turmsUidKey, value: turmsId.toString());
      // _storage.write(key: StoragekeyConstants.turmsTokenKey, value: turmsToken);

      _credentialService.writeCredential(result: result);

      startupFutures.add(startupStreamVideo(
          user: User.regular(userId: turmsId, name: name),
          userToken: authToken,
          apiKey: apiKey));

   

      // startupFutures.add(
      //     startupTurms(userId: turmsId.parseInt64(), password: turmsToken));

      await Future.wait(startupFutures);

      startupTurms(userId: turmsId.parseInt64(), password: turmsToken);

      // await startupStreamVideo(
      //     user: User.regular(userId: userId, name: name),
      //     userToken: authToken,
      //     apiKey: apiKey);

      // await startupStreamChat(
      //     userId: userId, userToken: authToken, apiKey: apiKey);

      log("jwt $jwtToken");
      log("turmsUID $turmsId");

      // await startupTurms(userId: turmsId.parseInt64(), password: turmsToken);

      emit(state.copyWith(loginStatus: LoginStatus.success));

      return;
    }

    if (res is ConnectionRefusedResponse ||
        res is TimeoutResponse ||
        res is NoInternetResponse) {
      emit(state.copyWith(
          loginStatus: LoginStatus.fail, errorMessage: "无法连接到服务器，请重新尝试"));
      return;
    }

    if (res is BadRequestException) {
      StatusCode.checkErrorCode(res.message, (String? errorMsg) {
        log("error message: $errorMsg");
        emit(state.copyWith(
            loginStatus: LoginStatus.fail, errorMessage: errorMsg));
      });

      return;

      // switch (res.message) {
      //   case "710":
      //     emit(state.copyWith(
      //         loginStatus: LoginStatus.fail,
      //         errorMessage: Strings.invalidLogin));
      //     return;
      //   case "661":
      //     emit(state.copyWith(
      //         loginStatus: LoginStatus.fail,
      //         errorMessage: Strings.emailFormatInvalid));
      //     return;
      //   case "662":
      //     emit(state.copyWith(
      //         loginStatus: LoginStatus.fail,
      //         errorMessage: Strings.emailUnavailable));
      //     return;
      //   case "663":
      //     emit(state.copyWith(
      //         loginStatus: LoginStatus.fail,
      //         errorMessage: Strings.emailInvalid));
      //     return;
      //   default:
      //     emit(state.copyWith(
      //         loginStatus: LoginStatus.fail, errorMessage: null));
      //     return;
      // }
    }

    emit(state.copyWith(loginStatus: LoginStatus.fail, errorMessage: null));
    return;
  }

  loginByPhone(
      {required String phone,
      required String otp,
      required String invitationCode}) async {
    emit(state.copyWith(loginStatus: LoginStatus.loading));

    Response res = await _loginRepository.loginByPhone(
        invitationCode: invitationCode, phone: phone, otp: otp);

    log("login result $res");

    if (res is MapSuccessResponse) {
      Map<String, dynamic> result = res.jsonRes["data"];
      String jwtToken = result["jwt"];
      String turmsToken = result["turmsJWT"];
      String userId = result["thirdPartyUserId"];
      String apiKey = result["thirdPartyAPIKey"];
      String authToken = result["thirdPartyAuthToken"];
      String turmsId = result["turmsUId"];
      String name = result["name"] ?? "Guest";

      List<Future> startupFutures = [];

      // _storage.write(key: StoragekeyConstants.jwtTokenKey, value: jwtToken);
      // _storage.write(key: StoragekeyConstants.userIdKey, value: userId);
      // _storage.write(key: StoragekeyConstants.apiKeyKey, value: apiKey);
      // _storage.write(key: StoragekeyConstants.authTokenKey, value: authToken);
      // _storage.write(
      //     key: StoragekeyConstants.turmsUidKey, value: turmsId.toString());
      // _storage.write(key: StoragekeyConstants.turmsTokenKey, value: turmsToken);

      _credentialService.writeCredential(result: result);

      startupFutures.add(startupStreamVideo(
          user: User.regular(userId: turmsId, name: name),
          userToken: authToken,
          apiKey: apiKey));

   

      // startupFutures.add(
      //     startupTurms(userId: turmsId.parseInt64(), password: turmsToken));

      await Future.wait(startupFutures);

      startupTurms(userId: turmsId.parseInt64(), password: turmsToken);

      // await startupStreamVideo(
      //     user: User.regular(userId: turmsId, name: name),
      //     userToken: authToken,
      //     apiKey: apiKey);

      // await startupStreamChat(
      //     userId: userId, userToken: authToken, apiKey: apiKey);

      log("jwt $jwtToken");
      log("turmsUID $turmsId");

      // await startupTurms(userId: turmsId.parseInt64(), password: turmsToken);

      emit(state.copyWith(loginStatus: LoginStatus.success));
      sl<ProfileRepository>().getProfile();
      return;
    }

    if (res is ConnectionRefusedResponse ||
        res is TimeoutResponse ||
        res is NoInternetResponse) {
      emit(state.copyWith(
          loginStatus: LoginStatus.fail,
          errorMessage: Strings.unableToConnectToServer));
      return;
    }

    if (res is BadRequestException) {
      StatusCode.checkErrorCode(res.message, (String? errorMsg) {
        log("error message: $errorMsg");
        emit(state.copyWith(
            loginStatus: LoginStatus.fail, errorMessage: errorMsg));
      });

      return;
      // switch (res.message) {
      //   case "710":
      //     emit(state.copyWith(
      //         loginStatus: LoginStatus.fail,
      //         errorMessage: Strings.invalidLogin));
      //     return;
      //   case "651":
      //     emit(state.copyWith(
      //         loginStatus: LoginStatus.fail,
      //         errorMessage: Strings.phoneFormatInvalid));
      //     return;
      //   case "652":
      //     emit(state.copyWith(
      //         loginStatus: LoginStatus.fail,
      //         errorMessage: Strings.phoneUnavailable));
      //     return;
      //   case "653":
      //     emit(state.copyWith(
      //         loginStatus: LoginStatus.fail,
      //         errorMessage: Strings.phoneInvalid));
      //     return;
      //   default:
      //     emit(state.copyWith(
      //         loginStatus: LoginStatus.fail, errorMessage: null));
      //     return;
      // }
    }

    emit(state.copyWith(loginStatus: LoginStatus.fail, errorMessage: null));
    return;
  }

  Future<void> logout() async {
    emit(state.copyWith(logoutStatus: LogoutStatus.loading));

    ConnectionStatusManager.dismissConnectionStatus();
    Response res = await _loginRepository.logout();

    _storage.delete(key: StoragekeyConstants.jwtTokenKey);
    _storage.delete(key: StoragekeyConstants.userIdKey);
    _storage.delete(key: StoragekeyConstants.apiKeyKey);
    _storage.delete(key: StoragekeyConstants.authTokenKey);

    await _storage.deleteAll();

    await disposeGetStream();

    sl<CredentialService>().deleteCredential();
    await sl<TurmsService>().handleTurmsResponse(() async {
      await sl<turms.TurmsClient>().userService.logout();
      await sl<turms.TurmsClient>().close();
      return;
    });

    BrowserMinimisedManager.removeMinimisedButton();

    emit(state.copyWith(logoutStatus: LogoutStatus.success));
    return;

    // if (res is MapSuccessResponse) {
    //   _storage.delete(key: StoragekeyConstants.jwtTokenKey);
    //   _storage.delete(key: StoragekeyConstants.userIdKey);
    //   _storage.delete(key: StoragekeyConstants.apiKeyKey);
    //   _storage.delete(key: StoragekeyConstants.authTokenKey);

    //   await disposeGetStream();

    //   emit(state.copyWith(logoutStatus: LogoutStatus.success));
    //   return;
    // }

    // emit(state.copyWith(logoutStatus: LogoutStatus.fail));
    // return;
  }
}
