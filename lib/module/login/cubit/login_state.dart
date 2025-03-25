part of 'login_cubit.dart';

enum LoginStatus { initial, success, fail, loading, empty }

enum LogoutStatus { initial, success, fail, loading, empty }

class LoginState extends Equatable {
  final LoginStatus? loginStatus;
  final LogoutStatus? logoutStatus;
  final String? errorMessage;

  const LoginState({
    this.loginStatus = LoginStatus.initial,
    this.logoutStatus = LogoutStatus.initial,
    this.errorMessage,
  });

  LoginState copyWith(
      {LoginStatus? loginStatus,
      LogoutStatus? logoutStatus,
      String? errorMessage}) {
    return LoginState(
        loginStatus: loginStatus ?? this.loginStatus,
        logoutStatus: logoutStatus ?? this.logoutStatus,
        errorMessage: errorMessage ?? this.errorMessage);
  }

  @override
  List<Object?> get props => [loginStatus, logoutStatus, errorMessage];
}
