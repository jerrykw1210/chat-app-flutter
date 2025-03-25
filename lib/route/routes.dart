import 'package:flutter/material.dart';
import 'package:protech_mobile_chat_stream/module/favorite/screen/favorite_list_screen.dart';
import 'package:protech_mobile_chat_stream/module/friend/screen/add_friend_screen.dart';
import 'package:protech_mobile_chat_stream/module/friend/screen/create_group_screen.dart';
import 'package:protech_mobile_chat_stream/module/forget_password/screen/forget_password_screen.dart';
import 'package:protech_mobile_chat_stream/module/friend/screen/friend_list_screen.dart';
import 'package:protech_mobile_chat_stream/module/chat/screen/friend_media_screen.dart';
import 'package:protech_mobile_chat_stream/module/chat/screen/friend_profile_screen.dart';
import 'package:protech_mobile_chat_stream/module/friend/screen/friend_request_screen.dart';
import 'package:protech_mobile_chat_stream/module/friend/screen/friend_selection_screen.dart';
import 'package:protech_mobile_chat_stream/module/invitation_code/screen/invitation_code_screen.dart';
import 'package:protech_mobile_chat_stream/module/friend/screen/qr_scanner_screen.dart';
import 'package:protech_mobile_chat_stream/module/login/screen/login_screen.dart';
import 'package:protech_mobile_chat_stream/module/navigation_bar/bottom_nav_bar.dart';
import 'package:protech_mobile_chat_stream/module/profile/screen/about_app_screen.dart';
import 'package:protech_mobile_chat_stream/module/profile/screen/account_security_screen.dart';
import 'package:protech_mobile_chat_stream/module/profile/screen/add_contact_method_screen.dart';
import 'package:protech_mobile_chat_stream/module/profile/screen/device_management_screen.dart';
import 'package:protech_mobile_chat_stream/module/profile/screen/edit_profile_screen.dart';
import 'package:protech_mobile_chat_stream/module/profile/screen/language_screen.dart';
import 'package:protech_mobile_chat_stream/module/profile/screen/message_notice_screen.dart';
import 'package:protech_mobile_chat_stream/module/profile/screen/my_qr_code_screen.dart';
import 'package:protech_mobile_chat_stream/module/profile/screen/privacy_screen.dart';
import 'package:protech_mobile_chat_stream/module/profile/screen/system_settings_screen.dart';
import 'package:protech_mobile_chat_stream/module/profile/screen/profile_screen.dart';
import 'package:protech_mobile_chat_stream/module/register/screen/register_screen.dart';
import 'package:protech_mobile_chat_stream/module/scan_qr/screen/scan_qr_screen.dart';
import 'package:protech_mobile_chat_stream/module/search/screen/search_screen.dart';
import 'package:protech_mobile_chat_stream/module/webview/screen/webview_screen.dart';

class Routes {
  static Map<String, WidgetBuilder> routes = {
    AppPage.login.routeName: (context) => const LoginScreen(),
    // AppPage.registration.routeName: (context) => const RegistrationScreen(),
    AppPage.navBar.routeName: (context) => const BottomNavBar(),
    // AppPage.chatList.routeName: (context) => ChatListScreen(),
    // //AppPage.chat.routeName: (context) => const ChatScreen(),
    AppPage.friendSelection.routeName: (context) =>
        const FriendSelectionScreen(),
    AppPage.profile.routeName: (context) => const ProfileScreen(),
    AppPage.friendProfile.routeName: (context) => const FriendProfileScreen(),
    AppPage.friendMedia.routeName: (context) => const FriendMediaScreen(),
    //AppPage.groupProfile.routeName: (context) => const GroupProfileScreen(),
    AppPage.editProfile.routeName: (context) => const EditProfileScreen(),
    AppPage.language.routeName: (context) => const LanguageScreen(),
    //AppPage.pinMessage.routeName: (context) => const PinMessageScreen(),
    AppPage.myQrCode.routeName: (context) => const MyQRCodeScreen(),
    // AppPage.groupPermission.routeName: (context) =>
    //     const GroupPermissionScreen(),
    // AppPage.feedback.routeName: (context) => FeedbackScreen(),
    AppPage.systemSettings.routeName: (context) => const SystemSettingsScreen(),
    AppPage.messageNotice.routeName: (context) => const MessageNoticeScreen(),
    AppPage.privacy.routeName: (context) => const PrivacyScreen(),
    AppPage.addContactMethod.routeName: (context) =>
        const AddContactMethodScreen(),
    AppPage.friendList.routeName: (context) => const FriendListScreen(),
    AppPage.friendRequest.routeName: (context) => const FriendRequestScreen(),
    AppPage.addFriend.routeName: (context) => const AddFriendScreen(),
    AppPage.qrScanner.routeName: (context) => const QRScannerScreen(),
    AppPage.accountSecurity.routeName: (context) =>
        const AccountSecurityScreen(),
    AppPage.deviceManagement.routeName: (context) =>
        const DeviceManagementScreen(),
    AppPage.invitationCode.routeName: (context) => const InvitationCodeScreen(),
    AppPage.register.routeName: (context) => const RegisterScreen(),
    AppPage.addGroup.routeName: (context) => AddGroupScreen(),
    AppPage.forgotPassword.routeName: (context) => const ForgetPasswordScreen(),
    // AppPage.confirmPassword.routeName: (context) =>
    //     const ConfirmPasswordScreen(),
    AppPage.search.routeName: (context) => const SearchScreen(),
    AppPage.about.routeName: (context) => const AboutAppScreen(),

    AppPage.scanQR.routeName: (context) => const ScanQRScreen(),
    AppPage.about.routeName: (context) => const AboutAppScreen(),

    AppPage.scanQR.routeName: (context) => const ScanQRScreen(),

    AppPage.favoriteList.routeName: (context) => const FavoriteListScreen(),

    AppPage.browser.routeName: (context) => const WebviewScreen(),
  };
}

