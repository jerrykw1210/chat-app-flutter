import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:protech_mobile_chat_stream/constants/string_constant.dart';
import 'package:protech_mobile_chat_stream/module/common/screen/status_screen.dart';
import 'package:protech_mobile_chat_stream/module/forget_password/cubit/forget_password_cubit.dart';
import 'package:protech_mobile_chat_stream/module/invitation_code/cubit/verify_invitation_code_cubit.dart';
import 'package:protech_mobile_chat_stream/route/routes.dart';
import 'package:protech_mobile_chat_stream/utils/string_apis.dart';
import 'package:protech_mobile_chat_stream/utils/toast_utils.dart';
import 'package:protech_mobile_chat_stream/widgets/authentication_header.dart';
import 'package:protech_mobile_chat_stream/widgets/password_text_field.dart';

class ConfirmPasswordScreen extends StatefulWidget {
  ConfirmPasswordScreen({super.key, this.email, this.phone, required this.otp});
  String? email;
  String? phone;
  String otp;

  @override
  State<ConfirmPasswordScreen> createState() => _ConfirmPasswordScreenState();
}

class _ConfirmPasswordScreenState extends State<ConfirmPasswordScreen> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool hidePassword = true;

  onSubmit() {
    final ForgetPasswordCubit forgetPasswordCubit =
        context.read<ForgetPasswordCubit>();
    final VerifyInvitationCodeCubit verifyInvitationCodeCubit =
        context.read<VerifyInvitationCodeCubit>();
    String invitationCode =
        verifyInvitationCodeCubit.state.invitationCode ?? "";

    String password = _passwordController.text;
    String confirmPassword = _confirmPasswordController.text;

    if (password.isBlank || confirmPassword.isBlank) {
      ToastUtils.showToast(
          context: context,
          msg: Strings.pleaseEnterPassword,
          type: Type.warning);
      return;
    }

    String pattern =
        r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$';
    RegExp regex = RegExp(pattern);

    if (!regex.hasMatch(password)) {
      ToastUtils.showToast(
          context: context,
          msg: Strings.passwordFormatDesc,
          type: Type.warning);
      return;
    }

    if (password != confirmPassword) {
      ToastUtils.showToast(
          context: context,
          msg: Strings.passwordDoesNotMatch,
          type: Type.warning);
      return;
    }

    if (widget.email != null) {
      forgetPasswordCubit.forgetPassword(
          email: widget.email ?? "",
          otp: widget.otp,
          invitationCode: invitationCode,
          newPassword: password);
    } else if (widget.phone != null) {
      forgetPasswordCubit.forgetPasswordByPhone(
          phone: widget.phone ?? "",
          otp: widget.otp,
          invitationCode: invitationCode,
          newPassword: password);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LoaderOverlay(
      child: Scaffold(
        body: SingleChildScrollView(
          child: GestureDetector(
            onTap: () {
              FocusManager.instance.primaryFocus?.unfocus();
            },
            child: AuthenticationHeader(
                logo:
                    Image.asset("assets/logo_icon.png", height: 55, width: 55),
                title: Strings.forgotPassword,
                subtitle: Strings.resetPassword,
                child: BlocListener<ForgetPasswordCubit, ForgetPasswordState>(
                  listener: (context, state) {
                    state.forgetPasswordStatus == ForgetPasswordStatus.loading
                        ? context.loaderOverlay.show()
                        : context.loaderOverlay.hide();

                    if (state.forgetPasswordStatus ==
                        ForgetPasswordStatus.success) {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => StatusScreen(
                              imgPath: "assets/reset_pw_success.png",
                              title: Strings.resetPasswordSuccess,
                              subtitle: Strings.passwordChangedSuccessfully,
                              buttonText: Strings.backToLogin,
                              buttonOnPress: () => Navigator.of(context)
                                  .popUntil(ModalRoute.withName(
                                      AppPage.login.routeName)))));
                    }

                    if (state.forgetPasswordStatus ==
                        ForgetPasswordStatus.fail) {
                      ToastUtils.showToast(
                          context: context,
                          msg: state.errorMessage ?? Strings.passwordResetFail,
                          type: Type.danger);
                    }
                  },
                  child: Column(
                    children: [
                      const SizedBox(height: 4),
                      PasswordTextField(
                          controller: _passwordController,
                          hintText: Strings.pleaseEnterPassword),
                      const SizedBox(height: 20),
                      TextField(
                        obscureText: hidePassword,
                        controller: _confirmPasswordController,
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
                  ),
                )),
          ),
        ),
      ),
    );
  }
}
