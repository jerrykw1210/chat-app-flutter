abstract class TurmsResponse<T> {}

abstract class TurmsSuccessfulResponse<T> extends TurmsResponse<T> {}

abstract class TurmsErrorResponse<T> extends TurmsResponse<T> {}

class TurmsMapSuccessResponse<T> extends TurmsSuccessfulResponse<T> {
  final T? res;
  TurmsMapSuccessResponse({this.res});
}

class TurmsInvalidErrorResponse<T> extends TurmsErrorResponse<T> {
  final String code;
  final String reason;
  TurmsInvalidErrorResponse({required this.code, required this.reason});
}

//Internal error response
class TurmsNoInternetResponse<T> extends TurmsErrorResponse<T> {}

class TurmsConnectionRefusedResponse<T> extends TurmsErrorResponse<T> {}

class TurmsTimeoutResponse<T> extends TurmsErrorResponse<T> {}

class TurmsGeneralErrorResponse<T> extends TurmsErrorResponse<T> {}

class TurmsUnknownErrorResponse<T> extends TurmsErrorResponse<T> {}
