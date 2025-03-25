import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:protech_mobile_chat_stream/module/webview/cubit/toggle_webview_cubit.dart';
import 'package:protech_mobile_chat_stream/utils/browser_minimised_manager.dart';

class DraggableFloatingActionButton extends StatefulWidget {
  final VoidCallback onPressed;
  final bool minimized;
  final Offset initialFabPosition;

  const DraggableFloatingActionButton({
    required this.onPressed,
    required this.initialFabPosition,
    this.minimized = true,
    super.key,
  });

  @override
  State<DraggableFloatingActionButton> createState() =>
      _DraggableFloatingActionButtonState();
}

class _DraggableFloatingActionButtonState
    extends State<DraggableFloatingActionButton> {
  late Offset _fabPosition; // Initial position
  bool _visible = true;
  int animationSpeed = 500;
  bool _isInDropZone = false;
  bool _animateDropZone = false;
  bool _dragStarted = false;

  @override
  void initState() {
    _fabPosition = widget.initialFabPosition;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    // FAB size to calculate bounds
    const fabSize = 50.0;

    return Stack(
      children: [
        // Quarter-circle overlay in the bottom-right corner
        BlocBuilder<ToggleWebviewCubit, ToggleWebviewState>(
          builder: (context, state) {
            if (state.isMinimized) {
              return Positioned(
                bottom: 0,
                right: 0,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.fastOutSlowIn,
                  width: _dragStarted
                      ? _animateDropZone
                          ? screenWidth / 2.8
                          : screenWidth / 3
                      : 0,
                  height: _dragStarted
                      ? _animateDropZone
                          ? screenWidth / 2.8
                          : screenWidth / 3
                      : 0,
                  decoration: BoxDecoration(
                    color: _animateDropZone
                        ? Colors.black.withOpacity(0.5)
                        : Colors.black
                            .withOpacity(0.3), // Animated color change
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(300),
                    ),
                  ),
                  child: const Align(
                      alignment: Alignment(0.2, 0.2),
                      child: Icon(Icons.delete, color: Colors.white, size: 30)),
                ),
              );
            }

            return const SizedBox.shrink();
          },
        ),
        AnimatedPositioned(
          duration: Duration(milliseconds: animationSpeed),
          curve: Curves.easeOut,
          left: _fabPosition.dx,
          top: _fabPosition.dy,
          child: BlocBuilder<ToggleWebviewCubit, ToggleWebviewState>(
            builder: (context, state) {
              log("state ${state.isMinimized}");
              return Draggable(
                onDragStarted: () {
                  setState(() {
                    _visible = false;
                    _dragStarted = true;
                  });
                },
                feedback: Container(
                  decoration: state.isMinimized
                      ? BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                              begin: Alignment.bottomLeft,
                              end: Alignment.topRight,
                              colors: [
                                Colors.white,
                                const Color.fromARGB(255, 169, 205, 255),
                                Theme.of(context).primaryColorLight,
                                Theme.of(context).primaryColorLight
                              ],
                              stops: const [
                                0.0,
                                0.02,
                                0.48,
                                1.0
                              ]))
                      : const BoxDecoration(
                          shape: BoxShape.circle,
                        ),
                  height: 50,
                  width: 50,
                  child: FittedBox(
                    child: FloatingActionButton(
                      elevation: 0,
                      focusElevation: 0,
                      hoverElevation: 0,
                      highlightElevation: 0,
                      disabledElevation: 0,
                      shape: CircleBorder(
                          side: state.isMinimized
                              ? BorderSide.none
                              : const BorderSide(
                                  color: Color.fromARGB(255, 216, 216, 216),
                                  width: 3)),
                      backgroundColor: state.isMinimized
                          ? Theme.of(context).primaryColorLight
                          : Colors.transparent,
                      onPressed: () {
                        if (state.isInitialized && !state.isMinimized) {
                          context
                              .read<ToggleWebviewCubit>()
                              .setIsMinimized(true);
                          context
                              .read<ToggleWebviewCubit>()
                              .setCurrentIndex(state.lastIndex);
                          return;
                        }
                        context.read<ToggleWebviewCubit>().openWebview();
                      },
                      child: state.isMinimized
                          ? const Icon(Icons.public,
                              color: Colors.white, size: 30)
                          : const Icon(Icons.close,
                              color: Color.fromARGB(255, 191, 191, 191),
                              size: 30),
                    ),
                  ),
                ),
                child: Visibility(
                  visible: _visible,
                  child: Container(
                    decoration: state.isMinimized
                        ? BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                                begin: Alignment.bottomLeft,
                                end: Alignment.topRight,
                                colors: [
                                  Colors.white,
                                  const Color.fromARGB(255, 169, 205, 255),
                                  Theme.of(context).primaryColorLight,
                                  Theme.of(context).primaryColorLight
                                ],
                                stops: const [
                                  0.0,
                                  0.02,
                                  0.48,
                                  1.0
                                ]))
                        : const BoxDecoration(
                            shape: BoxShape.circle,
                          ),
                    height: 50,
                    width: 50,
                    child: FittedBox(
                      child: FloatingActionButton(
                        elevation: 0,
                        focusElevation: 0,
                        hoverElevation: 0,
                        highlightElevation: 0,
                        disabledElevation: 0,
                        shape: CircleBorder(
                            side: state.isMinimized
                                ? BorderSide.none
                                : const BorderSide(
                                    color: Color.fromARGB(255, 216, 216, 216),
                                    width: 3)),
                        backgroundColor: Colors.transparent,
                        onPressed: () {
                          if (state.isInitialized && !state.isMinimized) {
                            context
                                .read<ToggleWebviewCubit>()
                                .setIsMinimized(true);
                            context
                                .read<ToggleWebviewCubit>()
                                .setCurrentIndex(state.lastIndex);
                            return;
                          }
                          context.read<ToggleWebviewCubit>().openWebview();
                        },
                        child: state.isMinimized
                            ? const Icon(Icons.public,
                                color: Colors.white, size: 30)
                            : const Icon(Icons.close,
                                color: Color.fromARGB(255, 191, 191, 191),
                                size: 30),
                      ),
                    ),
                  ),
                ),
                onDragUpdate: (details) {
                  final newOffset = details.delta + _fabPosition;

                  setState(() {
                    animationSpeed = 0;
                    _fabPosition = newOffset;

                    // Check if the FAB is inside the quarter-circle area
                    final isWithinX = newOffset.dx >
                        (screenWidth - ((screenWidth / 3) + (fabSize / 2)));
                    final isWithinY = newOffset.dy >
                        (screenHeight - ((screenWidth / 3) + (fabSize / 2)));
                    _animateDropZone = isWithinX && isWithinY;
                  });
                },
                onDraggableCanceled: (velocity, offset) {
                  final newOffset = offset;

                  // Calculate vertical bounds
                  const topBound = 0.0 + (kToolbarHeight * 2);
                  final bottomBound =
                      screenHeight - fabSize - kBottomNavigationBarHeight;

                  // Clamp the vertical position
                  final clampedY = newOffset.dy.clamp(topBound, bottomBound);

                  // Snap to the nearest side (left or right)
                  final snapX = (newOffset.dx + fabSize / 2 < screenWidth / 2)
                      ? 0.0 + 20 // Snap to left
                      : screenWidth - fabSize - 20; // Snap to right

                  setState(() {
                    animationSpeed = 300;
                    _fabPosition = Offset(snapX, clampedY);
                    _visible = true;
                    _dragStarted = false;

                    // Check if the FAB is inside the quarter-circle area
                    final isWithinX = newOffset.dx >
                        (screenWidth - ((screenWidth / 3) + (fabSize / 2)));
                    final isWithinY = newOffset.dy >
                        (screenHeight - ((screenWidth / 3) + (fabSize / 2)));

                    _isInDropZone = isWithinX && isWithinY;

                    // Trigger drop zone action if FAB is dropped in the zone
                    if (_isInDropZone && state.isMinimized) {
                      _triggerDropZoneAction();
                      _fabPosition =
                          Offset(screenWidth + fabSize, screenHeight + fabSize);
                    }
                  });
                },
              );
            },
          ),
        ),
      ],
    );
  }

  void _triggerDropZoneAction() {
    log("FAB dropped in the bottom-right drop zone!");

    Future.delayed(Duration(milliseconds: animationSpeed), () {
      BrowserMinimisedManager.removeMinimisedButton();
    });

    // widget.onPressed();
  }
}
