import 'package:flutter/material.dart';
import 'package:protech_mobile_chat_stream/module/call/screen/call_screen.dart';
import 'package:protech_mobile_chat_stream/route/routes.dart';
import 'package:protech_mobile_chat_stream/utils/pip_controller.dart';
import 'package:protech_mobile_chat_stream/utils/service_locator.dart';
import 'package:stream_video_flutter/stream_video_flutter.dart';

class PipWidget extends StatefulWidget {
  const PipWidget({
    super.key,
    required this.call,
    required this.initialPosition,
  });

  final Call call;
  final Offset initialPosition;

  @override
  State<PipWidget> createState() => _PipWidgetState();
}

class _PipWidgetState extends State<PipWidget> {
  late Offset _pipPosition;
  double _scale = 1.0;
  bool _isDragging = false;
  int _animationSpeed = 500;

  @override
  void initState() {
    super.initState();
    _pipPosition = widget.initialPosition;
  }

  void _navigateToCallScreen(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => CallScreen(
          call: widget.call,
          callOptions: widget.call.connectOptions,
        ),
        settings: RouteSettings(name: AppPage.call.routeName),
      ),
      (route) =>
          route.isCurrent && route.settings.name == AppPage.call.routeName
              ? false
              : true,
    );
    sl<PipService>().dismissPip();
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    setState(() {
      _pipPosition += details.delta;
      _animationSpeed = 0;
      _isDragging = true;
      _scale = 1.05;
    });
  }

  void _handleDragEnd(DragEndDetails details) {
    final screenSize = MediaQuery.of(context).size;
    const double width = 120;
    const double height = 160;

    // Calculate vertical bounds
    const topBound = 0.0 + (kToolbarHeight * 2);
    final bottomBound = screenSize.height - height - kBottomNavigationBarHeight;

    // Clamp vertical position
    final clampedY = _pipPosition.dy.clamp(topBound, bottomBound);

    // Snap to nearest side
    final snapX = (_pipPosition.dx + width / 2 < screenSize.width / 2)
        ? 20.0 // Left side
        : screenSize.width - width - 20; // Right side

    setState(() {
      _animationSpeed = 300;
      _pipPosition = Offset(snapX, clampedY);
      _isDragging = false;
      _scale = 1.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    const double width = 120;
    const double height = 160;

    return AnimatedPositioned(
      duration: Duration(milliseconds: _animationSpeed),
      curve: Curves.easeOut,
      top: _pipPosition.dy,
      left: _pipPosition.dx,
      child: GestureDetector(
        onTap: () => _navigateToCallScreen(context),
        onPanUpdate: _handleDragUpdate,
        onPanEnd: _handleDragEnd,
        child: AnimatedScale(
          duration: Duration(milliseconds: _isDragging ? 0 : 200),
          scale: _scale,
          child: MouseRegion(
            cursor: SystemMouseCursors.grab,
            child: _buildVideoContainer(width, height),
          ),
        ),
      ),
    );
  }

  Widget _buildVideoContainer(double width, double height) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 6,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: StreamBuilder<CallState>(
        stream: widget.call.state.valueStream,
        builder: (context, snapshot) {
          final participant = snapshot.data?.otherParticipants.firstOrNull;
          if (participant == null) return const SizedBox();

          return SizedBox(
            width: width,
            height: height,
            child: StreamVideoRenderer(
              call: widget.call,
              participant: participant,
              videoTrackType: SfuTrackType.video,
              placeholderBuilder: (context) {
                return Material(
                  color: Colors.transparent,
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.grey.shade400,
                          radius: 20,
                          child: Text(
                              participant.name.isEmpty
                                  ? "A"
                                  : participant.name[0].toUpperCase(),
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 17)),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          participant.name,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 14),
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
