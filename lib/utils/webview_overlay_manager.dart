
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:protech_mobile_chat_stream/module/webview/cubit/toggle_webview_cubit.dart';
import 'package:protech_mobile_chat_stream/module/webview/screen/webview_screen.dart';
import 'package:protech_mobile_chat_stream/utils/navigation_service.dart';

class WebViewOverlayManager {
  static final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  static OverlayEntry? _overlayEntry;

  static void showWebview() {
    final ScaffoldMessengerState? scaffoldMessenger =
        scaffoldMessengerKey.currentState;

    if (_overlayEntry != null) {
      return;
      _overlayEntry!.remove();
    }

    _overlayEntry = OverlayEntry(
      maintainState: true,
      builder: (context) {
        return BlocBuilder<ToggleWebviewCubit, ToggleWebviewState>(
          builder: (context, state) {
            return IndexedStack(
                index: state.isMinimized ? 1 : 0,
                children: [const WebviewScreen(), Container()]);
          },
        );
      },
    );

    // Overlay.of(scaffoldMessenger!.context).insert(_overlayEntry!);

    NavigationService.navigatorKey.currentState!.overlay!
        .insert(_overlayEntry!);

    // Future.delayed(const Duration(seconds: 3), () {
    //   dismissConnectionStatus();
    // });
  }
}
