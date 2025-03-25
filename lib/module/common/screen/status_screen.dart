import 'package:flutter/material.dart';

class StatusScreen extends StatelessWidget {
  const StatusScreen(
      {super.key,
      required this.title,
      required this.subtitle,
      required this.imgPath,
      required this.buttonText,
      required this.buttonOnPress});
  final String title;
  final String subtitle;
  final String imgPath;
  final String buttonText;
  final void Function() buttonOnPress;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: 20, vertical: kToolbarHeight + 70),
        child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
          ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 200, maxWidth: 200),
              child: Image.asset(imgPath)),
          const SizedBox(height: 40),
          Text(title,
              style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  fontFamily: "Inter")),
          const SizedBox(height: 20),
          Text(subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: Color.fromRGBO(75, 87, 104, 1),
                  fontFamily: "Inter")),
          const SizedBox(height: 30),
          SizedBox(
              width: MediaQuery.sizeOf(context).width,
              child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 16)),
                  onPressed: buttonOnPress,
                  child: Text(buttonText,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontFamily: "Inter",
                          fontWeight: FontWeight.w600))))
        ]),
      ),
    );
  }
}
