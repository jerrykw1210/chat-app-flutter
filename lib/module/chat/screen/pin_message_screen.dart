import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:intl/intl.dart';
import 'package:protech_mobile_chat_stream/constants/string_constant.dart';
import 'package:protech_mobile_chat_stream/model/database.dart';
import 'package:protech_mobile_chat_stream/module/chat/cubit/chat_cubit.dart';
import 'package:protech_mobile_chat_stream/service/database_helper.dart';
import 'package:protech_mobile_chat_stream/utils/colors.dart';
import 'package:protech_mobile_chat_stream/utils/service_locator.dart';
import 'package:protech_mobile_chat_stream/widgets/chat_bubble.dart';

class PinMessageScreen extends StatelessWidget {
  const PinMessageScreen({super.key, required this.conversationId});
  final String conversationId;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.chatBackgroundColor,
      appBar: AppBar(
        title: StreamBuilder(
          stream: sl<DatabaseHelper>().getPinnedMessage(conversationId),
          builder: (context, message) {
            return Text(
              "${message.data?.length ?? 0} ${Strings.pinnedMessages}",
              style: Theme.of(context)
                  .textTheme
                  .bodyLarge
                  ?.copyWith(color: Colors.white),
            );
          },
        ),
      ),
      body: StreamBuilder(
          stream: sl<DatabaseHelper>().getPinnedMessage(conversationId),
          builder: (context, snapshot) {
            return GroupedListView(
              elements: snapshot.data ?? [].cast<Message>(),
              groupBy: (message) => DateTime(
                message.sentAt.year,
                message.sentAt.month,
                message.sentAt.day,
              ),
              groupSeparatorBuilder: (DateTime value) => Align(
                alignment: Alignment.center,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      DateUtils.isSameDay(value, DateTime.now())
                          ? Strings.today
                          : DateTime(value.year, value.month, value.day) ==
                                  DateTime(
                                    DateTime.now().year,
                                    DateTime.now().month,
                                    DateTime.now().day - 1,
                                  )
                              ? Strings.yesterday
                              : DateFormat("d MMMM yyyy").format(value),
                      textAlign: TextAlign.center,
                      style: Theme.of(context)
                          .textTheme
                          .titleSmall
                          ?.copyWith(color: AppColor.greyText),
                    ),
                  ),
                ),
              ),
              interdependentItemBuilder:
                  (context, previousMessage, currentMessage, nextMessage) {
                bool displayAvatar = true;

                return ChatBubbleTurms(
                  currentMessage: currentMessage,
                  // messageList: context.read<ChatCubit>().state.pinnedMessages,
                  isGroup: true,
                  displayAvatar: displayAvatar,
                  // readOnly: true
                );
              },
            );
          }),
      bottomNavigationBar: BlocListener<ChatCubit, ChatState>(
        listener: (context, state) {
          if (state.pinnedMessages.isEmpty) {
            Navigator.pop(context);
          }
        },
        child: TextButton(
            onPressed: () async {
              List<Message> allMessages = [];

              try {
                await for (List<Message> messageList in sl<DatabaseHelper>()
                    .getPinnedMessage(conversationId)
                    .timeout(Durations.short2)) {
                  allMessages.addAll(messageList);
                }
              } catch (e) {
                log("Error occurred while listening to the stream: $e");
              }

              for (Message pinnedMessage in allMessages) {
                context
                    .read<ChatCubit>()
                    .savePinnedMessages(pinnedMessage.id.toString(), false);
              }
            },
            style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  vertical: 30,
                ),
                shape: const LinearBorder(),
                backgroundColor: AppColor.pinMessageButtonBackground),
            child: Text(Strings.unpinAllMessages.toUpperCase())),
      ),
    );
  }
}
