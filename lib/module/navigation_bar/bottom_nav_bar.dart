import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:protech_mobile_chat_stream/constants/string_constant.dart';
import 'package:protech_mobile_chat_stream/module/call/screen/call_screen.dart';
import 'package:protech_mobile_chat_stream/module/chat/cubit/chat_cubit.dart';
import 'package:protech_mobile_chat_stream/module/conversation/screen/conversations_screen.dart';
import 'package:protech_mobile_chat_stream/module/friend/screen/friend_list_screen.dart';
import 'package:protech_mobile_chat_stream/module/general/cubit/connection_status_cubit.dart';
import 'package:protech_mobile_chat_stream/module/profile/screen/profile_screen.dart';
import 'package:protech_mobile_chat_stream/module/webview/cubit/toggle_webview_cubit.dart';
import 'package:protech_mobile_chat_stream/module/webview/screen/webview_screen.dart';
import 'package:protech_mobile_chat_stream/route/routes.dart';
import 'package:protech_mobile_chat_stream/service/database_helper.dart';
import 'package:protech_mobile_chat_stream/utils/browser_minimised_manager.dart';
import 'package:protech_mobile_chat_stream/utils/connection_status_manager.dart';
import 'package:protech_mobile_chat_stream/utils/helper.dart';
import 'package:protech_mobile_chat_stream/utils/navigation_service.dart';
import 'package:protech_mobile_chat_stream/utils/service_locator.dart';
import 'package:protech_mobile_chat_stream/utils/webview_overlay_manager.dart';
import 'package:stream_video_flutter/stream_video_flutter.dart' as sv;
import 'package:rxdart/rxdart.dart';
import 'package:protech_mobile_chat_stream/utils/notificationBackgroundHandler.dart';

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({super.key});

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  int _selectedIndex = 0; //New
  int _lastIndex = 0;
  bool isTap = false;
  final videoClient = sl<sv.StreamVideo>();
  final _compositeSubscription = CompositeSubscription();
  late StreamSubscription _fcmSubscription;
  late StreamSubscription _incomingCallSubscription;
  late StreamSubscription _streamEventListener;
  final bool _isWebviewInitialized = false;
  final bool _isWebviewMinimized = false;
  final Offset _fabPosition = const Offset(50, 50);

  late WebviewScreen _webviewScreen;

  List<Widget> _buildScreens() => [
        const ConversationsScreen(),
        const FriendListScreen(),
        const WebviewScreen(),
        const ProfileScreen(),
      ];

  Widget _bottomNavigationItemIcon({required Widget child}) {
    return Padding(padding: const EdgeInsets.only(top: 6), child: child);
  }

  void _observeCallKitEvents() {
    final streamVideo = videoClient;

    _compositeSubscription.add(
      streamVideo.observeCoreCallKitEvents(
        onCallAccepted: (callToJoin) {
          Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                  builder: (context) => CallScreen(
                      call: callToJoin, callOptions: callToJoin.connectOptions),
                  settings: RouteSettings(name: AppPage.call.routeName)),
              (route) => route.settings.name != AppPage.call.routeName);
        },
      ),
    );

    // Or you can handle them by yourself, and/or add additional events such as handling mute events from CallKit
    // _compositeSubscription.add(streamVideo.onCallKitEvent<ActionCallToggleMute>(_onCallToggleMute));
  }

  _observeFcmMessages() {
    FirebaseMessaging.onBackgroundMessage(
        NotificationBackgroundHandler.firebaseMessagingBackgroundHandler);
    // _fcmSubscription = FirebaseMessaging.onMessage
    //     .listen(NotificationBackgroundHandler.handleRemoteMessage);
  }

  _addDevice() async {
    String? token = Helper.generateUUID();

    if (Platform.isAndroid) {
      if (token != null) {
        sv.StreamVideo.instance.addDevice(
            pushToken: token,
            pushProvider: sv.PushProvider.firebase,
            pushProviderName: "dev");
        final devices = await sv.StreamVideo.instance.getDevices();
        log("device added $devices");
      }
    }

    // if (Platform.isIOS) {
    //   final voipToken = await FlutterCallkitIncoming.getDevicePushTokenVoIP();

    //   if (token != null) {
    //     sv.StreamVideo.instance.addDevice(
    //         pushToken: token,
    //         pushProvider: sv.PushProvider.apn,
    //         voipToken: false,
    //         pushProviderName: 'apn');
    //   }

    //   if (voipToken != null) {
    //     sv.StreamVideo.instance.addDevice(
    //         pushToken: voipToken,
    //         pushProvider: sv.PushProvider.apn,
    //         voipToken: true,
    //         pushProviderName: 'apn');
    //   }
    // }
  }

  @override
  void initState() {
    //context.read<UserCubit>().fetchUsers();

    if (Platform.isAndroid) {
      _addDevice();
      _observeFcmMessages();
      _observeCallKitEvents();
    }
    _incomingCallSubscription =
        sv.StreamVideo.instance.state.incomingCall.listen((call) {
      if (call != null) {
        Navigator.of(NavigationService.navigatorKey.currentState!.context)
            .pushAndRemoveUntil(
                MaterialPageRoute(
                    builder: (context) => CallScreen(
                        call: call, callOptions: call.connectOptions),
                    settings: RouteSettings(name: AppPage.call.routeName)),
                (route) => route.isCurrent &&
                        route.settings.name == AppPage.call.routeName
                    ? false
                    : true);
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ConnectionStatusManager.showConnectionStatus(message: Strings.connecting);
      context
          .read<ConnectionStatusCubit>()
          .showConnectionStatus(Strings.connecting);
    });
    // _streamEventListener =
    //     sv.StreamVideo.instance.events.listen((sv.CoordinatorEvent event) {
    //   if (event is sv.CoordinatorCallCreatedEvent) {
    //     final call = videoClient.makeCall(
    //         callType: event.callCid.type, id: event.callCid.id);
    //     if (!call.isActiveCall) {
    //       Navigator.of(context).push(
    //           MaterialPageRoute(builder: (context) => CallScreen(call: call)));
    //     }
    //   }
    // });
    _webviewScreen = const WebviewScreen();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    // _incomingCallSubscription.cancel();
    // _streamEventListener.cancel();
    // _compositeSubscription.cancel();
  }

  @override
  Widget build(BuildContext context) {
    void onItemTapped(int index) {
      // log("$_isWebviewMinimized");
      final ToggleWebviewCubit toggleWebviewCubit =
          context.read<ToggleWebviewCubit>();
      context.read<ChatCubit>().resetNamecard();
      setState(() {
        if (index == 2) {
          // Assuming index 2 is the WebviewScreen
          if (!toggleWebviewCubit.state.isInitialized) {
            toggleWebviewCubit.setIsInitialized(true);
            toggleWebviewCubit.setIsMinimized(false);
            WebViewOverlayManager.showWebview();
          }
          BrowserMinimisedManager.showMinimisedButton();
          toggleWebviewCubit.setIsMinimized(false);
        }
        if (toggleWebviewCubit.state.isInitialized && index != 2) {
          toggleWebviewCubit.setIsMinimized(true);
          // BrowserMinimisedManager.showMinimisedButton();
        }
        _lastIndex = _selectedIndex;
        // toggleWebviewCubit.setLastIndex(_selectedIndex);
        _selectedIndex = index;
        toggleWebviewCubit.setCurrentIndex(_selectedIndex);
        isTap = true;
      });
    }

    int? argumentIndex = ModalRoute.of(context)!.settings.arguments as int?;
    if (argumentIndex != null && _selectedIndex != argumentIndex && !isTap) {
      _selectedIndex = argumentIndex;
    }

    return BlocConsumer<ToggleWebviewCubit, ToggleWebviewState>(
      listener: (context, state) {
        log("current bottom nav bar index ${state.currentIndex}");
        log("is webview initialized ${state.isInitialized}");
        if (state.isInitialized) {
          // BrowserMinimisedManager.showMinimisedButton();
        } else {
          // BrowserMinimisedManager.removeMinimisedButton();
        }
      },
      builder: (context, state) {
        return Scaffold(
          body: IndexedStack(
            index: state.currentIndex,
            children: [
              const ConversationsScreen(),
              const FriendListScreen(),
              state.isInitialized
                  ? _webviewScreen
                  : const Center(child: CircularProgressIndicator()),
              const ProfileScreen(),
            ],
          ),
          bottomNavigationBar: state.currentIndex == 2
              ? null
              : Container(
                  decoration: const BoxDecoration(
                      color: Colors.white,
                      border: Border(
                          top: BorderSide(
                              color: Color.fromARGB(255, 108, 108, 108),
                              width: 0.3))),
                  child: BottomNavigationBar(
                    elevation: 0,
                    backgroundColor: Colors.white,
                    type: BottomNavigationBarType.fixed,
                    selectedFontSize: 13,
                    selectedLabelStyle:
                        TextStyle(color: Theme.of(context).primaryColorLight),
                    items: [
                      BottomNavigationBarItem(
                        icon: _bottomNavigationItemIcon(
                          child: StreamBuilder<int>(
                              stream:
                                  sl<DatabaseHelper>().getTotalUnreadCount(),
                              builder: (context, snapshot) {
                                log("unread count ${snapshot.data}");
                                return Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    SvgPicture.asset(
                                      "assets/Buttons/message-chat-circle-inactive.svg",
                                    ),
                                    if (snapshot.hasData && snapshot.data != 0)
                                      Positioned(
                                          top: -3,
                                          right: -6,
                                          child: CircleAvatar(
                                              backgroundColor: Colors.red,
                                              radius: 8,
                                              child: Center(
                                                child: Text(
                                                    snapshot.data! > 100
                                                        ? "99"
                                                        : snapshot.data
                                                            .toString(),
                                                    style: const TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 10)),
                                              ))),
                                  ],
                                );
                              }),
                        ),
                        activeIcon: _bottomNavigationItemIcon(
                          child: StreamBuilder<int>(
                              stream:
                                  sl<DatabaseHelper>().getTotalUnreadCount(),
                              builder: (context, snapshot) {
                                log("unread count ${snapshot.data}");
                                return Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    SvgPicture.asset(
                                      "assets/Buttons/message-chat-circle-active.svg",
                                    ),
                                    if (snapshot.hasData && snapshot.data != 0)
                                      Positioned(
                                          top: -3,
                                          right: -6,
                                          child: CircleAvatar(
                                              backgroundColor: Colors.red,
                                              radius: 8,
                                              child: Center(
                                                child: Text(
                                                    snapshot.data! > 100
                                                        ? "99"
                                                        : snapshot.data
                                                            .toString(),
                                                    style: const TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 10)),
                                              ))),
                                  ],
                                );
                              }),
                        ),
                        label: Strings.chat,
                      ),
                      BottomNavigationBarItem(
                          icon: _bottomNavigationItemIcon(
                            child: SvgPicture.asset(
                              "assets/Buttons/file-inactive.svg",
                            ),
                          ),
                          activeIcon: _bottomNavigationItemIcon(
                            child: SvgPicture.asset(
                              "assets/Buttons/file-active.svg",
                            ),
                          ),
                          label: Strings.contact),
                      BottomNavigationBarItem(
                          icon: _bottomNavigationItemIcon(
                            child: SvgPicture.asset(
                              "assets/Buttons/browser.svg",
                              width: 30,
                              height: 30,
                              colorFilter: const ColorFilter.mode(
                                  Colors.black, BlendMode.srcIn),
                            ),
                          ),
                          activeIcon: _bottomNavigationItemIcon(
                            child: SvgPicture.asset(
                              "assets/Buttons/browser.svg",
                              width: 30,
                              height: 30,
                              colorFilter: ColorFilter.mode(
                                  Theme.of(context).primaryColorLight,
                                  BlendMode.srcIn),
                            ),
                          ),
                          label: Strings.browser),
                      BottomNavigationBarItem(
                          icon: _bottomNavigationItemIcon(
                            child: SvgPicture.asset(
                                "assets/Buttons/settings-inactive.svg"),
                          ),
                          activeIcon: _bottomNavigationItemIcon(
                            child: SvgPicture.asset(
                                "assets/Buttons/settings-active.svg"),
                          ),
                          label: Strings.settings),
                    ],
                    selectedItemColor: Theme.of(context).primaryColorLight,
                    currentIndex: state.currentIndex,
                    onTap: onItemTapped,
                  ),
                ),
        );
      },
    );
  }
}

extension on sv.Subscriptions {
  void addAll<T>(Iterable<StreamSubscription<T>?> subscriptions) {
    for (var i = 0; i < subscriptions.length; i++) {
      final subscription = subscriptions.elementAt(i);
      if (subscription == null) continue;

      add(i + 100, subscription);
    }
  }
}
