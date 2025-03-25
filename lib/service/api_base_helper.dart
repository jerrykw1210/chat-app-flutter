import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart' show Navigator, Text, debugPrint;
import 'package:http/http.dart' as http;
import 'package:protech_mobile_chat_stream/constants/network_constants.dart';
import 'package:protech_mobile_chat_stream/utils/app_exception.dart';
import 'package:protech_mobile_chat_stream/utils/device_info.dart';
import 'package:protech_mobile_chat_stream/utils/helper.dart';
import 'package:protech_mobile_chat_stream/utils/type.dart';

import 'data.dart';

/// This class provide the base helper for API request
///
/// It have method for GET and POST request
///
/// The method will handle the response and error by itself
///
/// The response will be mapped to the desired response that
/// will be passed in the mapper parameter
///
/// The error will be handled by the _handleOnError method
/// and the _handleResponse method will handle the response
/// and return the mapped response
///
/// The _handleOnError method will return [ErrorResponse]
/// and the _handleResponse method will return the mapped response
///
/// The class also have method for checking the authorization
/// token and refresh it if it is expired
///
/// The class is abstract and the method should be implemented
/// by the subclass
abstract class ApiBaseHelper {
  /// Send a GET request to the specified [url] or [fullurl]
  ///
  /// The response will be mapped to the desired response by the [mapper]
  ///
  /// The error will be handled by the _handleOnError method
  /// and the _handleResponse method will handle the response
  /// and return the mapped response
  ///
  /// The _handleOnError method will return [ErrorResponse]
  /// and the _handleResponse method will return the mapped response
  Future<Response> get(
      {required String url,
      required Response Function(String body) mapper,
      Map<String, String>? headers}) {
    if (headers != null) {
      headers.addAll({"DeviceId": DeviceInfoClass.deviceId});
    }

    return http
        .get(Uri.parse(url),
            headers: headers ?? {"DeviceId": DeviceInfoClass.deviceId})
        .timeout(const Duration(seconds: NetworkConstants.timeOutInSecond))
        .then((res) => _handleResponse(res, mapper), onError: _handleOnError);
  }

  /// Send a POST request to the specified [url] or [fullurl]
  ///
  /// The response will be mapped to the desired response by the [mapper]
  ///
  /// The error will be handled by the _handleOnError method
  /// and the _handleResponse method will handle the response
  /// and return the mapped response
  ///
  /// The _handleOnError method will return [ErrorResponse]
  /// and the _handleResponse method will return the mapped response
  Future<Response> post(
      {required String url,
      required Response Function(String body) mapper,
      Map<String, String>? headers,
      JsonMap? body}) {
    log("url ${Uri.parse(url).toString()}");
    // log(Uri.parse(fullurl ?? "").toString());
    log("body ${jsonEncode(body)}");

    if (headers != null) {
      headers.addAll({"Content-Type": "application/json"});
      headers.addAll({"DeviceId": DeviceInfoClass.deviceId});
    }

    log(jsonEncode(body));

    return http
        .post(Uri.parse(url),
            headers: headers ??
                {
                  "Content-Type": "application/json",
                  "DeviceId": DeviceInfoClass.deviceId
                },
            body: jsonEncode(body))
        .timeout(const Duration(seconds: NetworkConstants.timeOutInSecond))
        .then((res) => _handleResponse(res, mapper), onError: _handleOnError);
  }

  Future<Response> upload(
      {required String url,
      required Response Function(String body) mapper,
      Map<String, String>? headers,
      required List<File> files,
      required String fieldName,
      Map<String, String>? body}) async {
    log(jsonEncode(body));

    http.MultipartRequest request =
        http.MultipartRequest('POST', Uri.parse(url));

    for (File file in files) {
      final fileData = await http.MultipartFile.fromPath(fieldName, file.path);
      request.files.add(fileData);
    }

    if (body != null) {
      request.fields.addAll(body);
    }

    if (headers != null) {
      request.headers.addAll(headers);
    }

    log("file ${Helper.formatFileSize(request.files.first.length)}");
    final stopwatch = Stopwatch()..start();
    final streamedResponse = await request.send();
    log('File read time: ${stopwatch.elapsedMilliseconds}ms');

    return _handleUploadResponse(streamedResponse, mapper);
  }

  Future<Response> put(
      {required String url,
      required Response Function(String body) mapper,
      Map<String, String>? headers,
      JsonMap? body}) {
    log(jsonEncode(body));

    if (headers != null) {
      headers.addAll({"Content-Type": "application/json"});
      headers.addAll({"DeviceId": DeviceInfoClass.deviceId});
    }

    return http
        .put(Uri.parse(url),
            headers: headers ??
                {
                  "Content-Type": "application/json",
                  "DeviceId": DeviceInfoClass.deviceId
                },
            body: jsonEncode(body))
        .timeout(const Duration(seconds: NetworkConstants.timeOutInSecond))
        .then((res) => _handleResponse(res, mapper), onError: _handleOnError);
  }

