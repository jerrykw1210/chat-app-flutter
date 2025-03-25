import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:fixnum/fixnum.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:get_storage/get_storage.dart';
import 'package:protech_mobile_chat_stream/constants/string_constant.dart';
import 'package:protech_mobile_chat_stream/model/database.dart' as db;
import 'package:protech_mobile_chat_stream/model/message_status_enum.dart';
import 'package:protech_mobile_chat_stream/module/call/screen/call_screen.dart';
import 'package:protech_mobile_chat_stream/module/chat/cubit/chat_cubit.dart';
import 'package:protech_mobile_chat_stream/module/chat/cubit/group_cubit.dart';

import 'package:protech_mobile_chat_stream/module/chat/repository/chat_repository.dart';
import 'package:protech_mobile_chat_stream/module/chat/service/chat_service.dart';
import 'package:protech_mobile_chat_stream/module/feedback/repository/feedback_repository.dart';
import 'package:protech_mobile_chat_stream/module/file/repository/file_repository.dart';
import 'package:protech_mobile_chat_stream/module/forget_password/repository/forget_password_repository.dart';
import 'package:protech_mobile_chat_stream/module/friend/cubit/user_cubit.dart';
import 'package:protech_mobile_chat_stream/module/friend/repository/friend_repository.dart';
import 'package:protech_mobile_chat_stream/module/friend/service/friend_service.dart';
import 'package:protech_mobile_chat_stream/module/general/cubit/connection_status_cubit.dart';
import 'package:protech_mobile_chat_stream/module/invitation_code/repository/verify_invitation_code_repository.dart';
import 'package:protech_mobile_chat_stream/module/language/repository/language_repository.dart';
import 'package:protech_mobile_chat_stream/module/login/cubit/login_cubit.dart';
import 'package:protech_mobile_chat_stream/module/login/repository/login_repository.dart';
import 'package:protech_mobile_chat_stream/module/profile/cubit/profile_cubit.dart';
import 'package:protech_mobile_chat_stream/module/profile/repository/profile_repository.dart';
import 'package:protech_mobile_chat_stream/module/profile/service/profile_service.dart';
import 'package:protech_mobile_chat_stream/route/routes.dart';
import 'package:protech_mobile_chat_stream/service/authentication_service.dart';
import 'package:protech_mobile_chat_stream/service/credential_service.dart';
import 'package:protech_mobile_chat_stream/service/database_helper.dart';
import 'package:protech_mobile_chat_stream/service/endpoint_service.dart';
import 'package:protech_mobile_chat_stream/service/feedback_service.dart';
import 'package:protech_mobile_chat_stream/service/file_service.dart';
import 'package:protech_mobile_chat_stream/service/language_service.dart';
import 'package:protech_mobile_chat_stream/service/stream_service.dart';
import 'package:protech_mobile_chat_stream/service/turms_service.dart';
import 'package:protech_mobile_chat_stream/utils/navigation_service.dart';
import 'package:protech_mobile_chat_stream/utils/notificationBackgroundHandler.dart';
import 'package:protech_mobile_chat_stream/utils/pip_controller.dart';
import 'package:protech_mobile_chat_stream/utils/string_apis.dart';
import 'package:protech_mobile_chat_stream/widgets/custom_alert_dialog.dart';
import 'package:stream_video_flutter/stream_video_flutter.dart' as sv;
import 'package:stream_video_push_notification/stream_video_push_notification.dart';
import 'package:turms_client_dart/turms_client.dart' as turms;
import 'package:drift/drift.dart' as drift;

/// Register singleton instance for GetIt.
///
/// This function registers all the dependencies required for the app.
/// The registered objects are:
/// - [StreamChatClient]
/// - [AppDatabase]
/// - [GetStorage]
/// - [GetStreamService]
/// - [FlutterSecureStorage]
/// - [ChatRepository]
/// - [ChatService]
/// - [ConversationRepository]
/// - [ForgetPasswordRepository]
/// - [LoginRepository]
/// - [VerifyInvitationCodeRepository]
/// - [ProfileService]
/// - [AuthenticationService]
///
/// This function is called in the main function of the app.
///
final sl = GetIt.instance;

