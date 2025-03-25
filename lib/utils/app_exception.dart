import '../service/data.dart';

//Exception from API
class AppException implements Exception, ErrorResponse {
  final String message;
  final String prefix;

  AppException({this.message = "", this.prefix = ""});

  @override
  String toString() => "$prefix$message";
}

class GeneralException extends AppException {
  GeneralException([String message = ""])
      : super(message: message, prefix: "Error During Communication: ");
}

//400
class BadRequestException extends AppException {
  BadRequestException([String message = ""])
      : super(message: message, prefix: "Invalid Request: ");
}

class AlreadyLoggedInException extends AppException {
  AlreadyLoggedInException() {
    _navigate();
  }

  ///*******Force sign out**********
  void _navigate() async {
    await UserPreferences.setFirstRun(true);
    // await notifyDialog(
    //     sl<NavigationService>().navigatorKey.currentState!.context,
    //     title: "you-have-already-logged-in".i18n(),
    //     content: "sub-you-have-already-logged-in".i18n());
    // Navigator.of(sl<NavigationService>().navigatorKey.currentState!.context)
    //     .pushNamedAndRemoveUntil(FirstScreen.routeName, (route) => false);
  }
}

//403
class UnauthorisedException extends AppException {
  UnauthorisedException([String message = ""])
      : super(message: message, prefix: "Unauthorised: ");
}

class InvalidInputException extends AppException {
  InvalidInputException([String message = ""])
      : super(message: message, prefix: "Invalid Input: ");
}
