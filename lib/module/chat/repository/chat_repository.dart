import 'dart:developer';

import 'package:image_picker/image_picker.dart';
import 'package:protech_mobile_chat_stream/module/chat/service/chat_service.dart';
import 'package:protech_mobile_chat_stream/service/response.dart';
import 'package:protech_mobile_chat_stream/utils/service_locator.dart';

class ChatRepository {
  final ChatService _chatService = sl<ChatService>();

  Future<Response> getGif() async {
    Response res = await _chatService.getGif();
    return res;
  }

  Future<Response> searchGif(String keyword) async {
    Response res = await _chatService.searchGif(keyword);
    return res;
  }

  Future<Response> uploadImage(String attachment, String receiverId,
      {String? groupId = ""}) async {
    Response res = await _chatService.uploadImage(attachment, receiverId,
        groupId: groupId);
    log("image upload res $res");
    return res;
  }

  Future<Response> addSticker(XFile imageFile) async {
    Response res = await _chatService.addSticker(imageFile);
    log("sticker upload res $res");
    return res;
  }

  Future<Response> getStickerList(String userId) async {
    Response res = await _chatService.getStickerList(userId);
    log("sticker fetch res $res");
    return res;
  }

  Future<Response> deleteSticker(String stickerUrl) async {
    Response res = await _chatService.deleteSticker(stickerUrl);
    log("sticker delete res $res");
    return res;
  }
}
