import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:protech_mobile_chat_stream/constants/string_constant.dart';
import 'package:protech_mobile_chat_stream/module/login/cubit/login_cubit.dart';
import 'package:protech_mobile_chat_stream/route/routes.dart';
import 'package:protech_mobile_chat_stream/service/credential_service.dart';
import 'package:protech_mobile_chat_stream/service/database_helper.dart';
import 'package:protech_mobile_chat_stream/service/turms_response.dart';
import 'package:protech_mobile_chat_stream/utils/navigation_service.dart';
import 'package:protech_mobile_chat_stream/utils/service_locator.dart';
import 'package:protech_mobile_chat_stream/utils/string_apis.dart';
import 'package:protech_mobile_chat_stream/widgets/custom_alert_dialog.dart';
import 'package:turms_client_dart/turms_client.dart';

class TurmsService {
  TurmsClient turmsClient = sl<TurmsClient>();
  DatabaseHelper databaseHelper = sl<DatabaseHelper>();
  late MessageService messageService;
  late UserService userService;
  late ConversationService conversationService;
  late NotificationService notificationService;
  late GroupService groupService;
  late SyncService syncService;
  late TurmsDriver driver;

  TurmsService() {
    messageService = turmsClient.messageService;
    userService = turmsClient.userService;
    conversationService = turmsClient.conversationService;
    notificationService = turmsClient.notificationService;
    groupService = turmsClient.groupService;
    syncService = turmsClient.syncService;
    driver = turmsClient.driver;
  }

  /// Pins a conversation for the user.
  ///
  /// This method utilizes the `syncService` to pin the chat associated
  /// with the provided `targetId`. It logs the result, including the
  /// response code and data, for debugging purposes.
  ///
  /// Throws an exception if the pinning operation fails.
  Future<void> pinConversation(
      {required String targetId, bool isGroup = false}) async {
    // syncService.pinChat(targetId:)
    final res = await sl<TurmsClient>()
        .syncService
        .pinChat(targetId: targetId.parseInt64(), isGroup: isGroup);

    log("pin conversation : ${res.code} ${res.data}");
  }

  /// Unpins a conversation for the user.
  ///
  /// This method utilizes the `syncService` to unpin the chat associated
  /// with the provided `targetId`. It logs the result, including the
  /// response code and data, for debugging purposes.
  ///
  /// Throws an exception if the unpinning operation fails.
  Future<void> unPinConversation(
      {required String targetId, bool isGroup = false}) async {
    // syncService.pinChat(targetId:)
    final res = await sl<TurmsClient>()
        .syncService
        .unPinChat(targetId: targetId.parseInt64(), isGroup: isGroup);

    log("unpin conversation : ${res.code} ${res.data}");
  }

  /// Mutes a conversation for the user.
  ///
  /// This method utilizes the `syncService` to mute the chat associated
  /// with the provided `targetId`. It logs the result, including the
  /// response code and data, for debugging purposes.
  ///
  /// Throws an exception if the muting operation fails.
  Future<void> muteConversation(
      {required String targetId, bool isGroup = false}) async {
    // syncService.pinChat(targetId:)
    final res = await sl<TurmsClient>()
        .syncService
        .muteChat(targetId: targetId.parseInt64(), isGroup: isGroup);

    log("mute conversation : ${res.code} ${res.data}");
  }

  /// Unmutes a conversation for the user.
  ///
  /// This method utilizes the `syncService` to unmute the chat associated
  /// with the provided `targetId`. It logs the result, including the
  /// response code and data, for debugging purposes.
  ///
  /// Throws an exception if the unmuting operation fails.
  Future<void> unMuteConversation(
      {required String targetId, bool isGroup = false}) async {
    // syncService.pinChat(targetId:)
    final res = await sl<TurmsClient>()
        .syncService
        .unMuteChat(targetId: targetId.parseInt64(), isGroup: isGroup);

    log("unmute conversation : ${res.code} ${res.data}");
  }

  Future<void> favouriteMessage({required String messageId}) async {
    try {
      final res = await sl<TurmsClient>()
          .syncService
          .favouriteChat(targetId: messageId.parseInt64());

      log("favourite message : ${res.code} ${res.data}");
    } catch (e) {
      log("favourite message error : $e");
    }
  }

