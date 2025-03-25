import 'package:flutter/material.dart';

class MessageToast extends StatefulWidget {
  const MessageToast(
      {super.key,
      required this.message,
      required this.backgroundColor,
      required this.textColor,
      required this.icon,
      this.displayDuration = const Duration(seconds: 2),
      this.slideDuration = const Duration(milliseconds: 300)});
  final String message;
  final Color backgroundColor;
  final Color textColor;
  final IconData icon;
  final Duration displayDuration;
  final Duration slideDuration;

  @override
  State<MessageToast> createState() => _MessageToastState();
}

class _MessageToastState extends State<MessageToast>
    with SingleTickerProviderStateMixin {
  // defining the Animation Controller
  late final AnimationController _controller = AnimationController(
    duration: widget.slideDuration,
    vsync: this,
  );
  // defining the Offset of the animation
  late final Animation<Offset> _offsetAnimation = Tween<Offset>(
    begin: const Offset(1.5, 0.0),
    end: Offset.zero,
  ).animate(_controller);
  // After using disposing the controller
  // is must to releasing the resourses
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _controller.forward();
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Future.delayed(widget.displayDuration, () {
          if (mounted) {
            _controller.reverse();
          }
        });
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 100.0,
      right: 0.0,
      child: SlideTransition(
          position: _offsetAnimation,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            mainAxisSize: MainAxisSize.max,
            children: [
              Material(
                color: Colors.transparent,
                child: Container(
                  decoration: BoxDecoration(
                    color: widget.backgroundColor,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  padding: const EdgeInsets.fromLTRB(14, 10, 16, 10),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        widget.icon,
                        color: widget.textColor,
                      ),
                      const SizedBox(width: 5.0),
                      Text(
                        widget.message,
                        softWrap: true,
                        style: TextStyle(color: widget.textColor),
                      ),
                    ],
                  ),
                ),
              )
            ],
          )),
    );
  }
}
