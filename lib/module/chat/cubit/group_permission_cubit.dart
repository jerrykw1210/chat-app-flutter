import 'dart:convert';
import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:fixnum/fixnum.dart';
import 'package:no_screenshot/no_screenshot.dart';
import 'package:protech_mobile_chat_stream/service/credential_service.dart';
import 'package:protech_mobile_chat_stream/service/database_helper.dart';
import 'package:protech_mobile_chat_stream/utils/service_locator.dart';
import 'package:turms_client_dart/turms_client.dart';

part 'group_permission_state.dart';

class GroupPermissionCubit extends Cubit<GroupPermissionState> {
  GroupPermissionCubit() : super(const GroupPermissionState());

  void toggleScreenshot() async {
    final noScreenshot = NoScreenshot.instance;
    bool screenshotDisabled = !state.disableScreenshot;
    if (screenshotDisabled) {
      bool res = await noScreenshot.screenshotOff();
      log("screenshot on? $res");
    } else {
      noScreenshot.screenshotOn();
    }

    emit(state.copyWith(disableScreenshot: screenshotDisabled));
  }

  Future<void> updateConversationSettings(
      Int64 groupId, ConversationSettings conversationSettings) async {
    try {
      final conversationSettingsRes = await sl<TurmsClient>()
          .conversationService
          .upsertGroupConversationSettings(
              groupId, conversationSettings.settings);
      log("conversation settings response ${conversationSettingsRes.code}");
      log("message settings ${conversationSettings.settings}");
      if (conversationSettingsRes.code == 1000) {
        sl<DatabaseHelper>().updateGroupSettings(
            conversationId: DatabaseHelper.conversationId(
                targetId: groupId.toString(),
                myId: sl<CredentialService>().turmsId!),
            settings: jsonEncode(conversationSettings.writeToJsonMap()));
        // emit(state.copyWith(
        //     conversationSettings: conversationSettingsRes.data?.settings));
      }
    } catch (e) {
      log("error updating conversation settings $e");
    }
  }
}
