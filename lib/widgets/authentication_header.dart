import 'package:flutter/material.dart';

class AuthenticationHeader extends StatelessWidget {
  AuthenticationHeader(
      {super.key,
      required this.child,
      required this.logo,
      required this.title,
      required this.subtitle});
  Widget child;
  String title;
  String subtitle;
  Widget logo;

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: const BoxDecoration(
            image: DecorationImage(
                image: AssetImage("assets/bg.png"), fit: BoxFit.cover)),
        child: Padding(
          padding: const EdgeInsets.only(
              top: kToolbarHeight + 32, left: 16, right: 16),
          child: SizedBox(
            height: MediaQuery.of(context).size.height,
            child: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                logo,
                const SizedBox(height: 28),
                Text(title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontFamily: "Inter",
                      fontWeight: FontWeight.w600,
                      fontStyle: FontStyle.normal,
                    )),
                const SizedBox(height: 16),
                Text(subtitle,
                    style: const TextStyle(
                      fontSize: 16,
                      fontFamily: "Inter",
                      fontWeight: FontWeight.w400,
                      fontStyle: FontStyle.normal,
                    )),
                const SizedBox(height: 28),
                child
              ],
            ),
          ),
        ));
  }
}
