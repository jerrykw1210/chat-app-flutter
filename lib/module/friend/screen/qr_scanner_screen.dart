import 'dart:convert';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:protech_mobile_chat_stream/constants/string_constant.dart';
import 'package:protech_mobile_chat_stream/module/friend/cubit/user_cubit.dart';
import 'package:protech_mobile_chat_stream/module/friend/screen/search_friend_result_screen.dart';
import 'package:protech_mobile_chat_stream/service/authentication_service.dart';
import 'package:protech_mobile_chat_stream/service/credential_service.dart';
import 'package:protech_mobile_chat_stream/service/data.dart';
import 'package:protech_mobile_chat_stream/utils/service_locator.dart';
import 'package:protech_mobile_chat_stream/utils/string_apis.dart';
import 'package:protech_mobile_chat_stream/utils/toast_utils.dart';

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({super.key});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  final MobileScannerController controller = MobileScannerController();
  String qrContent = "";
  int resetDuration = 3;

  Widget _buildBarcodeOverlay() {
    return ValueListenableBuilder(
      valueListenable: controller,
      builder: (context, value, child) {
        if (!value.isInitialized || !value.isRunning || value.error != null) {
          return const SizedBox();
        }

        return StreamBuilder<BarcodeCapture>(
          stream: controller.barcodes,
          builder: (context, snapshot) {
            final BarcodeCapture? barcodeCapture = snapshot.data;

            if (barcodeCapture == null || barcodeCapture.barcodes.isEmpty) {
              return const SizedBox();
            }

            final scannedBarcode = barcodeCapture.barcodes.first;

            if (value.size.isEmpty ||
                scannedBarcode.size.isEmpty ||
                scannedBarcode.corners.isEmpty) {
              return const SizedBox();
            }

            return CustomPaint(
              painter: BarcodeOverlay(
                barcodeCorners: scannedBarcode.corners,
                barcodeSize: scannedBarcode.size,
                boxFit: BoxFit.contain,
                cameraPreviewSize: value.size,
              ),
            );
          },
        );
      },
    );
  }

  @override
  initState() {
    controller.barcodes.listen((snapshot) {
      final scannedBarcodes = snapshot.barcodes;
      String value = scannedBarcodes.isNotEmpty
          ? scannedBarcodes.first.rawValue ?? ''
          : '';

      if (!value.isBlank && qrContent != value) {
        setState(() {
          qrContent = value;
        });

        try {
          Map<String, dynamic> content = jsonDecode(qrContent);

          if (!content.containsKey("action") ||
              !content.containsKey("content")) {
            ToastUtils.showToast(
              context: context,
              msg: Strings.invalidQRCode,
              type: Type.warning,
            );
            Future.delayed(Duration(seconds: resetDuration), () {
              if (mounted) {
                setState(() {
                  qrContent = "";
                });
              }
            });
            return;
          }

          switch (content["action"]) {
            case "ADD_FRIEND":
              String userId = content["content"];
              String? myUserId = sl<CredentialService>().turmsId;

              if (myUserId == userId) {
                ToastUtils.showToast(
                    context: context,
                    msg: Strings.cannotAddYourselfAsFriend,
                    type: Type.warning);
                return;
              }

              context.read<UserCubit>().fetchUserProfile(userId: userId);
              break;
            case "LINK_DEVICE":
              Map<String, dynamic> payload = content["content"];
              sl<AuthenticationService>()
                  .linkDevice(body: payload)
                  .then((Response res) {
                log("link device response ${res.toString()}");
                if (res is! MapSuccessResponse) {
                  ToastUtils.showToast(
                    context: context,
                    msg: Strings.invalidQRCode,
                    type: Type.warning,
                  );
                  Future.delayed(Duration(seconds: resetDuration), () {
                    if (mounted) {
                      setState(() {
                        qrContent = "";
                      });
                    }
                  });
                }

                if (res is MapSuccessResponse) {
                  Navigator.of(context).pop();
                  ToastUtils.showToast(
                    context: context,
                    msg: Strings.loginSuccess,
                    type: Type.success,
                  );
                }
              });
              break;
          }
        } catch (e) {
          log("error when scanning qr code $e");
          ToastUtils.showToast(
            context: context,
            msg: Strings.invalidQRCode,
            type: Type.warning,
          );
          Future.delayed(Duration(seconds: resetDuration), () {
            if (mounted) {
              setState(() {
                qrContent = "";
              });
            }
          });
        }
      }
    });
    super.initState();
  }

  Widget _buildScanWindow(Rect scanWindowRect, Rect cutOutPath) {
    return ValueListenableBuilder(
      valueListenable: controller,
      builder: (context, value, child) {
        if (!value.isInitialized ||
            !value.isRunning ||
            value.error != null ||
            value.size.isEmpty) {
          return const SizedBox();
        }

        return CustomPaint(
          painter: ScannerOverlay(
              scanWindow: scanWindowRect, cutOutPath: cutOutPath),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Get the size of the screen
    final screenSize = MediaQuery.sizeOf(context);

    // Define the size and position for the scan window
    const scanWindowWidth = 250.0;
    const scanWindowHeight = 250.0;

    // Center the scan window
    final scanWindow = Rect.fromCenter(
      center: Offset(screenSize.width / 2,
          (screenSize.height / 2)), // Center of the screen
      width: scanWindowWidth,
      height: scanWindowHeight,
    );

    final cutOut = Rect.fromCenter(
      center: Offset(screenSize.width / 2,
          (screenSize.height / 2)), // Center of the screen
      width: scanWindowWidth - 20,
      height: scanWindowHeight - 20,
    );

    return LoaderOverlay(
      child: Scaffold(
        appBar: AppBar(
          title: Text(Strings.scanQRCode),
          centerTitle: true,
          backgroundColor: Colors.black.withOpacity(0.4),
          elevation: 0,
        ),
        extendBodyBehindAppBar: true,
        backgroundColor: Colors.black,
        body: Stack(
          fit: StackFit.expand,
          children: [
            MobileScanner(
              fit: BoxFit.cover,
              scanWindow: scanWindow,
              controller: controller,
              errorBuilder: (context, error, child) {
                return ScannerErrorWidget(error: error);
              },
            ),
            _buildBarcodeOverlay(),
            _buildScanWindow(scanWindow, cutOut),
            BlocListener<UserCubit, UserState>(
              listener: (context, state) {
                state.fetchUserProfileStatus == FetchUserProfileStatus.loading
                    ? context.loaderOverlay.show()
                    : context.loaderOverlay.hide();

                if (state.fetchUserProfileStatus ==
                    FetchUserProfileStatus.success) {
                  if (state.userProfile != null ||
                      state.searchResultUsers.isNotEmpty) {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => SearchFriendResult(
                            userInfo:
                                state.userProfile ?? state.searchResultUsers[0],
                            friendMethod: "qr"),
                      ),
                    );
                    Future.delayed(Duration(seconds: resetDuration), () {
                      if (mounted) {
                        setState(() {
                          qrContent = "";
                        });
                      }
                    });
                    return;
                  }

                  Future.delayed(Duration(seconds: resetDuration), () {
                    if (mounted) {
                      setState(() {
                        qrContent = "";
                      });
                    }
                  });

                  return;
                }

                if (state.fetchUserProfileStatus ==
                    FetchUserProfileStatus.fail) {
                  ToastUtils.showToast(
                    context: context,
                    msg: Strings.failToGetUserInfo,
                    type: Type.warning,
                  );

                  return;
                }

                if (state.fetchUserProfileStatus ==
                    FetchUserProfileStatus.fail) {
                  ToastUtils.showToast(
                    context: context,
                    msg: Strings.failToGetUserInfo,
                    type: Type.warning,
                  );

                  Future.delayed(Duration(seconds: resetDuration), () {
                    if (mounted) {
                      setState(() {
                        qrContent = "";
                      });
                    }
                  });
                }
              },
              // child: Align(
              //   alignment: Alignment.bottomCenter,
              //   child: Container(
              //     alignment: Alignment.center,
              //     padding:
              //         const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              //     height: 100,
              //     color: Colors.black.withOpacity(0.4),
              //     child: ScannedBarcodeLabel(barcodes: controller.barcodes),
              //   ),
              // ),
              child: const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Future<void> dispose() async {
    super.dispose();
    await controller.dispose();
  }
}

class ScannerOverlay extends CustomPainter {
  ScannerOverlay({required this.scanWindow, required this.cutOutPath});

  final Rect scanWindow;
  final Rect cutOutPath;

  @override
  void paint(Canvas canvas, Size size) {
    const double cornerRadius = 6.0; // Radius for rounded corners

    final backgroundPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    final cutoutPath = Path()
      ..addRRect(RRect.fromRectAndRadius(
          cutOutPath, const Radius.circular(cornerRadius)));

    final backgroundPaint = Paint()
      ..color = Colors.black.withOpacity(0.5)
      ..style = PaintingStyle.fill
      ..blendMode = BlendMode.dstATop;

    final backgroundWithCutout = Path.combine(
      PathOperation.difference,
      backgroundPath,
      cutoutPath,
    );
    canvas.drawPath(backgroundWithCutout, backgroundPaint);

    // Define the length, thickness, and corner radius of the border
    const double cornerLength = 45.0; // Length of the corner lines
    const double cornerVerticalLength = 85.0;
    const double cornerThickness = 5.0; // Thickness of the corner lines

// Define the paint for the corners
    final cornerPaint = Paint()
      ..color =
          const Color.fromRGBO(8, 103, 190, 0.71) // Blue color for corners
      ..style = PaintingStyle.stroke
      ..strokeWidth = cornerThickness;

// Top-left corner
    final topLeftCorner = Path()
      ..moveTo(scanWindow.left, scanWindow.top + cornerVerticalLength)
      ..lineTo(scanWindow.left, scanWindow.top + cornerRadius)
      ..arcToPoint(
        Offset(scanWindow.left + cornerRadius, scanWindow.top),
        radius: const Radius.circular(cornerRadius),
        clockwise: true,
      )
      ..lineTo(scanWindow.left + cornerLength, scanWindow.top);
    canvas.drawPath(topLeftCorner, cornerPaint);

// Top-right corner
    final topRightCorner = Path()
      ..moveTo(scanWindow.right, scanWindow.top + cornerVerticalLength)
      ..lineTo(scanWindow.right, scanWindow.top + cornerRadius)
      ..arcToPoint(
        Offset(scanWindow.right - cornerRadius, scanWindow.top),
        radius: const Radius.circular(cornerRadius),
        clockwise: false,
      )
      ..lineTo(scanWindow.right - cornerLength, scanWindow.top);
    canvas.drawPath(topRightCorner, cornerPaint);

// Bottom-left corner
    final bottomLeftCorner = Path()
      ..moveTo(scanWindow.left, scanWindow.bottom - cornerVerticalLength)
      ..lineTo(scanWindow.left, scanWindow.bottom - cornerRadius)
      ..arcToPoint(
        Offset(scanWindow.left + cornerRadius, scanWindow.bottom),
        radius: const Radius.circular(cornerRadius),
        clockwise: false,
      )
      ..lineTo(scanWindow.left + cornerLength, scanWindow.bottom);
    canvas.drawPath(bottomLeftCorner, cornerPaint);

// Bottom-right corner
    final bottomRightCorner = Path()
      ..moveTo(scanWindow.right, scanWindow.bottom - cornerVerticalLength)
      ..lineTo(scanWindow.right, scanWindow.bottom - cornerRadius)
      ..arcToPoint(
        Offset(scanWindow.right - cornerRadius, scanWindow.bottom),
        radius: const Radius.circular(cornerRadius),
        clockwise: true,
      )
      ..lineTo(scanWindow.right - cornerLength, scanWindow.bottom);
    canvas.drawPath(bottomRightCorner, cornerPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

// Barcode overlay and other classes remain unchanged.

class BarcodeOverlay extends CustomPainter {
  BarcodeOverlay({
    required this.barcodeCorners,
    required this.barcodeSize,
    required this.boxFit,
    required this.cameraPreviewSize,
  });

  final List<Offset> barcodeCorners;
  final Size barcodeSize;
  final BoxFit boxFit;
  final Size cameraPreviewSize;

  @override
  void paint(Canvas canvas, Size size) {
    if (barcodeCorners.isEmpty ||
        barcodeSize.isEmpty ||
        cameraPreviewSize.isEmpty) {
      return;
    }

    final adjustedSize = applyBoxFit(boxFit, cameraPreviewSize, size);

    double verticalPadding = size.height - adjustedSize.destination.height;
    double horizontalPadding = size.width - adjustedSize.destination.width;
    if (verticalPadding > 0) {
      verticalPadding = verticalPadding / 2;
    } else {
      verticalPadding = 0;
    }

    if (horizontalPadding > 0) {
      horizontalPadding = horizontalPadding / 2;
    } else {
      horizontalPadding = 0;
    }

    final double ratioWidth;
    final double ratioHeight;

    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.iOS) {
      ratioWidth = barcodeSize.width / adjustedSize.destination.width;
      ratioHeight = barcodeSize.height / adjustedSize.destination.height;
    } else {
      ratioWidth = cameraPreviewSize.width / adjustedSize.destination.width;
      ratioHeight = cameraPreviewSize.height / adjustedSize.destination.height;
    }

    final List<Offset> adjustedOffset = [
      for (final offset in barcodeCorners)
        Offset(
          offset.dx / ratioWidth + horizontalPadding,
          offset.dy / ratioHeight + verticalPadding,
        ),
    ];

    final cutoutPath = Path()..addPolygon(adjustedOffset, true);

    final backgroundPaint = Paint()
      ..color = Colors.red.withOpacity(0.3)
      ..style = PaintingStyle.fill
      ..blendMode = BlendMode.dstOut;

    canvas.drawPath(cutoutPath, backgroundPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

class ScannedBarcodeLabel extends StatelessWidget {
  const ScannedBarcodeLabel({super.key, required this.barcodes});
  final Stream<BarcodeCapture> barcodes;
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: barcodes,
      builder: (context, snapshot) {
        final scannedBarcodes = snapshot.data?.barcodes ?? [];

        return Text(
          scannedBarcodes.isNotEmpty
              ? scannedBarcodes.first.rawValue ?? ''
              : 'No display value.',
          overflow: TextOverflow.fade,
          style: const TextStyle(color: Colors.white),
        );
      },
    );
  }
}

class ScannerErrorWidget extends StatelessWidget {
  const ScannerErrorWidget({super.key, required this.error});

  final MobileScannerException error;

  @override
  Widget build(BuildContext context) {
    String errorMessage;

    switch (error.errorCode) {
      case MobileScannerErrorCode.controllerUninitialized:
        errorMessage = 'Controller not ready.';
      case MobileScannerErrorCode.permissionDenied:
        errorMessage = 'Permission denied';
      case MobileScannerErrorCode.unsupported:
        errorMessage = 'Scanning is unsupported on this device';
      default:
        errorMessage = 'Generic Error';
        break;
    }

    return ColoredBox(
      color: Colors.black,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.only(bottom: 16),
              child: Icon(Icons.error, color: Colors.white),
            ),
            Text(
              errorMessage,
              style: const TextStyle(color: Colors.white),
            ),
            Text(
              error.errorDetails?.message ?? '',
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
