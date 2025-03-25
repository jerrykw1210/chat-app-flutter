import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:fixnum/fixnum.dart';
import 'package:protech_mobile_chat_stream/constants/string_constant.dart';
import 'package:protech_mobile_chat_stream/model/database.dart' as db;
import 'package:protech_mobile_chat_stream/module/friend/repository/friend_repository.dart';
import 'package:protech_mobile_chat_stream/service/credential_service.dart';
import 'package:protech_mobile_chat_stream/service/data.dart';
import 'package:protech_mobile_chat_stream/service/database_helper.dart';
import 'package:protech_mobile_chat_stream/service/turms_response.dart';
import 'package:protech_mobile_chat_stream/service/turms_service.dart';
import 'package:protech_mobile_chat_stream/utils/service_locator.dart';
import 'package:protech_mobile_chat_stream/utils/string_apis.dart';
import 'package:turms_client_dart/turms_client.dart';

part 'user_state.dart';

class UserCubit extends Cubit<UserState> {
  final FriendRepository friendRepository = sl<FriendRepository>();
  final TurmsService turmsService = sl<TurmsService>();
  UserCubit() : super(const UserState());

  /// Fetches a list of users with their online status
  ///
  /// This function fetches a list of users that the current user is friends with.
  /// It fetches the user profiles and online status of the friends and emits
  /// [UserState] with the list of users and their online status.
  ///
  /// The function handles the following cases:
  ///
  /// - If the list of friends is empty, it emits a [UserState] with
  ///   [GetUsersStatus.empty].
  /// - If the list of friends is not empty, it fetches the user profiles and
  ///   online status of the friends and emits a [UserState] with the list of
  ///   users and their online status.
  Future<void> fetchUsers() async {
    try {
      emit(state.copyWith(getUsersStatus: GetUsersStatus.loading));
      final users = await sl<TurmsClient>().userService.queryFriends();

      if (users.code == ResponseStatusCode.noContent || users.data == null) {
        List<db.UserRelationship> relationshipList =
            await sl<DatabaseHelper>().getRelationshipList();
        if (relationshipList.isNotEmpty) {
          for (final relationship in relationshipList) {
            sl<DatabaseHelper>().updateRelationship(
              "r_${relationship.relatedUserId}_${sl<CredentialService>().turmsId}",
              "deleted",
            );
          }
        }

        emit(state.copyWith(getUsersStatus: GetUsersStatus.empty));
        return;
      }
      if (users.data?.userRelationships.isEmpty ?? false) {
        emit(state.copyWith(getUsersStatus: GetUsersStatus.empty));
      } else {
        log("user friend data ${users.code}");
        // users.removeWhere(
        //     (user) => user.id == sl<StreamChatClient>().state.currentUser?.id);
        Set<Int64> userIdsSet = users.data!.userRelationships
            .map((user) => user.relatedUserId)
            .toSet();

        // log("relationship id ididid ${relationship.id} $relationship");
        List<db.UserRelationship> relationshipList =
            await sl<DatabaseHelper>().getRelationshipList();

        final relationshipIds =
            relationshipList.map((e) => e.relatedUserId.parseInt64()).toSet();
        final toDeleteIds = relationshipIds.difference(userIdsSet);

        for (final id in toDeleteIds) {
          sl<DatabaseHelper>().updateRelationship(
            "r_${id}_${sl<CredentialService>().turmsId}",
            "deleted",
          );
        }
        await fetchUserOnlineStatuses(userIds: userIdsSet);
        final userProfileRes = await sl<TurmsClient>()
            .userService
            .queryUserProfiles(
                users.data?.userRelationships == null ? {} : userIdsSet);

        if (userProfileRes.data.isNotEmpty) {
          for (var element in userProfileRes.data) {
            log("friend ${element.id} ${element.name} ");
            sl<DatabaseHelper>().upsertUserRelationship(
              "r_${element.id}_${sl<CredentialService>().turmsId}",
              sl<CredentialService>().turmsId.toString(),
              element.id.toString(),
              "approved",
            );
          }

          emit(state.copyWith(
              getUsersStatus: GetUsersStatus.success,
              usersList: userProfileRes.data));
        }
      }
    } catch (e) {
      log("get users failed : $e");
      emit(state.copyWith(
        getUsersStatus: GetUsersStatus.fail,
      ));
    }
  }

