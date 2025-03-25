import 'dart:developer';
import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:protech_mobile_chat_stream/constants/string_constant.dart';
import 'package:protech_mobile_chat_stream/main.dart';
import 'package:protech_mobile_chat_stream/module/general/cubit/language_cubit.dart';
import 'package:protech_mobile_chat_stream/utils/helper.dart';
import 'package:protech_mobile_chat_stream/utils/locale.dart';
import 'package:protech_mobile_chat_stream/widgets/custom_alert_dialog.dart';

class LanguageScreen extends StatefulWidget {
  const LanguageScreen({super.key});

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  @override
  void initState() {
    super.initState();
    context.read<LanguageCubit>().getLanguageList();
  }

  @override
  Widget build(BuildContext context) {
    FilePickerResult? filePickerResult;

    return Scaffold(
      appBar: AppBar(
        title: Text(Strings.changeLanguage),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BlocConsumer<LanguageCubit, LanguageState>(
              listenWhen: (previous, current) =>
                  previous.downloadLanguageStatus !=
                  current.downloadLanguageStatus,
              listener: (context, state) async {
                if (state.downloadLanguageStatus ==
                    DownloadLanguageStatus.downloaded) {
                  // print("locale123566 ${state.languageList[index].code}");
                  if ("${context.locale.languageCode}-${context.locale.countryCode?.toLowerCase()}" !=
                      state.languageCode) {
                    await context.setLocale(LanguageLocale.supportedLocales
                        .singleWhere((locale) =>
                            "${locale.languageCode}-${locale.countryCode?.toLowerCase()}" ==
                            state.languageCode.toLowerCase()));

                    //TODO: add dialog
                    CustomAlertDialog.showGeneralDialog(
                        context: context,
                        title: Strings.changeLanguage,
                        content: Text(Strings.changeLanguageDesc),
                        actions: [
                          TextButton(
                            onPressed: () {
                              context
                                  .read<LanguageCubit>()
                                  .resetLanguageStatus();
                              MainApp.restartApp(context);
                            },
                            child: Text(Strings.ok),
                          )
                        ]);
                  }
                }
              },
              builder: (context, state) {
                if (state.languageList.isNotEmpty) {
                  return Column(
                    children: [
                      ListView.builder(
                        itemCount: state.languageList.length,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                          return ListTile(
                            title: Text(state.languageList[index].name),
                            onTap: () async {
                              if (File(
                                      "${Helper.directory?.path}/${state.languageList[index].path}")
                                  .existsSync()) {
                                await context.setLocale(LanguageLocale
                                    .supportedLocales
                                    .singleWhere((locale) =>
                                        "${locale.languageCode}-${locale.countryCode?.toLowerCase()}" ==
                                        state.languageList[index].code
                                            .toLowerCase()));
                                CustomAlertDialog.showGeneralDialog(
                                    context: context,
                                    title: Strings.changeLanguage,
                                    content: Text(Strings.changeLanguageDesc),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          context
                                              .read<LanguageCubit>()
                                              .resetLanguageStatus();
                                          MainApp.restartApp(context);
                                        },
                                        child: Text(Strings.ok),
                                      )
                                    ]);
                              } else {
                                context
                                    .read<LanguageCubit>()
                                    .resetLanguageStatus();
                                await context
                                    .read<LanguageCubit>()
                                    .downloadLanguagePack(
                                        state.languageList[index].path);
                              }
                            },
                            trailing: File(
                                        "${Helper.directory?.path}/${state.languageList[index].path}")
                                    .existsSync()
                                ? "${context.locale.languageCode}-${context.locale.countryCode?.toLowerCase()}" ==
                                        state.languageList[index].code
                                    ? const Icon(Icons.done)
                                    : const SizedBox()
                                : SvgPicture.asset(
                                    "assets/icons/download-03.svg"),
                          );
                        },
                      ),
                    ],
                  );
                }
                return const SizedBox();
              },
            ),
            // BlocBuilder<LanguageCubit, LanguageState>(
            //   builder: (context, state) {
            //     if (state.languageList.isNotEmpty) {
            //       return Column(
            //         children: [
            //           Text(Strings.downloadableLanguage),
            //           ListView.builder(
            //             itemCount: state.languageList.length,
            //             shrinkWrap: true,
            //             physics: const NeverScrollableScrollPhysics(),
            //             itemBuilder: (context, index) {
            //               return ListTile(
            //                 title: Text(state.languageList[index].name),
            //                 trailing:
            //                     BlocListener<LanguageCubit, LanguageState>(
            //                   listener: (context, state) {
            //                     if (state.downloadLanguageStatus ==
            //                         DownloadLanguageStatus.downloaded) {
            //                       context.setLocale(LanguageLocale
            //                           .supportedLocales
            //                           .singleWhere((locale) =>
            //                               "${locale.languageCode}-${locale.countryCode?.toLowerCase()}" ==
            //                               state.languageList[index].code
            //                                   .toLowerCase()));
            //                     }
            //                   },
            //                   child: IconButton(
            //                       onPressed: () {
            //                         context
            //                             .read<LanguageCubit>()
            //                             .downloadLanguagePack(
            //                                 state.languageList[index].path);
            //                       },
            //                       icon: SvgPicture.asset(
            //                           "assets/icons/download-03.svg")),
            //                 ),
            //               );
            //             },
            //           ),
            //         ],
            //       );
            //     }
            //     return const SizedBox();
            //   },
            // ),
          ],
        ),
      ),
    );
  }
}

class LanguageDemo {
  final String code;
  final String name;
  final String flag;

  const LanguageDemo(this.code, this.name, this.flag);
}