/// Initializes and registers singleton instances using GetIt for dependency injection.
///
/// This function sets up lazy singletons for various components of the app,
/// including repositories, services, and utilities. The registered objects are:
///
/// - [AppDatabase]: Manages the local database.
/// - [GetStorage]: Provides persistent storage.
/// - [GetStreamService]: Handles stream-related operations.
/// - [FlutterSecureStorage]: Manages secure storage on both Android and iOS.
/// - [ConversationRepository]: Manages conversation data.
/// - [LoginRepository]: Handles login operations.
/// - [VerifyInvitationCodeRepository]: Manages invitation code verification.
/// - [ChatRepository]: Handles chat-related data.
/// - [ForgetPasswordRepository]: Manages forget password operations.
/// - [AuthenticationService]: Handles authentication processes.
/// - [ProfileService]: Manages user profile operations.
/// - [ChatService]: Handles chat functionalities.
///
Future<void> startupSL() async {
  // sl.registerLazySingleton<StreamChatClient>(() => StreamChatClient(
  //     dotenv.env['GETSTREAM_API_KEY'].toString(),
  //     logLevel: Level.INFO));
  try {
    registerLazySingleton<db.AppDatabase>(() => db.AppDatabase());
    registerLazySingleton<DatabaseHelper>(() => DatabaseHelper());
    registerLazySingleton<GetStorage>(() => GetStorage());
    registerLazySingleton<GetStreamService>(() => GetStreamService());
    registerLazySingleton<FlutterSecureStorage>(() {
      AndroidOptions getAndroidOptions() => const AndroidOptions(
            encryptedSharedPreferences: true,
          );
      IOSOptions getIOSOptions() =>
          const IOSOptions(accessibility: KeychainAccessibility.first_unlock);
      return FlutterSecureStorage(
          aOptions: getAndroidOptions(), iOptions: getIOSOptions());
    });
    //repo
    registerLazySingleton<LoginRepository>(() => LoginRepository());
    registerLazySingleton<VerifyInvitationCodeRepository>(
        () => VerifyInvitationCodeRepository());
    registerLazySingleton<ChatRepository>(() => ChatRepository());
    registerLazySingleton<ForgetPasswordRepository>(
        () => ForgetPasswordRepository());
    registerLazySingleton<ProfileRepository>(() => ProfileRepository());
    registerLazySingleton<FileRepository>(() => FileRepository());
    registerLazySingleton<FeedbackRepository>(() => FeedbackRepository());
    registerLazySingleton<LanguageRepository>(() => LanguageRepository());
    registerLazySingleton<FriendRepository>(() => FriendRepository());
    //service
    registerLazySingleton<AuthenticationService>(() => AuthenticationService());
    registerLazySingleton<ProfileService>(() => ProfileService());
    registerLazySingleton<ChatService>(() => ChatService());
    registerLazySingleton<CredentialService>(() => CredentialService());
    registerLazySingleton<FileService>(() => FileService());
    registerLazySingleton<FeedbackService>(() => FeedbackService());
    // registerLazySingleton<TurmsService>(() => TurmsService());
    registerLazySingleton<LanguageService>(() => LanguageService());
    registerLazySingleton<FriendService>(() => FriendService());
    registerLazySingleton<PipService>(() => PipService());
  } catch (e) {
    log("error when starting service locator $e");
  }
}

void registerLazySingleton<T extends Object>(T Function() factoryFunc) {
  if (!sl.isRegistered<T>()) {
    sl.registerLazySingleton<T>(factoryFunc);
  }
}

