import 'package:image_picker/image_picker.dart';
import 'package:protech_mobile_chat_stream/service/feedback_service.dart';
import 'package:protech_mobile_chat_stream/service/response.dart';
import 'package:protech_mobile_chat_stream/utils/service_locator.dart';

class FeedbackRepository {
  final FeedbackService _feedbackService = sl<FeedbackService>();
  Future<Response> submitFeedback(
      {required String content,
      required String category,
      required List<String> attachment}) async {
    return _feedbackService.submitFeedback(
        content: content, category: category, attachment: attachment);
  }

  Future<Response> uploadFeedbackImage({required XFile attachment}) async {
    return _feedbackService.uploadFeedbackImage(attachment);
  }
}
