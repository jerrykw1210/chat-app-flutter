import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:protech_mobile_chat_stream/constants/storagekey_constants.dart';
import 'package:protech_mobile_chat_stream/utils/service_locator.dart';

class CredentialService {
  final FlutterSecureStorage _storage = sl<FlutterSecureStorage>();
  String? jwtToken;
  String? userId;
  String? apiKey;
  String? authToken;
  String? turmsId;
  String? turmsToken;
  String? userName;
  String? invitationCode;
  String? serviceUrlMap;

  CredentialService();

  Future<String?> get getJwtToken async =>
      jwtToken ??= await _storage.read(key: StoragekeyConstants.jwtTokenKey);

  Future<String?> get getUserId async =>
      userId ??= await _storage.read(key: StoragekeyConstants.userIdKey);

  Future<String?> get getApiKey async =>
      apiKey ??= await _storage.read(key: StoragekeyConstants.apiKeyKey);

  Future<String?> get getAuthToken async =>
      authToken ??= await _storage.read(key: StoragekeyConstants.authTokenKey);

  Future<String?> get getTurmsId async =>
      turmsId ??= await _storage.read(key: StoragekeyConstants.turmsUidKey);

  Future<String?> get getTurmsToken async => turmsToken ??=
      await _storage.read(key: StoragekeyConstants.turmsTokenKey);

  Future<String?> get getUserName async =>
      userName ??= await _storage.read(key: StoragekeyConstants.userNameKey);

  Future<String?> get getInvitationCode async => invitationCode ??=
      await _storage.read(key: StoragekeyConstants.invitationCodeKey);

  Future<String?> get getServiceUrlMap async => serviceUrlMap ??=
      await _storage.read(key: StoragekeyConstants.serviceUrlMapKey);

  Future<String?> get getStorageJwtToken async =>
      await _storage.read(key: StoragekeyConstants.jwtTokenKey);

  Future<String?> get getStorageUserId async =>
      await _storage.read(key: StoragekeyConstants.userIdKey);

  Future<String?> get getStorageApiKey async =>
      await _storage.read(key: StoragekeyConstants.apiKeyKey);

  Future<String?> get getStorageAuthToken async =>
      await _storage.read(key: StoragekeyConstants.authTokenKey);

  Future<String?> get getStorageTurmsId async =>
      await _storage.read(key: StoragekeyConstants.turmsUidKey);

  Future<String?> get getStorageTurmsToken async =>
      await _storage.read(key: StoragekeyConstants.turmsTokenKey);

  Future<String?> get getStorageUserName async =>
      await _storage.read(key: StoragekeyConstants.userNameKey);

  Future<String?> get getStorageInvitationCode async =>
      await _storage.read(key: StoragekeyConstants.invitationCodeKey);

  Future<String?> get getStorageServiceUrlMap async =>
      await _storage.read(key: StoragekeyConstants.serviceUrlMapKey);

  void writeInvitationCode(String code) {
    _storage.write(key: StoragekeyConstants.invitationCodeKey, value: code);
    invitationCode = code;
  }

  Future<void> writeServiceUrlMap(String serviceUrlMap) async {
    await _storage.write(
        key: StoragekeyConstants.serviceUrlMapKey, value: serviceUrlMap);
    this.serviceUrlMap = serviceUrlMap;
  }

  void writeCredential({required Map<String, dynamic> result}) {
    jwtToken = result["jwt"];
    turmsToken = result["turmsJWT"];
    userId = result["thirdPartyUserId"];
    apiKey = result["thirdPartyAPIKey"];
    authToken = result["thirdPartyAuthToken"];
    turmsId = result["turmsUId"];
    userName = result["name"] ?? "Guest";
    invitationCode = result["invitationCode"];
    serviceUrlMap = result["serviceUrlMap"];

    _storage.write(key: StoragekeyConstants.jwtTokenKey, value: jwtToken!);
    _storage.write(key: StoragekeyConstants.userIdKey, value: userId!);
    _storage.write(key: StoragekeyConstants.apiKeyKey, value: apiKey!);
    _storage.write(key: StoragekeyConstants.authTokenKey, value: authToken!);
    _storage.write(key: StoragekeyConstants.turmsUidKey, value: turmsId!);
    _storage.write(key: StoragekeyConstants.turmsTokenKey, value: turmsToken!);
    _storage.write(key: StoragekeyConstants.userNameKey, value: userName!);
  }

  void deleteCredential() {
    jwtToken = null;
    userId = null;
    apiKey = null;
    authToken = null;
    turmsId = null;
    turmsToken = null;
    userName = null;
    invitationCode = null;
    serviceUrlMap = null;
  }
}
