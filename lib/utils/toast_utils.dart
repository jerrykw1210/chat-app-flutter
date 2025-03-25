import 'package:flutter/material.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:flutter_svg/flutter_svg.dart';

enum Type { warning, success, danger }

/// A utility class for displaying toast notifications with different types
/// such as warning, success, and danger. Provides methods to customize the
/// appearance of the toast, including the leading widget.
class ToastUtils {
  static Widget leadWidget({Type? type, Widget? lead}) {
    if (lead != null) {
      return lead;
    }

    switch (type) {
      case Type.warning:
        return const Icon(Icons.warning_rounded,
            color: Color.fromRGBO(255, 204, 0, 1));
      case Type.danger:
        return const Icon(Icons.dangerous_rounded, color: Colors.red);
      case Type.success:
        return SvgPicture.asset("assets/Buttons/CheckCircleFilled.svg");
      default:
        return SvgPicture.asset("assets/Buttons/CheckCircleFilled.svg");
    }
  }

  static void showToast(
      {required BuildContext context,
      required String msg,
      Widget? lead,
      Type? type}) {
    showToastWidget(
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: Container(
            // width: MediaQuery.of(context).size.width * 0.6,
            decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Color.fromRGBO(0, 0, 0, 0.08), // First shadow
                    offset: Offset(0, 6),
                    blurRadius: 16,
                    spreadRadius: 0,
                  ),
                  BoxShadow(
                    color: Color.fromRGBO(0, 0, 0, 0.12), // Second shadow
                    offset: Offset(0, 3),
                    blurRadius: 6,
                    spreadRadius: -4,
                  ),
                  BoxShadow(
                    color: Color.fromRGBO(0, 0, 0, 0.05), // Third shadow
                    offset: Offset(0, 9),
                    blurRadius: 28,
                    spreadRadius: 8,
                  ),
                ],
                borderRadius: BorderRadius.all(Radius.circular(8))),
            child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 9, horizontal: 12),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    leadWidget(type: type, lead: lead),
                    const SizedBox(width: 8),
                    ConstrainedBox(
                      constraints: BoxConstraints(
                          maxWidth: MediaQuery.sizeOf(context).width * 0.7),
                      child: Text(msg,
                          textAlign: TextAlign.justify,
                          style: const TextStyle(
                              color: Color.fromRGBO(0, 0, 0, 0.88),
                              fontSize: 14,
                              fontFamily: "Inter",
                              decoration: TextDecoration.none,
                              fontWeight: FontWeight.w600)),
                    )
                  ],
                )),
          ),
        ),
        context: context,
        duration: const Duration(milliseconds: 3000),
        animDuration: const Duration(milliseconds: 350),
        position: const StyledToastPosition(align: Alignment.topRight),
        reverseAnimation: StyledToastAnimation.fade,
        animation: StyledToastAnimation.slideFromRight);
  }
}
