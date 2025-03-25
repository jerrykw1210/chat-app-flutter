import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:drift/drift.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:protech_mobile_chat_stream/constants/storagekey_constants.dart';
import 'package:protech_mobile_chat_stream/model/database.dart';
import 'package:protech_mobile_chat_stream/module/call/screen/call_screen.dart';
import 'package:protech_mobile_chat_stream/module/chat/cubit/audio_player_cubit.dart';
import 'package:protech_mobile_chat_stream/module/chat/cubit/chat_cubit.dart';
import 'package:protech_mobile_chat_stream/module/chat/cubit/chat_trigger_cubit.dart';
import 'package:protech_mobile_chat_stream/module/chat/cubit/group_cubit.dart';
import 'package:protech_mobile_chat_stream/module/chat/cubit/group_permission_cubit.dart';
import 'package:protech_mobile_chat_stream/module/chat/cubit/sticker_cubit.dart';
import 'package:protech_mobile_chat_stream/module/conversation/cubit/conversation_cubit.dart';
import 'package:protech_mobile_chat_stream/module/feedback/cubit/feedback_cubit.dart';
import 'package:protech_mobile_chat_stream/module/file/cubit/file_cubit.dart';
import 'package:protech_mobile_chat_stream/module/forget_password/cubit/forget_password_cubit.dart';
import 'package:protech_mobile_chat_stream/module/friend/cubit/user_cubit.dart';
import 'package:protech_mobile_chat_stream/module/general/cubit/connection_status_cubit.dart';
import 'package:protech_mobile_chat_stream/module/general/cubit/country_picker_cubit.dart';
import 'package:protech_mobile_chat_stream/module/general/cubit/language_cubit.dart';
import 'package:protech_mobile_chat_stream/module/general/cubit/navigator_cubit.dart';
import 'package:protech_mobile_chat_stream/module/general/cubit/password_cubit.dart';
import 'package:protech_mobile_chat_stream/module/invitation_code/cubit/verify_invitation_code_cubit.dart';
import 'package:protech_mobile_chat_stream/module/profile/cubit/profile_cubit.dart';
import 'package:protech_mobile_chat_stream/module/login/cubit/login_cubit.dart';
import 'package:protech_mobile_chat_stream/module/profile/cubit/settings_cubit.dart';
import 'package:protech_mobile_chat_stream/module/register/cubit/register_cubit.dart';
import 'package:protech_mobile_chat_stream/module/search/cubit/search_cubit.dart';
import 'package:protech_mobile_chat_stream/module/webview/cubit/toggle_webview_cubit.dart';
import 'package:protech_mobile_chat_stream/route/routes.dart';
import 'package:protech_mobile_chat_stream/service/authentication_service.dart';
import 'package:protech_mobile_chat_stream/service/credential_service.dart';
import 'package:protech_mobile_chat_stream/service/database_helper.dart';
import 'package:protech_mobile_chat_stream/service/notification_handler.dart';
import 'package:protech_mobile_chat_stream/splashscreen.dart';
import 'package:protech_mobile_chat_stream/utils/colors.dart';
import 'package:protech_mobile_chat_stream/utils/device_info.dart';
import 'package:protech_mobile_chat_stream/utils/language.dart';
import 'package:protech_mobile_chat_stream/utils/helper.dart';
import 'package:protech_mobile_chat_stream/utils/locale.dart';
import 'package:protech_mobile_chat_stream/utils/my_navigator_observer.dart';
import 'package:protech_mobile_chat_stream/utils/navigation_service.dart';
import 'package:protech_mobile_chat_stream/utils/service_locator.dart';
import 'package:protech_mobile_chat_stream/utils/shared_preferences.dart';
import 'package:stream_video_flutter/stream_video_flutter.dart';
import 'package:stream_video_push_notification/stream_video_push_notification.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await dotenv.load(fileName: "lib/.env");
  await PrefsStorage.init();
  await GetStorage.init();
  await DeviceInfoClass.init();
  await initializeDateFormatting('en_US', null); // Initialize locale here
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // await AwesomeNotifications().setListeners(
  //     onActionReceivedMethod: NotificationController.onActionReceivedMethod,
  //     onNotificationCreatedMethod:
  //         NotificationController.onNotificationCreatedMethod,
  //     onNotificationDisplayedMethod:
  //         NotificationController.onNotificationDisplayedMethod,
  //     onDismissActionReceivedMethod:
  //         NotificationController.onDismissActionReceivedMethod);

  NotificationController.initialize();

  await FirebaseMessaging.instance.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  if (Platform.isAndroid) {
    String? token = await FirebaseMessaging.instance.getToken();
    log("android push token $token");
  } else {
    // String? token = await FirebaseMessaging.instance.getAPNSToken();
    // String? token2 = await FirebaseMessaging.instance.getToken();
    // log("apple push token $token");
    // log("fcm push token $token2");
    // initializeVoIP();
  }

  FirebaseMessaging.onMessage.listen((RemoteMessage msg) async {
    log("received fcm push msg ${msg.toMap()}");

    if (msg.data.containsKey("message")) {
      Conversation? conversation;

      Map<String, dynamic> messageData = jsonDecode(msg.data["message"]);

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

      String? title = conversation?.title ?? msg.notification?.title;

      String? body = msg.notification?.body;

      if (title != null && body != null && senderId != myId) {
        NotificationController.display(title: title, body: body, payload: "");
      }

      // log("msg data ${messageData}");
    }

    if (sl.isRegistered<StreamVideo>()) {
      sl<StreamVideo>().handleVoipPushNotification(msg.data);
    }

    // NotificationController.displayFromFcm(msg);
  });

  FirebaseMessaging.onBackgroundMessage(
      NotificationController.firebaseMessagingBackgroundHandler);

  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage msg) {
    log("on Message Opened App msg ${msg.notification}");
  });

  if (Platform.isIOS) {
    MethodChannel platform =
        const MethodChannel('my.com.prochat.chat.pushnotifications');

    platform.setMethodCallHandler(
        NotificationController.handlePushNotificationFromNative);
  }

  await Helper.initializeDirectory();

  await startupSL();

  final FlutterSecureStorage storage = sl<FlutterSecureStorage>();
  //storage.delete(key: StoragekeyConstants.languageKey);
  String? storedLanguage =
      await storage.read(key: StoragekeyConstants.languageKey);
  List<String> languageCodes =
      storedLanguage != null && storedLanguage.isNotEmpty
          ? (jsonDecode(storedLanguage)).cast<String>()
          : [];
  List<Locale> languages = [];

  if (languageCodes.isEmpty) {
    languageCodes = ["en", "zh", "ms"];
    await storage.write(
        key: StoragekeyConstants.languageKey, value: jsonEncode(languageCodes));
  }
  log("stored code $languageCodes");
  languages = languageCodes.map((e) => Locale(e)).toList();
  log("languages in main $languages");

  //turms.UserService userService = sl<turms.UserService>();

  //client.activate();
  // await startupTurms(userId: 7296359814052372480, password: "123123");

  // client.activate();

  // String id = await _addConversation("title");

  // await _addMessage(id, "hi");

  // await fetch();
  // startupStreamVideo(
  //     user: sv.User.regular(userId: "mrpotato", name: "Mr Potato"),
  //     userToken:
  //         "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoibXJwb3RhdG8ifQ.7j5ou59rXqdXYX1F7Q3KTfQFW_lcsnBe2bc9tJYMahs");
  // await GetStreamService().connectUserForChat();

  runApp(EasyLocalization(
      assetLoader: LanguageClass(),
      supportedLocales: LanguageLocale.supportedLocales,
      path: Helper.directory?.path ?? "",
      fallbackLocale: const Locale('en'),
      child: const MainApp()));
}

