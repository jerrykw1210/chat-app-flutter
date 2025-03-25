import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:protech_mobile_chat_stream/constants/string_constant.dart';
import 'package:protech_mobile_chat_stream/module/general/cubit/country_picker_cubit.dart';
import 'package:protech_mobile_chat_stream/module/invitation_code/cubit/verify_invitation_code_cubit.dart';
import 'package:protech_mobile_chat_stream/module/register/screen/register_confirm_password_screen.dart';
import 'package:protech_mobile_chat_stream/service/authentication_service.dart';
import 'package:protech_mobile_chat_stream/service/response.dart';
import 'package:protech_mobile_chat_stream/utils/app_exception.dart';
import 'package:protech_mobile_chat_stream/utils/service_locator.dart';
import 'package:protech_mobile_chat_stream/utils/status_code.dart';
import 'package:protech_mobile_chat_stream/utils/string_apis.dart';
import 'package:protech_mobile_chat_stream/utils/toast_utils.dart';
import 'package:protech_mobile_chat_stream/widgets/authentication_header.dart';
import 'package:protech_mobile_chat_stream/widgets/email_text_field.dart';
import 'package:protech_mobile_chat_stream/widgets/verification_text_field.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _usernameController = TextEditingController();
  // final TextEditingController _phoneNoController = TextEditingController();
  final AuthenticationService _authenticationService =
      sl<AuthenticationService>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _verificationCodeController =
      TextEditingController();
  bool tncChecked = false;

  bool? sendOTP() {
    String email = _emailController.text;

    if (email.isBlank) {
      ToastUtils.showToast(
          context: context, msg: Strings.pleaseEnterEmail, type: Type.warning);
      return false;
    }

    _authenticationService
        .getOtp(
            email: email,
            invitationCode: context
                    .read<VerifyInvitationCodeCubit>()
                    .state
                    .invitationCode ??
                "")
        .then((Response response) {
      if (response is! MapSuccessResponse) {
        if (response is ConnectionRefusedResponse ||
            response is TimeoutResponse ||
            response is NoInternetResponse) {
          ToastUtils.showToast(
              context: context,
              msg: Strings.unableToConnectToServer,
              type: Type.warning);
          return;
        }

        if (response is BadRequestException) {
          StatusCode.checkErrorCode(response.message, (String? errorMsg) {
            log("error message: $errorMsg");
            ToastUtils.showToast(
                context: context,
                msg: errorMsg ?? Strings.couldNotSendOTP,
                type: Type.warning);
          });
          return;

          // switch (response.message) {
          //   case "661":
          //     ToastUtils.showToast(
          //         context: context,
          //         msg: Strings.emailFormatInvalid,
          //         type: Type.warning);
          //     return;
          //   case "662":
          //     ToastUtils.showToast(
          //         context: context,
          //         msg: Strings.emailUnavailable,
          //         type: Type.warning);
          //     return;
          //   case "663":
          //     ToastUtils.showToast(
          //         context: context,
          //         msg: Strings.emailInvalid,
          //         type: Type.warning);
          //     return;
          //   default:
          //     ToastUtils.showToast(
          //         context: context, msg: "无法发送OTP", type: Type.warning);
          //     return;
          // }
        }
        ToastUtils.showToast(
            context: context, msg: Strings.couldNotSendOTP, type: Type.warning);
        return;
      } else {
        // _verificationCodeController.value =
        //     TextEditingValue(text: response.jsonRes["data"]["otp"] ?? "");
      }
    });

    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: GestureDetector(
          onTap: () {
            FocusManager.instance.primaryFocus?.unfocus();
          },
          child: AuthenticationHeader(
              logo: Image.asset("assets/logo_icon.png", height: 55, width: 55),
              title: Strings.registerAccount,
              subtitle: Strings.welcomeMessage,
              child: Column(
                children: [
                  const SizedBox(height: 4),
                  TextField(
                    controller: _usernameController,
                    decoration:
                        InputDecoration(hintText: Strings.pleaseEnterUsername),
                  ),
                  const SizedBox(height: 20),
                  EmailTextField(emailController: _emailController),
                  const SizedBox(height: 20),
                  VerificationTextField(
                    verificationController: _verificationCodeController,
                    sendOTP: sendOTP,
                  ),
                  const SizedBox(height: 22),
                  Row(mainAxisSize: MainAxisSize.max, children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 4.0),
                      child: SizedBox(
                        height: 16,
                        width: 16,
                        child: Checkbox(
                            side: const BorderSide(
                                color: Color.fromRGBO(208, 213, 221, 1)),
                            shape: ContinuousRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            value: tncChecked,
                            onChanged: (checked) {
                              setState(() {
                                tncChecked = checked ?? false;
                              });
                            }),
                      ),
                    ),
                    const SizedBox(width: 8),
                     Text(Strings.iHaveReadAndAgreeTo,
                        style: const TextStyle(
                            color: Color.fromRGBO(52, 64, 84, 1),
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                            fontFamily: "Inter")),
                    const SizedBox(width: 4),
                    Text(Strings.privacyPolicy,
                        style: const TextStyle(
                            color: Color.fromRGBO(23, 116, 247, 0.65),
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                            fontFamily: "Inter"))
                  ]),
                  const SizedBox(height: 22),
                  BlocBuilder<CountryPickerCubit, CountryPickerState>(
                    builder: (context, state) {
                      return SizedBox(
                          width: MediaQuery.of(context).size.width,
                          child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 10, horizontal: 16)),
                              onPressed: () {
                                if (!tncChecked) {
                                  ToastUtils.showToast(
                                      context: context,
                                      msg: Strings.pleaseReadAndAgreeToPrivacyPolicy,
                                      type: Type.warning);
                                  return;
                                }

                                String username = _usernameController.text;
                                String verificationCode =
                                    _verificationCodeController.text;
                                String email = _emailController.text;

                                if (username.isBlank) {
                                  ToastUtils.showToast(
                                      context: context,
                                      msg: Strings.pleaseEnterEmail,
                                      type: Type.warning);
                                  return;
                                }

                                if (email.isBlank) {
                                  ToastUtils.showToast(
                                      context: context,
                                      msg: Strings.pleaseEnterEmail,
                                      type: Type.warning);
                                  return;
                                }

                                if (verificationCode.isBlank) {
                                  ToastUtils.showToast(
                                      context: context,
                                      msg: Strings.pleaseFillInVerificationCode,
                                      type: Type.warning);
                                  return;
                                }

                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) =>
                                        RegisterConfirmPasswordScreen(
                                            username: username,
                                            email: email,
                                            otp: verificationCode,
                                            verificationCode:
                                                verificationCode)));
                              },
                              child: Text(Strings.next,
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontFamily: "Inter",
                                      fontWeight: FontWeight.w600))));
                    },
                  ),
                  const SizedBox(height: 32),
                ],
              )),
        ),
      ),
    );
  }
}
 