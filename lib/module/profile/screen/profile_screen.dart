import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:protech_mobile_chat_stream/constants/string_constant.dart';
import 'package:protech_mobile_chat_stream/module/login/cubit/login_cubit.dart';
import 'package:protech_mobile_chat_stream/route/routes.dart';
import 'package:protech_mobile_chat_stream/utils/colors.dart';
import 'package:protech_mobile_chat_stream/utils/toast_utils.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    // context.read<ProfileCubit>().getProfile();
  }

  void showLogoutModal(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) {
          return Dialog(
            insetPadding: EdgeInsets.zero,
            clipBehavior: Clip.hardEdge,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: SizedBox(
              // clipBehavior: Clip.hardEdge,
              width: MediaQuery.sizeOf(context).width * 0.85,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 8, top: 20, right: 0, bottom: 14),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SvgPicture.asset(
                            "assets/Buttons/log-in-02.svg",
                            colorFilter: const ColorFilter.mode(
                                Colors.red, BlendMode.srcIn),
                          ),
                          IconButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              icon: const Icon(Icons.close))
                        ],
                      ),
                    ),
                    Text(Strings.logout,
                        style: const TextStyle(
                            fontFamily: "Inter",
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Color.fromRGBO(16, 24, 40, 1))),
                    const SizedBox(height: 6),
                    Text(Strings.logoutDescription,
                        style: const TextStyle(
                            fontFamily: "Inter",
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: Color.fromRGBO(71, 84, 103, 1))),
                    const SizedBox(height: 36),
                    SizedBox(
                      width: MediaQuery.sizeOf(context).width,
                      child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red),
                          onPressed: () {
                            context.read<LoginCubit>().logout();
                          },
                          child: Text(
                            Strings.logout,
                            style: const TextStyle(
                                fontFamily: "Inter",
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white),
                          )),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: MediaQuery.sizeOf(context).width,
                      child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text(Strings.cancel,
                              style: const TextStyle(
                                  fontFamily: "Inter",
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black))),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return LoaderOverlay(
      child: Scaffold(
        appBar: AppBar(
          title: Text(Strings.settings),
          actions: [
            IconButton(
                onPressed: () =>
                    Navigator.of(context).pushNamed(AppPage.myQrCode.routeName),
                icon: SvgPicture.asset(
                  "assets/Buttons/qr-code-02.svg",
                  colorFilter:
                      const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                ))
          ],
        ),
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              ListTile(
                  tileColor: Colors.white,
                  leading:
                      SvgPicture.asset("assets/Buttons/account_settings.svg"),
                  trailing: const Icon(Icons.chevron_right,
                      color: AppColor.systemBlack),
                  onTap: () => Navigator.pushNamed(
                      context, AppPage.accountSecurity.routeName),
                  title: Text(Strings.accountSettings,
                      style: const TextStyle(
                          color: AppColor.systemBlack,
                          fontFamily: "Inter",
                          fontSize: 16,
                          fontWeight: FontWeight.w500))),
              const Divider(
                  color: Color.fromRGBO(245, 246, 250, 1),
                  height: 10,
                  thickness: 10),
              ListView(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                children: ListTile.divideTiles(
                    color: const Color.fromRGBO(243, 243, 243, 1),
                    tiles: [
                      ListTile(
                          tileColor: Colors.white,
                          leading: SvgPicture.asset(
                            "assets/Buttons/privacy.svg",
                          ),
                          onTap: () => Navigator.pushNamed(
                              context, AppPage.privacy.routeName),
                          trailing: const Icon(Icons.chevron_right,
                              color: AppColor.systemBlack),
                          title: Text(Strings.privacy,
                              style: const TextStyle(
                                  color: AppColor.systemBlack,
                                  fontFamily: "Inter",
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500))),
                      ListTile(
                          tileColor: Colors.white,
                          leading: SvgPicture.asset(
                            "assets/Buttons/Message.svg",
                          ),
                          trailing: const Icon(Icons.chevron_right,
                              color: AppColor.systemBlack),
                          onTap: () => Navigator.pushNamed(
                              context, AppPage.systemSettings.routeName),
                          title: Text(Strings.systemSettings,
                              style: const TextStyle(
                                  color: AppColor.systemBlack,
                                  fontFamily: "Inter",
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500))),
                      ListTile(
                          tileColor: Colors.white,
                          leading: SvgPicture.asset(
                            "assets/Buttons/info.svg",
                          ),
                          trailing: const Icon(Icons.chevron_right,
                              color: AppColor.systemBlack),
                          onTap: () => Navigator.pushNamed(
                              context, AppPage.about.routeName),
                          title: Text(Strings.aboutUs,
                              style: const TextStyle(
                                  color: AppColor.systemBlack,
                                  fontFamily: "Inter",
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500))),
                    ]).toList(),
              ),
              const Divider(
                  color: Color.fromRGBO(245, 246, 250, 1),
                  height: 10,
                  thickness: 10),
              BlocListener<LoginCubit, LoginState>(
                listener: (context, state) {
                  state.logoutStatus == LogoutStatus.loading
                      ? context.loaderOverlay.show()
                      : context.loaderOverlay.hide();

                  if (state.logoutStatus == LogoutStatus.success) {
                    Navigator.of(context).pushNamedAndRemoveUntil(
                        AppPage.invitationCode.routeName,
                        (Route<dynamic> route) => false);

                    ToastUtils.showToast(
                        context: context,
                        msg: Strings.logoutSuccess,
                        type: Type.success);
                  }

                  if (state.logoutStatus == LogoutStatus.fail) {
                    ToastUtils.showToast(
                        context: context,
                        msg: Strings.logoutFail,
                        type: Type.danger);
                  }
                },
                child: ListTile(
                    onTap: () => showLogoutModal(context),
                    tileColor: Colors.white,
                    leading: SvgPicture.asset(
                      "assets/Buttons/logout.svg",
                      colorFilter:
                          const ColorFilter.mode(Colors.red, BlendMode.srcIn),
                    ),
                    title: Text(Strings.logout,
                        style: const TextStyle(
                            color: Colors.red,
                            fontFamily: "Inter",
                            fontSize: 16,
                            fontWeight: FontWeight.w500))),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
