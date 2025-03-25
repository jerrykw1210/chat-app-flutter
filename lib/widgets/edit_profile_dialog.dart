import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:lottie/lottie.dart';
import 'package:protech_mobile_chat_stream/constants/string_constant.dart';
import 'package:protech_mobile_chat_stream/module/general/cubit/country_picker_cubit.dart';
import 'package:protech_mobile_chat_stream/module/general/cubit/password_cubit.dart';
import 'package:protech_mobile_chat_stream/module/login/cubit/login_cubit.dart';
import 'package:protech_mobile_chat_stream/module/profile/cubit/profile_cubit.dart';
import 'package:protech_mobile_chat_stream/widgets/phone_no_text_field.dart';
import 'package:protech_mobile_chat_stream/widgets/verification_text_field.dart';

class VerifyEmailDialog extends StatefulWidget {
  const VerifyEmailDialog({super.key});

  @override
  State<VerifyEmailDialog> createState() => _VerifyEmailDialogState();
}

class _VerifyEmailDialogState extends State<VerifyEmailDialog> {
  TextEditingController passwordController = TextEditingController();
  TextEditingController otpController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return LoaderOverlay(
      child: AlertDialog(
        title:
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          SizedBox(
            width: 200,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  Strings.changeEmail,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                Text(
                  Strings.enterPasswordDescription,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(Icons.close))
        ]),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(Strings.email),
            BlocBuilder<ProfileCubit, ProfileState>(
              builder: (context, state) {
                return TextField(
                  controller:
                      TextEditingController(text: state.userProfile?.email),
                  readOnly: true,
                );
              },
            ),
            const SizedBox(
              height: 20,
            ),
            Text(Strings.password),
            BlocBuilder<PasswordCubit, bool>(
              builder: (context, state) {
                return TextField(
                  controller: passwordController,
                  obscureText: state,
                  decoration: InputDecoration(
                      hintText: "e.g 123456",
                      // Check if the password is incorrect, show errorText
                      errorText: context
                                  .watch<ProfileCubit>()
                                  .state
                                  .verifyPasswordStatus ==
                              VerifyPasswordStatus.fail
                          ? Strings.wrongPassword
                          : null,
                      suffixIcon: IconButton(
                        icon: Icon(
                            state ? Icons.visibility_off : Icons.visibility),
                        onPressed: () {
                          context.read<PasswordCubit>().showPassword();
                        },
                      )),
                );
              },
            ),
            const SizedBox(
              height: 20,
            ),
            SizedBox(
              width: MediaQuery.sizeOf(context).width * 0.8,
              child: BlocListener<ProfileCubit, ProfileState>(
                listener: (context, state) {
                  if (state.verifyPasswordStatus ==
                      VerifyPasswordStatus.success) {
                    context.loaderOverlay.hide();
                    Navigator.pop(context);
                    showDialog(
                        context: context,
                        builder: (dialogContext) => ChangeEmailDialog(
                              password: passwordController.text,
                            ));
                  }
                  if (state.verifyPasswordStatus == VerifyPasswordStatus.fail) {
                    context.loaderOverlay.hide();
                  }
                },
                child: ElevatedButton(
                    onPressed: () {
                      context.loaderOverlay.show();
                      context
                          .read<ProfileCubit>()
                          .verifyPassword(passwordController.text);
                    },
                    child: Text(
                      Strings.next,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: Colors.white),
                    )),
              ),
            ),
            SizedBox(
              width: MediaQuery.sizeOf(context).width * 0.8,
              child: ElevatedButton(
                  style:
                      ElevatedButton.styleFrom(backgroundColor: Colors.white),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(Strings.cancel,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: Colors.black))),
            ),
          ],
        ),
      ),
    );
  }
}

class VerifyPhoneDialog extends StatefulWidget {
  const VerifyPhoneDialog({super.key});

  @override
  State<VerifyPhoneDialog> createState() => _VerifyPhoneDialogState();
}