  Future<Response> delete(
      {required String url,
      required Response Function(String body) mapper,
      Map<String, String>? headers,
      JsonMap? body}) {
    return http
        .delete(Uri.parse(url), body: jsonEncode(body), headers: headers)
        .timeout(const Duration(seconds: NetworkConstants.timeOutInSecond))
        .then((res) => _handleResponse(res, mapper), onError: _handleOnError);
  }
  //Check authorization if required token
  // Future<void> checkToken() async {
  //   if (JwtDecoder.isTokenExpired(sl<SecureStorage>().token)) {
  //     await sl<SecureStorage>().refreshToken();
  //   }
  // }

  /// Handle error from the request
  ///
  /// Return [ErrorResponse] based on the error
  ///
  /// If the error is [SocketException], return [NoInternetResponse]
  ///
  /// If the error is [TimeoutException], return [TimeoutResponse]
  ///
  /// Otherwise, return [GeneralErrorResponse]
  ErrorResponse _handleOnError(e) {
    log("API error $e");
    log("API error type ${e.runtimeType}");
    switch (e) {
      case SocketException _:
        return NoInternetResponse();
      case http.ClientException _:
        return ConnectionRefusedResponse();
      case TimeoutException _:
        return TimeoutResponse();
      default:
        return GeneralErrorResponse();
    }
  }

  /// Handle response from the request
  ///
  /// Return [Response] based on the response
  ///
  /// If the response code is 200, check if the response body contains "meta" or "status"
  /// and return [Response] or [BadRequestException] accordingly
  ///
  /// If the response code is 400, return [BadRequestException] with error message
  ///
  /// If the response code is 401 or 403, return [UnauthorisedException]
  ///
  /// Otherwise, return [GeneralErrorResponse]
  Response _handleResponse(
      http.Response response, Response Function(String body) mapper) {
    debugPrint(response.body);
    log("headers ${response.headers}");
    log("Response body: ${response.body}");
    log("Status code: ${response.statusCode}");

    // Check if the 'Content-Type' header includes charset=utf-8
    String contentType = response.headers['content-type'] ?? '';
    bool isUtf8 = contentType.toLowerCase().contains('charset=utf-8');

    String responseBody = response.body;

    // If the content-type doesn't specify UTF-8, manually decode the body
    if (!isUtf8) {
      responseBody = utf8.decode(response.bodyBytes);
      log("utf-8 decoded body: $responseBody");
    }

    switch (response.statusCode) {
      case 200:
        if (jsonDecode(responseBody).containsKey('meta')) {
          switch (jsonDecode(responseBody)['meta']['status']) {
            case 200:
              return mapper(responseBody); // Pass decoded body to the mapper
            default:
              return BadRequestException(jsonDecode(responseBody)['error']);
          }
        } else if (jsonDecode(responseBody).containsKey('status')) {
          switch (jsonDecode(responseBody)['status']) {
            case 200:
              return mapper(responseBody); // Pass decoded body to the mapper
            default:
              return BadRequestException(
                  jsonDecode(responseBody)['error'].toString());
          }
        } else {
          return mapper(responseBody);
        }

      case 400:
        return GeneralErrorResponse();

      case 401:
      case 403:
        // if (NavigationService.navigatorKey.currentContext != null) {
        //   CustomAlertDialog.showGeneralDialog(
        //       context: NavigationService.navigatorKey.currentContext!,
        //       title: "You Have been Logged Out",
        //       content:
        //           const Text("You have been logged out, please login again"),
        //       onPositiveActionPressed: () async {
        //         await LoginCubit().logout();
        //         Navigator.of(NavigationService.navigatorKey.currentContext!)
        //             .pushNamedAndRemoveUntil(
        //                 AppPage.invitationCode.routeName, (route) => false);
        //       });
        // }

        return UnauthorisedException();

      default:
        return GeneralErrorResponse();
    }
  }

  Future<Response> _handleUploadResponse(http.StreamedResponse response,
      Response Function(String body) mapper) async {
    final responseBody = await response.stream.bytesToString();

    debugPrint(responseBody);
    log("Response: $responseBody");
    log("Status code: ${response.statusCode}");
    switch (response.statusCode) {
      case 200:
        return mapper(responseBody);
      case 400:
        return GeneralErrorResponse();
      case 401:
      case 403:
        return UnauthorisedException();
      default:
        return GeneralErrorResponse();
    }
  }
}