// final StompClient client = StompClient(
//     config: StompConfig(
//         url: "http://192.168.0.136:8083/connect",
//         useSockJS: true,
//         onStompError: (data) {
//           log("stomp error");
//         },
//         onWebSocketError: (data) {
//           log("stomp socket error $data");
//         },
//         onConnect: _onConnect));

// Future<void> _onConnect(StompFrame frame) async {
//   log("connected");
//   client.subscribe(
//       destination: "/topic/eugene",
//       callback: (StompFrame frame) {
//         log("data ${frame.body}");
//       });
// }

Future<void> initializeVoIP() async {
  final voipToken = await FlutterCallkitIncoming.getDevicePushTokenVoIP();
  log("voip token $voipToken");
}

Future<String> _addConversation(String title) async {
  AppDatabase db = sl<AppDatabase>();
  final id = Helper.generateUUID(); // Generate a new UUID
  await db.into(db.conversations).insert(ConversationsCompanion(
        id: Value(id),
        title: Value(title),
      ));

  return id;
}

Future<void> _addMessage(String conversationId, String content) async {
  AppDatabase db = sl<AppDatabase>();
  final id = Helper.generateUUID(); // Generate a new UUID for the message
  await db.into(db.messages).insert(MessagesCompanion(
        id: Value(id),
        conversationId: Value(conversationId),
        content: Value(content),
      ));
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});
  static void restartApp(BuildContext context) {
    context.findAncestorStateOfType<_MainAppState>()?.restart();
  }

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  Key key = UniqueKey();

  void restart() {
    setState(() => key = UniqueKey());
  }

  @override
  void initState() {
    super.initState();
    //_tryConsumingIncomingCallFromTerminatedState();
  }

  void _tryConsumingIncomingCallFromTerminatedState() {
    // This is only relevant for Android.
    if (CurrentPlatform.isIos) return;
    if (NavigationService.navigatorKey.currentContext == null) {
      // App is not running yet. Postpone consuming after app is in the foreground
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        _consumeIncomingCall();
      });
    } else {
      // no-op. If the app is already running we'll handle it via events
    }
  }

  Future<void> _consumeIncomingCall() async {
    //final CredentialService credentialService = sl<CredentialService>();

    // Get stored user credentials
    //bool isLogin = await sl<AuthenticationService>().isLogin();
    // var credentials = yourUserCredentialsGetMethod();
    //if (!isLogin) return;

    // String apiKey = await credentialService.getApiKey ?? "";
    // String authToken = await credentialService.getAuthToken ?? "";
    // String userId = await credentialService.getUserId ?? "";
    // String username = await credentialService.getUserName ?? "";

    final calls =
        await sl<StreamVideo>().pushNotificationManager?.activeCalls();
    if (calls == null || calls.isEmpty) return;

    final callResult = await sl<StreamVideo>().consumeIncomingCall(
      uuid: calls.first.uuid!,
      cid: calls.first.callCid!,
    );
    callResult.fold(success: (result) async {
      final call = result.data;

      await call.accept();
      //Navigate to call screen <---- IMPLEMENT NAVIGATION HERE
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
              builder: (context) =>
                  CallScreen(call: call, callOptions: call.connectOptions),
              settings: RouteSettings(name: AppPage.call.routeName)),
          (route) =>
              route.isCurrent && route.settings.name == AppPage.call.routeName
                  ? false
                  : true);
    }, failure: (error) {
      debugPrint('Error consuming incoming call: $error');
    });
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    log("supported ${context.supportedLocales}");
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => ConversationCubit()),
        BlocProvider(create: (context) => UserCubit()),
        BlocProvider(create: (context) => ChatTriggerCubit()),
        BlocProvider(create: (context) => ChatCubit()),
        BlocProvider(create: (context) => GroupCubit()),
        BlocProvider(create: (context) => CountryPickerCubit()),
        BlocProvider(create: (context) => ProfileCubit()),
        BlocProvider(create: (context) => LanguageCubit()),
        BlocProvider(create: (context) => LoginCubit()),
        BlocProvider(create: (context) => RegisterCubit()),
        BlocProvider(create: (context) => SearchCubit()),
        BlocProvider(create: (context) => VerifyInvitationCodeCubit()),
        BlocProvider(create: (context) => ForgetPasswordCubit()),
        BlocProvider(create: (context) => PasswordCubit()),
        BlocProvider(create: (context) => FileCubit()),
        BlocProvider(create: (context) => FeedbackCubit()),
        BlocProvider(create: (context) => SettingsCubit()),
        BlocProvider(create: (context) => GroupPermissionCubit()),
        BlocProvider(create: (context) => StickerCubit()),
        BlocProvider(create: (context) => ToggleWebviewCubit()),
        BlocProvider(create: (context) => ConnectionStatusCubit()),
        BlocProvider(create: (context) => NavigatorCubit()),
        BlocProvider(create: (context) => AudioPlayerCubit()),
      ],
      child: BlocListener<LanguageCubit, LanguageState>(
        listenWhen: (previous, current) =>
            current.languages.isNotEmpty &&
            previous.languages.length != current.languages.length,
        listener: (context, state) {
          log("langua ${state.languages}");
          if (state.languages.isNotEmpty) {
            StreamVideo.reset();

            MainApp.restartApp(context);
          }
        },
        child: BlocBuilder<LanguageCubit, LanguageState>(
          builder: (context, state) {
            log("state language ${state.languages}");
            return MaterialApp(
              navigatorKey: NavigationService.navigatorKey,
              key: key,
              debugShowCheckedModeBanner: false,
              home: const SplashScreen(),
              routes: Routes.routes,
              localizationsDelegates: context.localizationDelegates,
              supportedLocales: context.supportedLocales,
              locale: context.locale,
              navigatorObservers: [MyNavigatorObserver()],
              theme: ThemeData(
                  useMaterial3: true,
                  fontFamily: 'Roboto',
                  brightness: Brightness.light,
                  primaryColor: const Color.fromRGBO(23, 116, 247, 1),
                  primaryColorLight: const Color.fromRGBO(23, 116, 247, 1),
                  colorScheme: const ColorScheme.light(
                      primary: Color.fromRGBO(23, 116, 247, 1)),
                  dividerColor: Colors.transparent,
                  dialogBackgroundColor: Colors.white,
                  dialogTheme: DialogTheme(
                      backgroundColor: Colors.white,
                      surfaceTintColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12))),
                  bottomSheetTheme: const BottomSheetThemeData(
                    backgroundColor: Colors.white,
                    surfaceTintColor: Colors.transparent,
                  ),
                  listTileTheme: const ListTileThemeData(
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                  ),
                  cardTheme: const CardTheme(
                    color: Colors.white,
                    surfaceTintColor: Colors.transparent,
                  ),
                  inputDecorationTheme: const InputDecorationTheme(
                      fillColor: Colors.white,
                      filled: true,
                      isDense: true,
                      labelStyle: TextStyle(
                          fontSize: 16,
                          fontFamily: "Inter",
                          fontWeight: FontWeight.w400,
                          color: Color.fromRGBO(102, 112, 133, 1)),
                      hintStyle: TextStyle(
                          fontSize: 16,
                          fontFamily: "Inter",
                          fontWeight: FontWeight.w400,
                          color: Color.fromRGBO(102, 112, 133, 1)),
                      outlineBorder:
                          BorderSide(color: Color.fromRGBO(208, 213, 221, 1)),
                      enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Color.fromRGBO(208, 213, 221, 1)),
                          borderRadius: BorderRadius.all(Radius.circular(8))),
                      border: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Color.fromRGBO(208, 213, 221, 1)),
                          borderRadius: BorderRadius.all(Radius.circular(8))),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Color.fromRGBO(208, 213, 221, 1)),
                          borderRadius: BorderRadius.all(Radius.circular(8)))),
                  elevatedButtonTheme: ElevatedButtonThemeData(
                      style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color.fromRGBO(23, 116, 247, 1),
                          iconColor: Colors.white,
                          shadowColor: const Color.fromRGBO(16, 24, 40, 0.18),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                              side: const BorderSide(
                                  color: Color.fromRGBO(208, 213, 221, 1))))),
                  scaffoldBackgroundColor:
                      const Color.fromRGBO(242, 244, 247, 1),
                  dividerTheme:
                      const DividerThemeData(color: AppColor.dividerColor),
                  appBarTheme: const AppBarTheme(
                      // iconTheme: IconThemeData(
                      //   color: AppColor
                      //       .DarkModeCardColor, //change your color here
                      // ),
                      iconTheme: IconThemeData(color: Colors.white),
                      backgroundColor: Color.fromRGBO(23, 116, 247, 1),
                      titleTextStyle:
                          TextStyle(color: Colors.white, fontSize: 20),
                      elevation: 0,
                      centerTitle: false,
                      surfaceTintColor: Colors.transparent,
                      systemOverlayStyle: SystemUiOverlayStyle.dark)),
              builder: (context, child) => child!,
            );
          },
        ),
      ),
    );
  }
}
