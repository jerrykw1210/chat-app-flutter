import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:protech_mobile_chat_stream/constants/string_constant.dart';
import 'package:protech_mobile_chat_stream/module/chat/cubit/chat_trigger_cubit.dart';
import 'package:protech_mobile_chat_stream/utils/colors.dart';

class TextInputBar extends StatelessWidget {
  TextInputBar(
      {super.key,
      required this.messageInputController,
      required this.focusNode});
  TextEditingController messageInputController;
  FocusNode focusNode;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ChatTriggerCubit, ChatTriggerState>(
      listenWhen: (previous, current) =>
          previous.isEditing != current.isEditing,
      listener: (context, state) {
        if (state.isEditing) {
          messageInputController.value = TextEditingValue(
              text: state.messageToReply?.content.toString() ?? "");
        }
      },
      builder: (context, state) {
        return Flexible(
          flex: 10,
          fit: FlexFit.loose,
          child: state.recordingStatus == RecordingStatus.recording
              ? Text(
                  "${state.stopwatchDuration.inMinutes}:${state.stopwatchDuration.inSeconds.toString().padLeft(2, '0')}")
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Container(
                          decoration: BoxDecoration(
                              color: AppColor.chatReceiverBubbleColor,
                              borderRadius: BorderRadius.circular(30.0)),
                          child: _buildMessageInputField(
                              context, state, focusNode),
                        ),
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }

  Widget _buildMessageInputField(
      BuildContext context, ChatTriggerState state, FocusNode focusNode) {
    return Padding(
      padding: const EdgeInsets.only(left: 15.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: TextFormField(
              controller: messageInputController,
              focusNode: focusNode,
              minLines: 1,
              maxLines: 2,
              maxLength: 3000, // word count limit
              decoration: InputDecoration(
                  filled: false,
                  counterText: "",
                  focusedBorder: InputBorder.none,
                  hintText: Strings.typeHere,
                  border: InputBorder.none,
                  labelStyle: null,
                  hintStyle: null,
                  enabledBorder: InputBorder.none),
              onChanged: (value) {
                if (value.isNotEmpty) {
                  context.read<ChatTriggerCubit>().isTyping(true);
                } else {
                  context.read<ChatTriggerCubit>().isTyping(false);
                }
              },
            ),
          ),
          IconButton(
              onPressed: () {
                context.read<ChatTriggerCubit>().toggleEmoji();
                if (state.isExpandedTextField) {
                  context
                      .read<ChatTriggerCubit>()
                      .toggleExpandTextFieldBar(state.isExpandedTextField);
                }
                FocusScope.of(context).unfocus();
              },
              icon: SvgPicture.asset("assets/Buttons/emoji.svg")),
        ],
      ),
    );
  }
}
