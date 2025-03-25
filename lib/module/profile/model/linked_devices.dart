class LinkedDevices {
  int pageNumber;
  int pageSize;
  int totalRecord;
  List<LinkedDevice> devices;

  LinkedDevices({
    required this.pageNumber,
    required this.pageSize,
    required this.totalRecord,
    required this.devices,
  });

  factory LinkedDevices.fromJson(Map<String, dynamic> json) => LinkedDevices(
        pageNumber: json["pageNumber"] ?? 0,
        pageSize: json["pageSize"] ?? 0,
        totalRecord: json["totalRecord"] ?? 0,
        devices: json["items"] == null
            ? []
            : List<LinkedDevice>.from((json["items"] as List<dynamic>)
                .map((x) => LinkedDevice.fromJson(x))),
      );
}

class LinkedDevice {
  int id;
  int createdAt;
  dynamic createdBy;
  dynamic updatedAt;
  dynamic updatedBy;
  String type;
  String model;
  String token;
  String status;
  String jwt;
  bool isOnline;
  int? lastOnline;
  int userId;
  String username;

  LinkedDevice({
    required this.id,
    required this.createdAt,
    required this.createdBy,
    required this.updatedAt,
    required this.updatedBy,
    required this.type,
    required this.status,
    required this.model,
    required this.token,
    required this.jwt,
    this.isOnline = false,
    this.lastOnline,
    required this.userId,
    required this.username,
  });

  factory LinkedDevice.fromJson(Map<String, dynamic> json) => LinkedDevice(
        id: json["id"] ?? 0,
        createdAt: json["createdAt"] ?? 0,
        createdBy: json["createdBy"],
        updatedAt: json["updatedAt"],
        updatedBy: json["updatedBy"],
        type: json["type"] ?? "",
        status: json["status"] ?? "",
        model: json["model"] ?? "",
        token: json["token"] ?? "",
        jwt: json["jwt"] ?? "",
        isOnline: json["isOnline"] ?? false,
        lastOnline: json["lastOnline"],
        userId: json["userId"] ?? 0,
        username: json["username"] ?? "",
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "createdAt": createdAt,
        "createdBy": createdBy,
        "updatedAt": updatedAt,
        "updatedBy": updatedBy,
        "type": type,
        "status": status,
        "model": model,
        "token": token,
        "jwt": jwt,
        "isOnline": isOnline,
        "lastOnline": lastOnline,
        "userId": userId,
        "username": username,
      };
}
