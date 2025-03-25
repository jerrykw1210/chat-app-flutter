import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:protech_mobile_chat_stream/constants/string_constant.dart';
import 'package:protech_mobile_chat_stream/module/chat/cubit/group_cubit.dart';
import 'package:protech_mobile_chat_stream/module/chat/screen/chat_screen.dart';
import 'package:protech_mobile_chat_stream/module/profile/cubit/profile_cubit.dart';
import 'package:protech_mobile_chat_stream/module/search/cubit/search_cubit.dart';
import 'package:protech_mobile_chat_stream/service/credential_service.dart';
import 'package:protech_mobile_chat_stream/utils/helper.dart';
import 'package:protech_mobile_chat_stream/utils/service_locator.dart';
import 'package:protech_mobile_chat_stream/widgets/chat_avatar.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen(
      {super.key, this.conversationId, this.targetId, this.isGroup});
  final String? conversationId;
  final String? targetId;
  final bool? isGroup;
  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  TextEditingController searchTextController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            context.read<SearchCubit>().resetSearchState();
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back),
        ),
        title: BlocBuilder<SearchCubit, SearchState>(
          builder: (context, state) {
            return TextField(
                //focusNode: _focusNode,
                controller: searchTextController,
                cursorColor: Colors.white,
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(color: Colors.white),
                onChanged: (value) {
                  if (value.isNotEmpty) {
                    context.read<SearchCubit>().searchTypingStatus(true);
                  } else {
                    context.read<SearchCubit>().searchTypingStatus(false);
                  }
                },
                onSubmitted: (value) {
                  if (widget.conversationId != null) {
                    context.read<SearchCubit>().searchByKeyword(
                          searchTextController.text,
                          isChatSearch: true,
                          conversationId: widget.conversationId.toString(),
                          targetId: widget.targetId.toString(),
                          isGroup: widget.isGroup ?? false,
                        );
                  } else {
                    context.read<SearchCubit>().searchByKeyword(
                          searchTextController.text,
                          isChatSearch: false,
                        );
                  }
                },
                textInputAction: searchTextController.text.isEmpty
                    ? TextInputAction.done
                    : TextInputAction.search,
                maxLength: 200,
                decoration: InputDecoration(
                    hintText: Strings.searchHint,
                    counterText: "",
                    hintStyle: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(color: Colors.white.withOpacity(0.3)),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    filled: false));
          },
        ),
        actions: [
          BlocBuilder<SearchCubit, SearchState>(
            builder: (context, state) {
              return IconButton(
                onPressed: () {
                  if (state.searchTypingStatus == SearchTypingStatus.typing) {
                    searchTextController.clear();
                    context.read<SearchCubit>().searchTypingStatus(false);
                  } else {
                    if (searchTextController.text.isNotEmpty) {
                      if (widget.conversationId != null) {
                        context.read<SearchCubit>().searchByKeyword(
                              searchTextController.text,
                              isChatSearch: true,
                              conversationId: widget.conversationId.toString(),
                              targetId: widget.targetId.toString(),
                            );
                      } else {
                        context.read<SearchCubit>().searchByKeyword(
                              searchTextController.text,
                              isChatSearch: false,
                            );
                      }
                    }
                  }
                },
                icon: state.searchTypingStatus == SearchTypingStatus.typing
                    ? const Icon(Icons.close)
                    : SvgPicture.asset("assets/icons/search-lg.svg"),
              );
            },
          )
        ],
      ),
      body: BlocBuilder<SearchCubit, SearchState>(
        builder: (context, state) {
          if (state.searchStatus == SearchStatus.success) {
            return ListView.builder(
              itemCount: state.searchResults.length,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                final conversation = widget.conversationId != ""
                    ? state.searchedConversations[0]
                    : state.searchedConversations.firstWhere((conversation) {
                        return conversation.id ==
                            state.searchResults[index].conversationId;
                      });
                return ListTile(
                  leading: state.isChatSearch
                      ? const SizedBox()
                      : state.searchResults[index].senderId ==
                              sl<CredentialService>().userId
                          ? ChatAvatar(
                              errorWidget: CircleAvatar(
                                child: Image.file(
                                  File(
                                      "${Helper.directory?.path}/${sl<CredentialService>().turmsId}_${context.read<ProfileCubit>().state.userProfile?.profileUrl}"),
                                  fit: BoxFit.cover,
                                  width: 40,
                                  height: 40,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Image.asset(
                                    'assets/default-img/default-user.png',
                                    fit: BoxFit.cover,
                                    width: 40,
                                    height: 40,
                                  ),
                                ),
                              ),
                              targetId: widget.targetId ?? "",
                              isGroup: conversation.isGroup)
                          : ChatAvatar(
                              errorWidget: CircleAvatar(
                                radius: 30,
                                child: ClipOval(
                                  child: Image.file(
                                    File(
                                        "${Helper.directory?.path}/${conversation.avatar}"),
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            Text(conversation.title[0]),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              targetId: widget.targetId ?? "",
                              isGroup: conversation.isGroup),
                  onTap: () {
                    // Channel channel = sl<StreamChatClient>().channel(
                    //     "messaging",
                    //     id: state.searchResults[index].channel?.id);
                    // context.read<ChatCubit>().querySearchedMessage(
                    //     state.searchResults[index].message.id);

                    if (conversation.isGroup) {
                      context.read<GroupCubit>().reset();
                    }
                    context.read<SearchCubit>().resetSearchState();

                    //Navigator.pop(context);
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => MessageScreen(
                          conversation: conversation,
                          isGroup: conversation.isGroup,
                          searchedMessage: state.searchResults[index],
                        ),
                      ),
                    );
                    // Navigator.pop(context);
                  },
                  title: Text(state.searchedConversations
                          .any((conversation) => conversation.isGroup)
                      ? state.searchedConversations.firstWhere(
                          (group) {
                            return group.id ==
                                state.searchResults[index].conversationId;
                          },
                        ).title
                      : state.searchResults[index].senderId ==
                              sl<CredentialService>().turmsId
                          ? Strings.me
                          : state.relatedUserInfo.singleWhere((user) {
                              return user.id.toString() ==
                                  state.searchResults[index].senderId;
                            }).name),
                  subtitle: state.searchedConversations
                          .any((conversation) => conversation.isGroup)
                      ? Text(
                          "${state.searchResults[index].senderId == sl<CredentialService>().turmsId ? Strings.me : state.relatedUserInfo.singleWhere((user) => user.id.toString() == state.searchResults[index].senderId).name}: ${state.searchResults[index].content}")
                      : Text(state.searchResults[index].content),
                );
              },
            );
          } else if (state.searchStatus == SearchStatus.empty) {
            return Text(Strings.noResultFound);
          }
          return const SizedBox();
        },
      ),
    );
  }
}
