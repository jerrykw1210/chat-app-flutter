part of 'user_cubit.dart';

enum GetUsersStatus { initial, success, fail, loading, empty }

enum FetchUserProfileStatus { initial, success, fail, loading, empty }

enum SendFriendRequestStatus { initial, success, fail, loading, empty }

enum CreateRelationshipStatus { initial, success, fail, loading, empty }

enum DeleteFriendStatus { initial, success, fail, loading, empty }

//enum GetGroupsStatus { initial, success, fail, loading, empty }

enum GetUserSettingsStatus { initial, success, fail, loading, empty }

enum UpdateUserSettingsStatus { initial, success, fail, loading, empty }

class UserState extends Equatable {
  final GetUsersStatus getUsersStatus;
  final List<UserInfo> usersList;
  final List<Map<String, dynamic>> friendRequests;
  final List<Map<String, dynamic>> sentFriendRequests;
  final UserInfo? userProfile;
  final List<UserInfo> searchResultUsers;
  final UserOnlineStatus? userOnlineStatus;
  final List<UserOnlineStatus> onlineUsers;
  final List<UserOnlineStatus> offlineUsers;
  final FetchUserProfileStatus fetchUserProfileStatus;
  final String? errorMessage;
  final SendFriendRequestStatus sendFriendRequestStatus;
  final CreateRelationshipStatus createRelationshipStatus;
  final DeleteFriendStatus deleteFriendStatus;
  // final GetGroupsStatus getGroupsStatus;
  // final List<Group> groupsList;
  final String filterStatus;
  final Map<String, Value> userSettings;
  final GetUserSettingsStatus getUserSettingsStatus;
  final UpdateUserSettingsStatus updateUserSettingsStatus;


  const UserState({
    this.getUsersStatus = GetUsersStatus.initial,
    this.fetchUserProfileStatus = FetchUserProfileStatus.initial,
    this.sendFriendRequestStatus = SendFriendRequestStatus.initial,
    this.createRelationshipStatus = CreateRelationshipStatus.initial,
    this.deleteFriendStatus = DeleteFriendStatus.initial,
    // this.getGroupsStatus = GetGroupsStatus.initial,
    // this.groupsList = const [],
    this.searchResultUsers = const [],
    this.usersList = const [],
    this.friendRequests = const [],
    this.sentFriendRequests = const [],
    this.userProfile,
    this.userOnlineStatus,
    this.onlineUsers = const [],
    this.offlineUsers = const [],
    this.filterStatus = "ALL",
    this.userSettings = const {},
    this.errorMessage,
    this.getUserSettingsStatus = GetUserSettingsStatus.initial,
    this.updateUserSettingsStatus = UpdateUserSettingsStatus.initial,
  });

  UserState copyWith({
    GetUsersStatus? getUsersStatus,
    FetchUserProfileStatus? fetchUserProfileStatus,
    SendFriendRequestStatus? sendFriendRequestStatus,
    CreateRelationshipStatus? createRelationshipStatus,
    DeleteFriendStatus? deleteFriendStatus,
    // GetGroupsStatus? getGroupsStatus,
    // List<Group>? groupsList,
    List<UserInfo>? searchResultUsers,
    List<UserInfo>? usersList,
    List<Map<String, dynamic>>? friendRequests,
    List<Map<String, dynamic>>? sentFriendRequests,
    bool? sendNamecard,
    UserInfo? userProfile,
    List<UserOnlineStatus>? onlineUsers,
    List<UserOnlineStatus>? offlineUsers,
    String? filterStatus,
    String? errorMessage,
    UserOnlineStatus? userOnlineStatus,
    Map<String, Value>? userSettings,
    GetUserSettingsStatus? getUserSettingsStatus,
    UpdateUserSettingsStatus? updateUserSettingsStatus,
  }) {
    return UserState(
      getUsersStatus: getUsersStatus ?? this.getUsersStatus,
      sendFriendRequestStatus:
          sendFriendRequestStatus ?? this.sendFriendRequestStatus,
      createRelationshipStatus:
          createRelationshipStatus ?? this.createRelationshipStatus,
      deleteFriendStatus: deleteFriendStatus ?? this.deleteFriendStatus,
      fetchUserProfileStatus:
          fetchUserProfileStatus ?? this.fetchUserProfileStatus,
      errorMessage: errorMessage ?? this.errorMessage,
      searchResultUsers: searchResultUsers ?? this.searchResultUsers,
      // getGroupsStatus: getGroupsStatus ?? this.getGroupsStatus,
      // groupsList: groupsList ?? this.groupsList,
      usersList: usersList ?? this.usersList,
      friendRequests: friendRequests ?? this.friendRequests,
      sentFriendRequests: sentFriendRequests ?? this.sentFriendRequests,
      
      userProfile: userProfile ?? this.userProfile,
      userOnlineStatus: userOnlineStatus ?? this.userOnlineStatus,
      onlineUsers: onlineUsers ?? this.onlineUsers,
      offlineUsers: offlineUsers ?? this.offlineUsers,
      filterStatus: filterStatus ?? this.filterStatus,
      userSettings: userSettings ?? this.userSettings,
      getUserSettingsStatus:
          getUserSettingsStatus ?? this.getUserSettingsStatus,
      updateUserSettingsStatus:
          updateUserSettingsStatus ?? this.updateUserSettingsStatus,
    );
  }

  @override
  List<Object?> get props => [
        getUsersStatus,
        fetchUserProfileStatus,
        usersList,
   
        friendRequests,
        sendFriendRequestStatus,
        createRelationshipStatus,
        deleteFriendStatus,
        sentFriendRequests,
        errorMessage,
        userProfile,
        searchResultUsers,
        userOnlineStatus,
        onlineUsers,
        offlineUsers,
        filterStatus,
        userSettings,
        getUserSettingsStatus,
        updateUserSettingsStatus,
        // getGroupsStatus, groupsList
      ];
}

