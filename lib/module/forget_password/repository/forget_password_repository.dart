import 'package:protech_mobile_chat_stream/service/authentication_service.dart';
import 'package:protech_mobile_chat_stream/service/response.dart';
import 'package:protech_mobile_chat_stream/utils/service_locator.dart';

class ForgetPasswordRepository {
  final AuthenticationService _authenticationService =
      sl<AuthenticationService>();

  Future<Response> forgetPassword(
      {required String email,
      required String otp,
      required String invitationCode,
      required newPassword}) async {
    Response res = await _authenticationService.resetPassword(
        email: email,
        invitationCode: invitationCode,
        otp: otp,
        password: newPassword);
    return res;
  }

  Future<Response> forgetPasswordByPhone(
      {required String phone,
      required String otp,
      required String invitationCode,
      required newPassword}) async {
    Response res = await _authenticationService.resetPasswordbyPhone(
        phone: phone,
        invitationCode: invitationCode,
        otp: otp,
        password: newPassword);
    return res;
  }
}
