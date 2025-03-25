import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:protech_mobile_chat_stream/constants/network_constants.dart';
import 'package:protech_mobile_chat_stream/service/credential_service.dart';
import 'package:protech_mobile_chat_stream/service/data.dart';
import 'package:protech_mobile_chat_stream/utils/service_locator.dart';

class FriendService extends ApiBaseHelper {
  final FlutterSecureStorage _storage = sl<FlutterSecureStorage>();
  final CredentialService _credentialService = sl<CredentialService>();

  Future<Response> searchFriendsByPhone({required String phone}) async {
    String? jwtToken = _credentialService.jwtToken;

    String url = NetworkConstants.searchUserUrl + "?phone=$phone";

    Map<String, String> headers = {"Authorization": "Bearer $jwtToken"};

    return get(
        url: url,
        headers: headers,
        mapper: (resBody) => MapSuccessResponse(jsonRes: jsonDecode(resBody)));
  }
}