  Future<void> unfavouriteMessage({required String messageId}) async {
    try {
      final res = await sl<TurmsClient>()
          .syncService
          .unFavouriteChat(targetId: messageId.parseInt64());

      log("unfavourite message : ${res.code} ${res.data}");
    } catch (e) {
      log("unfavourite message error : $e");
    }
  }

  Future<void> deleteConversation(
      {required String targetId,
      required bool isGroup,
      required DateTime endDate}) async {
    final res = await handleTurmsResponse(() async {
      final res = await sl<TurmsClient>().messageService.deleteMessage(
          deviceType: Platform.isAndroid ? DeviceType.ANDROID : DeviceType.IOS,
          targetIds: [
            DeleteMessageByTargetId(
                targetId: targetId.parseInt64(),
                isGroup: isGroup,
                endDate: endDate.millisecondsSinceEpoch.toInt64())
          ]);
      log("delete conversation : ${res.code} ${res.data}");
      return res.data;
    });
  }

  /// Queries for synchronization transactions.
  ///
  /// This method interacts with the `syncService` to fetch a list of
  /// synchronization transactions. It logs the result, including the
  /// response code and data, for debugging purposes.
  ///
  /// Returns a `Future` containing a list of `SyncTransaction` objects.
  ///
  /// Throws an exception if the query operation fails.
  Future<List<SyncTransaction>?> querySyncTransaction() async {
    final res = await handleTurmsResponse<List<SyncTransaction>>(() async {
      final res = await sl<TurmsClient>().syncService.querySync(ids: []);
      log("query sync transaction : ${res.code} ${res.data}");
      return res.data;
    });

    if (res is TurmsMapSuccessResponse<List<SyncTransaction>>) {
      return res.res;
    }

    if (res is TurmsInvalidErrorResponse<List<SyncTransaction>>) {
      log("query sync transaction failed : ${res.code} ${res.reason}");

      return null;
    }
    return null;
  }

  Future<void> updateSync() async {
    try {
      List<SyncTransaction>? syncList = await querySyncTransaction();

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
    } catch (e) {
      log("Update sync error $e");
    }
  }

  Future<UserInfo?> queryUserProfile(String userId) async {
    final res = await sl<TurmsClient>()
        .userService
        .queryUserProfiles({userId.parseInt64()});
    log("query user profile : ${res.code} ${res.data}");
    if (res.data.isEmpty) {
      return null;
    }
    return res.data.first;
  }

  Future<UserOnlineStatus?> queryUserOnlineStatus(String userId) async {
    final res = await sl<TurmsClient>()
        .userService
        .queryOnlineStatuses({userId.parseInt64()});
    log("query user online status : ${res.code} ${res.data}");
    if (res.data.isEmpty) {
      return null;
    }
    return res.data.first;
  }

  Future<TurmsResponse<T>> handleTurmsResponse<T>(
      Future<T> Function() func) async {
    try {
      T res = await func();
      return TurmsMapSuccessResponse(res: res);
    } catch (e) {
      if (e is ResponseException) {
        log("[handleTurmsResponse][$T] turms response exception: ${e.code} ${e.reason}");
        if (e.code == ResponseStatusCode.clientSessionHasBeenClosed) {
          if (NavigationService.navigatorKey.currentContext != null) {
            log("session has been closed [$T]");
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
            }
          }
        }

        if (e.code == ResponseStatusCode.serverInternalError) {
          if (NavigationService.navigatorKey.currentContext != null) {
            log("server internal error [$T]");
            // ToastUtils.showToast(
            //     context: NavigationService.navigatorKey.currentContext!,
            //     msg:
            //         "Internal Server Error, Please reopen the app and try again.",
            //     type: Type.danger);
          }
        }

        if (e.code == ResponseStatusCode.serverUnavailable) {
          if (NavigationService.navigatorKey.currentContext != null) {
            log("server unavailable [$T]");
            // ToastUtils.showToast(
            //     context: NavigationService.navigatorKey.currentContext!,
            //     msg: "Server Unavailable, Please reopen the app and try again.",
            //     type: Type.danger);
          }
        }

        return TurmsInvalidErrorResponse(
            code: e.code.toString(), reason: e.reason ?? "");
      }
      return TurmsUnknownErrorResponse();
    }
  }
}
