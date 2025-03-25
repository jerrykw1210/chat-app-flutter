import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:protech_mobile_chat_stream/route/routes.dart';
import 'package:protech_mobile_chat_stream/utils/navigation_service.dart';
import 'package:protech_mobile_chat_stream/utils/pip_controller.dart';
import 'package:protech_mobile_chat_stream/utils/service_locator.dart';
import 'package:rxdart/rxdart.dart';
import 'package:stream_video_flutter/stream_video_flutter.dart';
import 'package:stream_video_flutter/stream_video_flutter_method_channel.dart';

class CallScreen extends StatefulWidget {
  const CallScreen({super.key, required this.call, this.callOptions});
  final Call call;
  final CallConnectOptions? callOptions;

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  final _compositeSubscription = CompositeSubscription();
  Timer? _timer;
  int? _start;

  @override
  void initState() {
    // TODO: implement initState
    // MethodChannelStreamVideoFlutter().setPictureInPictureEnabled(enable: false);
    super.initState();

    _compositeSubscription.add(widget.call.state.listen((state) {
      log("call status ${state.status}");

      Future.delayed(const Duration(seconds: 2), () {
        if (NavigationService.navigatorKey.currentContext != null) {
          if (state.status.isDisconnected &&
              Navigator.of(NavigationService.navigatorKey.currentContext!)
                      .widget
                      .pages
                      .last
                      .name ==
                  AppPage.call.routeName) {
            // MethodChannelStreamVideoFlutter()
            //     .setPictureInPictureEnabled(enable: false);

            if (Navigator.canPop(context)) {
              Navigator.pop(NavigationService.navigatorKey.currentContext!);
            }
          }
        }
      });

      if (state.status.isConnected) {
        if (_start == null && _timer == null) {
          _start = state.liveStartedAt?.millisecondsSinceEpoch ??
              DateTime.now().millisecondsSinceEpoch;

          _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
            setState(() {});
          });
        }

        MethodChannelStreamVideoFlutter()
            .setPictureInPictureEnabled(enable: true);
      }
    }));
  }

  @override
  dispose() {
    _timer?.cancel();
    _compositeSubscription.cancel();
    MethodChannelStreamVideoFlutter().setPictureInPictureEnabled(enable: false);
    super.dispose();
  }

  String _formatDuration(int milliseconds) {
    final int elapsedSeconds = milliseconds ~/ 1000;
    final int minutes = (elapsedSeconds ~/ 60) % 60;
    final int seconds = elapsedSeconds % 60;
    return "${minutes < 10 ? '0$minutes' : minutes}m "
        "${seconds < 10 ? '0$seconds' : seconds}s";
  }

  @override
  Widget build(BuildContext context) {
    return StreamCallContainer(
      call: widget.call,
      callConnectOptions: widget.callOptions,
      onCancelCallTap: () async {
        await widget.call.reject(reason: CallRejectReason.cancel());
        await widget.call.leave();
      },
      callContentBuilder: (context, call, state) {
        return PopScope(
          onPopInvokedWithResult: (didPop, result) {
            sl<PipService>().showPip(context, call,
                initialPosition: Offset(
                    MediaQuery.of(context).size.width - 120 - 20,
                    MediaQuery.of(context).size.height * 0.65));
          },
          child: StreamCallContent(
            call: call,
            callState: state,
            pictureInPictureConfiguration: const PictureInPictureConfiguration(
                enablePictureInPicture: true),
            callAppBarBuilder: (context, call, callState) {
              return AppBar(
                automaticallyImplyLeading: true,
                centerTitle: true,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    sl<PipService>().showPip(context, call,
                        initialPosition: Offset(
                            MediaQuery.of(context).size.width - 120 - 20,
                            MediaQuery.of(context).size.height * 0.65));
                    Navigator.pop(context);
                  },
                ),
                title: Text(_formatDuration(
                    DateTime.now().millisecondsSinceEpoch -
                        (_start ?? DateTime.now().millisecondsSinceEpoch))),
              );
            },
            callControlsBuilder: (context, call, callState) {
              final localParticipant = callState.localParticipant!;
              return StreamCallControls(
                options: [
                  ToggleSpeakerphoneOption(call: call),
                  FlipCameraOption(
                    call: call,
                    localParticipant: localParticipant,
                  ),
                  ToggleMicrophoneOption(
                    call: call,
                    localParticipant: localParticipant,
                  ),
                  ToggleCameraOption(
                    call: call,
                    localParticipant: localParticipant,
                  ),
                  LeaveCallOption(
                    call: call,
                    onLeaveCallTap: () async {
                      if (callState.callParticipants.length > 2) {
                        await call.leave();
                        return;
                      }
                      await call.end();
                    },
                  ),
                ],
              );
            },
            callParticipantsBuilder: (context, call, state) {
              return StreamCallParticipants(
                call: call,
                participants: state.callParticipants,
                callParticipantBuilder: (context, call, state) {
                  return StreamCallParticipant(
                    call: call,
                    participant: state,
                    videoPlaceholderBuilder: (context, call, state) {
                      // Build your placeholder here
                      return Center(
                        child: Text(
                          state.name,
                          style: const TextStyle(fontSize: 32),
                        ),
                      );
                    },
                  );
                },
              );
            },
          ),
        );
      },
      incomingCallBuilder: (context, call, callState) {
        return StreamIncomingCallContent(call: call, callState: callState);
      },
      outgoingCallBuilder: (context, call, callState) {
        return StreamOutgoingCallContent(call: call, callState: callState);
      },
    );
  }
}
