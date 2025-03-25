part of 'group_cubit.dart';

enum CreateGroupStatus { initial, success, fail, loading, empty }

enum GetGroupMemberStatus { initial, success, fail, loading, empty }

enum GetGroupInfoStatus { initial, success, fail, loading, empty }

enum JoinGroupStatus { initial, success, fail, loading, empty }

enum LeaveGroupStatus { initial, success, fail, loading, empty }

enum UpdateGroupStatus { initial, success, fail, loading, empty }

enum AddGroupMemberStatus { initial, success, fail, loading, empty }

enum KickGroupMemberStatus { initial, success, fail, loading, empty }

enum UpdateMemberScopeStatus { initial, success, fail, loading, empty }

enum TransferOwnerStatus { initial, success, fail, loading, empty }

enum FetchGroupStatus { initial, success, fail, loading, empty }

enum UploadGroupProfileImageStatus { initial, success, fail, loading, empty }

class GroupState extends Equatable {
  const GroupState({
    this.createGroupStatus = CreateGroupStatus.initial,
    this.getGroupMemberStatus = GetGroupMemberStatus.initial,
    this.getGroupInfoStatus = GetGroupInfoStatus.initial,
    this.joinGroupStatus = JoinGroupStatus.initial,
    this.leaveGroupStatus = LeaveGroupStatus.initial,
    this.updateGroupStatus = UpdateGroupStatus.initial,
    this.addGroupMemberStatus = AddGroupMemberStatus.initial,
    this.kickGroupMemberStatus = KickGroupMemberStatus.initial,
    this.updateMemberScopeStatus = UpdateMemberScopeStatus.initial,
    this.transferOwnerStatus = TransferOwnerStatus.initial,
    this.fetchGroupStatus = FetchGroupStatus.initial,
    this.uploadGroupProfileImageStatus = UploadGroupProfileImageStatus.initial,
    this.groupMemberList = const [],
    this.memberList = const [],
    this.groupJoinRequestList = const [],
    this.image,
    this.groupInfo,
    this.inactiveUsers = const [],
    this.groupList = const [],
    this.groupProfileImage = '',
  });

  final CreateGroupStatus createGroupStatus;
  final GetGroupMemberStatus getGroupMemberStatus;
  final GetGroupInfoStatus getGroupInfoStatus;
  final LeaveGroupStatus leaveGroupStatus;
  final JoinGroupStatus joinGroupStatus;
  final UpdateGroupStatus updateGroupStatus;
  final AddGroupMemberStatus addGroupMemberStatus;
  final KickGroupMemberStatus kickGroupMemberStatus;
  final UpdateMemberScopeStatus updateMemberScopeStatus;
  final TransferOwnerStatus transferOwnerStatus;
  final FetchGroupStatus fetchGroupStatus;
  final UploadGroupProfileImageStatus uploadGroupProfileImageStatus;
  final List<GroupMember> groupMemberList;
  final List<UserInfo> memberList;
  final List<Map<String, dynamic>> groupJoinRequestList;
  final XFile? image;
  final Group? groupInfo;
  final List<UserInfo> inactiveUsers;
  final List<Group> groupList;
  final String groupProfileImage;

  GroupState copyWith({
    CreateGroupStatus? createGroupStatus,
    GetGroupMemberStatus? getGroupMemberStatus,
    GetGroupInfoStatus? getGroupInfoStatus,
    LeaveGroupStatus? leaveGroupStatus,
    JoinGroupStatus? joinGroupStatus,
    UpdateGroupStatus? updateGroupStatus,
    AddGroupMemberStatus? addGroupMemberStatus,
    KickGroupMemberStatus? kickGroupMemberStatus,
    UpdateMemberScopeStatus? updateMemberScopeStatus,
    TransferOwnerStatus? transferOwnerStatus,
    FetchGroupStatus? fetchGroupStatus,
    UploadGroupProfileImageStatus? uploadGroupProfileImageStatus,
    List<GroupMember>? groupMemberList,
    List<UserInfo>? memberList,
    List<Map<String, dynamic>>? groupJoinRequestList,
    XFile? image,
    ValueGetter<Group?>? groupInfo,
    List<UserInfo>? inactiveUsers,
    List<Group>? groupList,
    String? groupProfileImage,
  }) =>
      GroupState(
        createGroupStatus: createGroupStatus ?? this.createGroupStatus,
        getGroupMemberStatus: getGroupMemberStatus ?? this.getGroupMemberStatus,
        getGroupInfoStatus: getGroupInfoStatus ?? this.getGroupInfoStatus,
        leaveGroupStatus: leaveGroupStatus ?? this.leaveGroupStatus,
        joinGroupStatus: joinGroupStatus ?? this.joinGroupStatus,
        updateGroupStatus: updateGroupStatus ?? this.updateGroupStatus,
        addGroupMemberStatus: addGroupMemberStatus ?? this.addGroupMemberStatus,
        kickGroupMemberStatus:
            kickGroupMemberStatus ?? this.kickGroupMemberStatus,
        updateMemberScopeStatus:
            updateMemberScopeStatus ?? this.updateMemberScopeStatus,
        transferOwnerStatus: transferOwnerStatus ?? this.transferOwnerStatus,
        fetchGroupStatus: fetchGroupStatus ?? this.fetchGroupStatus,
        uploadGroupProfileImageStatus:
            uploadGroupProfileImageStatus ?? this.uploadGroupProfileImageStatus,
        groupMemberList: groupMemberList ?? this.groupMemberList,
        memberList: memberList ?? this.memberList,
        groupJoinRequestList: groupJoinRequestList ?? this.groupJoinRequestList,
        image: image ?? this.image,
        groupInfo: groupInfo != null ? groupInfo() : this.groupInfo,
        inactiveUsers: inactiveUsers ?? this.inactiveUsers,
        groupList: groupList ?? this.groupList,
        groupProfileImage: groupProfileImage ?? this.groupProfileImage,
      );

  @override
  List<Object?> get props => [
        createGroupStatus,
        getGroupMemberStatus,
        getGroupInfoStatus,
        leaveGroupStatus,
        joinGroupStatus,
        updateGroupStatus,
        addGroupMemberStatus,
        kickGroupMemberStatus,
        updateMemberScopeStatus,
        transferOwnerStatus,
        fetchGroupStatus,
        uploadGroupProfileImageStatus,
        groupMemberList,
        memberList,
        groupJoinRequestList,
        image,
        groupInfo,
        inactiveUsers,
        groupList,
        groupProfileImage,
      ];
}

