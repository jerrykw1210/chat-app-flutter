import 'dart:convert';
import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:fixnum/fixnum.dart';
import 'package:protech_mobile_chat_stream/model/database.dart' as db;
import 'package:protech_mobile_chat_stream/service/turms_response.dart';
import 'package:protech_mobile_chat_stream/service/turms_service.dart';
import 'package:protech_mobile_chat_stream/utils/service_locator.dart';
import 'package:protech_mobile_chat_stream/utils/string_apis.dart';
import 'package:turms_client_dart/turms_client.dart';
import 'package:drift/drift.dart';

part 'search_state.dart';

class SearchCubit extends Cubit<SearchState> {
  SearchCubit() : super(const SearchState());

  void searchTypingStatus(bool isTyping) {
    if (!isTyping) {
      emit(state.copyWith(searchTypingStatus: SearchTypingStatus.notTyping));
    } else {
      emit(state.copyWith(searchTypingStatus: SearchTypingStatus.typing));
    }
  }

  void searchByKeyword(
    String keyword, {
    bool isChatSearch = false,
    String conversationId = "",
    String targetId = "",
    bool isGroup = false,
  }) async {
    emit(state.copyWith(searchStatus: SearchStatus.loading));
    try {
      List<db.Message> results = [];
      List<db.Conversation> conversations = [];
      if (isChatSearch) {
        // if(isGroup){
        //   (sl<db.AppDatabase>().select(sl<db.AppDatabase>().messages)
        //           ..where((message) =>
        //               message.content.like('%$keyword%') &
        //               message.conversationId.equals(conversationId)))
        //         .get();
        // }
        results =
            await (sl<db.AppDatabase>().select(sl<db.AppDatabase>().messages)
                  ..where((message) =>
                      message.content.like('%$keyword%') &
                      message.conversationId.equals(conversationId)))
                .get();
        log("searchssss $results $conversationId");

        db.Conversation matchedConversation = await (sl<db.AppDatabase>()
                .select(sl<db.AppDatabase>().conversations)
              ..where((conversation) => conversation.id.equals(conversationId)))
            .getSingle();
        List<Int64> members = (jsonDecode(matchedConversation.members) as List)
            .map((i) => i.toString().parseInt64())
            .toList();
        await fetchRelatedUsersFromSearch(id: members.toSet());

        final status =
            results.isEmpty ? SearchStatus.empty : SearchStatus.success;
        emit(state.copyWith(
            searchStatus: status,
            searchResults: results,
            searchedConversations: [matchedConversation],
            isChatSearch: true));
      } else {
        await fetchRelatedUsersFromSearch();
        results =
            await (sl<db.AppDatabase>().select(sl<db.AppDatabase>().messages)
                  ..where((message) => message.content.like('%$keyword%')))
                .get();

        for (var i in results) {
          List<db.Conversation> matchedConversation =
              await (sl<db.AppDatabase>()
                      .select(sl<db.AppDatabase>().conversations)
                    ..where((conversation) =>
                        conversation.id.equals(i.conversationId)))
                  .get();
          for (var convo in matchedConversation) {
            if (!conversations.contains(convo)) {
              conversations.add(convo);
            }
          }
        }
        emit(state.copyWith(searchedConversations: conversations));
        // final searchFutures = sl<StreamChatClient>()
        //     .state
        //     .channels
        //     .values
        //     .map((v) => v.search(query: keyword));
        // final responses = await Future.wait(searchFutures);
        // results = responses.expand((res) => res.results).toList();
        final status =
            results.isEmpty ? SearchStatus.empty : SearchStatus.success;
        emit(state.copyWith(
            searchStatus: status, searchResults: results, isChatSearch: false));
      }
    } catch (e) {
      log("search error $e");
      emit(state.copyWith(searchStatus: SearchStatus.fail));
    }
  }

  searchUserOrGroup(String name, String userType,
      {List<UserInfo> users = const [], List<Group> groups = const []}) {
    emit(state.copyWith(
        searchUserOrGroupStatus: SearchUserOrGroupStatus.loading));
    try {
      if (userType == "user") {
        final results = users
            .where(
                (user) => user.name.toLowerCase().contains(name.toLowerCase()))
            .toList();

        final status = results.isEmpty
            ? SearchUserOrGroupStatus.empty
            : SearchUserOrGroupStatus.matchedUsers;
        emit(state.copyWith(
            searchUserOrGroupStatus: status, searchedUserInfo: results));
      } else {
        final results =
            groups.where((group) => group.name.contains(name)).toList();
        final status = results.isEmpty
            ? SearchUserOrGroupStatus.empty
            : SearchUserOrGroupStatus.matchedGroups;
        emit(state.copyWith(
          searchUserOrGroupStatus: status,
          searchedGroupInfo: results,
        ));
      }
    } catch (e) {
      log("search error $e");
      emit(state.copyWith(
          searchUserOrGroupStatus: SearchUserOrGroupStatus.fail));
    }
  }

  fetchRelatedUsersFromSearch({Set<Int64>? id}) async {
    if (id != null) {
      final relatedUsers =
          await sl<TurmsClient>().userService.queryUserProfiles(id);
      emit(state.copyWith(relatedUserInfo: relatedUsers.data));
    } else {
      final relatedRes =
          await sl<TurmsClient>().userService.queryRelatedUserIds();
      if (relatedRes.code == 1000) {
        final relatedIds = relatedRes.data?.longs.toSet() ?? <Int64>{};
        final relatedUsers =
            await sl<TurmsClient>().userService.queryUserProfiles(relatedIds);
        emit(state.copyWith(relatedUserInfo: relatedUsers.data));
      }
    }
  }

  resetSearchState() {
    emit(state.copyWith(
        searchStatus: SearchStatus.initial,
        searchUserOrGroupStatus: SearchUserOrGroupStatus.initial,
        searchResults: [],
        searchedUserInfo: [],
        searchedGroupInfo: []));
  }
}
