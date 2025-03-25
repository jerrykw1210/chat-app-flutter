class LanguageModel {
  List<Language> languageList;

  LanguageModel({
    required this.languageList,
  });

  factory LanguageModel.fromJson(Map<String, dynamic> json) => LanguageModel(
        languageList:
            List<Language>.from(json["items"].map((x) => Language.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "items": List<dynamic>.from(languageList.map((x) => x.toJson())),
      };
}

class Language {
  int id;
  int createdAt;
  int createdBy;
  int? updatedAt;
  int? updatedBy;
  Status status;
  String code;
  String name;
  String path;

  Language({
    required this.id,
    required this.createdAt,
    required this.createdBy,
    this.updatedAt,
    this.updatedBy,
    required this.status,
    required this.code,
    required this.name,
    required this.path,
  });

  factory Language.fromJson(Map<String, dynamic> json) => Language(
        id: json["id"],
        createdAt: json["createdAt"],
        createdBy: json["createdBy"],
        updatedAt: json['updatedAt'],
        updatedBy: json["updatedBy"],
        status: statusValues.map[json["status"]] ?? Status.INACTIVE,
        code: json["code"],
        name: json["name"],
        path: json["path"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "createdAt": createdAt,
        "createdBy": createdBy,
        "updatedAt": updatedAt,
        "updatedBy": updatedBy,
        "status": statusValues.reverse[status],
        "code": code,
        "name": name,
        "path": path,
      };
}

enum Status { ACTIVE,INACTIVE, DELETED }

final statusValues =
    EnumValues({"ACTIVE": Status.ACTIVE,"INACTIVE": Status.INACTIVE, "DELETED": Status.DELETED});

class EnumValues<T> {
  Map<String, T> map;
  late Map<T, String> reverseMap;

  EnumValues(this.map);

  Map<T, String> get reverse {
    reverseMap = map.map((k, v) => MapEntry(v, k));
    return reverseMap;
  }
}
