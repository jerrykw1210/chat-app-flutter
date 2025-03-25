import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:protech_mobile_chat_stream/module/general/cubit/navigator_cubit.dart';
import 'package:protech_mobile_chat_stream/route/routes.dart';
import 'package:protech_mobile_chat_stream/utils/navigation_service.dart';

class MyNavigatorObserver extends NavigatorObserver {
  // This method will be called when a new route is pushed onto the stack
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    if (route.settings.name == AppPage.message.routeName) {
      NavigationService.navigatorKey.currentContext!
          .read<NavigatorCubit>()
          .navigatedToMessageScreen();
    } else {
      NavigationService.navigatorKey.currentContext!
          .read<NavigatorCubit>()
          .navigatedToOtherScreen();
    }
    debugPrint('Pushed route: ${route.settings.name}');
  }

  // This method will be called when a route is popped from the stack
  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    if (previousRoute?.settings.name == AppPage.message.routeName) {
      NavigationService.navigatorKey.currentContext!
          .read<NavigatorCubit>()
          .navigatedToMessageScreen();
    } else {
      NavigationService.navigatorKey.currentContext!
          .read<NavigatorCubit>()
          .navigatedToOtherScreen();
    }
    debugPrint('Popped route: ${route.settings.name}');
  }

  // This method will be called when the current route has changed
  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    if (newRoute?.settings.name == AppPage.message.routeName) {
      NavigationService.navigatorKey.currentContext!
          .read<NavigatorCubit>()
          .navigatedToMessageScreen();
    } else {
      NavigationService.navigatorKey.currentContext!
          .read<NavigatorCubit>()
          .navigatedToOtherScreen();
    }
    debugPrint('Replaced route: ${newRoute?.settings.name}');
  }
}
