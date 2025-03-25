import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:protech_mobile_chat_stream/module/call/screen/call_screen.dart';
import 'package:protech_mobile_chat_stream/route/routes.dart';
import 'package:protech_mobile_chat_stream/utils/helper.dart';
import 'package:protech_mobile_chat_stream/utils/navigation_service.dart';
import 'package:stream_video_flutter/stream_video_flutter.dart' as sv;

class GetStreamService {
  final userToken =
      "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoia2lraSJ9._OFOmA4D8rA9ezRSGQYKraHFGpWiGtxJJKgpN_KzX_k";
  // final userToken =
  //     "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiY29tZXRjaGF0LXVpZC00In0.KDZGsW3ratLM2Wexl8ZamJWCEMtJ30MLyNf2hLeQTfg";
  // final client = sl<StreamChatClient>();
  // final videoClient = sl<sv.StreamVideo>();
  // final client = StreamChatClient(dotenv.env['GETSTREAM_API_KEY'].toString(),
  //     logLevel: Level.INFO);

  Future<void> disconnect() async {
    await sv.StreamVideo.instance.disconnect();
    await sv.StreamVideo.reset();
  }

  Future<void> initiateCall(
      {required List<String> targetUserId,
      required String targetId,
      bool video = true,
      required bool isGroup}) async {
    String callId = Helper.generateUUID();

    Map<String, Object> custom = {"targetId": targetId, "isGroup": isGroup};

    final call = sv.StreamVideo.instance
        .makeCall(callType: sv.StreamCallType.defaultType(), id: callId);

    bool isRinging = targetUserId.isNotEmpty;

    sv.CallConnectOptions? callConnectOptions;

    if (video) {
      callConnectOptions = sv.CallConnectOptions(
          speakerDefaultOn: true,
          camera: sv.TrackOption.enabled(),
          microphone: sv.TrackOption.enabled());
    } else {
      callConnectOptions = sv.CallConnectOptions(
          speakerDefaultOn: false,
          camera: sv.TrackOption.disabled(),
          microphone: sv.TrackOption.enabled());
    }

    try {
      await call.getOrCreate(
          memberIds: targetUserId,
          ringing: isRinging,
          video: video,
          custom: custom);
    } catch (e, stk) {
      log('Error joining or creating call: $e');
      log(stk.toString());
    }

    NavigationService.navigatorKey.currentState?.pushAndRemoveUntil(
      MaterialPageRoute(
          builder: (context) =>
              CallScreen(call: call, callOptions: callConnectOptions),
          settings: RouteSettings(name: AppPage.call.routeName)),
      (route) =>
          route.isCurrent && route.settings.name == AppPage.call.routeName
              ? false
              : true,
    );
  }
}
