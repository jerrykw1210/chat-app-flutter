import 'package:protech_mobile_chat_stream/module/friend/service/friend_service.dart';
import 'package:protech_mobile_chat_stream/service/data.dart';
import 'package:protech_mobile_chat_stream/utils/service_locator.dart';

class FriendRepository {
  final FriendService _friendService = sl<FriendService>();
  Future<Response> searchFriendsByPhone({required String phone}) async {
    return _friendService.searchFriendsByPhone(phone: phone);
  }
}