/// Initializes and registers a [StreamVideo] client with the provided user credentials.
///
/// This function creates a new instance of [StreamVideo] using the given [user], [userToken],
/// and an optional [apiKey]. If the [apiKey] is not provided, it defaults to the value from
/// environment variables.
///
/// The [StreamVideo] client is configured with verbose logging and push notification management
/// for both Android and iOS platforms. Custom push notification parameters are set, including
/// app name, icon for iOS, and missed call notification details.
///
/// If a [StreamVideo] instance is already registered, it will be unregistered before registering
/// the new instance.
///
/// Throws an exception if the registration fails.
Future<void> startupStreamVideo(
    {required sv.User user, required String userToken, String? apiKey}) async {
  sv.StreamVideo videoclient = sv.StreamVideo(
      apiKey ?? dotenv.env['GETSTREAM_API_KEY'].toString(),
      user: user,
      userToken: userToken,
      options: const sv.StreamVideoOptions(
          logPriority: sv.Priority.none,
          keepConnectionsAliveWhenInBackground: true),
      pushNotificationManagerProvider:
          StreamVideoPushNotificationManager.create(
        androidPushProvider:
            const StreamVideoPushProvider.firebase(name: "dev"),
        iosPushProvider: const StreamVideoPushProvider.apn(
          name: 'apn',
        ),
        registerApnDeviceToken: true,
        backgroundVoipCallHandler:
            NotificationBackgroundHandler.backgroundVoipCallHandler,
        pushParams: const StreamVideoPushParams(
            appName: "testing",
            missedCallNotification: NotificationParams(
                showNotification: true,
                subtitle: 'Missed Call',
                isShowCallback: false,
                callbackText: 'Call Back')),
      ));

  if (sl.isRegistered<sv.StreamVideo>()) {
    await sl.unregister<sv.StreamVideo>();
  }

  sl.registerSingleton<sv.StreamVideo>(videoclient);

  sv.StreamBackgroundService.init(videoclient);
  _checkForIncomingCall();

  String? token = Platform.isAndroid
      ? await FirebaseMessaging.instance.getToken()
      : await FirebaseMessaging.instance.getAPNSToken();

  if (Platform.isIOS) {
    // final voipToken = await FlutterCallkitIncoming.getDevicePushTokenVoIP();

    // sv.StreamVideo.instance.addDevice(
    //     pushToken: token,
    //     pushProvider: sv.PushProvider.apn,
    //     voipToken: false,
    //     pushProviderName: 'apn');

    // sv.StreamVideo.instance.addDevice(
    //     pushToken: voipToken,
    //     pushProvider: sv.PushProvider.apn,
    //     voipToken: true,
    //     pushProviderName: 'apn');
  }

  if (Platform.isAndroid) {
    // sv.StreamVideo.instance.addDevice(
    //     pushToken: token,
    //     pushProvider: sv.PushProvider.firebase,
    //     pushProviderName: 'dev');
  }
}

/// Initializes both Stream Chat and Stream Video services for the given user.
///
/// This method sets up the necessary clients for chat and video functionalities.
/// It first initializes the chat service with the provided `userId`, `userToken`,
/// and optional `apiKey`. Then, it initializes the video service using the given
/// `user`, `userToken`, and optional `apiKey`.
///
/// Throws an exception if any of the service initializations fail.
Future<void> startupGetStream(
    {required String userId,
    required String userToken,
    String? apiKey,
    required sv.User user}) async {
  // await startupStreamChat(userId: userId, userToken: userToken, apiKey: apiKey);
  await startupStreamVideo(user: user, userToken: userToken, apiKey: apiKey);
}

