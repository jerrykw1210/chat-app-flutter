import 'package:protech_mobile_chat_stream/service/authentication_service.dart';
import 'package:protech_mobile_chat_stream/service/response.dart';
import 'package:protech_mobile_chat_stream/utils/service_locator.dart';

class LoginRepository {
  final AuthenticationService _authenticationService =
      sl<AuthenticationService>();

  Future<Response> login(
      {required String invitationCode,
      required String email,
      required String password}) async {
    Response res = await _authenticationService.login(
        invitationCode: invitationCode, email: email, password: password);

    return res;
  }

  Future<Response> loginByPhone(
      {required String invitationCode,
      required String phone,
      required String otp}) async {
    Response res = await _authenticationService.loginByPhone(
        invitationCode: invitationCode, phone: phone, otp: otp);

    return res;
  }

  Future<Response> logout() async {
    Response res = await _authenticationService.logout();

    return res;
  }
}
