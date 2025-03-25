enum MessageStatusEnum {
  sent(0),
  sending(1),
  failed(2);

  const MessageStatusEnum(this.value);

  final int value;
}
