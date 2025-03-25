import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:protech_mobile_chat_stream/module/register/repository/register_repository.dart';
import 'package:protech_mobile_chat_stream/service/response.dart';
import 'package:protech_mobile_chat_stream/utils/app_exception.dart';
import 'package:protech_mobile_chat_stream/utils/status_code.dart';

part 'register_state.dart';

class RegisterCubit extends Cubit<RegisterState> {
  RegisterCubit() : super(RegisterState());
  final RegisterRepository _registerRepository = RegisterRepository();

  register({
    required String invitationCode,
    required String username,
    required String password,
    required String email,
    required String otp,
  }) async {
    emit(state.copyWith(registerStatus: RegisterStatus.loading));

    Response res = await _registerRepository.register(
        invitationCode: invitationCode,
        email: email,
        username: username,
        password: password,
        otp: otp);

    log("register result $res");

    if (res is MapSuccessResponse) {
      emit(state.copyWith(registerStatus: RegisterStatus.success));
      return;
    }

    if (res is ConnectionRefusedResponse ||
        res is TimeoutResponse ||
        res is NoInternetResponse) {
      emit(state.copyWith(
          registerStatus: RegisterStatus.fail, errorMessage: "无法连接到服务器，请重新尝试"));
      return;
    }

    if (res is BadRequestException) {
      StatusCode.checkErrorCode(res.message, (String? errorMsg) {
        log("error message: $errorMsg");
        emit(state.copyWith(
            registerStatus: RegisterStatus.fail, errorMessage: errorMsg));
      });

      return;
      // switch (res.message) {
      //   case "661":
      //     emit(state.copyWith(
      //         registerStatus: RegisterStatus.fail,
      //         errorMessage: Strings.emailFormatInvalid));
      //     return;
      //   case "662":
      //     emit(state.copyWith(
      //         registerStatus: RegisterStatus.fail,
      //         errorMessage: Strings.emailUnavailable));
      //     return;
      //   case "663":
      //     emit(state.copyWith(
      //         registerStatus: RegisterStatus.fail,
      //         errorMessage: Strings.emailInvalid));
      //     return;
      //   case "671":
      //     emit(state.copyWith(
      //         registerStatus: RegisterStatus.fail,
      //         errorMessage: Strings.nameInvalid));
      //     return;
      //   case "672":
      //     emit(state.copyWith(
      //         registerStatus: RegisterStatus.fail,
      //         errorMessage: Strings.nameUnavailable));
      //     return;
      //   case "673":
      //     emit(state.copyWith(
      //         registerStatus: RegisterStatus.fail,
      //         errorMessage: Strings.nameBanned));
      //     return;
      //   case "681":
      //     emit(state.copyWith(
      //         registerStatus: RegisterStatus.fail,
      //         errorMessage: Strings.otpInvalid));
      //     return;
      //   case "682":
      //     emit(state.copyWith(
      //         registerStatus: RegisterStatus.fail,
      //         errorMessage: Strings.otpNotFound));
      //     return;
      //   case "683":
      //     emit(state.copyWith(
      //         registerStatus: RegisterStatus.fail,
      //         errorMessage: Strings.otpInvalid));
      //     return;
      //   default:
      //     emit(state.copyWith(
      //         registerStatus: RegisterStatus.fail, errorMessage: null));
      //     return;
      // }
    }

    emit(state.copyWith(
        registerStatus: RegisterStatus.fail, errorMessage: null));
  }
}
