part of 'connection_status_cubit.dart';

class ConnectionStatusState extends Equatable {
  bool showConnectionStatus;
  bool noInternetConnection;
  String? message;
  ConnectionStatusState(
      {this.showConnectionStatus = false,
      this.message,
      this.noInternetConnection = false});

  ConnectionStatusState copyWith({
    bool? showConnectionStatus,
    bool? noInternetConnection,
    String? message,
  }) {
    return ConnectionStatusState(
      showConnectionStatus: showConnectionStatus ?? this.showConnectionStatus,
      noInternetConnection: noInternetConnection ?? this.noInternetConnection,
      message: message ?? this.message,
    );
  }

  @override
  List<Object?> get props =>
      [showConnectionStatus, message, noInternetConnection];
}
