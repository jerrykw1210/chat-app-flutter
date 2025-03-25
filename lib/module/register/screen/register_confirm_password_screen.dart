import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:protech_mobile_chat_stream/constants/string_constant.dart';
import 'package:protech_mobile_chat_stream/module/common/screen/status_screen.dart';
import 'package:protech_mobile_chat_stream/module/invitation_code/cubit/verify_invitation_code_cubit.dart';
import 'package:protech_mobile_chat_stream/module/register/cubit/register_cubit.dart';
import 'package:protech_mobile_chat_stream/route/routes.dart';
import 'package:protech_mobile_chat_stream/utils/string_apis.dart';
import 'package:protech_mobile_chat_stream/utils/toast_utils.dart';
import 'package:protech_mobile_chat_stream/widgets/authentication_header.dart';
import 'package:protech_mobile_chat_stream/widgets/password_text_field.dart';

class RegisterConfirmPasswordScreen extends StatefulWidget {
  RegisterConfirmPasswordScreen(
      {super.key,
      required this.username,
      required this.email,
      required this.verificationCode,
      required this.otp});
  String username;
  String email;
  String verificationCode;
  String otp;

  @override
  State<RegisterConfirmPasswordScreen> createState() =>
      _RegisterConfirmPasswordScreenState();
}

class _RegisterConfirmPasswordScreenState
    extends State<RegisterConfirmPasswordScreen> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool hidePassword = true;

  @override
  Widget build(BuildContext context) {
    return BlocListener<RegisterCubit, RegisterState>(
      listener: (context, state) {
        log(state.registerStatus.toString());
        state.registerStatus == RegisterStatus.loading
            ? context.loaderOverlay.show()
            : context.loaderOverlay.hide();

        if (state.registerStatus == RegisterStatus.success) {
          context.loaderOverlay.hide();
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => StatusScreen(
                  imgPath: "assets/register_success.png",
                  title: Strings.registerSuccess,
                  subtitle: Strings.registerSuccessDesc,
                  buttonText: Strings.backToLogin,
                  buttonOnPress: () => Navigator.of(context).popUntil(
                      ModalRoute.withName(AppPage.login.routeName)))));
          // ToastUtils.showToast(
          //     context: context, msg: "注册成功, 请登入你的账号", type: Type.success);
          // Navigator.of(context)
          //     .popUntil(ModalRoute.withName(AppPage.login.routeName));
          return;
        }

        if (state.registerStatus == RegisterStatus.fail) {
          context.loaderOverlay.hide();

          ToastUtils.showToast(
              context: context,
              msg: state.errorMessage ?? Strings.registerFailed,
              type: Type.danger);
          return;
        }
      },
      child: LoaderOverlay(
        child: Scaffold(
          body: SingleChildScrollView(
            child: GestureDetector(
              onTap: () {
                FocusManager.instance.primaryFocus?.unfocus();
              },
              child: AuthenticationHeader(
                  logo: Image.asset("assets/logo_icon.png",
                      height: 55, width: 55),
                  title: Strings.confirmPassword,
                  subtitle: Strings.pleaseEnterPassword,
                  child: Column(
                    children: [
                      const SizedBox(height: 4),
                      PasswordTextField(
                          controller: _passwordController,
                          hintText: Strings.pleaseEnterPassword),
                      const SizedBox(height: 20),
                      TextField(
                        controller: _confirmPasswordController,
                        obscureText: hidePassword,
                        decoration: InputDecoration(
                            hintText: Strings.confirmPassword,
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
                                    color: Colors.grey))),
                      ),
                      const SizedBox(height: 24),
                      BlocBuilder<VerifyInvitationCodeCubit,
                          VerifyInvitationCodeState>(
                        builder: (context, state) {
                          return SizedBox(
                              width: MediaQuery.of(context).size.width,
                              child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 10, horizontal: 16)),
                                  onPressed: () {
                                    String invitationCode =
                                        state.invitationCode ?? "";
                                    String password = _passwordController.text;
                                    String confirmPassword =
                                        _confirmPasswordController.text;

                                    if (password.isBlank) {
                                      ToastUtils.showToast(
                                          context: context,
                                          msg: Strings.pleaseEnterPassword,
                                          type: Type.warning);
                                      return;
                                    }

                                    String pattern =
                                        r'^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[^\w\s]).{8,}$';
                                    RegExp regex = RegExp(pattern);

                                    if (!regex.hasMatch(password)) {
                                      ToastUtils.showToast(
                                          context: context,
                                          msg: Strings.passwordFormatDesc,
                                          type: Type.warning);
                                      return;
                                    }

                                    if (confirmPassword
                                            .trim()
                                            .compareTo(password.trim()) !=
                                        0) {
                                      ToastUtils.showToast(
                                          context: context,
                                          msg: Strings.passwordDoesNotMatch,
                                          type: Type.warning);
                                      return;
                                    }

                                    context.read<RegisterCubit>().register(
                                          invitationCode: invitationCode,
                                          username: widget.username,
                                          email: widget.email,
                                          password: password,
                                          otp: widget.otp,
                                        );
                                    context.loaderOverlay.show();
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
                      Align(
                          alignment: Alignment.center,
                          child: GestureDetector(
                            onTap: () {
                              Navigator.of(context).popUntil(
                                  ModalRoute.withName(
                                      AppPage.register.routeName));
                            },
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SvgPicture.asset(
                                    "assets/Buttons/arrow-left.svg"),
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
                  )),
            ),
          ),
        ),
      ),
    );
  }
}
