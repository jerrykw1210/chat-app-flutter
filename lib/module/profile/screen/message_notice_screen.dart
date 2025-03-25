import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:protech_mobile_chat_stream/constants/string_constant.dart';
import 'package:protech_mobile_chat_stream/utils/shared_preferences.dart';

class MessageNoticeScreen extends StatefulWidget {
  const MessageNoticeScreen({super.key});

  @override
  State<MessageNoticeScreen> createState() => _MessageNoticeScreenState();
}

class _MessageNoticeScreenState extends State<MessageNoticeScreen> {
  bool newMessageNotification = true;

  bool inAppSounds = true;

  bool inAppVibration = true;

  @override
  void initState() {
    super.initState();
    init();
  }

  init() {
    log("newMessageNotification ${PrefsStorage.newMessageNotification.boolValue}, inAppSounds ${PrefsStorage.inAppSound.boolValue}, inAppVibration ${PrefsStorage.inAppVibration.boolValue}");
    setState(() {
      newMessageNotification = PrefsStorage.newMessageNotification.boolValue;

      if (!newMessageNotification) {
        inAppSounds = false;
        inAppVibration = false;
        return;
      }

      inAppSounds = PrefsStorage.inAppSound.boolValue;
      inAppVibration = PrefsStorage.inAppVibration.boolValue;
    });
  }

  void newMsgSwitchOnChanged(bool value) {
    if (!value) {
      setState(() {
        inAppSounds = false;
        inAppVibration = false;
      });
      PrefsStorage.inAppSound.setBool(false);
      PrefsStorage.inAppVibration.setBool(false);
    }
    PrefsStorage.newMessageNotification.setBool(value);
    setState(() {
      newMessageNotification = value;
    });
  }

  void soundSwitchOnChanged(bool value) {
    if (newMessageNotification) {
      PrefsStorage.inAppSound.setBool(value);
      setState(() {
        inAppSounds = value;
      });
    }
  }

  void vibrationSwitchOnChanged(bool value) {
    if (newMessageNotification) {
      PrefsStorage.inAppVibration.setBool(value);
      setState(() {
        inAppVibration = value;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          Strings.messageNotice,
          style: Theme.of(context)
              .textTheme
              .titleLarge
              ?.copyWith(color: Colors.white),
        ),
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading: SvgPicture.asset(
                "assets/Buttons/message-notification-circle.svg",
              ),
              title: Text(Strings.newMessageNotification),
              trailing: CupertinoSwitch(
                  value: newMessageNotification,
                  onChanged: newMsgSwitchOnChanged),
            ),
            const Divider(
              thickness: 10,
            ),
            ListTile(
              leading: SvgPicture.asset(
                "assets/Buttons/bell-ringing-01.svg",
              ),
              title: Text(Strings.inAppSound),
              trailing: CupertinoSwitch(
                  value: inAppSounds, onChanged: soundSwitchOnChanged),
            ),
            const Divider(
              indent: 50,
              endIndent: 50,
            ),
            ListTile(
              leading: SvgPicture.asset(
                "assets/Buttons/notification-vibrate.svg",
              ),
              title: Text(Strings.inAppVibration),
              trailing: CupertinoSwitch(
                  value: inAppVibration, onChanged: vibrationSwitchOnChanged),
            ),
            const Divider(
              indent: 50,
              endIndent: 50,
            ),
            // Padding(
            //   padding: const EdgeInsets.only(top: 2),
            //   child: ListTile(
            //     title: const Text("System notification"),
            //     tileColor: Colors.white,
            //     trailing: CupertinoSwitch(value: false, onChanged: (value) {}),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}
