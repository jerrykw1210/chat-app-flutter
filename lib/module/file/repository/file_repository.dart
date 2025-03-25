import 'dart:typed_data';

import 'package:image_picker/image_picker.dart';
import 'package:protech_mobile_chat_stream/service/data.dart';
import 'package:protech_mobile_chat_stream/service/file_service.dart';
import 'package:protech_mobile_chat_stream/utils/service_locator.dart';

class FileRepository {
  final FileService _fileService = sl<FileService>();
  Future<Response> uploadImage({required XFile file}) async {
    return _fileService.uploadImage(imageFile: file);
  }

  Future<Response> uploadFile({required XFile file}) async {
    return _fileService.uploadFile(attachment: file);
  }

  Future<Uint8List> getImage({required String fileUrl}) async {
    return _fileService.getImage(fileUrl: fileUrl);
  }

  Future<Uint8List> getThumbnailImage({required String fileUrl}) async {
    return _fileService.getThumbnailImage(fileUrl: fileUrl);
  }

  Future<Response> uploadGroupProfileImage(
      {required XFile file, required String groupId}) async {
    return _fileService.uploadGroupProfileImage(
        imageFile: file, groupId: groupId);
  }

  Future<Response> uploadProfileImage({required XFile file}) async {
    return _fileService.uploadProfileImage(imageFile: file);
  }
}