enum AppPage {
  login,
  registration,
  navBar,
  chatList,
  chat,
  friendSelection,
  profile,
  friendProfile,
  friendMedia,
  groupProfile,
  editProfile,
  pinMessage,
  language,
  myQrCode,
  groupPermission,
  feedback,
  systemSettings,
  messageNotice,
  privacy,
  addContactMethod,
  friendList,
  friendRequest,
  addFriend,
  qrScanner,
  accountSecurity,
  deviceManagement,
  invitationCode,
  register,
  addGroup,
  forgotPassword,
  confirmPassword,
  search,
  about,
  searchChatResult,
  scanQR,
  favoriteList,
  browser,
  message,
  call
}

extension AppPageExtension on AppPage {
  // for named routes
  String get routeName {
    switch (this) {
      case AppPage.login:
        return "/login";

      case AppPage.registration:
        return "/registration";

      case AppPage.navBar:
        return "/navBar";

      case AppPage.chatList:
        return "/chatList";

      case AppPage.chat:
        return "/chat";

      case AppPage.friendSelection:
        return "/friendSelection";

      case AppPage.profile:
        return "/profile";

      case AppPage.friendProfile:
        return "/friendProfile";

      case AppPage.friendMedia:
        return "/friendMedia";

      case AppPage.groupProfile:
        return "/groupProfile";

      case AppPage.groupPermission:
        return "/groupPermission";

      case AppPage.editProfile:
        return "/editProfile";

      case AppPage.pinMessage:
        return "/pinMessage";

      case AppPage.language:
        return "/language";

      case AppPage.myQrCode:
        return "/myQrCode";

      case AppPage.feedback:
        return "/feedback";

      case AppPage.systemSettings:
        return "/systemSettings";

      case AppPage.messageNotice:
        return "/messageNotice";

      case AppPage.privacy:
        return "/privacy";

      case AppPage.addContactMethod:
        return "/addContactMethod";

      case AppPage.friendList:
        return "/friendList";

      case AppPage.friendRequest:
        return "/friendRequest";

      case AppPage.addFriend:
        return "/addFriend";

      case AppPage.qrScanner:
        return "/qrScanner";

      case AppPage.accountSecurity:
        return "/accountSecurity";

      case AppPage.deviceManagement:
        return "/deviceManagement";

      case AppPage.invitationCode:
        return "/invitationCode";

      case AppPage.register:
        return "/register";

      case AppPage.forgotPassword:
        return "/forgotPassword";

      case AppPage.confirmPassword:
        return "/confirmPassword";

      case AppPage.addGroup:
        return "/addGroup";

      case AppPage.search:
        return "/search";

      case AppPage.about:
        return "/about";

      case AppPage.searchChatResult:
        return "/searchChatResult";

      case AppPage.scanQR:
        return "/scanQR";

      case AppPage.favoriteList:
        return "/favoriteList";

      case AppPage.browser:
        return "/browser";

      case AppPage.message:
        return "/message";
      
      case AppPage.call:
        return "/call";

      default:
        return "/home";
    }
  }
}
