import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:protech_mobile_chat_stream/constants/string_constant.dart';
import 'package:protech_mobile_chat_stream/module/general/cubit/country_picker_cubit.dart';
import 'package:protech_mobile_chat_stream/module/invitation_code/cubit/verify_invitation_code_cubit.dart';
import 'package:protech_mobile_chat_stream/module/login/cubit/login_cubit.dart';
import 'package:protech_mobile_chat_stream/module/profile/cubit/profile_cubit.dart';
import 'package:protech_mobile_chat_stream/module/webview/cubit/toggle_webview_cubit.dart';
import 'package:protech_mobile_chat_stream/route/routes.dart';
import 'package:protech_mobile_chat_stream/service/authentication_service.dart';
import 'package:protech_mobile_chat_stream/service/response.dart';
import 'package:protech_mobile_chat_stream/utils/app_exception.dart';
import 'package:protech_mobile_chat_stream/utils/service_locator.dart';
import 'package:protech_mobile_chat_stream/utils/status_code.dart';
import 'package:protech_mobile_chat_stream/utils/toast_utils.dart';
import 'package:protech_mobile_chat_stream/widgets/authentication_header.dart';
import 'package:protech_mobile_chat_stream/widgets/email_text_field.dart';
import 'package:protech_mobile_chat_stream/widgets/phone_no_text_field.dart';
import 'package:protech_mobile_chat_stream/utils/string_apis.dart';
import 'package:protech_mobile_chat_stream/widgets/verification_text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final PageController _pageController = PageController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _userIdPasswordController =
      TextEditingController();
  final TextEditingController _phoneNoController = TextEditingController();
  final TextEditingController _phoneNoPasswordController =
      TextEditingController();
  final TextEditingController _verificationCodeController =
      TextEditingController();
  final AuthenticationService _authenticationService =
      sl<AuthenticationService>();
  int activePageIndex = 0;
  bool hidePassword = true;

  @override
  void dispose() {
    _pageController.dispose();
    _emailController.dispose();
    _userIdPasswordController.dispose();
    _phoneNoController.dispose();
    _phoneNoPasswordController.dispose();
    super.dispose();
  }

  bool? sendOTP() {
    final verifyInvitationCodeCubit = context.read<VerifyInvitationCodeCubit>();
    final countryCubit = context.read<CountryPickerCubit>();

    String input = _phoneNoController.text;

    if (input.isBlank) {
      ToastUtils.showToast(
          context: context,
          msg: Strings.pleaseFillInPhoneNumber,
          type: Type.warning);
      return false;
    }

    _authenticationService
        .getPhoneOtp(
            phone:
                "(${countryCubit.state.selectedCountry?.dialCode ?? "+60"})$input",
            invitationCode:
                verifyInvitationCodeCubit.state.invitationCode ?? "",
            type: "LOGIN")
        .then((Response response) {
      if (response is! MapSuccessResponse) {
        if (response is ConnectionRefusedResponse ||
            response is TimeoutResponse ||
            response is NoInternetResponse) {
          ToastUtils.showToast(
              context: context,
              msg: Strings.unableToConnectToServer,
              type: Type.warning);
          return false;
        }

        if (response is BadRequestException) {
          StatusCode.checkErrorCode(response.message, (String? errorMsg) {
            log("error message: $errorMsg");
            ToastUtils.showToast(
                context: context,
                msg: errorMsg ?? Strings.couldNotSendOTP,
                type: Type.warning);
          });
          return false;
          // switch (response.message) {
          //   case "651":
          //     ToastUtils.showToast(
          //         context: context,
          //         msg: Strings.phoneFormatInvalid,
          //         type: Type.warning);
          //     return false;
          //   case "652":
          //     ToastUtils.showToast(
          //         context: context,
          //         msg: Strings.phoneUnavailable,
          //         type: Type.warning);
          //     return false;
          //   case "653":
          //     ToastUtils.showToast(
          //         context: context,
          //         msg: Strings.phoneInvalid,
          //         type: Type.warning);
          //     return false;
          //   default:
          //     ToastUtils.showToast(
          //         context: context, msg: "无法发送OTP", type: Type.warning);
          //     return false;
          // }
        }
        ToastUtils.showToast(
            context: context, msg: Strings.unableToSendOTP, type: Type.warning);
        return false;
      } else {
        // _verificationCodeController.value =
        //     TextEditingValue(text: response.jsonRes["data"]["otp"] ?? "");
      }
    });

    return true;
  }

  @override
  Widget build(BuildContext context) {
    return LoaderOverlay(
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        body: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: GestureDetector(
                onTap: () {
                  FocusManager.instance.primaryFocus?.unfocus();
                },
                child: AuthenticationHeader(
                  logo: Image.asset("assets/logo_icon.png",
                      height: 55, width: 55),
                  title: Strings.login,
                  subtitle: Strings.welcomeMessage,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: MediaQuery.of(context).size.height * 0.5,
                      maxHeight: constraints.maxHeight,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _menuBar(context),
                        const SizedBox(height: 32),
                        BlocListener<LoginCubit, LoginState>(
                          listener: (context, state) {
                            state.loginStatus == LoginStatus.loading
                                ? context.loaderOverlay.show()
                                : context.loaderOverlay.hide();

                            if (state.loginStatus == LoginStatus.fail) {
                              ToastUtils.showToast(
                                  context: context,
                                  msg:
                                      state.errorMessage ?? Strings.loginFailed,
                                  type: Type.danger);
                            }

                            if (state.loginStatus == LoginStatus.success) {
                              context.read<ProfileCubit>().getProfile();
                              ToastUtils.showToast(
                                  context: context,
                                  msg: Strings.loginSuccess,
                                  type: Type.success);
                              context
                                  .read<ToggleWebviewCubit>()
                                  .setCurrentIndex(0);
                              Navigator.of(context).pushNamedAndRemoveUntil(
                                  AppPage.navBar.routeName,
                                  (Route<dynamic> route) => false);
                            }
                          },
                          child: SizedBox(
                            height: constraints.maxHeight * 0.6,
                            child: PageView(
                              controller: _pageController,
                              physics: const NeverScrollableScrollPhysics(),
                              onPageChanged: (int i) {
                                FocusScope.of(context)
                                    .requestFocus(FocusNode());
                                setState(() {
                                  activePageIndex = i;
                                });
                              },
                              children: [
                                _phoneNoLogin(context),
                                _emailLogin(context)
                              ],
                            ),
                          ),
                        ),
                        // const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _submit({bool isPhoneNoLogin = false, required BuildContext context}) {
    final loginCubit = context.read<LoginCubit>();
    final verifyInvitationCodeCubit = context.read<VerifyInvitationCodeCubit>();
    final countryCubit = context.read<CountryPickerCubit>();

    if (isPhoneNoLogin) {
      final phone = _phoneNoController.text;
      final otp = _verificationCodeController.text;

      if (phone.isEmpty || otp.isEmpty) {
        ToastUtils.showToast(
            context: context,
            msg: phone.isEmpty
                ? Strings.pleaseFillInPhoneNumber
                : Strings.pleaseFillInVerificationCode,
            type: Type.warning);
        return;
      }

      final invitationCode =
          verifyInvitationCodeCubit.state.invitationCode ?? "";
      final selectedCountry = countryCubit.state.selectedCountry;

      loginCubit.loginByPhone(
          phone: "(${selectedCountry?.dialCode ?? "+60"})$phone",
          otp: otp,
          invitationCode: invitationCode);
    } else {
      final email = _emailController.text;
      final password = _userIdPasswordController.text;

      if (email.isEmpty || password.isEmpty) {
        ToastUtils.showToast(
            context: context,
            msg: email.isEmpty
                ? Strings.pleaseEnterEmail
                : Strings.pleaseEnterPassword,
            type: Type.warning);
        return;
      }

      final invitationCode =
          verifyInvitationCodeCubit.state.invitationCode ?? "";

      loginCubit.login(
          email: email, password: password, invitationCode: invitationCode);
    }
  }

  Widget _phoneNoLogin(BuildContext context) {
    return Column(
      children: [
        PhoneNoTextField(phoneNoController: _phoneNoController),
        const SizedBox(height: 20),
        VerificationTextField(
          verificationController: _verificationCodeController,
          sendOTP: sendOTP,
        ),
        const SizedBox(height: 20),
        GestureDetector(
          onTap: () =>
              Navigator.of(context).pushNamed(AppPage.forgotPassword.routeName),
          child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(Strings.forgotPassword,
                    style: const TextStyle(
                        fontFamily: "Inter",
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color.fromRGBO(23, 116, 247, 1)))
              ]),
        ),
        const SizedBox(height: 20),
        SizedBox(
            width: MediaQuery.of(context).size.width,
            child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 16)),
                onPressed: () {
                  _submit(isPhoneNoLogin: true, context: context);
                },
                child: Text(Strings.login,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontFamily: "Inter",
                        fontWeight: FontWeight.w600)))),
        const SizedBox(height: 32),
        Align(
            alignment: Alignment.center,
            child: GestureDetector(
              onTap: () =>
                  Navigator.of(context).pushNamed(AppPage.register.routeName),
              child: Text(Strings.registerAccount,
                  style: const TextStyle(
                      fontFamily: "Inter",
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color.fromRGBO(23, 116, 247, 1))),
            ))
      ],
    );
  }

  Widget _emailLogin(BuildContext context) {
    return Column(
      children: [
        EmailTextField(emailController: _emailController),
        const SizedBox(height: 20),
        TextField(
            controller: _userIdPasswordController,
            obscureText: hidePassword,
            decoration: InputDecoration(
                hintText: Strings.pleaseEnterPassword,
                suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        hidePassword = !hidePassword;
                      });
                    },
                    icon: Icon(
                        hidePassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: Colors.grey)))),
        const SizedBox(height: 20),
        GestureDetector(
          onTap: () =>
              Navigator.of(context).pushNamed(AppPage.forgotPassword.routeName),
          child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(Strings.forgotPassword,
                    style: const TextStyle(
                        fontFamily: "Inter",
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color.fromRGBO(23, 116, 247, 1)))
              ]),
        ),
        const SizedBox(height: 20),
        SizedBox(
            width: MediaQuery.of(context).size.width,
            child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 16)),
                onPressed: () {
                  _submit(context: context);
                },
                child: Text(Strings.login,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontFamily: "Inter",
                        fontWeight: FontWeight.w600)))),
        const SizedBox(height: 32),
        Align(
            alignment: Alignment.center,
            child: GestureDetector(
              onTap: () =>
                  Navigator.of(context).pushNamed(AppPage.register.routeName),
              child: Text(Strings.registerAccount,
                  style: const TextStyle(
                      fontFamily: "Inter",
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color.fromRGBO(23, 116, 247, 1))),
            ))
      ],
    );
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
                  Strings.phoneLogin,
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
                  Strings.emailLogin,
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
}
