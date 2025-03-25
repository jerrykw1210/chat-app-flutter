import 'package:flutter/material.dart';

class CustomBottomSheet extends StatefulWidget {
  const CustomBottomSheet({
    super.key,
    required this.builder,
    required this.onClose,
  });

  final Widget Function(BuildContext) builder;
  final VoidCallback onClose;

  @override
  State<CustomBottomSheet> createState() => _CustomBottomSheetState();
}

class _CustomBottomSheetState extends State<CustomBottomSheet>
    with SingleTickerProviderStateMixin {
  late AnimationController animationController;

  @override
  void initState() {
    super.initState();
    animationController = BottomSheet.createAnimationController(
      this,
      sheetAnimationStyle: AnimationStyle(
          duration: const Duration(milliseconds: 500)), // Adjust duration
    );
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus(); // Close keyboard on tap outside
      },
      child: Material(
        color: Colors.transparent,
        child: Stack(
          children: [
            // Background tap area
            GestureDetector(
              onTap: widget.onClose,
              child: Container(
                color: Colors.black.withOpacity(0.5),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: BottomSheet(
                animationController: animationController,
                enableDrag: false,
                showDragHandle: false,
                onClosing: widget.onClose,
                builder: widget.builder,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
