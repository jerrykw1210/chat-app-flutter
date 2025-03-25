import 'package:flutter/material.dart';
import 'package:protech_mobile_chat_stream/utils/navigation_service.dart';
import 'package:protech_mobile_chat_stream/widgets/custom_bottom_sheet.dart';

class BottomSheetManager {
  static final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  static OverlayEntry? _overlayEntry;

  // final vsync = TickerProviderState.of(context);

  // Create the AnimationController using the TickerProvider
  //   final animationController = BottomSheet.createAnimationController(vsync);

  // // Create an AnimationController
  // final animationController = BottomSheet.createAnimationController(
  //     NavigationService.navigatorKey.currentState!.overlay!.context);

  static void showCustomBottomSheet(
      {required Widget Function(BuildContext) builder}) {
    if (_overlayEntry != null) {
      // return;
      _overlayEntry!.remove();
    }

    _overlayEntry = OverlayEntry(
      maintainState: true,
      builder: (context) {
        return CustomBottomSheet(
            builder: builder,
            onClose: () {
              // Handle the closing logic
              _overlayEntry?.remove();
              _overlayEntry = null;
            });
      },
    );

    // Overlay.of(scaffoldMessenger!.context).insert(_overlayEntry!);

    NavigationService.navigatorKey.currentState!.overlay!
        .insert(_overlayEntry!);

    // Future.delayed(const Duration(seconds: 3), () {
    //   dismissConnectionStatus();
    // });
  }

  static void close() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }
}