Future<void> startupTurms(
    {required Int64 userId, required String password}) async {
  // if (sl.isRegistered<turms.TurmsClient>()) {
  //   await sl.unregister<turms.TurmsClient>();
  // }

  String turmsEndpoint =
      sl<EndpointService>().getEndpoint(ServiceTypeEnum.turmsUserMobile);

  List<String> parts = turmsEndpoint.split(':');

  String host = parts[0];
  int port = int.parse(parts[1]);

  if (!sl.isRegistered<turms.TurmsClient>()) {
    sl.registerLazySingleton<turms.TurmsClient>(() {
      turms.TurmsClient client =
          turms.TurmsClient(host: host, port: port.toInt());
      return client;
    });
    if (sl.isRegistered<TurmsService>()) {
      await sl.unregister<TurmsService>();
      sl.registerLazySingleton<TurmsService>(() => TurmsService());
    } else {
      sl.registerLazySingleton<TurmsService>(() => TurmsService());
    }
  } else {
    await sl.unregister<turms.TurmsClient>();
    sl.registerLazySingleton<turms.TurmsClient>(() {
      turms.TurmsClient client =
          turms.TurmsClient(host: host, port: port.toInt());
      return client;
    });
    if (sl.isRegistered<TurmsService>()) {
      await sl.unregister<TurmsService>();
      sl.registerLazySingleton<TurmsService>(() => TurmsService());
    } else {
      sl.registerLazySingleton<TurmsService>(() => TurmsService());
    }
  }

  //TurmsClient client = TurmsClient(host: "18.118.34.67", port: 11510);

  sl<turms.TurmsClient>()
      .driver
      .addOnDisconnectedListener(({error, stackTrace}) async {
    final context = NavigationService.navigatorKey.currentContext;
    if (context != null) {
      context
          .read<ConnectionStatusCubit>()
          .showConnectionStatus(Strings.unableToConnectToServer);
    }
    log('onDisconnected: $error $stackTrace');

    await startupSL();

    final CredentialService credentialService = sl<CredentialService>();

    // Get stored user credentials
    bool isLogin = await sl<AuthenticationService>().isLogin();

    if (!isLogin) {
      return;
    }

    while (true) {
      log('reconnecting turms');
      await startupSL();

      final CredentialService credentialService = sl<CredentialService>();

      // Get stored user credentials
      bool isLogin = await sl<AuthenticationService>().isLogin();

      if (!isLogin) break;

      await sl<turms.TurmsClient>()
          .driver
          .connect(host: host, port: port.toInt());
      if (sl<turms.TurmsClient>().driver.isConnected) {
        if (context != null) {
          context.read<ConnectionStatusCubit>().dismissConnectionStatus();
        }
        log('reconnected turms');
        break;
      }

      await Future.delayed(const Duration(seconds: 2));
    }
  });

  sl<turms.TurmsClient>().userService.addOnOnlineListener(() {
    log('onOnline from service locator startup turms');
    // ConnectionStatusManager.dismissConnectionStatus();
    final context = NavigationService.navigatorKey.currentContext;
    if (context != null) {
      sl<DatabaseHelper>().updateLoadingMessageToFailed();
      context.read<ConnectionStatusCubit>().dismissConnectionStatus();
      context.read<UserCubit>().fetchUsers();
      context.read<UserCubit>().getFriendRequest();
      context.read<UserCubit>().getSentFriendRequest();
      context.read<GroupCubit>().fetchGroup();
      context.read<ProfileCubit>().getProfile();
      context.read<ChatCubit>().queryMessages();
      context.read<ChatCubit>().queryGroupMessages();
    }
  });

  // Listen to the offline event
  sl<turms.TurmsClient>().userService.addOnOfflineListener((info) async {
    print(
        'onOffline: ${info.closeStatus}:${info.businessStatus}:${info.reason}');
    String? fcmToken = await FirebaseMessaging.instance.getToken();

    await startupSL();

    final CredentialService credentialService = sl<CredentialService>();

    // Get stored user credentials
    bool isLogin = await sl<AuthenticationService>().isLogin();

    if (!isLogin) return;

    if (info.closeStatus > 500) {
      final context = NavigationService.navigatorKey.currentContext;
      if (context != null) {
        // context.read<LoginCubit>().logout();
        CustomAlertDialog.showGeneralDialog(
            context: NavigationService.navigatorKey.currentContext!,
            title: Strings.youHaveBeenLoggedOut,
            content: Text(Strings.youHaveBeenLoggedOutDesc),
            undismissible: true,
            onPositiveActionPressed: () async {
              await LoginCubit().logout();
              Navigator.of(NavigationService.navigatorKey.currentContext!)
                  .pushNamedAndRemoveUntil(
                      AppPage.invitationCode.routeName, (route) => false);
            });
        return;
      }
      return;
    }

    // relogin
    while (true) {
      log("relogin turms");

      await startupSL();

      final CredentialService credentialService = sl<CredentialService>();

      // Get stored user credentials
      bool isLogin = await sl<AuthenticationService>().isLogin();

      if (!isLogin) break;

      try {
        final res = await sl<turms.TurmsClient>().userService.login(
            userId.toInt64(),
            password: password,
            deviceType: Platform.isAndroid
                ? turms.DeviceType.ANDROID
                : turms.DeviceType.IOS,
            deviceDetails: {"deviceToken": fcmToken ?? ""});

        if (sl<turms.TurmsClient>().userService.isLoggedIn) {
          log("reloggedin turms userId: $userId");
          break;
        }
      } catch (e) {
        if (e is turms.ResponseException) {
          if (e.code ==
              turms.ResponseStatusCode.clientSessionAlreadyEstablished) {
            break;
          }
        }
        log("relogin failed with $e, retrying");
      }

      await Future.delayed(const Duration(seconds: 2));
    }
  });

// Listen to inbound notifications
  sl<turms.TurmsClient>()
      .notificationService
      .addNotificationListener((notification) {
    if (notification.relayedRequest.hasCreateFriendRequestRequest()) {
      NavigationService.navigatorKey.currentContext!
          .read<UserCubit>()
          .getFriendRequest();
    }
    if (notification.relayedRequest.hasUpdateFriendRequestRequest()) {
      NavigationService.navigatorKey.currentContext!
          .read<UserCubit>()
          .fetchUsers();
    }

    if (notification.relayedRequest.hasUpdateMessageRequest()) {
      log("pin or unpin ${notification.relayedRequest.updateMessageRequest.toPin}");

      if (notification.relayedRequest.updateMessageRequest.hasToPin()) {
        (sl<db.AppDatabase>().select(sl<db.AppDatabase>().messages)
              ..where((message) => message.id.equals(
                    notification.relayedRequest.updateMessageRequest.messageId
                        .toString(),
                  )))
            .getSingleOrNull()
            .then((message) {
          sl<DatabaseHelper>().updateMessage(message!.id.toString(),
              isPin: notification.relayedRequest.updateMessageRequest.toPin);
        });
      }
      // else {
      //   (sl<db.AppDatabase>().select(sl<db.AppDatabase>().messages)
      //         ..where((message) => message.id.equals(
      //               notification.relayedRequest.updateMessageRequest.messageId
      //                   .toString(),
      //             )))
      //       .getSingleOrNull()
      //       .then((message) {
      //     sl<DatabaseHelper>().updateMessage(message!.id.toString(),
      //         text: notification.relayedRequest.updateMessageRequest.text,
      //         messageStatus: MessageStatusEnum.sent);
      //   });
      // }
    }

    if (notification.relayedRequest.hasCreateGroupJoinRequestRequest()) {
      NavigationService.navigatorKey.currentContext!
          .read<GroupCubit>()
          .queryJoinGroupRequest(notification
              .relayedRequest.createGroupJoinRequestRequest.groupId);
    }
    if (notification.relayedRequest.hasCreateGroupMembersRequest()) {
      NavigationService.navigatorKey.currentContext!
          .read<GroupCubit>()
          .getGroupMember(
              groupId: notification
                  .relayedRequest.createGroupJoinRequestRequest.groupId);
    }

    if (notification.relayedRequest.hasUpdateConversationSettingsRequest()) {
      // update conversation settings request
      NavigationService.navigatorKey.currentContext!
          .read<GroupCubit>()
          .fetchGroupSettings(notification
              .relayedRequest.updateConversationSettingsRequest.groupId);
    }
    if (notification.relayedRequest.hasUpdateMessageRequest() &&
        !notification.relayedRequest.updateMessageRequest.hasRecallDate() &&
        !notification.relayedRequest.updateMessageRequest.hasToPin()) {
      sl<DatabaseHelper>()
          .updateMessage(
              notification.relayedRequest.updateMessageRequest.messageId
                  .toString(),
              text: notification.relayedRequest.updateMessageRequest.text,
              messageType: "TEXT_TYPE",
              // isPin: editedMessage.isPinned,
              messageStatus: MessageStatusEnum.sent)
          .then((_) {
        (sl<db.AppDatabase>()
            .select(sl<db.AppDatabase>().messages)
            .get()
            .then((messages) {
          List<db.Message> messagesToEdit = messages.where((msg) {
            if (msg.parentMessage != null) {
              return jsonDecode(msg.parentMessage.toString())['id'] ==
                  notification.relayedRequest.updateMessageRequest.messageId
                      .toString();
            }
            return false;
          }).toList();
          for (var message in messagesToEdit) {
            log("message parent msg to edit ${message.parentMessage}");
            sl<DatabaseHelper>().updateMessage(message.id.toString(),
                parentMessage: jsonEncode(messages.firstWhere((message) =>
                    message.id ==
                    notification.relayedRequest.updateMessageRequest.messageId
                        .toString())),
                messageType: "TEXT_TYPE");
          }
        }));
      });
    }
    if (notification.relayedRequest.updateMessageRequest.hasRecallDate()) {
      (sl<db.AppDatabase>().select(sl<db.AppDatabase>().messages)
            ..where((message) => message.id.equals(
                  notification.relayedRequest.updateMessageRequest.messageId
                      .toString(),
                )))
          .getSingleOrNull()
          .then((recalledmsg) {
        if (recalledmsg != null) {
          if (recalledmsg.id != null) {
            sl<DatabaseHelper>()
                .updateMessage(recalledmsg.id.toString(),
                    text: Strings.messageHasBeenRecalled,
                    parentMessage: null,
                    extraInfo: jsonEncode({'isDeleted': true}),
                    messageType: "TEXT_TYPE")
                .then((_) {
              (sl<db.AppDatabase>()
                  .select(sl<db.AppDatabase>().messages)
                  .get()
                  .then((messages) {
                List<db.Message> messagesToRecall = messages.where((msg) {
                  if (msg.parentMessage != null) {
                    return jsonDecode(msg.parentMessage.toString())['id'] ==
                        recalledmsg.id;
                  }
                  return false;
                }).toList();
                for (var message in messagesToRecall) {
                  final recalledParentMsg = recalledmsg.copyWith(
                      content: Strings.messageHasBeenRecalled);

                  sl<DatabaseHelper>().updateMessage(message.id.toString(),
                      parentMessage: jsonEncode(recalledParentMsg),
                      messageType: "TEXT_TYPE",
                      messageStatus: MessageStatusEnum.sent);
                }
              }));
            });
          }
        }
      });
    }
    if (notification.relayedRequest.hasDeleteGroupMembersRequest()) {
      if (NavigationService.navigatorKey.currentContext != null) {
        NavigationService.navigatorKey.currentContext!
            .read<GroupCubit>()
            .getGroupMember(
                groupId: notification
                    .relayedRequest.deleteGroupMembersRequest.groupId);
      }
    }
    if (notification.relayedRequest.hasUpdateGroupRequest()) {
      if (NavigationService.navigatorKey.currentContext != null) {
        NavigationService.navigatorKey.currentContext!
            .read<GroupCubit>()
            .getGroupInfo(
                notification.relayedRequest.updateGroupRequest.groupId);
        sl<DatabaseHelper>().updateGroupName(
          notification.relayedRequest.updateGroupRequest.name,
          notification.relayedRequest.updateGroupRequest.groupId.toString(),
        );
      }
    }

    // if(notification.relayedRequest.hasCreateGroupMembersRequest()){
    // when admin add user to group
    // }
    if (notification.relayedRequest.hasDeleteRelationshipRequest()) {
      sl<DatabaseHelper>().updateRelationship(
        "r_${notification.relayedRequest.deleteRelationshipRequest.userId}_${sl<CredentialService>().turmsId}",
        "deleted",
      );
    }
    return print(
        'onNotification: Receive a notification from other users or server: $notification \br 123');
  });
  List<db.Conversation> localConversations = await sl<DatabaseHelper>()
      .getOwnConversation(sl<CredentialService>().turmsId ?? "");

// Listen to inbound messages
  sl<turms.TurmsClient>().messageService.addMessageListener((message, _) async {
    String myId = sl<CredentialService>().turmsId ?? "0";
    log("onMessage: $message");
    db.Conversation? conversation = await sl<DatabaseHelper>().getConversation(
        message.hasGroupId()
            ? message.groupId != Int64(0)
                ? DatabaseHelper.conversationId(
                    targetId: message.groupId.toString(), myId: myId)
                : DatabaseHelper.conversationId(
                    targetId: message.recipientId.toString() == myId
                        ? message.senderId.toString()
                        : message.recipientId.toString(),
                    myId: myId)
            : DatabaseHelper.conversationId(
                targetId: message.recipientId.toString() == myId
                    ? message.senderId.toString()
                    : message.recipientId.toString(),
                myId: myId));

    log("have conversation already?: $conversation");

    if (conversation == null) {
      if (message.hasGroupId() && message.groupId != Int64(0)) {
        String friendId = message.groupId.toString();
        final groupMemberRes = await sl<turms.TurmsClient>()
            .groupService
            .queryGroupMembers(message.groupId);
        List<String> membersId = [];
        if (groupMemberRes.data?.groupMembers.isNotEmpty ?? false) {
          membersId = groupMemberRes.data!.groupMembers
              .map((e) => e.userId.toString())
              .toList();
        }

        final groupDatas = await sl<turms.TurmsClient>()
            .groupService
            .queryGroups({message.groupId});

        final groupData =
            groupDatas.data.isEmpty ? null : groupDatas.data.first;

        await sl<DatabaseHelper>().upsertConversation(
            friendId: friendId,
            members: membersId,
            isGroup: message.groupId != 0 ? true : false,
            targetId: message.groupId.toString(),
            ownerId:
                groupData?.ownerId.toString() ?? message.recipientId.toString(),
            title: groupData?.name ?? friendId,
            lastMessageDate: DateTime.fromMillisecondsSinceEpoch(
                message.deliveryDate.toInt()));

        await NavigationService.navigatorKey.currentContext!
            .read<GroupCubit>()
            .fetchGroupSettings(message.groupId);
      } else {
        String friendId =
            sl<CredentialService>().turmsId!.parseInt64() == message.senderId
                ? message.recipientId.toString()
                : message.senderId.toString();

        turms.UserInfo? friendInfo =
            await sl<TurmsService>().queryUserProfile(friendId);

        await sl<DatabaseHelper>().upsertConversation(
            friendId: friendId,
            members: [friendId, sl<CredentialService>().turmsId!],
            isGroup: message.groupId != 0 ? true : false,
            targetId: friendId,
            ownerId: sl<CredentialService>().turmsId!,
            title: friendInfo?.name ?? friendId,
            lastMessageDate: DateTime.fromMillisecondsSinceEpoch(
                message.deliveryDate.toInt()));
      }

      // sl<AppDatabase>().into(sl<AppDatabase>().conversations).insert(
      //     ConversationsCompanion(
      //         id: drift.Value(
      //             "c_${message.senderId}_${sl<turms.TurmsClient>().userService.userInfo!.userId}"),
      //         title: drift.Value(message.senderId.toString()),
      //         members: drift.Value(jsonEncode([
      //           message.senderId.toString(),
      //           sl<turms.TurmsClient>().userService.userInfo!.userId.toString()
      //         ]))));
    }

    log("received message ${message.url}, ${message.type}");

    if (!message.hasRecallDate()) {
      sl<DatabaseHelper>().updateConversationLastMessageDate(
        message.hasGroupId() && message.groupId != Int64(0)
            ? DatabaseHelper.conversationId(
                targetId: message.groupId.toString(), myId: myId)
            : DatabaseHelper.conversationId(
                targetId: message.recipientId.toString() == myId
                    ? message.senderId.toString()
                    : message.recipientId.toString(),
                myId: myId),
        lastMessageDate:
            DateTime.fromMillisecondsSinceEpoch(message.deliveryDate.toInt()),
      );
    }

    if (message.url.isNotEmpty &&
        !message.hasRecallDate() &&
        message.type != turms.MessageType.TEXT_TYPE) {
      //  AttachmentModel url = AttachmentModel.fromJson(jsonDecode(message.url[0]));
      //   url.localPath = "${Helper.directory?.path}/"
      //   final updateUrl = AttachmentModel.fromJson(jsonDecode(message.url[0])).localPath;
      sl<DatabaseHelper>().upsertMessage(
          message: turms.Message(
              id: message.id.toInt64(),
              text: message.text,
              recipientId: message.recipientId.toInt64(),
              senderId: message.senderId.toInt64(),
              groupId: message.groupId,
              type: message.type,
              url: message.url,
              parentConversationId: message.parentConversationId,
              deliveryDate: message.deliveryDate,
              extraInfo: message.extraInfo),
          receiveMessage: true);
    } else if (message.text != "" && !message.hasRecallDate()) {
      if (message.parentConversationId != 0) {
        db.Message parentMessage = await (sl<db.AppDatabase>().messages.select()
              ..where((dbMessage) =>
                  dbMessage.id.equals(message.parentConversationId.toString())))
            .getSingle();
        log("service locator parent message $parentMessage");
        sl<DatabaseHelper>().upsertMessage(
            message: turms.Message(
                id: message.id.toInt64(),
                text: message.text,
                recipientId: message.recipientId.toInt64(),
                senderId: message.senderId.toInt64(),
                groupId: message.groupId,
                type: message.type,
                parentConversationId: message.parentConversationId,
                deliveryDate: message.deliveryDate,
                extraInfo: message.extraInfo),
            parentMessage: jsonEncode(parentMessage),
            receiveMessage: true);
      } else {
        sl<DatabaseHelper>().upsertMessage(
            message: turms.Message(
                id: message.id.toInt64(),
                text: message.text,
                recipientId: message.recipientId.toInt64(),
                senderId: message.senderId.toInt64(),
                groupId: message.groupId,
                type: message.type,
                parentConversationId: message.parentConversationId,
                deliveryDate: message.deliveryDate,
                extraInfo: message.extraInfo),
            receiveMessage: true);
      }

      // sl<DatabaseHelper>().updateConversationLastMessageDate(
      //   message.hasGroupId()
      //       ? DatabaseHelper.conversationId(
      //           targetId: message.groupId.toString(), myId: myId)
      //       : DatabaseHelper.conversationId(
      //           targetId: message.recipientId.toString() == myId
      //               ? message.senderId.toString()
      //               : message.recipientId.toString(),
      //           myId: myId),
      //   lastMessageDate:
      //       DateTime.fromMillisecondsSinceEpoch(message.deliveryDate.toInt()),
      // );
    }
    if (_.recalledMessageIds.isNotEmpty) {
      log("message recalled ${_.recalledMessageIds} ${message.id}");
      sl<DatabaseHelper>().upsertMessage(
          message: turms.Message(
            id: message.id.toInt64(),
            text: "This message has been recalled",
            recipientId: message.recipientId.toInt64(),
            senderId: message.senderId.toInt64(),
            groupId: message.groupId,
            deliveryDate: message.deliveryDate,
            type: message.type,
          ),
          receiveMessage: true);
      // if (message.type == turms.MessageType.IMAGE_TYPE) {
      //   sl<DatabaseHelper>().deleteMessage(message.id.toString());
      // }
    }
    return print(
        'onMessage: Receive a message from other users or server: $message $_');
  });

  final userService = sl<turms.TurmsClient>().userService;
  if (!userService.isLoggedIn) {
    try {
      String? fcmToken = await FirebaseMessaging.instance.getToken();
      log("user $userId, password $password");
      final res = await userService.login(userId.toInt64(),
          password: password,
          deviceType: Platform.isAndroid
              ? turms.DeviceType.ANDROID
              : turms.DeviceType.IOS,
          deviceDetails: {"deviceToken": fcmToken ?? ""});
      log("login res $res");
    } catch (e) {
      log('error turms $e');
    }
    //sl<turms.TurmsClient>().syncService.querySync();
    //userService.login(userId, password: password);
  }

  log("is turms client logged in? ${userService.isLoggedIn}");

  if (userService.isLoggedIn) {
    final context = NavigationService.navigatorKey.currentContext;
    sl<TurmsService>().updateSync();
  }

  // final users = (await client.userService.queryNearbyUsers(
  //         35.792657, 139.667651,
  //         maxCount: 10, maxDistance: 1000))
  //     .data;
  // print('nearby users: $users');

  // final msgId = (await client.messageService.sendMessage(
  //         false, Int64(7332388649234522112),
  //         text: 'Hello Turms from ding', burnAfter: 30))
  //     .data;
  // print('message $msgId has been sent');

  // final conversationMessage = await client.messageService.queryMessages(
  //     fromIds: Set()..add(Int64(7332388649234522112)), areGroupMessages: false);

  // log("messages $conversationMessage");

  // final groupId = (await client.groupService.createGroup(
  //         'Turms Developers Group',
  //         announcement:
  //             'This is a group for the developers who are interested in Turms',
  //         intro: 'nope'))
  //     .data;
  // print('group $groupId has been created');
}

