import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:protech_mobile_chat_stream/constants/string_constant.dart';

part 'connection_status_state.dart';

class ConnectionStatusCubit extends Cubit<ConnectionStatusState> {
  ConnectionStatusCubit() : super(ConnectionStatusState());

  void showConnectionStatus(String message) {
    emit(ConnectionStatusState(
      showConnectionStatus: true,
      message: message,
    ));
  }

  void dismissConnectionStatus() {
    emit(ConnectionStatusState(
      showConnectionStatus: false,
      message: "",
    ));
  }

  void noInternetConnection() {
    emit(ConnectionStatusState(
      showConnectionStatus: true,
      noInternetConnection: true,
      message: Strings.noInternetConnection,
    ));
  }

  void noInternetConnectionDismiss() {
    emit(ConnectionStatusState(
      noInternetConnection: false,
    ));
  }
}
