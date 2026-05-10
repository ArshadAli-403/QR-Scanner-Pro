// lib/widgets/scanner_overlay.dart
import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../constants/app_colors.dart';

class ScannerOverlay extends StatefulWidget {
  final double scanLineProgress;

  const ScannerOverlay({
    super.key,
    this.scanLineProgress = 0.0,
  });

  @override
  State<ScannerOverlay> createState() => _ScannerOverlayState();
}

class _ScannerOverlayState extends State<ScannerOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _scanController;
  late Animation<double> _scanAnimation;

  @override
  void initState() {
    super.initState();
    _scanController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _scanAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _scanController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scanController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scanAnimation,
      builder: (context, _) {
        return CustomPaint(
          painter: _OverlayPainter(
            scanProgress: _scanAnimation.value,
          ),
          child: const SizedBox.expand(),
        );
      },
    );
  }
}

class _OverlayPainter extends CustomPainter {
  final double scanProgress;

  _OverlayPainter({required this.scanProgress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final scanBoxSize = math.min(size.width, size.height) * 0.65;
    final rect = Rect.fromCenter(
      center: center,
      width: scanBoxSize,
      height: scanBoxSize,
    );

    // Draw dark overlay
    final overlayPaint = Paint()..color = AppColors.scannerOverlay;
    final fullRect = Rect.fromLTWH(0, 0, size.width, size.height);
    final scanRRect = RRect.fromRectAndRadius(rect, const Radius.circular(16));

    // Punch hole in overlay
    final path = Path()
      ..addRect(fullRect)
      ..addRRect(scanRRect)
      ..fillType = PathFillType.evenOdd;
    canvas.drawPath(path, overlayPaint);

    // Draw corner brackets
    const cornerLen = 30.0;
    const cornerWidth = 4.0;
    const cornerRadius = 6.0;
    final cornerPaint = Paint()
      ..color = AppColors.scannerCorner
      ..strokeWidth = cornerWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final l = rect.left;
    final t = rect.top;
    final r = rect.right;
    final b = rect.bottom;

    // Top-left
    canvas.drawPath(
      Path()
        ..moveTo(l + cornerRadius, t)
        ..lineTo(l + cornerLen, t)
        ..moveTo(l, t + cornerRadius)
        ..lineTo(l, t + cornerLen),
      cornerPaint,
    );

    // Top-right
    canvas.drawPath(
      Path()
        ..moveTo(r - cornerLen, t)
        ..lineTo(r - cornerRadius, t)
        ..moveTo(r, t + cornerRadius)
        ..lineTo(r, t + cornerLen),
      cornerPaint,
    );

    // Bottom-left
    canvas.drawPath(
      Path()
        ..moveTo(l, b - cornerLen)
        ..lineTo(l, b - cornerRadius)
        ..moveTo(l + cornerRadius, b)
        ..lineTo(l + cornerLen, b),
      cornerPaint,
    );

    // Bottom-right
    canvas.drawPath(
      Path()
        ..moveTo(r, b - cornerLen)
        ..lineTo(r, b - cornerRadius)
        ..moveTo(r - cornerLen, b)
        ..lineTo(r - cornerRadius, b),
      cornerPaint,
    );

    // Draw animated scan line
    final scanY = rect.top + (rect.height * scanProgress);
    final linePaint = Paint()
      ..shader = LinearGradient(
        colors: [
          AppColors.scannerLine.withOpacity(0),
          AppColors.scannerLine,
          AppColors.scannerLine.withOpacity(0),
        ],
      ).createShader(Rect.fromLTWH(rect.left, scanY, rect.width, 3));
    canvas.drawLine(
      Offset(rect.left, scanY),
      Offset(rect.right, scanY),
      linePaint..strokeWidth = 2.5,
    );

    // Glow below scan line
    final glowPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          AppColors.scannerLine.withOpacity(0.08),
          AppColors.scannerLine.withOpacity(0.0),
        ],
      ).createShader(
          Rect.fromLTWH(rect.left, scanY, rect.width, 20));
    canvas.drawRect(
      Rect.fromLTWH(rect.left, scanY, rect.width, 20),
      glowPaint,
    );
  }

  @override
  bool shouldRepaint(_OverlayPainter old) => old.scanProgress != scanProgress;
}