  Future<void> fetchUserProfile({required String userId}) async {
    emit(
        state.copyWith(fetchUserProfileStatus: FetchUserProfileStatus.loading));
    log("fetching target user $userId");
    final res =
        await sl<TurmsService>().handleTurmsResponse<UserInfo?>(() async {
      try {
        final res = await sl<TurmsClient>()
            .userService
            .queryUserProfiles({userId.parseInt64()});
        log("query user profile : ${res.code} ${res.data}");
        if (res.data.isEmpty) {
          return null;
        }
        return res.data.first;
      } catch (e) {
        log("query user profile error: $e");
      }
      return null;
    });

    if (res is TurmsMapSuccessResponse<UserInfo?>) {
      if (res.res == null) {
        List<UserInfo> userInfos = [];

        final apiRes =
            await friendRepository.searchFriendsByPhone(phone: userId);
        if (apiRes is MapSuccessResponse) {
          try {
            final data = apiRes.jsonRes['data'];

            if ((data["items"] as List).isNotEmpty) {
              for (var element in data["items"]) {
                UserInfo userInfo = UserInfo(
                    id: element["turmsUId"].toString().parseInt64(),
                    name: element["name"],
                    profilePicture: element["profileUrl"],
                    active: element["status"] == "ACTIVE");

                userInfos.add(userInfo);
              }
            }

            emit(state.copyWith(
                fetchUserProfileStatus: FetchUserProfileStatus.success,
                userProfile: null,
                searchResultUsers: userInfos));
            return;
          } catch (e) {
            log("search friends by phone failed : $e");
            emit(state.copyWith(
                fetchUserProfileStatus: FetchUserProfileStatus.fail,
                errorMessage: "unknown error"));
            return;
          }
        }

        if (res is ConnectionRefusedResponse ||
            res is TimeoutResponse ||
            res is NoInternetResponse) {
          emit(state.copyWith(
              fetchUserProfileStatus: FetchUserProfileStatus.fail,
              errorMessage: Strings.unableToConnectToServer));
          return;
        }

        emit(state.copyWith(
            fetchUserProfileStatus: FetchUserProfileStatus.fail));
        return;
      }

      emit(state.copyWith(
          userProfile: res.res,
          fetchUserProfileStatus: FetchUserProfileStatus.success));
      return;
    }

    if (res is TurmsInvalidErrorResponse<UserInfo>) {
      log("res user profile : ${res.reason}");
      emit(state.copyWith(
          fetchUserProfileStatus: FetchUserProfileStatus.fail,
          errorMessage: res.reason));

      return;
    }

    emit(state.copyWith(
        fetchUserProfileStatus: FetchUserProfileStatus.fail,
        errorMessage: Strings.unknownError));
  }

  Future<void> resetSearchUser() async {
    emit(state.copyWith(
      searchResultUsers: [],
      fetchUserProfileStatus: FetchUserProfileStatus.initial,
      sendFriendRequestStatus: SendFriendRequestStatus.initial,
      // getUsersStatus: GetUsersStatus.initial,
    ));
  }

  /// Fetches the online status of a given user ID
  ///
  /// This function makes a request to the Turms server to fetch the online status
  /// of the given user ID. The function will emit a new state with the online
  /// status of the given user ID.
  ///
  /// The function takes a String user ID as a parameter and returns a Future that
  /// resolves to void when the request is complete.
  Future<void> fetchUserOnlineStatus({required String userId}) async {
    log("fetching target user online status $userId");
    UserOnlineStatus? targetUserOnlineStatus =
        await sl<TurmsService>().queryUserOnlineStatus(userId);
    emit(state.copyWith(userOnlineStatus: targetUserOnlineStatus));
  }

