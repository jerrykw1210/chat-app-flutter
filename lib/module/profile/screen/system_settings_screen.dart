import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:path_provider/path_provider.dart';
import 'package:protech_mobile_chat_stream/constants/string_constant.dart';
import 'package:protech_mobile_chat_stream/module/profile/cubit/profile_cubit.dart';
import 'package:protech_mobile_chat_stream/module/profile/cubit/settings_cubit.dart';
import 'package:protech_mobile_chat_stream/route/routes.dart';
import 'package:protech_mobile_chat_stream/service/database_helper.dart';
import 'package:protech_mobile_chat_stream/utils/helper.dart';
import 'package:protech_mobile_chat_stream/utils/service_locator.dart';
import 'package:protech_mobile_chat_stream/utils/toast_utils.dart';
import 'package:protech_mobile_chat_stream/widgets/feedback_dialog.dart';

class SystemSettingsScreen extends StatelessWidget {
  const SystemSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return LoaderOverlay(
      child: Scaffold(
          appBar: AppBar(
            leading: IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.arrow_back)),
            title: Text(
              Strings.systemSettings,
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(color: Colors.white),
            ),
          ),
          backgroundColor: Colors.white,
          body: BlocListener<SettingsCubit, SettingsState>(
            listener: (context, state) {
              state.deleteChatHistoryStatus == DeleteChatHistoryStatus.loading
                  ? context.loaderOverlay.show()
                  : context.loaderOverlay.hide();

              if (state.deleteChatHistoryStatus ==
                  DeleteChatHistoryStatus.fail) {
                ToastUtils.showToast(
                    context: context,
                    msg: state.errorMessage ?? Strings.deleteFailed,
                    type: Type.warning);
              }

              if (state.deleteChatHistoryStatus ==
                  DeleteChatHistoryStatus.success) {
                ToastUtils.showToast(
                    context: context,
                    msg: Strings.deleteSuccess,
                    type: Type.success);
                sl<DatabaseHelper>().clearDatabase();
              }
            },
            child: Column(
              children: [
                ListTile(
                  leading: SvgPicture.asset(
                      "assets/Buttons/message-notification-circle.svg"),
                  title: Text(Strings.messageNotice),
                  onTap: () => Navigator.of(context)
                      .pushNamed(AppPage.messageNotice.routeName),
                  trailing: const Icon(Icons.chevron_right),
                ),
                const Divider(
                  indent: 50,
                  endIndent: 50,
                ),
                ListTile(
                    leading:
                        SvgPicture.asset("assets/Buttons/translate-02.svg"),
                    title: Text(Strings.switchLanguage),
                    onTap: () => Navigator.pushNamed(
                        context, AppPage.language.routeName),
                    trailing: const Icon(Icons.chevron_right)
                    // trailing: BlocBuilder<ProfileCubit, ProfileState>(
                    //   builder: (context, state) {
                    //     return DropdownButtonHideUnderline(
                    //       child: DropdownButton(
                    //           value: state.language,
                    //           alignment: Alignment.centerRight,
                    //           icon: const Icon(Icons.keyboard_arrow_down),
                    //           items: [
                    //             DropdownMenuItem(
                    //               value: "US",
                    //               child: Text("English",
                    //                   style: Theme.of(context).textTheme.bodyMedium),
                    //             ),
                    //             DropdownMenuItem(
                    //               value: "CN",
                    //               child: Text("简体中文",
                    //                   style: Theme.of(context).textTheme.bodyMedium),
                    //             ),
                    //             DropdownMenuItem(
                    //               value: "TW",
                    //               child: Text("Bahasa Melayu",
                    //                   style: Theme.of(context).textTheme.bodyMedium),
                    //             )
                    //           ],
                    //           onChanged: (value) {
                    //             context
                    //                 .read<ProfileCubit>()
                    //                 .changeLanguage(value.toString());

                    //             // context.setLocale(Language.languages[
                    //             //     Language.languages.indexWhere((language) =>
                    //             //         language.countryCode == value.toString())]);
                    //             // PrefsStorage.userLanguage
                    //             //     .setString(context.locale.toString());
                    //           }),
                    //     );
                    //   },
                    // ),
                    ),
                const Divider(
                  indent: 50,
                  endIndent: 50,
                ),
                ListTile(
                  leading: SvgPicture.asset("assets/Buttons/clear-cache.svg"),
                  title: Text(Strings.clearCache),
                  onTap: () async {
                    final cacheDir = await getTemporaryDirectory();
                    int totalSize = 0;
                    if (cacheDir.existsSync()) {
                      cacheDir.listSync().forEach((file) {
                        totalSize += file.statSync().size;
                      });
                    }
                    String fileSize = Helper.formatFileSize(totalSize);
                    showDialog(
                      context: context,
                      builder: (dialogcontext) {
                        return AlertDialog(
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Icon(
                                Icons.delete,
                                color: Colors.red,
                              ),
                              IconButton(
                                  onPressed: () => Navigator.pop(dialogcontext),
                                  icon: const Icon(Icons.close))
                            ],
                          ),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "${Strings.clearCache} $fileSize",
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                Strings.clearCacheDesc
                                    .replaceAll("[fileSize]", fileSize),
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              const SizedBox(height: 10),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red),
                                  onPressed: () {
                                    if (cacheDir.existsSync()) {
                                      for (var file in cacheDir.listSync()) {
                                        try {
                                          if (file is File) {
                                            file.delete();
                                          } else if (file is Directory) {
                                            file.delete(recursive: true);
                                          }
                                          ToastUtils.showToast(
                                              context: context,
                                              msg: Strings.clearCacheSuccess,
                                              type: Type.success);
                                        } catch (e) {
                                          print(
                                              'Failed to delete ${file.path}: $e');
                                          ToastUtils.showToast(
                                              context: context,
                                              msg: Strings.clearCacheFailed,
                                              type: Type.warning);
                                        }
                                      }
                                    }
                                    Navigator.of(context).pop();
                                  },
                                  child: Text(
                                    Strings.clear,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(color: Colors.white),
                                  ),
                                ),
                              ),
                              SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.white),
                                    child: Text(Strings.cancel,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(color: Colors.black)),
                                  ))
                            ],
                          ),
                        );
                      },
                    );
                  },
                  trailing: const Icon(Icons.chevron_right),
                ),
                const Divider(
                  indent: 50,
                  endIndent: 50,
                ),
                ListTile(
                  leading:
                      SvgPicture.asset("assets/Buttons/message-x-circle.svg"),
                  title: Text(Strings.clearChatHistory),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (dialogcontext) {
                        return AlertDialog(
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Icon(
                                Icons.delete,
                                color: Colors.red,
                              ),
                              IconButton(
                                  onPressed: () => Navigator.pop(dialogcontext),
                                  icon: const Icon(Icons.close))
                            ],
                          ),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                Strings.clearChatHistory,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                Strings.clearChatHistoryDesc,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              const SizedBox(height: 10),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red),
                                  onPressed: () {
                                    context
                                        .read<SettingsCubit>()
                                        .deleteChatHistory();

                                    Navigator.of(context).pop();
                                  },
                                  child: Text(
                                    Strings.clear,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(color: Colors.white),
                                  ),
                                ),
                              ),
                              SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.white),
                                    child: Text(Strings.cancel,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(color: Colors.black)),
                                  ))
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
                const Divider(
                  indent: 50,
                  endIndent: 50,
                ),
                ListTile(
                  leading: SvgPicture.asset("assets/Buttons/info.svg"),
                  title: Text(Strings.feedback),
                  onTap: () {
                    context.read<ProfileCubit>().resetFeedback();
                    showDialog(
                      context: context,
                      builder: (dialogcontext) => BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                          child: FeedbackDialog()),
                    );
                  },
                  trailing: const Icon(Icons.chevron_right),
                ),
              ],
            ),
          )),
    );
  }
}
