import 'dart:async';

import 'package:flutter/material.dart';
import 'package:protech_mobile_chat_stream/widgets/pip_widget.dart';
import 'package:stream_video_flutter/stream_video_flutter.dart';

class PipService {
  OverlayEntry? _pipOverlay;
  StreamSubscription? streamListener;
  Offset _pipPosition = const Offset(20, 20);
  bool _isCallActive = false;

  void showPip(BuildContext context, Call call,
      {required Offset initialPosition}) {
    if (_pipOverlay != null) return;
    _isCallActive = true;

    _pipPosition = initialPosition;

    _pipOverlay = OverlayEntry(
      builder: (context) =>
          PipWidget(call: call, initialPosition: initialPosition),
    );

    Overlay.of(context).insert(_pipOverlay!);

    streamListener = call.state.listen((state) {
      if (state.status.isDisconnected) {
        dismissPip();
      }
    });
  }

  void dismissPip() {
    _isCallActive = false;
    _pipOverlay?.remove();
    _pipOverlay = null;
    if (streamListener != null) {
      streamListener?.cancel();
    }
  }
}
