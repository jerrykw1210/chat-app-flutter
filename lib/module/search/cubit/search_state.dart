part of 'search_cubit.dart';

enum SearchStatus { initial, success, fail, loading, empty }

enum SearchTypingStatus { typing, notTyping }

enum SearchUserOrGroupStatus {
  initial,
  loading,
  matchedGroups,
  matchedUsers,
  fail,
  empty
}

class SearchState extends Equatable {
  final SearchStatus searchStatus;
  final List<db.Message> searchResults;
  final List<UserInfo> searchedUserInfo;
  final List<UserInfo> relatedUserInfo;
  final List<Group> searchedGroupInfo;
  final List<db.Conversation> searchedConversations;
  final SearchTypingStatus searchTypingStatus;
  final SearchUserOrGroupStatus searchUserOrGroupStatus;
  final bool isChatSearch;
  const SearchState({
    this.searchStatus = SearchStatus.initial,
    this.searchResults = const [],
    this.searchedUserInfo = const [],
    this.relatedUserInfo = const [],
    this.searchedGroupInfo = const [],
    this.searchedConversations = const [],
    this.searchTypingStatus = SearchTypingStatus.notTyping,
    this.searchUserOrGroupStatus = SearchUserOrGroupStatus.initial,
    this.isChatSearch = false,
  });
  SearchState copyWith(
      {SearchStatus? searchStatus,
      bool? chatSearch,
      List<db.Message>? searchResults,
      List<UserInfo>? searchedUserInfo,
      List<UserInfo>? relatedUserInfo,
      List<Group>? searchedGroupInfo,
      List<db.Conversation>? searchedConversations,
      SearchTypingStatus? searchTypingStatus,
      SearchUserOrGroupStatus? searchUserOrGroupStatus,
      bool? isChatSearch}) {
    return SearchState(
      searchStatus: searchStatus ?? this.searchStatus,
      searchResults: searchResults ?? this.searchResults,
      searchedUserInfo: searchedUserInfo ?? this.searchedUserInfo,
      relatedUserInfo: relatedUserInfo ?? this.relatedUserInfo,
      searchedGroupInfo: searchedGroupInfo ?? this.searchedGroupInfo,
      searchedConversations:
          searchedConversations ?? this.searchedConversations,
      searchTypingStatus: searchTypingStatus ?? this.searchTypingStatus,
      searchUserOrGroupStatus:
          searchUserOrGroupStatus ?? this.searchUserOrGroupStatus,
      isChatSearch: isChatSearch ?? this.isChatSearch,
    );
  }

  @override
  List<Object?> get props => [
        searchStatus,
        searchResults,
        searchedUserInfo,
        relatedUserInfo,
        searchedGroupInfo,
        searchedConversations,
        searchTypingStatus,
        searchUserOrGroupStatus,
        isChatSearch
      ];
}