class _VerifyPhoneDialogState extends State<VerifyPhoneDialog> {
  TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return LoaderOverlay(
      child: AlertDialog(
        title:
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          SizedBox(
            width: 200,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  Strings.changePhone,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                Text(
                  Strings.enterPasswordDescription,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(Icons.close))
        ]),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(Strings.phone),
            BlocBuilder<ProfileCubit, ProfileState>(
              builder: (context, state) {
                return TextField(
                  controller:
                      TextEditingController(text: state.userProfile?.phone),
                  readOnly: true,
                );
              },
            ),
            const SizedBox(
              height: 20,
            ),
            Text(Strings.password),
            BlocBuilder<PasswordCubit, bool>(
              builder: (context, state) {
                return TextField(
                  controller: passwordController,
                  obscureText: state,
                  decoration: InputDecoration(
                      hintText: "e.g 123456",
                      // Check if the password is incorrect, show errorText
                      errorText: context
                                  .watch<ProfileCubit>()
                                  .state
                                  .verifyPasswordStatus ==
                              VerifyPasswordStatus.fail
                          ? Strings.wrongPassword
                          : null,
                      suffixIcon: IconButton(
                        icon: Icon(
                            state ? Icons.visibility_off : Icons.visibility),
                        onPressed: () {
                          context.read<PasswordCubit>().showPassword();
                        },
                      )),
                );
              },
            ),
            const SizedBox(
              height: 20,
            ),
            SizedBox(
              width: MediaQuery.sizeOf(context).width * 0.8,
              child: BlocListener<ProfileCubit, ProfileState>(
                listener: (context, state) {
                  if (state.verifyPasswordStatus ==
                      VerifyPasswordStatus.success) {
                    context.loaderOverlay.hide();
                    Navigator.pop(context);
                    showDialog(
                        context: context,
                        builder: (dialogContext) => ChangePhoneDialog(
                              password: passwordController.text,
                            ));
                  }
                  if (state.verifyPasswordStatus == VerifyPasswordStatus.fail) {
                    context.loaderOverlay.hide();
                  }
                },
                child: ElevatedButton(
                    onPressed: () {
                      context.loaderOverlay.show();
                      context
                          .read<ProfileCubit>()
                          .verifyPassword(passwordController.text);
                    },
                    child: Text(
                      Strings.next,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: Colors.white),
                    )),
              ),
            ),
            SizedBox(
              width: MediaQuery.sizeOf(context).width * 0.8,
              child: ElevatedButton(
                  style:
                      ElevatedButton.styleFrom(backgroundColor: Colors.white),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(Strings.cancel,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: Colors.black))),
            ),
          ],
        ),
      ),
    );
  }
}

class VerifyPasswordDialog extends StatefulWidget {
  const VerifyPasswordDialog({super.key});

  @override
  State<VerifyPasswordDialog> createState() => _VerifyPasswordDialogState();
}

class _VerifyPasswordDialogState extends State<VerifyPasswordDialog> {
  TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return LoaderOverlay(
      child: AlertDialog(
        title:
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                Strings.verifyPassword,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(Icons.close))
        ]),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(Strings.password),
            BlocBuilder<PasswordCubit, bool>(
              builder: (context, state) {
                return TextField(
                  controller: passwordController,
                  obscureText: state,
                  decoration: InputDecoration(
                      hintText: "e.g 123456",
                      // Check if the password is incorrect, show errorText
                      errorText: context
                                  .watch<ProfileCubit>()
                                  .state
                                  .verifyPasswordStatus ==
                              VerifyPasswordStatus.fail
                          ? Strings.wrongPassword
                          : null,
                      suffixIcon: IconButton(
                        icon: Icon(
                            state ? Icons.visibility_off : Icons.visibility),
                        onPressed: () {
                          context.read<PasswordCubit>().showPassword();
                        },
                      )),
                );
              },
            ),
            const SizedBox(
              height: 20,
            ),
            SizedBox(
              width: MediaQuery.sizeOf(context).width * 0.8,
              child: BlocListener<ProfileCubit, ProfileState>(
                listener: (context, state) {
                  if (state.deleteAccountStatus ==
                      DeleteAccountStatus.success) {
                    context.loaderOverlay.hide();
                    context.read<LoginCubit>().logout();
                    // Navigator.pop(context);
                    // showDialog(
                    //     context: context,
                    //     builder: (dialogContext) => ChangeEmailDialog(
                    //           password: passwordController.text,
                    //         ));
                  }
                  if (state.deleteAccountStatus == DeleteAccountStatus.fail) {
                    context.loaderOverlay.hide();
                  }
                },
                child: ElevatedButton(
                    onPressed: () {
                      context.loaderOverlay.show();
                      context
                          .read<ProfileCubit>()
                          .deleteAccount(passwordController.text);
                    },
                    child: Text(
                      Strings.delete,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: Colors.white),
                    )),
              ),
            ),
            SizedBox(
              width: MediaQuery.sizeOf(context).width * 0.8,
              child: ElevatedButton(
                  style:
                      ElevatedButton.styleFrom(backgroundColor: Colors.white),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(Strings.cancel,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: Colors.black))),
            ),
          ],
        ),
      ),
    );
  }
}

class ChangeEmailDialog extends StatefulWidget {
  const ChangeEmailDialog({super.key, required this.password});
  final String password;
  @override
  State<ChangeEmailDialog> createState() => _ChangeEmailDialogState();
}

