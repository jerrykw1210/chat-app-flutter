import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:protech_mobile_chat_stream/utils/shared_preferences.dart';

enum WsErrorTypeEnum {
  dbError("DB_ERROR");

  const WsErrorTypeEnum(this.value);
  final String value;
}

enum HttpEnum { get, post, put }

enum JsonStatusEnum {
  success("success"),
  failure("failure");

  const JsonStatusEnum(this.value);
  final String value;
}

enum AppEnvironmentEnum {
  production('production'),
  development('development'); // dev

  const AppEnvironmentEnum(this.value);
  final String value;
}

extension AppEnvironmentEnumExtension on AppEnvironmentEnum {
  static bool isLive() {
    if (WebserviceClass.developerModeEnabled) {
      return WebserviceClass.developerModeEnvironment().value ==
          AppEnvironmentEnum.production.value;
    }
    return WebserviceClass.productionEnvironment ==
        AppEnvironmentEnum.production;
  }
}

enum JsonStatus { success, failure }

class WebserviceClass {
  //*** IMPORTANT NOTE ***

  // 1. DON'T CHANGE SETTING HERE. DOUBLE CHECK WHEN YOU COMMIT OR WANT TO BUILD APK.

  // 2. UNCOMMENT BELOW LINE WHEN
  //  a. RELEASE TO APP STORE, TESTFLIGHT, PLAY STORE
  //static const _developerModeEnabled = kDebugMode;

  // 3. UNCOMMENT LINE 55 WHEN
  //  a. YOU BUILD FROM YOUR ANDROID STUDIO, XCODE, VSCODE
  //  b. FOR TESTER
  static const _developerModeEnabled = true;

  //  !!!!!!!!!!!! DON'T  CHANGE ANY SETTING BEYOND THIS LINE !!!!!!!!!!!!
  // ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  static get developerModeEnabled => _developerModeEnabled;

  static get forceUpdateEnabled => false;

  static AppEnvironmentEnum productionEnvironment =
      AppEnvironmentEnum.production;

  static AppEnvironmentEnum developerModeEnvironment() {
    return developerModeEnabled
        ? (PrefsStorage.appEnvironment.stringValue ==
                productionEnvironment.value
            ? productionEnvironment
            : AppEnvironmentEnum.development)
        : productionEnvironment;
  }

  // 16 characters - 128 bits
  // 24 characters - 196 bits
  // 32 characters - 256 bits
  static String streamPrivateKey = '45tyrvge8ycx'; // api key

// live url
  static const liveUrl = "https://3.80.228.170:8001/";

  // dev url
  static const devStreamUrl = "https://chat.stream-io-api.com/";
  static const devUrl = "https://3.80.228.170:8001/";

  static String get mainUrl =>
      AppEnvironmentEnumExtension.isLive() ? liveUrl : devUrl;

  static get channelUrl => "${mainUrl}channels";

  static get loginUrl => "${mainUrl}api/auth/authenticate";

  static asyncRequest({
    required HttpEnum type,
    required String uri,
    Map<String, dynamic>? parameters,
    Map<String, dynamic>? body,
    required Function(int statusCode, Map<String, dynamic> body) onOutput,
  }) async {
    final urlInString = Uri.parse(uri).replace(queryParameters: parameters);

    //call api

    try {
      Duration duration = const Duration(seconds: 30);

      // default: itower

      dynamic headers = _setHeaders();

      // get http response
      http.Response? response;

      switch (type) {
        case HttpEnum.get:
          response =
              await http.get(urlInString, headers: headers).timeout(duration);

          break;

        case HttpEnum.post:
          response = await http
              .post(urlInString, body: jsonEncode(body), headers: headers)
              .timeout(duration);

          break;

        case HttpEnum.put:
          response = await http.put(urlInString, headers: headers);

          break;
      }

      // json object
      final jsonObject = json.decode(response.body);

      // print nicely

      debugPrint(response.request?.url.toString());
      final prettyString =
          const JsonEncoder.withIndent('  ').convert(jsonObject);
      debugPrint(prettyString);

      // var jsonStatus = (jsonObject['status'].toString().toLowerCase() ==
      //         JsonStatusEnum.success.value ||
      //     jsonObject["code"] == 0);

      return onOutput(response.statusCode, jsonObject);
    } catch (error) {
      if (error is TimeoutException) {
        // CommonUtil.showAlert(
        //   title: Strings.txtRequestTimeout,
        //   msg: Strings.txtMsgTimeOut,
        // );
      }
      debugPrint("webservice error is $error");
      throw http.ClientException("Error on api call");
    }
  }

  static _setHeaders({
    String contentType = 'application/json',
    String? authorizationHeader,
  }) {
    var header = {
      'Authorization': authorizationHeader, // user token
      'Stream-Auth-Type': 'jwt',
      'Content-Type': contentType
    };

    if (authorizationHeader != null) {
      header[HttpHeaders.authorizationHeader] = authorizationHeader;
    }

    return header;
  }
}

String getPrettyJSONString(jsonObject) {
  var encoder = const JsonEncoder.withIndent("     ");
  return encoder.convert(jsonObject);
}
