part of 'feedback_cubit.dart';

enum SubmitFeedbackStatus { initial, success, fail, loading, empty }

class FeedbackState extends Equatable {
  FeedbackState(
      {this.submitFeedbackStatus = SubmitFeedbackStatus.initial,
      this.errorMessage});
  SubmitFeedbackStatus submitFeedbackStatus;
  String? errorMessage;

  FeedbackState copyWith({
    SubmitFeedbackStatus? submitFeedbackStatus,
    String? errorMessage,
  }) {
    return FeedbackState(
      submitFeedbackStatus: submitFeedbackStatus ?? this.submitFeedbackStatus,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [submitFeedbackStatus, errorMessage];
}
