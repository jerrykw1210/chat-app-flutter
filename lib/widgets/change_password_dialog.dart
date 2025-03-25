import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:protech_mobile_chat_stream/constants/string_constant.dart';
import 'package:protech_mobile_chat_stream/module/profile/cubit/profile_cubit.dart';
import 'package:protech_mobile_chat_stream/utils/toast_utils.dart';
import 'package:protech_mobile_chat_stream/widgets/edit_profile_dialog.dart';

class ChangePasswordDialog extends StatefulWidget {
  const ChangePasswordDialog({super.key});

  @override
  State<ChangePasswordDialog> createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends State<ChangePasswordDialog> {
  TextEditingController oldPasswordController = TextEditingController();
  TextEditingController newPasswordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool hidePassword = true;
  bool hideNewPassword = true;
  bool hideConfirmPassword = true;

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
                  Strings.changePassword,
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
        content: BlocListener<ProfileCubit, ProfileState>(
          listener: (context, state) {
            if (state.updatePasswordStatus == UpdatePasswordStatus.fail) {
              switch (state.updatePasswordError) {
                case "631":
                  ToastUtils.showToast(
                      context: context,
                      type: Type.warning,
                      msg: Strings.passwordFormatInvalid);
                  break;
                case "641":
                  ToastUtils.showToast(
                      context: context,
                      type: Type.warning,
                      msg: Strings.newPasswordFormatInvalid);
                  break;
                default:
              }
            }
          },
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(Strings.oldPassword),
                TextFormField(
                  controller: oldPasswordController,
                  obscureText: hidePassword,
                  decoration: InputDecoration(
                      hintText: "e.g 123456",
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
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return Strings.passwordEmpty;
                    }
                    if (value.length < 6) {
                      return Strings.passwordTooShort;
                    }

                    return null;
                  },
                ),
                const SizedBox(
                  height: 20,
                ),
                Text(Strings.newPassword),
                TextFormField(
                  obscureText: hideNewPassword,
                  controller: newPasswordController,
                  decoration: InputDecoration(
                      hintText: "e.g 123456",
                      suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              hideNewPassword = !hideNewPassword;
                            });
                          },
                          icon: Icon(
                              hideNewPassword
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: Colors.grey))),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return Strings.passwordEmpty;
                    }
                    if (value.length < 6) {
                      return Strings.passwordTooShort;
                    }
                    return null;
                  },
                ),
                const SizedBox(
                  height: 20,
                ),
                Text(Strings.confirmPassword),
                TextFormField(
                  obscureText: hideConfirmPassword,
                  controller: confirmPasswordController,
                  validator: (value) {
                    if (value != newPasswordController.text) {
                      return Strings.passwordDoesNotMatch;
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                      hintText: "e.g 123456",
                      suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              hideConfirmPassword = !hideConfirmPassword;
                            });
                          },
                          icon: Icon(
                              hideConfirmPassword
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: Colors.grey))
                      // Check if the password is incorrect, show errorText

                      // errorText: confirmPasswordController.value.text !=
                      //         newPasswordController.value.text
                      //     ? Strings.wrongPassword
                      //     : null,
                      ),
                ),
                const SizedBox(
                  height: 20,
                ),
                SizedBox(
                  width: MediaQuery.sizeOf(context).width * 0.8,
                  child: BlocListener<ProfileCubit, ProfileState>(
                    listener: (context, state) {
                      if (state.updatePasswordStatus ==
                          UpdatePasswordStatus.success) {
                        context.loaderOverlay.hide();
                        Navigator.pop(context);
                        showDialog(
                            context: context,
                            builder: (context) => ChangeInfoSuccessDialog(
                                text: Strings.password));
                      }
                      if (state.updatePasswordStatus ==
                          UpdatePasswordStatus.fail) {
                        context.loaderOverlay.hide();
                      }
                    },
                    child: ElevatedButton(
                        onPressed: () {
                          //context.loaderOverlay.show();
                          if (_formKey.currentState!.validate()) {
                            context.read<ProfileCubit>().updatePassword(
                                oldPasswordController.text,
                                newPasswordController.text);
                          }
                        },
                        child: Text(
                          Strings.changePassword,
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
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white),
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
        ),
      ),
    );
  }
}
