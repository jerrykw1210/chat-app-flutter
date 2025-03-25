import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:protech_mobile_chat_stream/constants/string_constant.dart';
import 'package:protech_mobile_chat_stream/utils/colors.dart';
import 'package:protech_mobile_chat_stream/route/routes.dart';
import 'package:protech_mobile_chat_stream/widgets/account_deletion_dialog.dart';
import 'package:protech_mobile_chat_stream/widgets/change_password_dialog.dart';

class AccountSecurityScreen extends StatelessWidget {
  const AccountSecurityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          Strings.accountSecurity,
          style: Theme.of(context)
              .textTheme
              .titleLarge
              ?.copyWith(color: Colors.white),
        ),
      ),
      backgroundColor: AppColor.greyBackgroundColor3,
      body: SingleChildScrollView(
          child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: ListTile(
              tileColor: Colors.white,
              leading: SvgPicture.asset(
                "assets/Buttons/user-01.svg",
              ),
              title: Text(Strings.myProfile),
              onTap: () => Navigator.of(context)
                  .pushNamed(AppPage.editProfile.routeName),
              trailing: const Icon(Icons.chevron_right),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: ListTile(
              tileColor: Colors.white,
              leading: SvgPicture.asset(
                "assets/Buttons/monitor-02.svg",
              ),
              title: Text(Strings.deviceManagement),
              onTap: () => Navigator.of(context)
                  .pushNamed(AppPage.deviceManagement.routeName),
              trailing: const Icon(Icons.chevron_right),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: ListTile(
              tileColor: Colors.white,
              leading: SvgPicture.asset(
                "assets/Buttons/monitor-02.svg",
              ),
              title: Text(Strings.changePassword),
              onTap: () => showDialog(
                context: context,
                builder: (context) => const ChangePasswordDialog(),
              ),
              trailing: const Icon(Icons.chevron_right),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: ListTile(
              tileColor: Colors.white,
              leading: SvgPicture.asset(
                "assets/Buttons/monitor-02.svg",
              ),
              title: Text(Strings.deleteAccount),
              onTap: () => showDialog(
                context: context,
                builder: (context) => const AccountDeletionDialog(),
              ),
              trailing: const Icon(Icons.chevron_right),
            ),
          ),
        ],
      )),
    );
  }
}
