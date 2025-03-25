import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:protech_mobile_chat_stream/constants/string_constant.dart';
import 'package:protech_mobile_chat_stream/module/friend/cubit/user_cubit.dart';

class AddContactMethodScreen extends StatefulWidget {
  const AddContactMethodScreen({super.key});

  @override
  State<AddContactMethodScreen> createState() => _AddContactMethodScreenState();
}

class _AddContactMethodScreenState extends State<AddContactMethodScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          Strings.addContactMethod,
          style: Theme.of(context)
              .textTheme
              .titleLarge
              ?.copyWith(color: Colors.white),
        ),
      ),
      body: BlocBuilder<UserCubit, UserState>(
        builder: (context, state) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                leading: SvgPicture.asset(
                  "assets/Buttons/privacy.svg",
                ),
                title: const Text("ID"),
                trailing: CupertinoSwitch(
                    value:
                        state.userSettings['ADDING_USING_ID']?.int32Value == 1
                            ? true
                            : false,
                    onChanged: (value) {
                      setState(() {
                        state.userSettings['ADDING_USING_ID']?.int32Value =
                            value ? 1 : 0;
                        context
                            .read<UserCubit>()
                            .updateUserSettings(state.userSettings);
                      });
                    }),
              ),
              const Divider(
                indent: 50,
                endIndent: 50,
              ),
              ListTile(
                leading: SvgPicture.asset(
                  "assets/Buttons/account_settings.svg",
                ),
                title: Text(Strings.groups),
                trailing: CupertinoSwitch(
                    value:
                        state.userSettings['ADDING_WITHIN_GROUP']?.int32Value ==
                                1
                            ? true
                            : false,
                    onChanged: (value) {
                      setState(() {
                        state.userSettings['ADDING_WITHIN_GROUP']?.int32Value =
                            value ? 1 : 0;

                        context
                            .read<UserCubit>()
                            .updateUserSettings(state.userSettings);
                      });
                    }),
              ),
              const Divider(
                indent: 50,
                endIndent: 50,
              ),
              ListTile(
                leading: SvgPicture.asset(
                  "assets/Buttons/credit-card-01.svg",
                ),
                title: Text(Strings.namecard),
                trailing: CupertinoSwitch(
                    value: state.userSettings['ADDING_USING_BUSINESS_CARD']
                                ?.int32Value ==
                            1
                        ? true
                        : false,
                    onChanged: (value) {
                      setState(() {
                        state.userSettings['ADDING_USING_BUSINESS_CARD']
                            ?.int32Value = value ? 1 : 0;

                        context
                            .read<UserCubit>()
                            .updateUserSettings(state.userSettings);
                      });
                    }),
              ),
              const Divider(
                indent: 50,
                endIndent: 50,
              ),
              ListTile(
                leading: SvgPicture.asset(
                  "assets/Buttons/qr-code-02.svg",
                ),
                title: Text(Strings.myQrCode),
                trailing: CupertinoSwitch(
                    value: state.userSettings['ADDING_USING_MY_QR_CODE']
                                ?.int32Value ==
                            1
                        ? true
                        : false,
                    onChanged: (value) {
                      setState(() {
                        state.userSettings['ADDING_USING_MY_QR_CODE']
                            ?.int32Value = value ? 1 : 0;

                        context
                            .read<UserCubit>()
                            .updateUserSettings(state.userSettings);
                      });
                    }),
              ),
            ],
          );
        },
      ),
    );
  }
}
