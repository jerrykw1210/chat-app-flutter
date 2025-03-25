import 'package:flutter/material.dart';
import 'package:protech_mobile_chat_stream/utils/navigation_service.dart';
import 'package:protech_mobile_chat_stream/widgets/connection_status_bar.dart';

class ConnectionStatusManager {
  static final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  static OverlayEntry? _overlayEntry;

  static void showConnectionStatus({
    required String message,
    StatusBarType statusBarType = StatusBarType.warning,
  }) {
    final ScaffoldMessengerState? scaffoldMessenger =
        scaffoldMessengerKey.currentState;

    if (_overlayEntry != null) {
      _overlayEntry!.remove();
    }

    _overlayEntry = OverlayEntry(
      builder: (context) {
        return Stack(
          children: [
            Positioned(
              top: kToolbarHeight,
              left: 0,
              right: 0,
              child: ConnectionStatusBar(
                message: message,
                statusBarType: statusBarType,
              ),
            ),
          ],
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

  static void dismissConnectionStatus() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }
}
