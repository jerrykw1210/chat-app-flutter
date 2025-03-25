import 'dart:async';

import 'package:flutter/material.dart';
import 'package:protech_mobile_chat_stream/constants/string_constant.dart';
import 'package:protech_mobile_chat_stream/widgets/edit_profile_dialog.dart';

class AccountDeletionDialog extends StatefulWidget {
  const AccountDeletionDialog({super.key});

  @override
  State<AccountDeletionDialog> createState() => _AccountDeletionDialogState();
}

class _AccountDeletionDialogState extends State<AccountDeletionDialog> {
  Timer? _timer;

  int _countdownTime = 10;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Icon(
        Icons.warning_rounded,
        color: Colors.red,
        size: 48,
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            Strings.accountDeletion,
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          Text(Strings.accountDeletionDescription),
        ],
      ),
      actions: [
        SizedBox(
          width: MediaQuery.sizeOf(context).width * 0.8,
          child: ElevatedButton(
            onPressed: _countdownTime == 0
                ? () {
                    Navigator.pop(context);
                    showDialog(
                      context: context,
                      builder: (context) => const VerifyPasswordDialog(),
                    );
                  }
                : null,
            child: _countdownTime == 0
                ? Text(
                    Strings.delete,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: Colors.white),
                  )
                : Text("${Strings.delete}(${_countdownTime}s)"),
          ),
        ),
        SizedBox(
          width: MediaQuery.sizeOf(context).width * 0.8,
          child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(Strings.cancel,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: Colors.black))),
        ),
      ],
    );
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_countdownTime > 0) {
          _countdownTime--;
        } else {
          _timer?.cancel();
        }
      });
    });
  }
}
