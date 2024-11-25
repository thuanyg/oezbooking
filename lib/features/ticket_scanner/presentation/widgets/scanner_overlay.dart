import 'package:flutter/material.dart';

class ScannerOverlayPainter extends CustomPainter {
  final double animationValue;

  ScannerOverlayPainter({required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    final double scanAreaSize = size.width * 0.7;
    final double scanAreaHeight = scanAreaSize;
    final double left = (size.width - scanAreaSize) / 2;
    final double top = (size.height - scanAreaHeight) / 2;
    final double right = left + scanAreaSize;
    final double bottom = top + scanAreaHeight;

    // Draw semi-transparent overlay
    final Paint backgroundPaint = Paint()
      ..color = Colors.black.withOpacity(0.5)
      ..style = PaintingStyle.fill;

    Path backgroundPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));

    Path transparentPath = Path()
      ..addRect(Rect.fromLTRB(left, top, right, bottom));

    final Path overlayPath = Path.combine(
      PathOperation.difference,
      backgroundPath,
      transparentPath,
    );

    canvas.drawPath(overlayPath, backgroundPaint);

    // Draw scanning area border
    final Paint borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    // Draw corner lines
    const double cornerLength = 20.0;

    // Top left corner
    canvas.drawLine(
        Offset(left, top + cornerLength), Offset(left, top), borderPaint);
    canvas.drawLine(
        Offset(left, top), Offset(left + cornerLength, top), borderPaint);

    // Top right corner
    canvas.drawLine(
        Offset(right - cornerLength, top), Offset(right, top), borderPaint);
    canvas.drawLine(
        Offset(right, top), Offset(right, top + cornerLength), borderPaint);

    // Bottom left corner
    canvas.drawLine(
        Offset(left, bottom - cornerLength), Offset(left, bottom), borderPaint);
    canvas.drawLine(
        Offset(left, bottom), Offset(left + cornerLength, bottom), borderPaint);

    // Bottom right corner
    canvas.drawLine(Offset(right - cornerLength, bottom), Offset(right, bottom),
        borderPaint);
    canvas.drawLine(Offset(right, bottom), Offset(right, bottom - cornerLength),
        borderPaint);

    // Draw scan line with smooth animation
    final Paint scanLinePaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.white.withOpacity(0.0),
          Colors.white.withOpacity(0.7),
          Colors.white.withOpacity(0.0),
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromLTRB(left, top, right, bottom));

    // Smooth up and down animation
    final double scanLineY = top + (bottom - top) * animationValue;

    canvas.drawLine(
      Offset(left, scanLineY),
      Offset(right, scanLineY),
      scanLinePaint..strokeWidth = 3.0,
    );
  }

  @override
  bool shouldRepaint(covariant ScannerOverlayPainter oldDelegate) {
    return animationValue != oldDelegate.animationValue;
  }
}