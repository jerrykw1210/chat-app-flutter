import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:protech_mobile_chat_stream/constants/string_constant.dart';
import 'package:protech_mobile_chat_stream/module/forget_password/repository/forget_password_repository.dart';
import 'package:protech_mobile_chat_stream/service/response.dart';
import 'package:protech_mobile_chat_stream/utils/app_exception.dart';
import 'package:protech_mobile_chat_stream/utils/service_locator.dart';
import 'package:protech_mobile_chat_stream/utils/status_code.dart';

part 'forget_password_state.dart';

class ForgetPasswordCubit extends Cubit<ForgetPasswordState> {
  ForgetPasswordCubit() : super(ForgetPasswordState());

  final ForgetPasswordRepository _forgetPasswordRepository =
      sl<ForgetPasswordRepository>();

  Future<void> forgetPassword(
      {required String email,
      required String otp,
      required String invitationCode,
      required newPassword}) async {
    emit(state.copyWith(forgetPasswordStatus: ForgetPasswordStatus.loading));
    Response res = await _forgetPasswordRepository.forgetPassword(
        email: email,
        otp: otp,
        invitationCode: invitationCode,
        newPassword: newPassword);

    if (res is MapSuccessResponse) {
      emit(state.copyWith(forgetPasswordStatus: ForgetPasswordStatus.success));
      return;
    }
    if (res is ConnectionRefusedResponse ||
        res is TimeoutResponse ||
        res is NoInternetResponse) {
      emit(state.copyWith(
          forgetPasswordStatus: ForgetPasswordStatus.fail,
          errorMessage: Strings.unableToConnectToServer));
      return;
    }

    if (res is BadRequestException) {
      StatusCode.checkErrorCode(res.message, (String? errorMsg) {
        log("error message: $errorMsg");
        emit(state.copyWith(
            forgetPasswordStatus: ForgetPasswordStatus.fail,
            errorMessage: errorMsg));
      });
      return;
      // switch (res.message) {
      //   case "681":
      //     emit(state.copyWith(
      //         forgetPasswordStatus: ForgetPasswordStatus.fail,
      //         errorMessage: Strings.otpInvalid));
      //     return;
      //   case "682":
      //     emit(state.copyWith(
      //         forgetPasswordStatus: ForgetPasswordStatus.fail,
      //         errorMessage: Strings.otpNotFound));
      //     return;
      //   case "683":
      //     emit(state.copyWith(
      //         forgetPasswordStatus: ForgetPasswordStatus.fail,
      //         errorMessage: Strings.otpInvalid));
      //     return;
      //   case "661":
      //     emit(state.copyWith(
      //         forgetPasswordStatus: ForgetPasswordStatus.fail,
      //         errorMessage: Strings.emailFormatInvalid));
      //     return;
      //   case "662":
      //     emit(state.copyWith(
      //         forgetPasswordStatus: ForgetPasswordStatus.fail,
      //         errorMessage: Strings.emailUnavailable));
      //     return;
      //   case "663":
      //     emit(state.copyWith(
      //         forgetPasswordStatus: ForgetPasswordStatus.fail,
      //         errorMessage: Strings.emailInvalid));
      //     return;
      //   default:
      //     emit(state.copyWith(
      //         forgetPasswordStatus: ForgetPasswordStatus.fail,
      //         errorMessage: null));
      //     return;
      // }
    }

    emit(state.copyWith(
        forgetPasswordStatus: ForgetPasswordStatus.fail, errorMessage: null));
  }

  Future<void> forgetPasswordByPhone(
      {required String phone,
      required String otp,
      required String invitationCode,
      required newPassword}) async {
    emit(state.copyWith(forgetPasswordStatus: ForgetPasswordStatus.loading));
    Response res = await _forgetPasswordRepository.forgetPasswordByPhone(
        phone: phone,
        otp: otp,
        invitationCode: invitationCode,
        newPassword: newPassword);

    if (res is MapSuccessResponse) {
      emit(state.copyWith(forgetPasswordStatus: ForgetPasswordStatus.success));
      return;
    }

    if (res is ConnectionRefusedResponse ||
        res is TimeoutResponse ||
        res is NoInternetResponse) {
      emit(state.copyWith(
          forgetPasswordStatus: ForgetPasswordStatus.fail,
          errorMessage: Strings.unableToConnectToServer));
      return;
    }

    if (res is BadRequestException) {
      StatusCode.checkErrorCode(res.message, (String? errorMsg) {
        log("error message: $errorMsg");
        emit(state.copyWith(
            forgetPasswordStatus: ForgetPasswordStatus.fail,
            errorMessage: errorMsg));
      });
      return;
      // switch (res.message) {
      //   case "681":
      //     emit(state.copyWith(
      //         forgetPasswordStatus: ForgetPasswordStatus.fail,
      //         errorMessage: Strings.otpInvalid));
      //     return;
      //   case "682":
      //     emit(state.copyWith(
      //         forgetPasswordStatus: ForgetPasswordStatus.fail,
      //         errorMessage: Strings.otpNotFound));
      //     return;
      //   case "683":
      //     emit(state.copyWith(
      //         forgetPasswordStatus: ForgetPasswordStatus.fail,
      //         errorMessage: Strings.otpInvalid));
      //     return;
      //   case "651":
      //     emit(state.copyWith(
      //         forgetPasswordStatus: ForgetPasswordStatus.fail,
      //         errorMessage: Strings.phoneFormatInvalid));
      //     return;
      //   case "652":
      //     emit(state.copyWith(
      //         forgetPasswordStatus: ForgetPasswordStatus.fail,
      //         errorMessage: Strings.phoneUnavailable));
      //     return;
      //   case "653":
      //     emit(state.copyWith(
      //         forgetPasswordStatus: ForgetPasswordStatus.fail,
      //         errorMessage: Strings.phoneInvalid));
      //     return;
      //   default:
      //     emit(state.copyWith(
      //         forgetPasswordStatus: ForgetPasswordStatus.fail,
      //         errorMessage: null));
      //     return;
      // }
    }

    emit(state.copyWith(
        forgetPasswordStatus: ForgetPasswordStatus.fail, errorMessage: null));
  }
}
