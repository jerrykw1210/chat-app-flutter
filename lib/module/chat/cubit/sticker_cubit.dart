import 'dart:developer';
import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:protech_mobile_chat_stream/constants/network_constants.dart';
import 'package:protech_mobile_chat_stream/module/chat/repository/chat_repository.dart';
import 'package:protech_mobile_chat_stream/service/credential_service.dart';
import 'package:protech_mobile_chat_stream/service/database_helper.dart';
import 'package:protech_mobile_chat_stream/service/response.dart';
import 'package:protech_mobile_chat_stream/utils/service_locator.dart';
import 'package:http/http.dart' as http;

part 'sticker_state.dart';

class StickerCubit extends Cubit<StickerState> {
  StickerCubit() : super(const StickerState());
  final ChatRepository _chatRepository = sl<ChatRepository>();
  void addSticker(XFile image) async {
    emit(state.copyWith(addStickerStatus: AddStickerStatus.loading));
    final res = await _chatRepository.addSticker(image);
    if (res is MapSuccessResponse) {
      sl<DatabaseHelper>().upsertSticker(
          stickerPath: image.path,
          stickerUrl: res.jsonRes['data']['stickerUrl']);
      emit(state.copyWith(addStickerStatus: AddStickerStatus.success));
    }
  }

  void getStickerList(String userId) async {
    emit(state.copyWith(fetchStickerStatus: FetchStickerStatus.loading));
    final res = await _chatRepository.getStickerList(userId.toString());
    if (res is MapSuccessResponse) {
      // await sl<DatabaseHelper>().upsertSticker();
      final tempDir = await getTemporaryDirectory();
      String? targetPath;
      for (Map<String, dynamic> sticker in res.jsonRes['data']) {
        targetPath = "${tempDir.path}/${sticker['stickerUrl']}.jpg";
        if (!File(targetPath).existsSync()) {
          try {
            final getStickerRes = await http.get(Uri.parse(
                "${NetworkConstants.getStickerWithTokenUrl}${sticker['stickerUrl']}?token=${sl<CredentialService>().jwtToken}"));
            if (getStickerRes.statusCode == 200) {
              log("status ${getStickerRes.statusCode}");

              // Write the downloaded bytes to a file
              await File(targetPath)
                  .writeAsBytes(getStickerRes.bodyBytes)
                  .then((File file) {
                sl<DatabaseHelper>().upsertSticker(
                    stickerPath: targetPath.toString(),
                    stickerUrl: sticker['stickerUrl']);
              });
            } else {
              throw Exception(
                  "Failed to get sticker. Status code: ${getStickerRes.statusCode}");
            }
          } on Exception catch (e) {
            throw Exception("Failed to get sticker. Error: $e");
          }
        }
      }

      emit(state.copyWith(fetchStickerStatus: FetchStickerStatus.success));
    }
  }

  void deleteSticker(String stickerUrl) async {
    emit(state.copyWith(deleteStickerStatus: DeleteStickerStatus.loading));
    log("sticker delete $stickerUrl");
    final res = await _chatRepository.deleteSticker(stickerUrl.toString());
    if (res is MapSuccessResponse) {
      await sl<DatabaseHelper>().deleteSticker(stickerUrl);

      emit(state.copyWith(deleteStickerStatus: DeleteStickerStatus.success));
    }
  }
}
