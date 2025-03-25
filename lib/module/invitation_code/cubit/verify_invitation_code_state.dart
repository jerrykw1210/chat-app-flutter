part of 'verify_invitation_code_cubit.dart';

enum VerifyStatus { initial, success, fail, loading, empty }

class VerifyInvitationCodeState extends Equatable {
  VerifyInvitationCodeState(
      {this.verifyStatus = VerifyStatus.initial,
      this.invitationCode = "",
      this.errorMessage});
  final VerifyStatus verifyStatus;
  String? invitationCode;
  String? errorMessage;

  @override
  List<Object?> get props => [verifyStatus, invitationCode, errorMessage];

  VerifyInvitationCodeState copyWith(
      {VerifyStatus? verifyStatus,
      String? invitationCode,
      String? errorMessage}) {
    return VerifyInvitationCodeState(
        verifyStatus: verifyStatus ?? this.verifyStatus,
        errorMessage: errorMessage ?? this.errorMessage,
        invitationCode: invitationCode ?? this.invitationCode);
  }
}