  /// Fetch online status of a given set of user IDs
  ///
  /// This function makes a request to the Turms server to fetch the online status
  /// of the given user IDs. The function will emit a new state with the list of
  /// online and offline users.
  ///
  /// The function takes a set of Int64 user IDs as a parameter.
  ///
  /// The function returns a Future that resolves to void when the request is
  /// complete.
  ///
  /// The function logs the number of online users if the request is successful.
  Future<void> fetchUserOnlineStatuses({required Set<Int64> userIds}) async {
    final userOnlineStatusRes =
        await sl<TurmsClient>().userService.queryOnlineStatuses(userIds);
    log("fetch online ${userOnlineStatusRes.data[0].userStatus.name}");
    if (userOnlineStatusRes.code == 1000) {
      List<UserOnlineStatus> onlineUsers = userOnlineStatusRes.data
          .where((user) => user.userStatus.name == "AVAILABLE")
          .toList();

      List<UserOnlineStatus> offlineUsers = userOnlineStatusRes.data
          .where((user) => user.userStatus.name == "OFFLINE")
          .toList();
      log("on: $onlineUsers, off: $offlineUsers");
      emit(
          state.copyWith(onlineUsers: onlineUsers, offlineUsers: offlineUsers));
    }
  }

  /// Filter the users list based on the given status. If the status is "ONLINE", the filtered list
  /// will contain users who are online. If the status is "OFFLINE", the filtered list will contain
  /// users who are offline. If the status is neither "ONLINE" nor "OFFLINE", the filtered list will
  /// contain all users.
  void filterUserStatus(String status) async {
    await fetchUsers();
    log("status filter $status");
    if (status == "ONLINE") {
      List<UserInfo> onlineUserList = List.from(state.usersList);

      if (state.offlineUsers.isNotEmpty) {
        onlineUserList.removeWhere((user) => state.offlineUsers
            .any((offlineUser) => offlineUser.userId == user.id));
      }

      emit(state.copyWith(
          usersList: onlineUserList, filterStatus: Strings.online));
    } else if (status == "OFFLINE") {
      List<UserInfo> offlineUserList = List.from(state.usersList);
      if (state.onlineUsers.isNotEmpty) {
        offlineUserList.removeWhere((user) => state.onlineUsers
            .any((onlineUser) => onlineUser.userId == user.id));
      }

      log("offline user list ${state.onlineUsers} ${state.offlineUsers} $offlineUserList");
      emit(state.copyWith(
          usersList: offlineUserList, filterStatus: Strings.offline));
    } else {
      emit(state.copyWith(filterStatus: Strings.all));
    }
  }

  Future<void> getFriendRequest() async {
    try {
      final res =
          await sl<TurmsClient>().userService.queryFriendRequests(false);
      log("get friend request : ${res.code} ${res.data}");
      List<Map<String, dynamic>> friendRequestList = [];

      if (res.code == ResponseStatusCode.ok) {
        if (res.data != null) {
          if (res.data!.userFriendRequests.isNotEmpty) {
            for (UserFriendRequest request in res.data!.userFriendRequests
                .where(
                    (request) => request.requestStatus == RequestStatus.PENDING)
                .toList()) {
              Map<String, dynamic> friendRequestMap = {};

              UserInfo? usr;

              UserInfo? userInfo = await sl<TurmsService>()
                  .queryUserProfile(request.requesterId.toString());

              if (userInfo != null) {
                usr = userInfo;
              }

              friendRequestMap["userInfo"] = usr;

              friendRequestMap["userFriendRequest"] = request;
              log("my friend $friendRequestMap");
              friendRequestList.add(friendRequestMap);
            }
          }
        }
      }

      emit(state.copyWith(friendRequests: friendRequestList));
    } catch (e) {
      log("get friend request failed : $e");
    }
  }

