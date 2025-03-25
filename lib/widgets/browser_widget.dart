import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:protech_mobile_chat_stream/module/webview/cubit/toggle_webview_cubit.dart';

class BrowserWidget extends StatefulWidget {
  const BrowserWidget({super.key});

  @override
  State<BrowserWidget> createState() => _BrowserWidgetState();
}

class _BrowserWidgetState extends State<BrowserWidget> {
  final GlobalKey _fabKey = GlobalKey();

  bool isFABVisible = true; // Tracks FAB visibility
  Offset fabPosition = const Offset(0, 0); // Set to bottom right
  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: fabPosition.dx,
      bottom: fabPosition.dy,
      child: Draggable(
        key: _fabKey,
        feedback: FloatingActionButton(
          onPressed: () {},
          child: const Icon(Icons.zoom_in),
        ),
        child: isFABVisible
            ? FloatingActionButton(
                onPressed: () =>
                    context.read<ToggleWebviewCubit>().setIsMinimized(false),
                child: const Icon(Icons.add),
              )
            : Container(),
        onDragEnd: (details) {
          final screenSize = MediaQuery.of(context).size;
          final RenderBox fabBox =
              _fabKey.currentContext!.findRenderObject()! as RenderBox;
          final fabOffset = fabBox
              .localToGlobal(Offset.zero); // Get the global offset of the FAB

          Offset newPosition = Offset(
            fabPosition.dx + details.offset.dx - fabOffset.dx,
            fabPosition.dy + details.offset.dy - fabOffset.dy,
          );

          newPosition = Offset(
            newPosition.dx
                .clamp(0.0, screenSize.width - kFloatingActionButtonMargin),
            newPosition.dy
                .clamp(0.0, screenSize.height - kFloatingActionButtonMargin),
          );
          // Calculate the new position relative to the FAB's original position

          log("fab offset dx: ${details.offset.dx} ${fabOffset.dx} dy: ${details.offset.dy} ${fabOffset.dy}");
          setState(() {
            fabPosition = newPosition; // Update FAB position when dragged
            isFABVisible = true;
          });
          log("is my fab still visible $isFABVisible");
        },
        onDragStarted: () {
          setState(() {
            isFABVisible = false;
          });
        },
      ),
    );
  }
}
