import 'dart:developer';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:protech_mobile_chat_stream/module/general/cubit/language_cubit.dart';
import 'package:protech_mobile_chat_stream/module/profile/cubit/profile_cubit.dart';
import 'package:protech_mobile_chat_stream/route/routes.dart';
import 'package:protech_mobile_chat_stream/service/authentication_service.dart';
import 'package:protech_mobile_chat_stream/service/credential_service.dart';
import 'package:protech_mobile_chat_stream/service/database_helper.dart';
import 'package:protech_mobile_chat_stream/service/turms_service.dart';
import 'package:protech_mobile_chat_stream/utils/service_locator.dart';
import 'package:turms_client_dart/turms_client.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  double progress = 0.0; // Progress tracker (0.0 to 1.0)
  bool isLoading = true; // Whether the loading process is in progress
  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    bool isLogin = await sl<AuthenticationService>().isLogin();

    if (isLogin) {
      await sl<AuthenticationService>().autoLogin();
      context.read<LanguageCubit>().getLanguageList();
      List<Locale> newSupportedLocales = List.from(context.supportedLocales);
      
      log("localeee ${context.supportedLocales}");
      final FlutterSecureStorage storage = sl<FlutterSecureStorage>();

      // String? storedLanguage =
      //     await storage.read(key: StoragekeyConstants.selectedLanguageKey);
      // if (storedLanguage != null && storedLanguage.isNotEmpty) {
      //   context.setLocale(storedLanguage.toLocale());
      // }

      // Step 2: Get profile and update sync
      await Future.wait([context.read<ProfileCubit>().getProfile()]);

      // updateSync();

      Navigator.of(context).pushNamedAndRemoveUntil(
          AppPage.navBar.routeName, (Route<dynamic> route) => false);
      return;
    } else {
      Navigator.of(context).pushNamedAndRemoveUntil(
          AppPage.invitationCode.routeName, (Route<dynamic> route) => false);
      return;
    }
  }

  Future<void> updateSync() async {
    List<SyncTransaction>? syncList =
        await sl<TurmsService>().querySyncTransaction();
    if (syncList != null) {
      DatabaseHelper databaseHelper = sl<DatabaseHelper>();
      String myId = sl<CredentialService>().turmsId ?? "";

      if (syncList.isNotEmpty) {
        for (SyncTransaction syncTransaction in syncList) {
          switch (syncTransaction.actionType) {
            case SyncTransactionActionType.PIN_PRIVATE_CHAT:
              // log("pin");
              databaseHelper.pinConversation(DatabaseHelper.conversationId(
                  targetId: syncTransaction.targetId.toString(), myId: myId));
              break;
            case SyncTransactionActionType.UNPIN_PRIVATE_CHAT:
              // log("unpin");
              databaseHelper.unPinConversation(DatabaseHelper.conversationId(
                  targetId: syncTransaction.targetId.toString(), myId: myId));
              break;
            case SyncTransactionActionType.MUTE_PRIVATE_CHAT:
              // log("mute");
              databaseHelper.muteConversation(DatabaseHelper.conversationId(
                  targetId: syncTransaction.targetId.toString(), myId: myId));
              break;
            case SyncTransactionActionType.UNMUTE_PRIVATE_CHAT:
              // log("unmute");
              databaseHelper.unMuteConversation(DatabaseHelper.conversationId(
                  targetId: syncTransaction.targetId.toString(), myId: myId));
              break;
            case SyncTransactionActionType.FAVOURITE_MESSAGE:
              // log("unmute");
              databaseHelper
                  .favouriteMessage(syncTransaction.targetId.toString());
              break;
            case SyncTransactionActionType.UNFAVOURITE_MESSAGE:
              // log("unmute");
              databaseHelper
                  .unFavouriteMessage(syncTransaction.targetId.toString());
              break;
            default:
              break;
          }
        }
      } else {
        databaseHelper.unPinAllConversation();
        databaseHelper.unMuteAllConversation();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          Container(
              decoration: const BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage("assets/splash_screen.png"),
                      fit: BoxFit.cover))),
        ],
      ),
    );
  }
}