  Future<void> getSentFriendRequest() async {
    try {
      final sentFriendRequestRes =
          await sl<TurmsClient>().userService.queryFriendRequests(true);
      log("get sent friend request : ${sentFriendRequestRes.code} ${sentFriendRequestRes.data}");
      List<Map<String, dynamic>> sentFriendRequestList = [];

      if (sentFriendRequestRes.code == ResponseStatusCode.ok) {
        if (sentFriendRequestRes.data != null) {
          if (sentFriendRequestRes.data!.userFriendRequests.isNotEmpty) {
            for (UserFriendRequest request in sentFriendRequestRes
                .data!.userFriendRequests
                .where(
                    (request) => request.requestStatus == RequestStatus.PENDING)
                .toList()) {
              Map<String, dynamic> sentFriendRequestMap = {};

              UserInfo? usr;

              UserInfo? userInfo = await sl<TurmsService>()
                  .queryUserProfile(request.recipientId.toString());

              if (userInfo != null) {
                usr = userInfo;
              }

              sentFriendRequestMap["userInfo"] = usr;

              sentFriendRequestMap["userFriendRequest"] = request;

              sentFriendRequestList.add(sentFriendRequestMap);
            }
          }
        }
      }

      emit(state.copyWith(sentFriendRequests: sentFriendRequestList));
    } catch (e) {
      log("get sent friend request failed : $e");
    }
  }

  Future<void> sendFriendRequest(Int64 recipientId) async {
    emit(state.copyWith(
        sendFriendRequestStatus: SendFriendRequestStatus.loading));

    final friendListRes = await turmsService
        .handleTurmsResponse<List<UserRelationship>?>(() async {
      final res = await sl<TurmsClient>().userService.queryFriends();
      if (res.data == null) {
        return null;
      }
      return res.data!.userRelationships;
    });

    if (friendListRes is TurmsMapSuccessResponse<List<UserRelationship>?>) {
      if (friendListRes.res != null) {
        if (friendListRes.res!
            .any((friend) => friend.relatedUserId == recipientId)) {
          emit(state.copyWith(
              errorMessage: Strings.alreadyFriendWithThisUser,
              sendFriendRequestStatus: SendFriendRequestStatus.fail));
          return;
        }
      }
    }

    final res = await turmsService.handleTurmsResponse<Int64>(() async {
      final res = await sl<TurmsClient>()
          .userService
          .sendFriendRequest(recipientId, "");
      return res.data;
    });

    if (res is TurmsMapSuccessResponse<Int64>) {
      if (res.res != null) {
        await sl<DatabaseHelper>().upsertUserRelationship(
          "r_${recipientId}_${sl<CredentialService>().turmsId}",
          sl<CredentialService>().turmsId.toString(),
          recipientId.toString(),
          "pending",
        );
        emit(state.copyWith(
          sendFriendRequestStatus: SendFriendRequestStatus.success,
        ));
        return;
      }
    }

    if (res is TurmsInvalidErrorResponse<Int64>) {
      log("send friend request failed : ${res.code} ${res.reason}");
      emit(state.copyWith(
          sendFriendRequestStatus: SendFriendRequestStatus.fail,
          errorMessage: res.reason));
      return;
    }

    emit(state.copyWith(
        errorMessage: Strings.unknownError,
        sendFriendRequestStatus: SendFriendRequestStatus.fail));
  }

  Future<void> respondFriendRequest(
      int requestId, ResponseAction action) async {
    try {
      final res = await sl<TurmsClient>()
          .userService
          .replyFriendRequest(requestId.toInt64(), action);
      if (res.code == 1000) {
        fetchUsers();
        getFriendRequest();
      }
      log("accept friend request : ${res.code}");
    } catch (e) {
      log("accept friend request failed : $e");
    }
  }

  Future<void> getUserSettings({Int64? targetUserId}) async {
    try {
      emit(state.copyWith(
        getUserSettingsStatus: GetUserSettingsStatus.loading,
      ));
      final res = await sl<TurmsClient>()
          .userService
          .queryUserSettings(targetId: targetUserId);
      if (res.code == 1000) {
        emit(state.copyWith(
            getUserSettingsStatus: GetUserSettingsStatus.success,
            userSettings: res.data?.settings));
      }
      log("user setting response $res");
    } catch (e) {
      emit(state.copyWith(
        getUserSettingsStatus: GetUserSettingsStatus.fail,
      ));
      log("query user setting error $e");
    }
  }

