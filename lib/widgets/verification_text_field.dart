import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:protech_mobile_chat_stream/constants/string_constant.dart';
import 'package:protech_mobile_chat_stream/constants/util_constants.dart';

class VerificationTextField extends StatefulWidget {
  VerificationTextField(
      {super.key, required this.verificationController, required this.sendOTP});
  TextEditingController verificationController = TextEditingController();
  bool? Function() sendOTP;

  @override
  State<VerificationTextField> createState() => _VerificationTextFieldState();
}

class _VerificationTextFieldState extends State<VerificationTextField> {
  bool verificationSent = false;
  String countDown = _formattedTime(timeInSecond: UtilConstants.otpTimer);
  Timer? countDownTimer;
  final FocusNode _focusNode = FocusNode();
  bool focused = false;

  @override
  void dispose() {
    countDownTimer?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    // log(countDown);
    super.initState();
    _focusNode.addListener(() {
      focused = _focusNode.hasFocus;
    });
  }

  void _handleTap() {
    // print(countDown);
    if (verificationSent) {
      return;
    }

    //send verification otp
    bool isCalled = widget.sendOTP() ?? false;

    if (!isCalled) {
      return;
    }

    setState(() {
      verificationSent = true;
    });
    log("verification sent $verificationSent");
    int counter = UtilConstants.otpTimer;
    countDownTimer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      // log("${timer.tick}");
      counter--;

      setState(() {
        countDown = _formattedTime(timeInSecond: counter);
      });

      if (counter == 0) {
        setState(() {
          verificationSent = false;
        });
        timer.cancel();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
        controller: widget.verificationController,
        focusNode: _focusNode,
        decoration: InputDecoration(
            hintText: Strings.pleaseFillInVerificationCode,
            suffixIcon: GestureDetector(
              onTap: _handleTap,
              child: Container(
                width: 102,
                decoration: BoxDecoration(
                    color: verificationSent
                        ? const Color.fromRGBO(199, 205, 207, 1)
                        : Theme.of(context).primaryColorLight,
                    border: Border.all(color: Colors.transparent, width: 2),
                    borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(8),
                        bottomRight: Radius.circular(8))),
                child: Align(
                  alignment: Alignment.center,
                  child: Text(verificationSent ? countDown : Strings.getOTP,
                      style: const TextStyle(
                          color: Colors.white,
                          fontFamily: "Inter",
                          fontSize: 13,
                          fontWeight: FontWeight.w400)),
                ),
              ),
            )));
  }
}

String _formattedTime({required int timeInSecond}) {
  int sec = timeInSecond % 60;
  int min = (timeInSecond / 60).floor();
  String minute = min.toString().length <= 1 ? "0$min" : "$min";
  String second = sec.toString().length <= 1 ? "0$sec" : "$sec";
  return "$minute : $second";
}
