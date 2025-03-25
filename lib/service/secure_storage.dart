import 'package:flutter_secure_storage/flutter_secure_storage.dart';


class SecureStorage {
  static SecureStorage? _instance;
  final FlutterSecureStorage _storage;
  String? _token;

  static Future<SecureStorage> getInstance() async {
    if (_instance == null) {
      var secureStorage = SecureStorage._();
      await secureStorage._init();
      _instance = secureStorage;
    }
    return _instance ?? SecureStorage();
  }

  factory SecureStorage() => _instance ??= SecureStorage._();

  String get token => _token ?? "";

  SecureStorage._() : _storage = const FlutterSecureStorage();

  Future<void> _init() async {
    // print("init tokenssss");
    _token = await _storage.read(key: _tokenKey);
    // print("sasa $_token");
  }

  static const _tokenKey = "TOKEN";
  // static const _emailKey = "EMAIL";
  // static const _phoneKey = "PHONE";

  Future<void> persistPrivate(String token) async {
    // await _storage.write(key: _emailKey, value: email);
    _token = token;
    await _storage.write(key: _tokenKey, value: token);
  }

  Future<bool> hasToken() async {
    var value = await _storage.read(key: _tokenKey);
    //print("has token? $value");
    return value != null;
  }

  // Future<bool> hasEmail() async {
  //   var value = _storage.read(key: _emailKey);
  //   return value != null;
  // }
  Future<void> deleteToken() async {
    return _storage.delete(key: _tokenKey);
  }

  // Future<void> deleteEmail() async {
  //   return _storage.delete(key: _emailKey);
  // }

  // Future<String?> getToken() async {
  //   if (token.isEmpty) return null;
  //   // String uaid = JwtDecoder.getUserId(token);
  //   // print("uaid $uaid");
  //   if (JwtDecoder.isTokenExpired(token)) {
  //     debugPrint("Token refresh");
  //     await refreshToken();
  //   }
  //   _token = await _storage.read(key: _tokenKey);
  //   return _storage.read(key: _tokenKey);
  // }

  //Refresh the token when token expired
  // Future<void> refreshToken() async {
  //   final _res = await sl<CredentialService>().refreshToken();
  //   if (_res is MapSuccessResponse) {
  //     await persistPrivate(_res.jsonRes['data']['token']);
  //     _token = await _storage.read(key: _tokenKey);
  //   }
  // }

  Future<void> deleteAll() async {
    await _setDefaultToken();
    return _storage.deleteAll();
  }

  Future<void> _setDefaultToken() async {
    _token = "";
  }

  // Future<void> cleanIfFirstUseAfterUninstall() async {
  //   print("first run? ${UserPreferences.getIsFirstRun().toString()}");
  //   if (UserPreferences.getIsFirstRun() ?? true) {
  //     debugPrint("first run");
  //     _token = null;
  //     await deleteAll();
  //     await UserPreferences.setFirstRun(false);
  //     return;
  //   }
  // }
}
