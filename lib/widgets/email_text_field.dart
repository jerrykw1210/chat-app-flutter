import 'package:flutter/material.dart';
import 'package:protech_mobile_chat_stream/constants/string_constant.dart';

class EmailTextField extends StatefulWidget {
  const EmailTextField({super.key, required this.emailController});
  final TextEditingController emailController;

  @override
  State<EmailTextField> createState() => _EmailTextFieldState();
}

class _EmailTextFieldState extends State<EmailTextField> {
  final FocusNode _focusNode = FocusNode();
  bool _haveFocus = false;

  @override
  void initState() {
    _focusNode.addListener(() {
      setState(() {
        _haveFocus = _focusNode.hasFocus;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.emailController,
      focusNode: _focusNode,
      keyboardType: TextInputType.emailAddress,
      decoration: InputDecoration(
          hintText: Strings.pleaseEnterEmail,
          prefixIcon: Icon(Icons.email_outlined,
              color: _haveFocus
                  ? Theme.of(context).primaryColorLight
                  : Colors.grey)),
    );
  }
}
