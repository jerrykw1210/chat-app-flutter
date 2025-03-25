import 'dart:developer';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:protech_mobile_chat_stream/constants/string_constant.dart';
import 'package:protech_mobile_chat_stream/utils/colors.dart';
import 'package:protech_mobile_chat_stream/utils/device_info.dart';
import 'package:webview_flutter/webview_flutter.dart';

class AboutAppScreen extends StatelessWidget {
  const AboutAppScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(Strings.about),
      ),
      backgroundColor: Colors.white,
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 30.0, bottom: 40.0),
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  color: Colors.white,
                  child: Image.asset(
                    'assets/logo_icon.png',
                    height: 100,
                  ),
                ),
                Text(
                  "Prochat".toUpperCase(),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text("${Strings.version} : ${DeviceInfoClass.getAppVersion()}",
                    textAlign: TextAlign.center),
              ],
            ),
          ),
          const Divider(
            thickness: 10,
            color: AppColor.greyBackgroundColor3,
          ),
          // Padding(
          //   padding: const EdgeInsets.only(left: 10.0),
          //   child: ListTile(
          //     leading: SvgPicture.asset("assets/Buttons/cube-02.svg"),
          //     title: Text(Strings.checkAppVersion),
          //     trailing: const Icon(Icons.chevron_right),
          //   ),
          // ),
          // const Divider(
          //   height: 0,
          //   indent: 60,
          //   endIndent: 40,
          // ),
          Padding(
            padding: const EdgeInsets.only(left: 10.0),
            child: ListTile(
              leading: SvgPicture.asset("assets/Buttons/server-06.svg"),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const TermsOfUseScreen(),
                ),
              ),
              title: Text(Strings.userAgreement),
              trailing: const Icon(Icons.chevron_right),
            ),
          ),
          const Divider(
            height: 0,
            indent: 60,
            endIndent: 40,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 10.0),
            child: ListTile(
              leading: SvgPicture.asset("assets/Buttons/server-05.svg"),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PrivacyPolicyScreen(),
                ),
              ),
              title: Text(Strings.privacyPolicy),
              trailing: const Icon(Icons.chevron_right),
            ),
          ),
          const Divider(
            height: 0,
            indent: 60,
            endIndent: 40,
          ),
        ],
      ),
    );
  }
}

class TermsOfUseScreen extends StatefulWidget {
  const TermsOfUseScreen({super.key});

  @override
  State<TermsOfUseScreen> createState() => _TermsOfUseScreenState();
}

class _TermsOfUseScreenState extends State<TermsOfUseScreen> {
  late WebViewController _webViewController;
  @override
  void initState() {
    super.initState();
    // Initialize WebView

    // if (context.locale == Locale('zh', 'CN')) {
    //   _webViewController
    //       .loadFlutterAsset('assets/tnc/TermOfUse_prochat_cn.html');
    // } else {
    //   _webViewController
    //       .loadFlutterAsset('assets/tnc/TermOfUse_prochat_en.html');
    // }
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted);

    _webViewController.loadRequest(
        Uri.parse('http://chat-server-01.prosdtech.com.my/terms-conditions'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(Strings.termOfUse),
        ),
        body: WebViewWidget(controller: _webViewController));
  }
}

class PrivacyPolicyScreen extends StatefulWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  State<PrivacyPolicyScreen> createState() => _PrivacyPolicyScreenState();
}

class _PrivacyPolicyScreenState extends State<PrivacyPolicyScreen> {
  late WebViewController _webViewController;
  @override
  void initState() {
    super.initState();
    // Initialize WebView
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted);
    _webViewController.loadRequest(
        Uri.parse('http://chat-server-01.prosdtech.com.my/privacy-policy'));
    // if (context.locale == Locale('zh', 'CN')) {
    //   _webViewController
    //       .loadFlutterAsset('assets/tnc/PrivacyPolicy_prochat_cn.html');
    // } else {
    //   _webViewController
    //       .loadFlutterAsset('assets/tnc/PrivacyPolicy_prochat_en.html');
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(Strings.privacyPolicy),
        ),
        body: WebViewWidget(controller: _webViewController));
  }
}