  Future<void> updateUserSettings(Map<String, Value> userSettings) async {
    try {
      emit(state.copyWith(
        updateUserSettingsStatus: UpdateUserSettingsStatus.loading,
      ));
      final res =
          await sl<TurmsClient>().userService.upsertUserSettings(userSettings);
      if (res.code == 1000) {
        await getUserSettings(
            targetUserId: sl<CredentialService>().turmsId?.parseInt64());
        emit(state.copyWith(
          updateUserSettingsStatus: UpdateUserSettingsStatus.success,
        ));
      }
      log("update user setting response $res");
    } catch (e) {
      emit(state.copyWith(
        updateUserSettingsStatus: UpdateUserSettingsStatus.fail,
      ));
      log("update user setting error $e");
    }
  }

  Future<void> addFriendWithoutRequest(Int64 recipientId) async {
    emit(state.copyWith(
        createRelationshipStatus: CreateRelationshipStatus.loading));

    final friendListRes = await turmsService
        .handleTurmsResponse<List<UserRelationship>?>(() async {
      final res = await sl<TurmsClient>().userService.queryFriends();
      if (res.data == null) {
        return null;
      }
      return res.data!.userRelationships;
    });

    if (friendListRes is TurmsMapSuccessResponse<List<UserRelationship>?>) {
      if (friendListRes.res != null) {
        if (friendListRes.res!
            .any((friend) => friend.relatedUserId == recipientId)) {
          emit(state.copyWith(
              errorMessage: Strings.alreadyFriendWithThisUser,
              createRelationshipStatus: CreateRelationshipStatus.fail));
          return;
        }
      }
    }

    final res = await turmsService.handleTurmsResponse<void>(() async {
      final res = await sl<TurmsClient>().userService.createFriendRelationship(
            recipientId,
          );
      if (res.code == 1000) {
        sl<DatabaseHelper>().upsertUserRelationship(
          "r_${recipientId}_${sl<CredentialService>().turmsId}",
          sl<CredentialService>().turmsId.toString(),
          recipientId.toString(),
          "approved",
        );
        fetchUsers();
        emit(state.copyWith(
          createRelationshipStatus: CreateRelationshipStatus.success,
        ));
      }
      log("create relationship request $res");
    });

    // if (res is TurmsMapSuccessResponse<Int64>) {
    //   if (res.res != null) {
    //     emit(state.copyWith(
    //       sendFriendRequestStatus: SendFriendRequestStatus.success,
    //     ));
    //     return;
    //   }
    // }

    // if (res is TurmsInvalidErrorResponse<Int64>) {
    //   log("send friend request failed : ${res.code} ${res.reason}");
    //   emit(state.copyWith(
    //       sendFriendRequestStatus: SendFriendRequestStatus.fail,
    //       errorMessage: res.reason));
    //   return;
    // }

    emit(state.copyWith(
        errorMessage: Strings.unknownError,
        createRelationshipStatus: CreateRelationshipStatus.fail));
  }

  Future<void> deleteFriend(Int64 targetId) async {
    try {
      emit(state.copyWith(
        deleteFriendStatus: DeleteFriendStatus.loading,
      ));
      final res =
          await sl<TurmsClient>().userService.deleteRelationship(targetId);
      if (res.code == 1000) {
        sl<DatabaseHelper>().updateRelationship(
          "r_${targetId}_${sl<CredentialService>().turmsId}",
          "deleted",
        );
        fetchUsers();
        emit(state.copyWith(
          deleteFriendStatus: DeleteFriendStatus.success,
        ));
      }
      log("delete friend response $res");
    } catch (e) {
      emit(state.copyWith(
        deleteFriendStatus: DeleteFriendStatus.fail,
      ));
      log("delete friend error $e");
    }
  }

  void resetAllUserStatus() {
    emit(state.copyWith(
      fetchUserProfileStatus: FetchUserProfileStatus.initial,
      sendFriendRequestStatus: SendFriendRequestStatus.initial,
      getUsersStatus: GetUsersStatus.initial,
      createRelationshipStatus: CreateRelationshipStatus.initial,
      getUserSettingsStatus: GetUserSettingsStatus.initial,
      deleteFriendStatus: DeleteFriendStatus.initial,
      usersList: [],
      searchResultUsers: [],
    ));
  }
}
