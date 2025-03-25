class EmojiReaction {
  final String imagePath;
  final String reactionType;

  EmojiReaction({required this.imagePath, required this.reactionType});
}

class EmojiList {
  // List of emoji reactions
  final List<EmojiReaction> emojis = [
    EmojiReaction(
        imagePath: "assets/reaction/thumbs-up-emoji.png", reactionType: "like"),
    EmojiReaction(
        imagePath: "assets/reaction/heart-emoji.png", reactionType: "love"),
    EmojiReaction(
        imagePath: "assets/reaction/laugh-in-tears-emoji.png",
        reactionType: "funny"),
    EmojiReaction(
        imagePath: "assets/reaction/suprised-emoji.png",
        reactionType: "surprised"),
    EmojiReaction(
        imagePath: "assets/reaction/crying-emoji.png", reactionType: "cry"),
    EmojiReaction(
        imagePath: "assets/reaction/praying-emoji.png", reactionType: "pray"),
  ];
}
