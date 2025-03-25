import 'package:shared_preferences/shared_preferences.dart';

class UserPreferences {
  static SharedPreferences? _preferences;

  static const _keyToken = "token";
  static const _keyTokenExp = "token_exp";
  static const _firstRun = "first_run";
  static const _keyExpTime = "exptime";
  static const _keyUserId = "userId";

  UserPreferences._();

  static Future<SharedPreferences> init() async =>
      _preferences = await SharedPreferences.getInstance();

  static Future setToken(String token) async =>
      await _preferences?.setString(_keyToken, token);
  static Future setTokenExp(String tokenexp) async =>
      await _preferences?.setString(_keyTokenExp, tokenexp);

  static Future setFirstRun(bool isfirst) async =>
      await _preferences?.setBool(_firstRun, isfirst);

  static String? getToken() => _preferences?.getString(_keyToken);
  static String? getTokenExp() => _preferences?.getString(_keyTokenExp);
  static bool? getIsFirstRun() => _preferences?.getBool(_firstRun);

  static Future setUserId(String userId) async =>
      await _preferences?.setString(_keyUserId, userId);

  static String? getUserId() => _preferences?.getString(_keyUserId);

  // static Future setExpTime(String expTime) async {
  //   DateTime parseExpTimeToDate =
  //       DateFormat("yyyy-MM-dd'T'HH:mm:ssZ").parse(expTime);
  //   var parseExpTimeFormat = DateFormat("yyyy-MM-dd HH:mm:ss");
  //   var parseExpTime = parseExpTimeFormat.format(parseExpTimeToDate);

  //   log("From user preference : " + parseExpTime);

  //   return await _preferences?.setString(_keyExpTime, parseExpTime);
  // }

  static DateTime? getExpTime() {
    final varExpTime = _preferences?.getString(_keyExpTime);

    return varExpTime == null ? null : DateTime.tryParse(varExpTime);
  }

  //clean preference
  Future<void> cleanPreferences() async {
    // SharedPreferences preferences = await SharedPreferences.getInstance();
    await _preferences?.clear();
  }

  //Search history
  static const String _h1 = "h1";

  static setSearchHistory(List<String> h) async =>
      await _preferences?.setStringList(_h1, h);
  static List<String>? getSearch() => _preferences?.getStringList(_h1);

  //Set language system
  static const String _langCode = "lang_code";
  static String? get getLangCode => _preferences?.getString(_langCode);
  static setLanguageSystem(String code) async {
    await _preferences?.setString(_langCode, code);
  }

  static const String _countryCode = "country_code";
  static String? get getCountryCode => _preferences?.getString(_countryCode);
  static setCountryCodeSystem(String code) async {
    await _preferences?.setString(_countryCode, code);
  }
}
