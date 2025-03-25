import 'dart:convert';
import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:protech_mobile_chat_stream/constants/string_constant.dart';
import 'package:protech_mobile_chat_stream/module/invitation_code/repository/verify_invitation_code_repository.dart';
import 'package:protech_mobile_chat_stream/service/credential_service.dart';
import 'package:protech_mobile_chat_stream/service/response.dart';
import 'package:protech_mobile_chat_stream/utils/app_exception.dart';
import 'package:protech_mobile_chat_stream/utils/service_locator.dart';
import 'package:protech_mobile_chat_stream/utils/status_code.dart';

part 'verify_invitation_code_state.dart';

class VerifyInvitationCodeCubit extends Cubit<VerifyInvitationCodeState> {
  VerifyInvitationCodeCubit() : super(VerifyInvitationCodeState());

  final VerifyInvitationCodeRepository _verifyInvitationCodeRepository =
      sl<VerifyInvitationCodeRepository>();

  final CredentialService _credentialService = sl<CredentialService>();

  verifyInvitationCode({required String invitationCode}) async {
    emit(state.copyWith(verifyStatus: VerifyStatus.loading));

    Response res = await _verifyInvitationCodeRepository.verifyInvitationCode(
        invitationCode: invitationCode);

    log("verify result $res");

    if (res is MapSuccessResponse) {
      try {
        await _credentialService.writeServiceUrlMap(jsonEncode(res.jsonRes));

        await startupEndpointService();

        emit(state.copyWith(verifyStatus: VerifyStatus.success));
        return;
      } catch (e) {
        emit(state.copyWith(
            verifyStatus: VerifyStatus.fail, errorMessage: null));
      }
    }

    if (res is ConnectionRefusedResponse ||
        res is TimeoutResponse ||
        res is NoInternetResponse) {
      emit(state.copyWith(
          verifyStatus: VerifyStatus.fail,
          errorMessage: Strings.unableToConnectToServer));
      return;
    }

    if (res is BadRequestException) {
      StatusCode.checkErrorCode(res.message, (String? errorMsg) {
        log("error message: $errorMsg");
        emit(state.copyWith(
            verifyStatus: VerifyStatus.fail, errorMessage: errorMsg));
      });
      return;
      // switch (res.message) {
      //   case "761":
      //     emit(state.copyWith(
      //         verifyStatus: VerifyStatus.fail,
      //         errorMessage: Strings.invitationCodeInvalid));
      //     return;
      //   default:
      //     emit(state.copyWith(
      //         verifyStatus: VerifyStatus.fail, errorMessage: null));
      //     return;
      // }
    }

    emit(state.copyWith(verifyStatus: VerifyStatus.fail, errorMessage: null));
  }

  setInvitationCode({required String invitationCode}) {
    emit(state.copyWith(
        invitationCode: invitationCode, verifyStatus: VerifyStatus.initial));
  }
}
