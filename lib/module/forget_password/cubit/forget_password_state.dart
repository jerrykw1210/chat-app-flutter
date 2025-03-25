part of 'forget_password_cubit.dart';

enum ForgetPasswordStatus { initial, success, fail, loading, empty }

class ForgetPasswordState extends Equatable {
  ForgetPasswordState(
      {this.forgetPasswordStatus = ForgetPasswordStatus.initial, this.errorMessage});
  final ForgetPasswordStatus? forgetPasswordStatus;
  String? errorMessage;

  ForgetPasswordState copyWith({
    ForgetPasswordStatus? forgetPasswordStatus,
    String? errorMessage,
  }) {
    return ForgetPasswordState(
      forgetPasswordStatus: forgetPasswordStatus ?? this.forgetPasswordStatus,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [forgetPasswordStatus, errorMessage];
}
