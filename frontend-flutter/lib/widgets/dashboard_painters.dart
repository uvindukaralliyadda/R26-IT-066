import 'package:flutter/material.dart';

/// Smooth Mini Sparkline Wave Painter
class SparklinePainter extends CustomPainter {
  final List<double> values;
  final Color lineColor;
  final bool showFill;

  SparklinePainter({
    required this.values,
    required this.lineColor,
    this.showFill = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;

    final paint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final minVal = values.reduce((a, b) => a < b ? a : b);
    final maxVal = values.reduce((a, b) => a > b ? a : b);
    final range = (maxVal - minVal) == 0 ? 1.0 : (maxVal - minVal);

    final path = Path();
    final points = <Offset>[];

    final dx = size.width / (values.length - 1);
    for (int i = 0; i < values.length; i++) {
      final x = i * dx;
      final normalized = (values[i] - minVal) / range;
      final y = size.height - (normalized * (size.height * 0.7) + size.height * 0.15);
      points.add(Offset(x, y));
    }

    if (points.isNotEmpty) {
      path.moveTo(points[0].dx, points[0].dy);
      for (int i = 0; i < points.length - 1; i++) {
        final p0 = points[i];
        final p1 = points[i + 1];
        final controlPoint1 = Offset(p0.dx + (p1.dx - p0.dx) / 2, p0.dy);
        final controlPoint2 = Offset(p0.dx + (p1.dx - p0.dx) / 2, p1.dy);
        path.cubicTo(
          controlPoint1.dx, controlPoint1.dy,
          controlPoint2.dx, controlPoint2.dy,
          p1.dx, p1.dy,
        );
      }
    }

    if (showFill) {
      final fillPath = Path.from(path)
        ..lineTo(size.width, size.height)
        ..lineTo(0, size.height)
        ..close();

      final fillPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            lineColor.withValues(alpha: 0.25),
            lineColor.withValues(alpha: 0.0),
          ],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

      canvas.drawPath(fillPath, fillPaint);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant SparklinePainter oldDelegate) => true;
}

/// 24-Hour Multi-Series Line Chart Painter
class TrendsChartPainter extends CustomPainter {
  final List<double> moistureData;
  final List<double> tempData;
  final List<double> humidityData;
  final List<String> timeLabels;

  TrendsChartPainter({
    required this.moistureData,
    required this.tempData,
    required this.humidityData,
    required this.timeLabels,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = const Color(0xFFE2E8F0)
      ..strokeWidth = 1.0;

    // Draw horizontal gridlines (0, 25, 50, 75, 100)
    const int lines = 4;
    final chartHeight = size.height - 24;
    for (int i = 0; i <= lines; i++) {
      final y = (chartHeight / lines) * i;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Helper to draw series path & dots
    void drawSeries(List<double> data, Color color) {
      if (data.isEmpty) return;
      final path = Path();
      final dx = size.width / (data.length - 1);
      final strokePaint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round;

      final dotPaint = Paint()..color = color;
      final innerDotPaint = Paint()..color = Colors.white;

      for (int i = 0; i < data.length; i++) {
        final x = i * dx;
        final y = chartHeight - (data[i] / 100.0) * chartHeight;
        if (i == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }

      canvas.drawPath(path, strokePaint);

      for (int i = 0; i < data.length; i++) {
        final x = i * dx;
        final y = chartHeight - (data[i] / 100.0) * chartHeight;
        canvas.drawCircle(Offset(x, y), 3.5, dotPaint);
        canvas.drawCircle(Offset(x, y), 1.5, innerDotPaint);
      }
    }

    drawSeries(moistureData, const Color(0xFF3B82F6)); // Moisture (Blue)
    drawSeries(tempData, const Color(0xFFF97316));     // Temp (Orange)
    drawSeries(humidityData, const Color(0xFF10B981)); // Humidity (Green)
  }

  @override
  bool shouldRepaint(covariant TrendsChartPainter oldDelegate) => true;
}

/// Simulated Zoned Field Map Custom Painter
class FieldMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Outer background field texture (dark vegetation green)
    final bgPaint = Paint()..color = const Color(0xFF1B4332);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(0, 0, w, h), const Radius.circular(12)), bgPaint);

    // Zone 1: Top-Left (Light Green - Good)
    final path1 = Path()
      ..moveTo(0, 0)
      ..lineTo(w * 0.52, 0)
      ..lineTo(w * 0.48, h * 0.48)
      ..lineTo(0, h * 0.52)
      ..close();
    final p1 = Paint()..color = const Color(0xFF22C55E).withValues(alpha: 0.65);
    canvas.drawPath(path1, p1);

    // Zone 2: Top-Right (Deep Green - Excellent)
    final path2 = Path()
      ..moveTo(w * 0.52, 0)
      ..lineTo(w, 0)
      ..lineTo(w, h * 0.54)
      ..lineTo(w * 0.48, h * 0.48)
      ..close();
    final p2 = Paint()..color = const Color(0xFF15803D).withValues(alpha: 0.75);
    canvas.drawPath(path2, p2);

    // Zone 3: Bottom-Left (Yellow/Orange - Moderate)
    final path3 = Path()
      ..moveTo(0, h * 0.52)
      ..lineTo(w * 0.48, h * 0.48)
      ..lineTo(0.55 * w, h)
      ..lineTo(0, h)
      ..close();
    final p3 = Paint()..color = const Color(0xFFEAB308).withValues(alpha: 0.70);
    canvas.drawPath(path3, p3);

    // Zone 4: Bottom-Right (Red - Poor)
    final path4 = Path()
      ..moveTo(w * 0.48, h * 0.48)
      ..lineTo(w, h * 0.54)
      ..lineTo(w, h)
      ..lineTo(w * 0.55, h)
      ..close();
    final p4 = Paint()..color = const Color(0xFFEF4444).withValues(alpha: 0.65);
    canvas.drawPath(path4, p4);

    // Zone grid dividers
    final gridPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.7)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    canvas.drawLine(Offset(w * 0.52, 0), Offset(w * 0.55, h), gridPaint);
    canvas.drawLine(Offset(0, h * 0.52), Offset(w, h * 0.54), gridPaint);

    // Draw Map Location Pin Markers
    void drawPin(Offset center) {
      final pinPaint = Paint()..color = Colors.black;
      final innerPinPaint = Paint()..color = Colors.white;
      canvas.drawCircle(center, 7, pinPaint);
      canvas.drawCircle(center, 3, innerPinPaint);
    }

    drawPin(Offset(w * 0.25, h * 0.28));
    drawPin(Offset(w * 0.75, h * 0.25));
    drawPin(Offset(w * 0.30, h * 0.75));
    drawPin(Offset(w * 0.72, h * 0.78));
  }

  @override
  bool shouldRepaint(covariant FieldMapPainter oldDelegate) => false;
}
