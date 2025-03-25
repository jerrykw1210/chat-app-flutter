part of 'register_cubit.dart';

enum RegisterStatus { initial, success, fail, loading, empty }

class RegisterState extends Equatable {
  RegisterStatus? registerStatus;
  String? errorMessage;

  RegisterState({this.registerStatus, this.errorMessage});

  RegisterState copyWith(
      {RegisterStatus? registerStatus, String? errorMessage}) {
    return RegisterState(
        registerStatus: registerStatus ?? this.registerStatus,
        errorMessage: errorMessage ?? this.errorMessage);
  }

  @override
  List<Object?> get props => [registerStatus, errorMessage];
}