class _ChangeEmailDialogState extends State<ChangeEmailDialog> {
  TextEditingController otpController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return BlocListener<ProfileCubit, ProfileState>(
      listener: (context, state) {
        if (state.updateEmailStatus == UpdateEmailStatus.success) {
          Navigator.pop(context);
          showDialog(
              context: context,
              builder: (context) =>
                  ChangeInfoSuccessDialog(text: Strings.email));
        }
      },
      child: AlertDialog(
        title:
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          SizedBox(
            width: 200,
            child: Column(
              children: [
                Text(
                  Strings.changeEmail,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                Text(
                  Strings.enterPasswordDescription,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(Icons.close))
        ]),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(Strings.email),
            TextField(
              controller: emailController,
              decoration:
                  const InputDecoration(hintText: "e.g admin@gmail.com"),
            ),
            const SizedBox(
              height: 20,
            ),
            VerificationTextField(
                verificationController: otpController,
                sendOTP: () {
                  bool otpSent = context
                      .read<ProfileCubit>()
                      .sendOTPEmailAccount(emailController.text);
                  log("otp sent $otpSent");
                  return true;
                }),
            const SizedBox(
              height: 20,
            ),
            SizedBox(
                width: MediaQuery.sizeOf(context).width * 0.8,
                child: ElevatedButton(
                    onPressed: () {
                      context.read<ProfileCubit>().updateEmail(
                          otpController.text,
                          widget.password,
                          emailController.text);
                    },
                    child: Text(Strings.next,
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(color: Colors.white)))),
            SizedBox(
                width: MediaQuery.sizeOf(context).width * 0.8,
                child: ElevatedButton(
                    onPressed: () {},
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.white),
                    child: Text(Strings.cancel,
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(color: Colors.black)))),
          ],
        ),
      ),
    );
  }
}

class ChangePhoneDialog extends StatefulWidget {
  const ChangePhoneDialog({super.key, required this.password});
  final String password;
  @override
  State<ChangePhoneDialog> createState() => _ChangePhoneDialogState();
}

class _ChangePhoneDialogState extends State<ChangePhoneDialog> {
  TextEditingController otpController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return BlocListener<ProfileCubit, ProfileState>(
      listener: (context, state) {
        if (state.updatePhoneStatus == UpdatePhoneStatus.success) {
          Navigator.pop(context);
          showDialog(
              context: context,
              builder: (context) =>
                  ChangeInfoSuccessDialog(text: Strings.phone));
        }
      },
      child: AlertDialog(
        title:
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          SizedBox(
            width: 200,
            child: Column(
              children: [
                Text(
                  Strings.changePhone,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                Text(
                  Strings.enterPasswordDescription,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(Icons.close))
        ]),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(Strings.phone),
            PhoneNoTextField(phoneNoController: phoneController),
            const SizedBox(
              height: 20,
            ),
            VerificationTextField(
                verificationController: otpController,
                sendOTP: () {
                  // "(${context.read<CountryPickerCubit>().state.selectedCountry?.dialCode ?? "+60"})${phoneController.text}";
                  // context.read<ProfileCubit>().sendOTPPhoneAccount(
                  //     "${context.read<CountryPickerCubit>().state.selectedCountry?.dialCode?.split("+")[1]}${phoneController.text}");

                  context.read<ProfileCubit>().sendOTPPhoneAccount(
                      "(${context.read<CountryPickerCubit>().state.selectedCountry?.dialCode ?? "+60"})${phoneController.text}");

                  return true;
                }),
            const SizedBox(
              height: 20,
            ),
            SizedBox(
                width: MediaQuery.sizeOf(context).width * 0.8,
                child: ElevatedButton(
                    onPressed: () {
                      context.read<ProfileCubit>().updatePhone(
                          otpController.text,
                          widget.password,
                          "(${context.read<CountryPickerCubit>().state.selectedCountry?.dialCode ?? "+60"})${phoneController.text}");
                      // context.read<ProfileCubit>().updatePhone(
                      //     otpController.text,
                      //     widget.password,
                      //     "${context.read<CountryPickerCubit>().state.selectedCountry?.dialCode?.split("+")[1]}${phoneController.text}");
                    },
                    child: Text(Strings.next,
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(color: Colors.white)))),
            SizedBox(
                width: MediaQuery.sizeOf(context).width * 0.8,
                child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.white),
                    child: Text(Strings.cancel,
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(color: Colors.black)))),
          ],
        ),
      ),
    );
  }
}

class ChangeInfoSuccessDialog extends StatelessWidget {
  const ChangeInfoSuccessDialog({super.key, required this.text});
  final String text;
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title:
          Lottie.asset("assets/lottie/success.json", width: 100, height: 100),
      content: Text(
        "You've changed your $text",
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.titleMedium,
      ),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        SizedBox(
          width: 200,
          child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                Strings.ok,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: Colors.white),
              )),
        )
      ],
    );
  }
}
