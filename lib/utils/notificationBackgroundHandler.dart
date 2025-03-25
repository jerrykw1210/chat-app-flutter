// As this runs in a separate isolate, we need to setup the app again.
import 'dart:developer';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:protech_mobile_chat_stream/service/authentication_service.dart';
import 'package:protech_mobile_chat_stream/service/credential_service.dart';
import 'package:protech_mobile_chat_stream/utils/service_locator.dart';
import 'package:stream_video_flutter/stream_video_flutter.dart';
import 'package:stream_video_push_notification/stream_video_push_notification.dart';

class NotificationBackgroundHandler {
  @pragma('vm:entry-point')
  static Future<void> firebaseMessagingBackgroundHandler(
      RemoteMessage message) async {
    // Initialise Firebase
    // await Firebase.initializeApp(
    //     options: DefaultFirebaseOptions.currentPlatform);

    await dotenv.load(fileName: "lib/.env");

    try {
      // Get stored user credentials
      // var credentials = yourUserCredentialsGetMethod();
      // if (credentials == null) return;
      await startupSL();

      final CredentialService credentialService = sl<CredentialService>();

      // Get stored user credentials
      bool isLogin = await sl<AuthenticationService>().isLogin();
      // var credentials = yourUserCredentialsGetMethod();
      if (!isLogin) return;

      String apiKey = await credentialService.getApiKey ?? "";
      String authToken = await credentialService.getAuthToken ?? "";
      String userId = await credentialService.getUserId ?? "";
      String username = await credentialService.getUserName ?? "";

      // Initialise StreamVideo
      final streamVideo = StreamVideo(apiKey,
          user: User.regular(userId: userId, name: username),
          userToken: authToken,
          pushNotificationManagerProvider:
              StreamVideoPushNotificationManager.create(
            androidPushProvider:
                const StreamVideoPushProvider.firebase(name: "dev"),
            iosPushProvider: const StreamVideoPushProvider.apn(
              name: 'apn',
            ),
            pushParams: const StreamVideoPushParams(
                appName: "testing",
                ios: IOSParams(iconName: 'IconMask'),
                missedCallNotification: NotificationParams(
                    showNotification: true,
                    subtitle: 'Missed Call',
                    callbackText: 'Call Back',
                    isShowCallback: false)),
          ));

      // Observe Declined CallKit event to handle declining the call even when app is terminated
      streamVideo.observeCallDeclinedCallKitEvent();

      // Pass it along to the handler
      await handleRemoteMessage(message);
    } catch (e, stk) {
      log('Error handling remote message: $e');
      log(stk.toString());
    }

    StreamVideo.reset();
  }

  @pragma('vm:entry-point')
  static Future<void> backgroundVoipCallHandler() async {
    WidgetsFlutterBinding.ensureInitialized();

    final CredentialService credentialService = sl<CredentialService>();

    // Get stored user credentials
    bool isLogin = await sl<AuthenticationService>().isLogin();
    // var credentials = yourUserCredentialsGetMethod();
    if (!isLogin) return;

    String apiKey = await credentialService.getApiKey ?? "";
    String authToken = await credentialService.getAuthToken ?? "";
    String userId = await credentialService.getUserId ?? "";
    String username = await credentialService.getUserName ?? "";

    // Initialise StreamVideo
    StreamVideo(
      // ...
      // Make sure you initialise push notification manager
      apiKey,
      user: User.regular(userId: userId, name: username),
      userToken: authToken,
      pushNotificationManagerProvider:
          StreamVideoPushNotificationManager.create(
        iosPushProvider: const StreamVideoPushProvider.apn(
          name: 'apn',
        ),
        androidPushProvider: const StreamVideoPushProvider.firebase(
          name: 'dev',
        ),
        pushParams: const StreamVideoPushParams(
          ios: IOSParams(supportsVideo: true),
        ),
      ),
    );
  }

  static Future<void> handleRemoteMessage(RemoteMessage message) async {
    log("handleRemoteMessage ${message.toMap().toString()}");
    await StreamVideo.instance.handleVoipPushNotification(message.data);
  }
}
