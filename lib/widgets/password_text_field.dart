import 'package:flutter/material.dart';
import 'package:protech_mobile_chat_stream/constants/string_constant.dart';

class PasswordTextField extends StatefulWidget {
  PasswordTextField({super.key, required this.controller, this.hintText});
  TextEditingController controller;
  String? hintText;

  @override
  State<PasswordTextField> createState() => _PasswordTextFieldState();
}

class _PasswordTextFieldState extends State<PasswordTextField> {
  bool hidePassword = true;

  @override
  Widget build(BuildContext context) {
    return TextField(
        controller: widget.controller,
        obscureText: hidePassword,
        decoration: InputDecoration(
            hintText: widget.hintText ?? Strings.pleaseEnterPassword,
            prefixIcon: Tooltip(
                message: Strings.passwordFormat,
                showDuration: const Duration(seconds: 5),
                margin: const EdgeInsets.all(10),
                triggerMode: TooltipTriggerMode.tap,
                child: const Icon(Icons.info_outline, color: Colors.grey)),
            suffixIcon: IconButton(
                onPressed: () {
                  setState(() {
                    hidePassword = !hidePassword;
                  });
                },
                icon: Icon(
                    hidePassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: Colors.grey))));
  }
}
