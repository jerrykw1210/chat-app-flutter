class UserProfile {
  final int id;
  final DateTime createdAt;
  final String? createdBy;
  final DateTime? updatedAt;
  final String? updatedBy;
  final String? phone;
  final String email;
  final String password;
  final String name;
  final String? gender;
  final String profileUrl;
  final String status;
  final String uid;
  final bool? isOnline;
  final DateTime lastOnline;
  final int invitationCodeId;
  final String invitationCodeCode;
  final String? tenantId;
  final String? tenantName;
  final String? turmsUid;
  final String? statusMessage;
  final List<dynamic> userSearchByDTOS;

  UserProfile({
    required this.id,
    required this.createdAt,
    this.createdBy,
    this.updatedAt,
    this.updatedBy,
    this.phone,
    required this.email,
    required this.password,
    required this.name,
    this.gender,
    required this.profileUrl,
    required this.status,
    required this.uid,
    this.isOnline,
    required this.lastOnline,
    required this.invitationCodeId,
    required this.invitationCodeCode,
    this.tenantId,
    this.tenantName,
    this.turmsUid,
    this.statusMessage,
    required this.userSearchByDTOS,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] ?? 0,
      createdAt: json['createdAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['createdAt'])
          : DateTime.now(),
      createdBy: json['createdBy'] ?? '',
      updatedAt: json['updatedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['updatedAt'])
          : null,
      updatedBy: json['updatedBy'].toString() ?? '',
      phone: json['phone'] ?? '',
      email: json['email'] ?? '',
      password: json['password'] ?? '',
      name: json['name'] ?? '',
      gender: json['gender'],
      profileUrl: json['profileUrl'] ?? '',
      status: json['status'] ?? '',
      uid: json['uid'] ?? '',
      isOnline: json['isOnline'] ?? false,
      lastOnline: json['lastOnline'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['lastOnline'])
          : DateTime.now(),
      invitationCodeId: json['invitationCodeId'] ?? 0,
      invitationCodeCode: json['invitationCodeCode'] ?? '',
      tenantId: json['tenantId'].toString(),
      tenantName: json['tenantName'] ?? '',
      turmsUid: json['turmsUId'] ?? "0",
      statusMessage: json['statusMessage'] ?? '',
      userSearchByDTOS: json['userSearchByDTOS']?.cast<dynamic>() ?? [],
    );
  }
}
