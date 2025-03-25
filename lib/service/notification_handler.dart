import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:protech_mobile_chat_stream/firebase_options.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:protech_mobile_chat_stream/model/database.dart';
import 'package:protech_mobile_chat_stream/service/credential_service.dart';
import 'package:protech_mobile_chat_stream/service/database_helper.dart';
import 'package:protech_mobile_chat_stream/utils/notificationBackgroundHandler.dart';
import 'package:protech_mobile_chat_stream/utils/service_locator.dart';
import 'package:protech_mobile_chat_stream/utils/shared_preferences.dart';

class NotificationController {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static void initialize() async {
    // Initialization  setting for android
    await _notificationsPlugin.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings("mipmap/ic_launcher"),
        iOS: DarwinInitializationSettings(),
      ),
      // to handle event when we receive notification
      onDidReceiveNotificationResponse: (details) {
        log("onDidReceiveNotificationResponse ${details.payload}");
        if (details.input != null) {}
      },
    );
  }

  static Future<void> displayFromFcm(RemoteMessage message) async {
    // SharedPreferences prefs = await SharedPreferences.getInstance();
    bool soundEnabled = PrefsStorage.inAppSound.boolValue;
    bool vibrationEnabled = PrefsStorage.inAppVibration.boolValue;
    bool newMessageNotification = PrefsStorage.newMessageNotification.boolValue;

    // To display the notification in device
    try {
      if (newMessageNotification) {
        if (message.notification?.title != null) {
          final id = DateTime.now().millisecondsSinceEpoch ~/ 1000;
          NotificationDetails notificationDetails = NotificationDetails(
              android: AndroidNotificationDetails("Channel Id", "Main Channel",
                  color: Colors.blue,
                  importance: Importance.max,
                  icon: "mipmap/launcher_icon",
                  // different sound for
                  // different notification
                  playSound: soundEnabled,
                  enableVibration: vibrationEnabled,
                  priority: Priority.high),
              iOS: DarwinNotificationDetails(presentSound: soundEnabled));
          await _notificationsPlugin.show(id, message.notification?.title,
              message.notification?.body, notificationDetails,
              payload: message.data['route']);
        }
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  static Future<void> display({
    required String title,
    required String body,
    required String payload,
  }) async {
    bool soundEnabled = PrefsStorage.inAppSound.boolValue;
    bool vibrationEnabled = PrefsStorage.inAppVibration.boolValue;
    bool newMessageNotification = PrefsStorage.newMessageNotification.boolValue;
    try {
      if (newMessageNotification) {
        final id = DateTime.now().millisecondsSinceEpoch ~/ 1000;
        NotificationDetails notificationDetails = NotificationDetails(
            android: AndroidNotificationDetails(
                "local_notification_${vibrationEnabled.toString()}_${soundEnabled.toString()}",
                "Main_${vibrationEnabled ? "vibrate" : "no_vibrate"}_${soundEnabled ? "sound" : "no_sound"}",
                color: Colors.blue,
                importance: Importance.high,
                icon: "mipmap/launcher_icon",
                playSound: soundEnabled,
                // sound: soundEnabled
                //     ? const RawResourceAndroidNotificationSound("notification")
                //     : null,
                vibrationPattern:
                    vibrationEnabled ? Int64List.fromList([0, 500]) : null,
                enableVibration: vibrationEnabled,
                priority: Priority.high),
            iOS: DarwinNotificationDetails(presentSound: soundEnabled));
        await _notificationsPlugin.show(id, title, body, notificationDetails,
            payload: payload);
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  @pragma('vm:entry-point')
  static Future<void> firebaseMessagingBackgroundHandler(
      RemoteMessage message) async {
    // If you're going to use other Firebase services in the background, such as Firestore,
    // make sure you call `initializeApp` before using other Firebase services.
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);

    await PrefsStorage.init();

    print("Handling a background message: ${message.toMap()}");

    // AwesomeNotifications().createNotification(
    //   content: NotificationContent(
    //       id: Helper.generateIntUUID(count: 6),
    //       channelKey: 'basic_channel',
    //       title: message.notification?.title,
    //       body: message.notification?.body,
    //       wakeUpScreen: true),
    // );

    NotificationBackgroundHandler.firebaseMessagingBackgroundHandler(message);

    if (message.data.containsKey("message")) {
      Conversation? conversation;

      Map<String, dynamic> messageData = jsonDecode(message.data["message"]);

      await startupSL();

      bool isGroup = messageData.containsKey("isGroupMessage")
          ? messageData["isGroupMessage"]
          : false;

      String myId = await sl<CredentialService>().getTurmsId ?? "";

      String? targetId = messageData.containsKey("targetId")
          ? messageData["targetId"].toString()
          : null;

      String? senderId = messageData.containsKey("senderId")
          ? messageData["senderId"].toString()
          : null;

      String? friendId = isGroup
          ? targetId
          : myId == senderId
              ? targetId
              : senderId;

      if (friendId != null) {
        log("target id $friendId");

        conversation =
            await sl<DatabaseHelper>().getConversationByTargetId(friendId);

        // log("is required to show local notification $isMuted");

        if (conversation?.isMuted ?? false) {
          return;
        }
      }

      String? title = conversation?.title ?? message.notification?.title;

      String? body = message.notification?.body;

      if (title != null && body != null && senderId != myId) {
        NotificationController.display(title: title, body: body, payload: "");
      }

      // log("msg data ${messageData}");
    }

    // NotificationController.displayFromFcm(message);
  }

  @pragma('vm:entry-point')
  static Future<void> handlePushNotificationFromNative(MethodCall call) async {
    if (call.method == 'onPushNotificationReceived') {
      final Map<dynamic, dynamic> notificationData = call.arguments;
      log('Received push notification from native: $notificationData');

      // AwesomeNotifications().createNotification(
      //   content: NotificationContent(
      //       id: Helper.generateIntUUID(count: 6),
      //       channelKey: 'basic_channel',
      //       title: notificationData["aps"]["alert"]["title"] ?? "title",
      //       body: notificationData["aps"]["alert"]["body"] ?? "body",
      //       wakeUpScreen: true),
      // );

      NotificationController.display(
          title: notificationData["aps"]["alert"]["title"] ?? "title",
          body: notificationData["aps"]["alert"]["body"] ?? "body",
          payload: "payload");

      // Do something with the data, e.g., show an alert, update UI, etc.
    }
  }
}
