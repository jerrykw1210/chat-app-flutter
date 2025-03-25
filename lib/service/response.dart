abstract class Response {}

abstract class SuccessfulResponse extends Response {}

abstract class ErrorResponse extends Response {}

//Common success message response
class CommonSuccessResponse extends SuccessfulResponse {
  final String message;
  CommonSuccessResponse({this.message = ""});
}

//Common Map response
class MapSuccessResponse extends SuccessfulResponse {
  final Map<String, dynamic> jsonRes;
  MapSuccessResponse({this.jsonRes = const {}});
}

//Internal error response
class NoInternetResponse extends ErrorResponse {}

class ConnectionRefusedResponse extends ErrorResponse {}

class TimeoutResponse extends ErrorResponse {}

class GeneralErrorResponse extends ErrorResponse {}
