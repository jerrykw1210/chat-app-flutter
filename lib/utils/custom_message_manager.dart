import 'package:flutter/material.dart';
import 'package:protech_mobile_chat_stream/utils/navigation_service.dart';
import 'package:protech_mobile_chat_stream/widgets/message_toast.dart';

class CustomMessageManager {
  static final List<_QueuedMessage> _messages = [];
  static OverlayEntry? _overlayEntry;
  static const int maxMessages = 5;
  static const Duration displayDuration = Duration(seconds: 2);
  static const Duration slideDuration = Duration(milliseconds: 300);

  static void showConnectionStatus({
    required String message,
    Color backgroundColor = Colors.orange,
    Color textColor = Colors.white,
    IconData icon = Icons.info,
  }) {
    _messages.add(_QueuedMessage(
      message: message,
      backgroundColor: backgroundColor,
      textColor: textColor,
      icon: icon,
    ));

    // if (_overlayEntry == null) {
    //   _showOverlay();
    // } else {
    //   _updateOverlay();
    // }

    if (_overlayEntry != null) {
      _removeOverlay();
    }

    _showOverlay(
        message: _QueuedMessage(
      message: message,
      backgroundColor: backgroundColor,
      textColor: textColor,
      icon: icon,
    ));

    // Schedule auto-dismiss for this message
    Future.delayed(displayDuration + slideDuration, () {
      // if (_messages.isNotEmpty) {
      //   _removeMessage(0); // Remove the first message after its duration
      // }
      // _removeOverlay();
    });
  }

  static void _showOverlay(
      {required _QueuedMessage message,
      Duration displayDuration = const Duration(seconds: 2),
      Duration slideDuration = const Duration(milliseconds: 300)}) {
    final overlay = NavigationService.navigatorKey.currentState!.overlay!;
    _overlayEntry = OverlayEntry(
      builder: (context) {
        return MessageToast(
          message: message.message,
          backgroundColor: message.backgroundColor,
          textColor: message.textColor,
          icon: message.icon,
          displayDuration: displayDuration,
          slideDuration: slideDuration,
        );
      },
    );

    overlay.insert(_overlayEntry!);
  }

  static void _updateOverlay() {
    _overlayEntry?.markNeedsBuild();
  }

  static void _removeMessage(int index) {
    if (index >= 0 && index < _messages.length) {
      _messages.removeAt(index); // Remove the message from the list
      _updateOverlay();

      // Remove overlay if no messages are left
      if (_messages.isEmpty) {
        _removeOverlay();
      }
    }
  }

  static void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }
}

class _QueuedMessage {
  final String message;
  final Color backgroundColor;
  final Color textColor;
  final IconData icon;

  _QueuedMessage({
    required this.message,
    required this.backgroundColor,
    required this.textColor,
    required this.icon,
  });
}
