import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:protech_mobile_chat_stream/constants/string_constant.dart';
import 'package:protech_mobile_chat_stream/module/general/cubit/connection_status_cubit.dart';

enum StatusBarType { error, warning }

class ConnectionStatusBar extends StatefulWidget {
  final String message;
  final StatusBarType statusBarType;

  const ConnectionStatusBar({
    super.key,
    required this.message,
    required this.statusBarType,
  });

  @override
  State<ConnectionStatusBar> createState() => _ConnectionStatusBarState();
}

class _ConnectionStatusBarState extends State<ConnectionStatusBar> {
  late final StreamSubscription<InternetStatus> _subscription;
  late final AppLifecycleListener _listener;

  @override
  void initState() {
    super.initState();
    _subscription = InternetConnection().onStatusChange.listen((status) {
      // Handle internet status changes
      if (status == InternetStatus.disconnected) {
        context.read<ConnectionStatusCubit>().noInternetConnection();
      } else {
        context.read<ConnectionStatusCubit>().noInternetConnectionDismiss();
      }
    });
    _listener = AppLifecycleListener(
      onResume: _subscription.resume,
      onHide: _subscription.pause,
      onPause: _subscription.pause,
    );
  }

  @override
  void dispose() {
    _subscription.cancel();
    _listener.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.statusBarType == StatusBarType.error
        ? Colors.red
        : const Color.fromRGBO(255, 251, 230, 1);

    return SafeArea(
      child: BlocBuilder<ConnectionStatusCubit, ConnectionStatusState>(
        builder: (context, state) {
          return AnimatedContainer(
            clipBehavior: Clip.antiAlias,
            duration: const Duration(milliseconds: 400),
            width: MediaQuery.of(context).size.width,
            height: state.showConnectionStatus || state.noInternetConnection
                ? 50
                : 0,
            padding:
                const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
            color: color,
            child: Material(
              color: Colors.transparent,
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Icon(Icons.warning_rounded,
                      color: Color.fromRGBO(250, 173, 20, 1)),
                  const SizedBox(width: 10.0),
                  Text(
                    state.noInternetConnection
                        ? Strings.noInternetConnection
                        : state.message ?? widget.message,
                    style: const TextStyle(color: Colors.black, fontSize: 14.0),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