/// Disconnects and disposes of the Stream services.
///
/// This function calls the `disconnect` method on the `GetStreamService` to cleanly
/// disconnect the user and release resources associated with the Stream Chat and
/// Stream Video services. It is typically used during app shutdown or when the user
/// logs out to ensure all connections are properly terminated.
Future<void> disposeGetStream() async {
  // await sl<GetStreamService>().disconnect();
  await sl<sv.StreamVideo>().disconnect();
  await sl<sv.StreamVideo>().dispose();
  await sv.StreamVideo.instance.disconnect();
  await sv.StreamVideo.instance.dispose();
  await sv.StreamVideo.reset();
}

/// Initializes and registers an [EndpointService] with the provided service URL map.
///
/// This method first retrieves the service URL map from the [CredentialService] and
/// then registers an [EndpointService] with the decoded service URL map using the
/// [ServiceLocator]. It is typically used during app startup to initialize the
/// endpoint service.
///
/// Throws an exception if the service URL map cannot be retrieved or decoded.
Future<void> startupEndpointService() async {
  try {
    String? serviceUrlMap = await sl<CredentialService>().getServiceUrlMap;

    Map<String, dynamic> decodedServiceURLMap = jsonDecode(serviceUrlMap!);

    if (sl.isRegistered<EndpointService>()) {
      await sl.unregister<EndpointService>();
    }

    sl.registerLazySingleton<EndpointService>(
        () => EndpointService(decodedServiceURLMap["data"]["serviceURLMap"]));
  } catch (e) {
    throw Exception(e);
  }
}

Future<bool> _checkForIncomingCall() async {
  final activeCalls =
      await sv.StreamVideo.instance.pushNotificationManager?.activeCalls();
  print("consumeIncomingCall for call $activeCalls");
  if (activeCalls == null || activeCalls.isEmpty) return false;

  final callResult = await sv.StreamVideo.instance.consumeIncomingCall(
    uuid: activeCalls.first.uuid!,
    cid: activeCalls.first.callCid!,
  );

  return callResult.fold(
    success: (result) async {
      final call = result.data;
      await call.accept();
      // Use navigatorKey to handle navigation globally
      NavigationService.navigatorKey.currentState?.pushAndRemoveUntil(
          MaterialPageRoute(
              builder: (context) =>
                  CallScreen(call: call, callOptions: call.connectOptions),
              settings: RouteSettings(name: AppPage.call.routeName)),
          (route) =>
              route.isCurrent && route.settings.name == AppPage.call.routeName
                  ? false
                  : true);
      return true; // Call was handled
    },
    failure: (error) {
      debugPrint('Error accepting call: $error');
      return false;
    },
  );
}
