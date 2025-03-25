import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:protech_mobile_chat_stream/constants/string_constant.dart';
import 'package:protech_mobile_chat_stream/module/forget_password/screen/confirm_password_screen.dart';
import 'package:protech_mobile_chat_stream/module/general/cubit/country_picker_cubit.dart';
import 'package:protech_mobile_chat_stream/module/invitation_code/cubit/verify_invitation_code_cubit.dart';
import 'package:protech_mobile_chat_stream/route/routes.dart';
import 'package:protech_mobile_chat_stream/service/authentication_service.dart';
import 'package:protech_mobile_chat_stream/service/response.dart';
import 'package:protech_mobile_chat_stream/utils/app_exception.dart';
import 'package:protech_mobile_chat_stream/utils/service_locator.dart';
import 'package:protech_mobile_chat_stream/utils/status_code.dart';
import 'package:protech_mobile_chat_stream/utils/string_apis.dart';
import 'package:protech_mobile_chat_stream/utils/toast_utils.dart';
import 'package:protech_mobile_chat_stream/widgets/authentication_header.dart';
import 'package:protech_mobile_chat_stream/widgets/email_text_field.dart';
import 'package:protech_mobile_chat_stream/widgets/phone_no_text_field.dart';
import 'package:protech_mobile_chat_stream/widgets/verification_text_field.dart';

class ForgetPasswordScreen extends StatefulWidget {
  const ForgetPasswordScreen({super.key});

  @override
  State<ForgetPasswordScreen> createState() => _ForgetPasswordScreenState();
}

class _ForgetPasswordScreenState extends State<ForgetPasswordScreen> {
  final TextEditingController _phoneNoController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _verificationCodeController =
      TextEditingController();
  final PageController _pageController = PageController();
  int activePageIndex = 0;
  final AuthenticationService _authenticationService =
      sl<AuthenticationService>();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _phoneNoController.dispose();
    _verificationCodeController.dispose();
    _pageController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _onSwitchPhoneNoLogin() {
    _pageController.jumpToPage(0);
    // _pageController.animateToPage(0,
    //     duration: const Duration(milliseconds: 500), curve: Curves.decelerate);
  }

  void _onSwitchUserIdLogin() {
    _pageController.jumpToPage(1);
    // _pageController.animateToPage(1,
    //     duration: const Duration(milliseconds: 500), curve: Curves.decelerate);
  }

  bool sendOTP({bool isPhoneOtp = false}) {
    final verifyInvitationCodeCubit = context.read<VerifyInvitationCodeCubit>();
    final countryCubit = context.read<CountryPickerCubit>();

    String input = isPhoneOtp ? _phoneNoController.text : _emailController.text;

    if (input.isBlank) {
      ToastUtils.showToast(
          context: context,
          msg: isPhoneOtp ? "请先填写手机号" : "请先填写邮箱",
          type: Type.warning);
      return false;
    }

    if (isPhoneOtp) {
      _authenticationService
          .getPhoneOtp(
              phone:
                  "(${countryCubit.state.selectedCountry?.dialCode ?? "+60"})$input",
              invitationCode:
                  verifyInvitationCodeCubit.state.invitationCode ?? "",
              type: "RESET_PASSWORD")
          .then((Response response) {
        if (response is! MapSuccessResponse) {
          if (response is ConnectionRefusedResponse ||
              response is TimeoutResponse ||
              response is NoInternetResponse) {
            ToastUtils.showToast(
                context: context, msg: "无法连接到服务器，请重新尝试", type: Type.warning);
            return false;
          }

          if (response is BadRequestException) {
            StatusCode.checkErrorCode(response.message, (String? errorMsg) {
              log("error message: $errorMsg");
              ToastUtils.showToast(
                  context: context,
                  msg: errorMsg ?? "Could not send OTP",
                  type: Type.warning);
            });
            return false;
            // switch (response.message) {
            //   case "661":
            //     ToastUtils.showToast(
            //         context: context,
            //         msg: Strings.emailFormatInvalid,
            //         type: Type.warning);
            //     return false;
            //   case "662":
            //     ToastUtils.showToast(
            //         context: context,
            //         msg: Strings.emailUnavailable,
            //         type: Type.warning);
            //     return false;
            //   case "663":
            //     ToastUtils.showToast(
            //         context: context,
            //         msg: Strings.emailInvalid,
            //         type: Type.warning);
            //     return false;
            //   default:
            //     ToastUtils.showToast(
            //         context: context, msg: "无法发送OTP", type: Type.warning);
            //     return false;
            // }
          }
          ToastUtils.showToast(
              context: context,
              msg: Strings.couldNotSendOTP,
              type: Type.warning);
          return false;
        } else {
          // _verificationCodeController.value =
          //     TextEditingValue(text: response.jsonRes["data"]["otp"] ?? "");
        }
      });
    } else {
      _authenticationService
          .getOtp(
              email: input,
              invitationCode:
                  verifyInvitationCodeCubit.state.invitationCode ?? "")
          .then((Response response) {
        if (response is! MapSuccessResponse) {
          ToastUtils.showToast(
              context: context,
              msg: Strings.couldNotSendOTP,
              type: Type.warning);
          return false;
        } else {
          // _verificationCodeController.value =
          //     TextEditingValue(text: response.jsonRes["data"]["otp"] ?? "");
        }
      });
    }

    return true;
  }

