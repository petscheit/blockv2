import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/session_settings.dart';

class AnalogClock extends StatelessWidget {
  const AnalogClock({
    super.key,
    required this.time,
    required this.settings,
  });

  final DateTime time;
  final SessionSettings settings;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: CustomPaint(
        painter: _ClockPainter(time: time, settings: settings),
      ),
    );
  }
}

class _ClockPainter extends CustomPainter {
  _ClockPainter({
    required this.time,
    required this.settings,
  });

  final DateTime time;
  final SessionSettings settings;

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = size.center(Offset.zero);
    final double radius = size.shortestSide * 0.48;
    final bool isNight = settings.themeMode == BlockThemeMode.night;
    final Color faceColor = isNight ? const Color(0xFF17212B) : const Color(0xFFF6EFE2);
    final Color ringColor = isNight ? const Color(0xFF3A5166) : const Color(0xFFBC9F73);
    final Color markerColor = isNight ? const Color(0xFFD9E3EC) : const Color(0xFF2C2418);
    final Color handColor = isNight ? const Color(0xFFF2F4F7) : const Color(0xFF2E271D);
    final Color secondColor = isNight ? const Color(0xFF96B8CF) : const Color(0xFF8A6D40);

    final Rect faceRect = Rect.fromCircle(center: center, radius: radius);
    final Paint shadowPaint = Paint()
      ..color = isNight ? const Color(0x40000000) : const Color(0x332A2418)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
    canvas.drawCircle(center.translate(0, 12), radius * 0.96, shadowPaint);

    final Paint facePaint = Paint()
      ..shader = RadialGradient(
        colors: isNight
            ? const <Color>[Color(0xFF1F2B36), Color(0xFF131A22)]
            : const <Color>[Color(0xFFFDF7ED), Color(0xFFE7DBC8)],
      ).createShader(faceRect);
    canvas.drawCircle(center, radius * 0.96, facePaint);

    final Paint ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = radius * 0.045
      ..color = ringColor.withValues(alpha: 0.9);
    canvas.drawCircle(center, radius * 0.93, ringPaint);

    final Paint markerPaint = Paint()
      ..color = markerColor.withValues(alpha: 0.82)
      ..strokeCap = StrokeCap.round;
    for (int i = 0; i < 12; i++) {
      final double angle = (i * math.pi / 6) - (math.pi / 2);
      final bool major = i % 3 == 0;
      final double outer = radius * 0.85;
      final double inner = radius * (major ? 0.72 : 0.77);
      markerPaint.strokeWidth = major ? radius * 0.03 : radius * 0.014;
      final Offset p1 = Offset(center.dx + outer * math.cos(angle), center.dy + outer * math.sin(angle));
      final Offset p2 = Offset(center.dx + inner * math.cos(angle), center.dy + inner * math.sin(angle));
      canvas.drawLine(p1, p2, markerPaint);
    }

    final double hour = (time.hour % 12) + (time.minute / 60);
    final double minute = time.minute + (time.second / 60);
    final double second = time.second + (time.millisecond / 1000);
    final double hourAngle = ((hour / 12) * 2 * math.pi) - math.pi / 2;
    final double minuteAngle = ((minute / 60) * 2 * math.pi) - math.pi / 2;
    final double secondAngle = ((second / 60) * 2 * math.pi) - math.pi / 2;

    _drawHand(
      canvas: canvas,
      center: center,
      angle: hourAngle,
      length: radius * 0.46,
      thickness: settings.handThickness * 1.35,
      color: handColor,
      shadowColor: shadowPaint.color,
    );
    _drawHand(
      canvas: canvas,
      center: center,
      angle: minuteAngle,
      length: radius * 0.68,
      thickness: settings.handThickness,
      color: handColor.withValues(alpha: 0.95),
      shadowColor: shadowPaint.color,
    );
    if (settings.showSecondHand) {
      _drawHand(
        canvas: canvas,
        center: center,
        angle: secondAngle,
        length: radius * 0.74,
        thickness: 2.2,
        color: secondColor,
        shadowColor: Colors.transparent,
      );
    }

    final Paint centerCapPaint = Paint()..color = handColor;
    final Paint centerInnerPaint = Paint()..color = faceColor;
    canvas.drawCircle(center, radius * 0.05, centerCapPaint);
    canvas.drawCircle(center, radius * 0.015, centerInnerPaint);
  }

  void _drawHand({
    required Canvas canvas,
    required Offset center,
    required double angle,
    required double length,
    required double thickness,
    required Color color,
    required Color shadowColor,
  }) {
    final Offset tip = Offset(center.dx + length * math.cos(angle), center.dy + length * math.sin(angle));
    final Offset tail = Offset(
      center.dx - (length * 0.22) * math.cos(angle),
      center.dy - (length * 0.22) * math.sin(angle),
    );

    if (shadowColor.a > 0) {
      final Paint shadow = Paint()
        ..color = shadowColor
        ..strokeWidth = thickness * 1.2
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
      canvas.drawLine(tail.translate(0, 1.5), tip.translate(0, 1.5), shadow);
    }

    final Paint handPaint = Paint()
      ..color = color
      ..strokeCap = StrokeCap.round
      ..strokeWidth = thickness;
    canvas.drawLine(tail, tip, handPaint);
  }

  @override
  bool shouldRepaint(covariant _ClockPainter oldDelegate) {
    return oldDelegate.time != time || oldDelegate.settings != settings;
  }
}
