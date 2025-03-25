import 'package:flutter/material.dart';
import 'package:protech_mobile_chat_stream/utils/navigation_service.dart';
import 'package:protech_mobile_chat_stream/widgets/draggable_floating_action_button.dart';

class BrowserMinimisedManager {
  static final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  static OverlayEntry? _overlayEntry;

  static void showMinimisedButton() {
    final ScaffoldMessengerState? scaffoldMessenger =
        scaffoldMessengerKey.currentState;

    if (_overlayEntry != null) {
      return;
      _overlayEntry!.remove();
    }

    _overlayEntry = OverlayEntry(
      builder: (context) {
        return DraggableFloatingActionButton(
            onPressed: () {},
            initialFabPosition: Offset(
                MediaQuery.of(context).size.width - 50 - 20,
                MediaQuery.of(context).size.height * 0.65));
      },
    );

    // Overlay.of(scaffoldMessenger!.context).insert(_overlayEntry!);

    NavigationService.navigatorKey.currentState!.overlay!
        .insert(_overlayEntry!);

    // Future.delayed(const Duration(seconds: 3), () {
    //   dismissConnectionStatus();
    // });
  }

  static void removeMinimisedButton() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }
}
