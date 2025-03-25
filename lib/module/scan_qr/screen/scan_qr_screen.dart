import 'dart:convert';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:protech_mobile_chat_stream/service/authentication_service.dart';
import 'package:protech_mobile_chat_stream/service/response.dart';
import 'package:protech_mobile_chat_stream/utils/service_locator.dart';
import 'package:protech_mobile_chat_stream/utils/string_apis.dart';
import 'package:protech_mobile_chat_stream/utils/toast_utils.dart';

class ScanQRScreen extends StatefulWidget {
  const ScanQRScreen({super.key});

  @override
  State<ScanQRScreen> createState() => _ScanQRScreenState();
}

class _ScanQRScreenState extends State<ScanQRScreen> {
  final MobileScannerController controller =
      MobileScannerController(detectionSpeed: DetectionSpeed.unrestricted);
  String qrContent = "";

  Widget _buildBarcodeOverlay() {
    return ValueListenableBuilder(
      valueListenable: controller,
      builder: (context, value, child) {
        // Not ready.
        if (!value.isInitialized || !value.isRunning || value.error != null) {
          return const SizedBox();
        }

        return StreamBuilder<BarcodeCapture>(
          stream: controller.barcodes,
          builder: (context, snapshot) {
            final BarcodeCapture? barcodeCapture = snapshot.data;

            // No barcode.
            if (barcodeCapture == null || barcodeCapture.barcodes.isEmpty) {
              return const SizedBox();
            }

            final scannedBarcode = barcodeCapture.barcodes.first;

            // No barcode corners, or size, or no camera preview size.
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

  Widget _buildScanWindow(Rect scanWindowRect) {
    return ValueListenableBuilder(
      valueListenable: controller,
      builder: (context, value, child) {
        // Not ready.
        if (!value.isInitialized ||
            !value.isRunning ||
            value.error != null ||
            value.size.isEmpty) {
          return const SizedBox();
        }

        return CustomPaint(
          painter: ScannerOverlay(scanWindowRect),
        );
      },
    );
  }

  @override
  void initState() {
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

          sl<AuthenticationService>()
              .linkDevice(body: content)
              .then((Response res) {
            log("link device response ${res.toString()}");
            if (res is! MapSuccessResponse) {
              ToastUtils.showToast(
                context: context,
                msg: "无效二维码",
                type: Type.warning,
              );
            }

            if (res is MapSuccessResponse) {
              Navigator.of(context).pop();
              ToastUtils.showToast(
                context: context,
                msg: "登陆成功",
                type: Type.success,
              );
            }
          });
        } catch (e) {
          ToastUtils.showToast(
            context: context,
            msg: "无效二维码",
            type: Type.warning,
          );
        }
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final scanWindow = Rect.fromCenter(
      center: MediaQuery.sizeOf(context).center(Offset.zero),
      width: 200,
      height: 200,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('With Scan window')),
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          _buildBarcodeOverlay(),
          _buildScanWindow(scanWindow),
          MobileScanner(
            fit: BoxFit.contain,
            scanWindow: scanWindow,
            controller: controller,
            errorBuilder: (context, error, child) {
              return ScannerErrorWidget(error: error);
            },
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              height: 100,
              color: Colors.black.withOpacity(0.4),
              child: ScannedBarcodeLabel(barcodes: controller.barcodes),
            ),
          ),
        ],
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
  ScannerOverlay(this.scanWindow);

  final Rect scanWindow;

  @override
  void paint(Canvas canvas, Size size) {
    final backgroundPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    final cutoutPath = Path()..addRect(scanWindow);

    final backgroundPaint = Paint()
      ..color = Colors.black.withOpacity(0.5)
      ..style = PaintingStyle.fill
      ..blendMode = BlendMode.dstOver;

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
    const double cornerRadius = 6.0; // Radius for rounded corners

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
      ..color = Colors.blue.withOpacity(0.3)
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

    return const ColoredBox(
        color: Colors.black,
        child: Center(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
          Padding(
            padding: EdgeInsets.only(bottom: 16),
          )
        ])));
  }
}
