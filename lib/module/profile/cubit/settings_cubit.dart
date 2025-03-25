import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:protech_mobile_chat_stream/service/turms_response.dart';
import 'package:protech_mobile_chat_stream/service/turms_service.dart';
import 'package:protech_mobile_chat_stream/utils/service_locator.dart';
import 'package:turms_client_dart/turms_client.dart';

part 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit() : super(const SettingsState());
  final TurmsService turmsService = sl<TurmsService>();

  Future<void> deleteChatHistory() async {
    emit(state.copyWith(
        deleteChatHistoryStatus: DeleteChatHistoryStatus.loading));

    final res = await turmsService.handleTurmsResponse<dynamic>(() async {
      
      final res = await sl<TurmsClient>().messageService.deleteMessage(
          deviceType: Platform.isAndroid ? DeviceType.ANDROID : DeviceType.IOS,
          endDate: DateTime.now().millisecondsSinceEpoch.toInt64());
      return res.data;
    });

    if (res is TurmsMapSuccessResponse<dynamic>) {
      emit(state.copyWith(
          deleteChatHistoryStatus: DeleteChatHistoryStatus.success));
      return;
    }

    if (res is TurmsInvalidErrorResponse<dynamic>) {
      emit(state.copyWith(
          deleteChatHistoryStatus: DeleteChatHistoryStatus.fail,
          errorMessage: res.reason));
      return;
    }

    emit(state.copyWith(deleteChatHistoryStatus: DeleteChatHistoryStatus.fail));
  }
}