  void onSubmit({bool isPhoneOtp = false}) {
    final countryCubit = context.read<CountryPickerCubit>();

    final String input =
        isPhoneOtp ? _phoneNoController.text : _emailController.text;
    final String otp = _verificationCodeController.text;

    if (input.isEmpty) {
      ToastUtils.showToast(
          context: context,
          msg: isPhoneOtp
              ? Strings.pleaseFillInPhoneNumber
              : Strings.pleaseEnterEmail,
          type: Type.warning);
      return;
    }

    if (otp.isBlank) {
      ToastUtils.showToast(
          context: context,
          msg: Strings.pleaseFillInVerificationCode,
          type: Type.warning);
      return;
    }

    if (isPhoneOtp) {
      Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => ConfirmPasswordScreen(
              phone:
                  "(${countryCubit.state.selectedCountry?.dialCode ?? "+60"})$input",
              otp: otp)));
    } else {
      Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => ConfirmPasswordScreen(email: input, otp: otp)));
    }
  }

  Widget _menuBar(BuildContext context) {
    const double borderRadius = 8.0;

    return Container(
      width: MediaQuery.of(context).size.width,
      height: 36.0,
      decoration: const BoxDecoration(
        color: Color.fromRGBO(249, 250, 251, 1),
        border: Border.fromBorderSide(
            BorderSide(color: Color.fromRGBO(228, 231, 236, 1))),
        borderRadius: BorderRadius.all(Radius.circular(borderRadius)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Expanded(
            child: InkWell(
              borderRadius:
                  const BorderRadius.all(Radius.circular(borderRadius)),
              onTap: _onSwitchPhoneNoLogin,
              child: Container(
                width: MediaQuery.of(context).size.width,
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                alignment: Alignment.center,
                decoration: (activePageIndex == 0)
                    ? const BoxDecoration(
                        color: Colors.white,
                        border: Border(
                            top: BorderSide(
                                width: 0.5,
                                color: Color.fromRGBO(208, 213, 221, 1)),
                            right: BorderSide(
                                width: 1,
                                color: Color.fromRGBO(208, 213, 221, 1)),
                            left: BorderSide(
                                width: 0.5,
                                color: Color.fromRGBO(208, 213, 221, 1)),
                            bottom: BorderSide(
                                width: 0.5,
                                color: Color.fromRGBO(208, 213, 221, 1))),
                        borderRadius:
                            BorderRadius.all(Radius.circular(borderRadius)),
                      )
                    : null,
                child: Text(
                  Strings.phoneVerification,
                  style: (activePageIndex == 0)
                      ? const TextStyle(
                          color: Color.fromRGBO(52, 64, 84, 1),
                          fontWeight: FontWeight.w600,
                          fontFamily: "Inter",
                          fontSize: 14)
                      : const TextStyle(
                          color: Color.fromRGBO(102, 112, 133, 1),
                          fontWeight: FontWeight.w600,
                          fontFamily: "Inter",
                          fontSize: 14),
                ),
              ),
            ),
          ),
          Expanded(
            child: InkWell(
              borderRadius:
                  const BorderRadius.all(Radius.circular(borderRadius)),
              onTap: _onSwitchUserIdLogin,
              child: Container(
                width: MediaQuery.of(context).size.width,
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                alignment: Alignment.center,
                decoration: (activePageIndex == 1)
                    ? const BoxDecoration(
                        color: Colors.white,
                        border: Border(
                            top: BorderSide(
                                width: 0.5,
                                color: Color.fromRGBO(208, 213, 221, 1)),
                            right: BorderSide(
                                width: 0.5,
                                color: Color.fromRGBO(208, 213, 221, 1)),
                            left: BorderSide(
                                width: 1,
                                color: Color.fromRGBO(208, 213, 221, 1)),
                            bottom: BorderSide(
                                width: 0.5,
                                color: Color.fromRGBO(208, 213, 221, 1))),
                        borderRadius:
                            BorderRadius.all(Radius.circular(borderRadius)))
                    : null,
                child: Text(
                  Strings.emailVerification,
                  style: (activePageIndex == 1)
                      ? const TextStyle(
                          color: Color.fromRGBO(52, 64, 84, 1),
                          fontWeight: FontWeight.w600,
                          fontFamily: "Inter",
                          fontSize: 14)
                      : const TextStyle(
                          color: Color.fromRGBO(102, 112, 133, 1),
                          fontWeight: FontWeight.w600,
                          fontFamily: "Inter",
                          fontSize: 14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _phoneNoValidation(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 4),
        PhoneNoTextField(phoneNoController: _phoneNoController),
        const SizedBox(height: 20),
        VerificationTextField(
          verificationController: _verificationCodeController,
          sendOTP: () {
            bool? result = sendOTP(isPhoneOtp: true);
            return result;
          },
        ),
        const SizedBox(height: 24),
        SizedBox(
            width: MediaQuery.of(context).size.width,
            child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 16)),
                onPressed: () {
                  onSubmit(isPhoneOtp: true);
                },
                child: Text(Strings.next,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontFamily: "Inter",
                        fontWeight: FontWeight.w600)))),
      ],
    );
  }

  Widget _emailValidation(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 4),
        EmailTextField(emailController: _emailController),
        const SizedBox(height: 20),
        VerificationTextField(
          verificationController: _verificationCodeController,
          sendOTP: () {
            bool? result = sendOTP();
            return result;
          },
        ),
        const SizedBox(height: 24),
        SizedBox(
            width: MediaQuery.of(context).size.width,
            child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 16)),
                onPressed: () {
                  onSubmit();
                },
                child: Text(Strings.next,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontFamily: "Inter",
                        fontWeight: FontWeight.w600)))),
      ],
    );
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
              title: Strings.forgotPassword,
              subtitle: Strings.resetPassword,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 320),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _menuBar(context),
                    const SizedBox(height: 32),
                    Expanded(
                      flex: 2,
                      child: PageView(
                        controller: _pageController,
                        physics: const NeverScrollableScrollPhysics(),
                        onPageChanged: (int i) {
                          FocusScope.of(context).requestFocus(FocusNode());
                          setState(() {
                            activePageIndex = i;
                          });
                        },
                        children: [
                          _phoneNoValidation(context),
                          _emailValidation(context)
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    Align(
                        alignment: Alignment.center,
                        child: GestureDetector(
                          onTap: () {
                            Navigator.of(context).popUntil(
                                ModalRoute.withName(AppPage.login.routeName));
                          },
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SvgPicture.asset("assets/Buttons/arrow-left.svg"),
                              const SizedBox(width: 4),
                              Text(Strings.backToLogin,
                                  style: const TextStyle(
                                      color: Color.fromRGBO(71, 84, 103, 1),
                                      fontWeight: FontWeight.w500,
                                      fontSize: 14,
                                      fontFamily: "Inter"))
                            ],
                          ),
                        ))
                  ],
                ),
              )),
        ),
      ),
    );
  }
}
