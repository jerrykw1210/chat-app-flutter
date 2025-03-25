import 'package:protech_mobile_chat_stream/service/authentication_service.dart';
import 'package:protech_mobile_chat_stream/service/response.dart';
import 'package:protech_mobile_chat_stream/utils/service_locator.dart';

class RegisterRepository {
  final AuthenticationService _authenticationService =
      sl<AuthenticationService>();

  Future<Response> register({
    required String invitationCode,
    required String username,
    required String password,
    required String email,
    required String otp,
  }) async {
    Response res = await _authenticationService.register(
        invitationCode: invitationCode,
        username: username,
        password: password,
        email: email,
        otp: otp);

    return res;
  }
}
