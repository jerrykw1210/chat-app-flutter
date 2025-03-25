import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:gal/gal.dart';
import 'package:protech_mobile_chat_stream/constants/string_constant.dart';
import 'package:protech_mobile_chat_stream/service/credential_service.dart';
import 'package:protech_mobile_chat_stream/utils/colors.dart';
import 'package:protech_mobile_chat_stream/utils/service_locator.dart';
import 'package:protech_mobile_chat_stream/utils/toast_utils.dart';
import 'package:syncfusion_flutter_barcodes/barcodes.dart';
import 'package:widgets_to_image/widgets_to_image.dart';

class MyQRCodeScreen extends StatefulWidget {
  const MyQRCodeScreen({super.key});

  @override
  State<MyQRCodeScreen> createState() => _MyQRCodeScreenState();
}

class _MyQRCodeScreenState extends State<MyQRCodeScreen> {
  // WidgetsToImageController to access widget
  WidgetsToImageController controller = WidgetsToImageController();
// to save image bytes of widget
  Uint8List? bytes;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(Strings.myQrCode),
      ),
      body: SingleChildScrollView(
        child: SafeArea(
            child: Padding(
          padding: const EdgeInsets.only(left: 10.0, right: 10.0, bottom: 8.0),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 50, bottom: 10),
                    child: Text(
                      Strings.scanQRToAddFriend,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 30),
                  child: Text(
                    Strings.myQRDesc,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: const Color.fromARGB(255, 120, 120, 120)),
                  ),
                ),
                WidgetsToImage(
                  controller: controller,
                  child: Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                            color: AppColor.feedbackTypeColor,
                            borderRadius: BorderRadius.circular(8.0)),
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        height: 250,
                        child: SfBarcodeGenerator(
                          value:
                              "{\"action\":\"ADD_FRIEND\", \"content\":\"${sl<CredentialService>().turmsId}\"}",
                          symbology: QRCode(),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text("ID: ${sl<CredentialService>().turmsId}"),
                    ],
                  ),
                ),
                // TextButton(
                //     onPressed: () {}, child: const Text("Update QR Code")),
                Padding(
                  padding: const EdgeInsets.only(bottom: 50.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                          width: MediaQuery.sizeOf(context).width * 0.7,
                          child: ElevatedButton(
                              onPressed: () async {
                                final bytes = await controller.capture();
                                bool hasAccess =
                                    await Gal.hasAccess(toAlbum: true);
                                if (bytes != null) {
                                  if (!hasAccess) {
                                    hasAccess =
                                        await Gal.requestAccess(toAlbum: true);
                                    if (hasAccess) {
                                      Gal.putImageBytes(bytes).then((value) {
                                        if (mounted) {
                                          ToastUtils.showToast(
                                              context: context,
                                              msg: Strings.QRSaved);
                                        }
                                      });
                                      return;
                                    }
                                    return;
                                  }

                                  Gal.putImageBytes(bytes).then((value) {
                                    if (mounted) {
                                      ToastUtils.showToast(
                                          context: context,
                                          msg: Strings.QRSaved);
                                    }
                                  });
                                }
                              },
                              child: Text(
                                Strings.saveQr,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(color: Colors.white),
                              ))),
                      // SizedBox(
                      //   width: MediaQuery.sizeOf(context).width * 0.7,
                      //   child: ElevatedButton(
                      //       onPressed: () {

                      //       },
                      //       style: ElevatedButton.styleFrom(
                      //           backgroundColor: Colors.white),
                      //       child: Text(
                      //         Strings.shareNow,
                      //         style: Theme.of(context).textTheme.bodyMedium,
                      //       )),
                      // ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        )),
      ),
    );
  }
}
