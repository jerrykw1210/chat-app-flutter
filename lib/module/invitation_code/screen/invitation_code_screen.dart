
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:protech_mobile_chat_stream/constants/string_constant.dart';
import 'package:protech_mobile_chat_stream/module/invitation_code/cubit/verify_invitation_code_cubit.dart';
import 'package:protech_mobile_chat_stream/route/routes.dart';
import 'package:protech_mobile_chat_stream/service/credential_service.dart';
import 'package:protech_mobile_chat_stream/utils/service_locator.dart';
import 'package:protech_mobile_chat_stream/utils/string_apis.dart';
import 'package:protech_mobile_chat_stream/utils/toast_utils.dart';
import 'package:protech_mobile_chat_stream/widgets/authentication_header.dart';

class InvitationCodeScreen extends StatefulWidget {
  const InvitationCodeScreen({super.key});

  @override
  State<InvitationCodeScreen> createState() => _InvitationCodeScreenState();
}

class _InvitationCodeScreenState extends State<InvitationCodeScreen> {
  final TextEditingController _invitationCodeController =
      TextEditingController();

  @override
  void initState() {
    // _invitationCodeController.value =
    //     const TextEditingValue(text: "dKOCG8OQm8");
    super.initState();
  }

  @override
  void dispose() {
    _invitationCodeController.dispose();
    super.dispose();
  }

  _submit() {
    String invitationCode = _invitationCodeController.text;

    if (invitationCode.isBlank) {
      ToastUtils.showToast(
          context: context,
          msg: Strings.pleaseFillInVerificationCode,
          type: Type.warning);
      return;
    }

    context
        .read<VerifyInvitationCodeCubit>()
        .verifyInvitationCode(invitationCode: invitationCode);
  }

  @override
  Widget build(BuildContext context) {
    return LoaderOverlay(
      child: Scaffold(
        body:
            BlocListener<VerifyInvitationCodeCubit, VerifyInvitationCodeState>(
          listener: (context, state) {
            state.verifyStatus == VerifyStatus.loading
                ? context.loaderOverlay.show()
                : context.loaderOverlay.hide();

            if (state.verifyStatus == VerifyStatus.success) {
              context.read<VerifyInvitationCodeCubit>().setInvitationCode(
                  invitationCode: _invitationCodeController.text);

              sl<CredentialService>()
                  .writeInvitationCode(_invitationCodeController.text);

              ToastUtils.showToast(
                  context: context,
                  msg: Strings.invitationCodeValid,
                  type: Type.success);

              Navigator.of(context).pushNamed(AppPage.login.routeName);
              return;
            }

            if (state.verifyStatus == VerifyStatus.fail) {
              ToastUtils.showToast(
                  context: context,
                  msg: state.errorMessage ?? Strings.invitationCodeInvalid,
                  type: Type.danger);
              return;
            }
          },
          child: SingleChildScrollView(
            child: GestureDetector(
              onTap: () {
                FocusManager.instance.primaryFocus?.unfocus();
              },
              child: AuthenticationHeader(
                  logo: Image.asset("assets/logo_icon.png",
                      height: 55, width: 55),
                  title: Strings.joinWithInvitationCode,
                  subtitle: Strings.pleaseFillInVerificationCode,
                  child: Column(
                    children: [
                      const SizedBox(height: 4),
                      TextField(
                        controller: _invitationCodeController,
                        decoration: InputDecoration(
                            hintText: Strings.pleaseFillInVerificationCode),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                          width: MediaQuery.of(context).size.width,
                          child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 10, horizontal: 16)),
                              onPressed: _submit,
                              child: Text(Strings.join,
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontFamily: "Inter",
                                      fontWeight: FontWeight.w600)))),
                      const SizedBox(height: 32),
                      ConstrainedBox(
                        constraints: BoxConstraints(
                            maxWidth: MediaQuery.sizeOf(context).width * 0.85),
                        child: Align(
                            alignment: Alignment.center,
                            child: Wrap(
                              children: [
                                Text(Strings.loginAgreement,
                                    style: const TextStyle(
                                        color: Color.fromRGBO(
                                            174, 174, 174, 1),
                                        fontWeight: FontWeight.w400,
                                        fontSize: 14,
                                        fontFamily: "Inter")),
                                GestureDetector(
                                  onTap: () {},
                                  child: Text(Strings.privacyPolicy,
                                      style: const TextStyle(
                                          color:
                                              Color.fromRGBO(23, 116, 247, 1),
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                          fontFamily: "Inter")),
                                )
                              ],
                            )),
                      )
                    ],
                  )),
            ),
          ),
        ),
      ),
    );
  }
}
