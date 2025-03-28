import 'package:flutter/material.dart';
import 'package:stream_video_flutter/stream_video_flutter.dart';

class BadgedCallOption extends StatelessWidget {
  const BadgedCallOption({
    super.key,
    required this.callControlOption,
    this.badgeCount = 0,
  });

  final CallControlOption callControlOption;
  final int badgeCount;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        callControlOption,
        Positioned(
          top: 0,
          right: 8,
          child: Badge(
            count: badgeCount,
          ),
        )
      ],
    );
  }
}

class Badge extends StatelessWidget {
  const Badge({
    super.key,
    required this.count,
  });

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 18,
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColorLight,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          count.toString(),
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 10,
          ),
        ),
      ),
    );
  }
}
