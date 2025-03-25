import 'package:protech_mobile_chat_stream/service/authentication_service.dart';
import 'package:protech_mobile_chat_stream/service/response.dart';
import 'package:protech_mobile_chat_stream/utils/service_locator.dart';

class VerifyInvitationCodeRepository {
  final AuthenticationService _authenticationService =
      sl<AuthenticationService>();

  Future<Response> verifyInvitationCode(
      {required String invitationCode}) async {
    Response res = await _authenticationService.verifyInvitationCode(
        invitationCode: invitationCode);

    return res;
  }
}
