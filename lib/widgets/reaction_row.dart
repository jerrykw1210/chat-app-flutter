import 'package:flutter/material.dart';
import 'package:protech_mobile_chat_stream/model/database.dart';
import 'package:protech_mobile_chat_stream/module/chat/model/reaction.dart';

class ReactionRow extends StatefulWidget {
  const ReactionRow({super.key, required this.currentMessage});
  final Message currentMessage;
  // final Channel channel;
  @override
  State<ReactionRow> createState() => _ReactionRowState();
}

class _ReactionRowState extends State<ReactionRow> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      mainAxisSize: MainAxisSize.min,
      children: EmojiList().emojis.map((emoji) {
        return GestureDetector(
          onTap: () async {
            // widget.channel
            //     .sendReaction(widget.currentMessage, emoji.reactionType);
            Navigator.pop(context);
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.asset(
              emoji.imagePath,
              width: 20,
              height: 20,
            ),
          ),
        );
      }).toList(),
    );
  }
}
