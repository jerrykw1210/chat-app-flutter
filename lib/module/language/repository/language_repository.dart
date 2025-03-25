
import 'package:protech_mobile_chat_stream/service/language_service.dart';
import 'package:protech_mobile_chat_stream/service/response.dart';
import 'package:protech_mobile_chat_stream/utils/service_locator.dart';

class LanguageRepository {
  final LanguageService _languageService = sl<LanguageService>();
  Future<Response> getLanguageFile(String path) async {
    return _languageService.getLanguageFile(path);
  }

  Future<Response> getLanguageList() async {
    return _languageService.getLanguageList();
  }
}
