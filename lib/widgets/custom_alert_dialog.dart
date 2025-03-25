import 'package:flutter/material.dart';
import 'package:protech_mobile_chat_stream/constants/string_constant.dart';

class CustomAlertDialog {
  static void showGeneralDialog(
      {required BuildContext context,
      String? title,
      Widget? content,
      List<Widget>? actions,
      Function? onPositiveActionPressed,
      Function? onNegativeActionPressed,
      bool undismissible = false,
      Key? key}) {
    final defaultActions = [
      TextButton(
        onPressed: onPositiveActionPressed != null
            ? () => onPositiveActionPressed()
            : () => Navigator.of(context).pop(),
        child: Text(Strings.ok),
      ),
      if (!undismissible)
        TextButton(
          onPressed: onNegativeActionPressed != null
              ? () => onNegativeActionPressed()
              : () => Navigator.of(context).pop(),
          child: Text(Strings.cancel),
        ),
    ];

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          key: key,
          title: title != null
              ? Column(
                  children: [
                    undismissible
                        ? const SizedBox(height: 20)
                        : Align(
                            alignment: Alignment.topRight,
                            child: IconButton(
                                onPressed: () => Navigator.pop(context),
                                alignment: AlignmentDirectional.topEnd,
                                icon: const Icon(Icons.close)),
                          ),
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                )
              : undismissible
                  ? const SizedBox(height: 20)
                  : Align(
                      alignment: Alignment.topRight,
                      child: IconButton(
                          onPressed: () => Navigator.pop(context),
                          alignment: AlignmentDirectional.topEnd,
                          icon: const Icon(Icons.close)),
                    ),
          titlePadding: EdgeInsets.zero,
          content: content,
          actions: actions ?? defaultActions,
        );
      },
    );
  }

  static void showCustomDialog({
    required BuildContext context,
    Widget? title,
    Widget? content,
    List<Widget>? actions,
    Function? onPositiveActionPressed,
    Function? onNegativeActionPressed,
  }) {
    final defaultActions = [
      TextButton(
        onPressed: onPositiveActionPressed != null
            ? () => onPositiveActionPressed()
            : () => Navigator.of(context).pop(),
        child: Text(Strings.ok),
      ),
      TextButton(
        onPressed: onNegativeActionPressed != null
            ? () => onNegativeActionPressed()
            : () => Navigator.of(context).pop(),
        child: Text(Strings.cancel),
      ),
    ];

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: title ??
              Text("Title", style: Theme.of(context).textTheme.titleMedium),
          titlePadding: const EdgeInsets.all(3),
          content: content,
          actions: actions ?? defaultActions,
        );
      },
    );
  }
}
