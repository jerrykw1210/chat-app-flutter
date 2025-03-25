import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:protech_mobile_chat_stream/constants/string_constant.dart';
import 'package:protech_mobile_chat_stream/module/friend/cubit/user_cubit.dart';
import 'package:protech_mobile_chat_stream/route/routes.dart';
import 'package:protech_mobile_chat_stream/service/credential_service.dart';
import 'package:protech_mobile_chat_stream/utils/service_locator.dart';
import 'package:protech_mobile_chat_stream/utils/string_apis.dart';

class PrivacyScreen extends StatefulWidget {
  const PrivacyScreen({super.key});

  @override
  State<PrivacyScreen> createState() => _PrivacyScreenState();
}

class _PrivacyScreenState extends State<PrivacyScreen> {
  @override
  void initState() {
    super.initState();
    context.read<UserCubit>().getUserSettings(
        targetUserId: sl<CredentialService>().turmsId?.parseInt64());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          Strings.privacy,
          style: Theme.of(context)
              .textTheme
              .titleLarge
              ?.copyWith(color: Colors.white),
        ),
      ),
      backgroundColor: Colors.white,
      body: Column(
        children: [
          BlocBuilder<UserCubit, UserState>(
            builder: (context, state) {
              return ListTile(
                leading: SvgPicture.asset(
                  "assets/Buttons/privacy.svg",
                ),
                title: Text(Strings.addMeNeedVerification),
                tileColor: Colors.white,
                trailing: CupertinoSwitch(
                    value: state.userSettings['ADD_ME_NEED_VERIFICATION']
                                ?.int32Value ==
                            1
                        ? true
                        : false,
                    onChanged: (value) {
                      setState(() {
                        state.userSettings['ADD_ME_NEED_VERIFICATION']
                            ?.int32Value = value ? 1 : 0;
                        context
                            .read<UserCubit>()
                            .updateUserSettings(state.userSettings);
                      });
                    }),
              );
            },
          ),
          const Divider(
            indent: 50,
            endIndent: 50,
          ),
          ListTile(
            leading: SvgPicture.asset(
              "assets/Buttons/account_settings.svg",
            ),
            onTap: () => Navigator.of(context)
                .pushNamed(AppPage.addContactMethod.routeName),
            title: Text(Strings.methodsForAddingContact),
            tileColor: Colors.white,
            trailing: const Icon(Icons.chevron_right),
          ),
          const Divider(
            indent: 50,
            endIndent: 50,
          ),
          // ListTile(
          //   leading: SvgPicture.asset(
          //     "assets/Buttons/file-02.svg",
          //   ),
          //   title:  Text(Strings.blacklist),
          //   tileColor: Colors.white,
          //   trailing: const Icon(Icons.chevron_right),
          // ),
        ],
      ),
    );
  }
}
