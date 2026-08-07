import 'package:flutter/material.dart';

import '../core/models/daily_entry.dart';
import '../core/models/mood_type.dart';

/// 7-day mood trend line chart drawn with [CustomPainter].
///
/// No external chart library dependency. Maps each [MoodType] to a
/// Y-axis index (0-6), draws a smooth line with gradient fill,
/// dots at data points, and day labels below. Handles empty state.
class MoodTrendChart extends StatelessWidget {
  const MoodTrendChart({
    super.key,
    required this.entries,
    this.height = 180,
  });

  final List<DailyEntry> entries;
  final double height;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (entries.isEmpty) {
      return SizedBox(
        height: height,
        child: Center(
          child: Text('No entries yet this week', style: theme.textTheme.bodyMedium),
        ),
      );
    }

    return SizedBox(
      height: height,
      child: CustomPaint(
        size: Size.infinite,
        painter: _MoodTrendPainter(
          entries: entries,
          gridColor: theme.colorScheme.outline.withOpacity(0.15),
          labelColor: theme.colorScheme.onSurface.withOpacity(0.4),
          lineColor: theme.colorScheme.primary,
          dotCenterColor: theme.colorScheme.surface,
        ),
      ),
    );
  }
}

class _MoodTrendPainter extends CustomPainter {
  _MoodTrendPainter({
    required this.entries,
    required this.gridColor,
    required this.labelColor,
    required this.lineColor,
    required this.dotCenterColor,
  });

  final List<DailyEntry> entries;
  final Color gridColor;
  final Color labelColor;
  final Color lineColor;
  final Color dotCenterColor;

  static const List<MoodType> _moodOrder = [
    MoodType.peaceful,
    MoodType.thankful,
    MoodType.joyful,
    MoodType.hopeful,
    MoodType.anxious,
    MoodType.worried,
    MoodType.tired,
  ];

  int _moodIndex(MoodType mood) => _moodOrder.indexOf(mood);

  @override
  void paint(Canvas canvas, Size size) {
    final padding = const EdgeInsets.only(left: 40, right: 16, top: 24, bottom: 32);
    final chartWidth = size.width - padding.left - padding.right;
    final chartHeight = size.height - padding.top - padding.bottom;

    final labelStyle = TextPainter(textDirection: TextDirection.ltr, textAlign: TextAlign.right);

    for (int i = 0; i < _moodOrder.length; i++) {
      final y = padding.top + chartHeight - (i / (_moodOrder.length - 1)) * chartHeight;
      labelStyle.text = TextSpan(
        text: _moodOrder[i].name.substring(0, 3).toUpperCase(),
        style: TextStyle(fontSize: 10, color: labelColor),
      );
      labelStyle.layout();
      labelStyle.paint(canvas, Offset(padding.left - 36, y - 6));
    }

    final gridPaint = Paint()
      ..color = gridColor
      ..strokeWidth = 0.5;

    for (int i = 0; i < _moodOrder.length; i++) {
      final y = padding.top + chartHeight - (i / (_moodOrder.length - 1)) * chartHeight;
      canvas.drawLine(Offset(padding.left, y), Offset(size.width - padding.right, y), gridPaint);
    }

    if (entries.length < 2) {
      _drawDot(canvas, padding, chartWidth, chartHeight, 0);
      _drawDayLabel(canvas, padding, chartWidth, chartHeight, 0, size.height);
      return;
    }

    final points = <Offset>[];
    for (int i = 0; i < entries.length; i++) {
      final x = padding.left + (i / (entries.length - 1)) * chartWidth;
      final moodIdx = _moodIndex(entries[i].mood);
      final y = padding.top + chartHeight - (moodIdx / (_moodOrder.length - 1)) * chartHeight;
      points.add(Offset(x, y));
    }

    final fillPath = Path()
      ..moveTo(points.first.dx, padding.top + chartHeight)
      ..lineTo(points.first.dx, points.first.dy);
    for (int i = 1; i < points.length; i++) {
      fillPath.lineTo(points[i].dx, points[i].dy);
    }
    fillPath
      ..lineTo(points.last.dx, padding.top + chartHeight)
      ..close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [lineColor.withOpacity(0.3), lineColor.withOpacity(0.0)],
      ).createShader(Rect.fromLTRB(
        padding.left,
        padding.top,
        size.width - padding.right,
        padding.top + chartHeight,
      ));

    canvas.drawPath(fillPath, fillPaint);

    final linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    final linePath = Path()..moveTo(points.first.dx, points.first.dy);
    for (int i = 1; i < points.length; i++) {
      linePath.lineTo(points[i].dx, points[i].dy);
    }
    canvas.drawPath(linePath, linePaint);

    for (int i = 0; i < points.length; i++) {
      _drawDotAt(canvas, points[i], entries[i].mood.colorToken);
    }

    for (int i = 0; i < entries.length; i++) {
      _drawDayLabel(canvas, padding, chartWidth, chartHeight, i, size.height);
    }
  }

  void _drawDot(Canvas canvas, EdgeInsets padding, double chartWidth, double chartHeight, int index) {
    final x = padding.left + (index / (entries.length - 1)) * chartWidth;
    final moodIdx = _moodIndex(entries[index].mood);
    final y = padding.top + chartHeight - (moodIdx / (_moodOrder.length - 1)) * chartHeight;
    _drawDotAt(canvas, Offset(x, y), entries[index].mood.colorToken);
  }

  void _drawDotAt(Canvas canvas, Offset center, Color color) {
    canvas.drawCircle(center, 8, Paint()..color = color.withOpacity(0.2));
    canvas.drawCircle(center, 5, Paint()..color = color);
    canvas.drawCircle(center, 2, Paint()..color = dotCenterColor);
  }

  void _drawDayLabel(Canvas canvas, EdgeInsets padding, double chartWidth, double chartHeight, int index, double totalHeight) {
    final x = padding.left + (index / (entries.length - 1)) * chartWidth;
    final dayName = _dayAbbreviation(entries[index].date);

    final labelPainter = TextPainter(
      text: TextSpan(text: dayName, style: TextStyle(fontSize: 10, color: labelColor)),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );
    labelPainter.layout();
    labelPainter.paint(canvas, Offset(x - labelPainter.width / 2, totalHeight - 24));
  }

  String _dayAbbreviation(DateTime date) {
    const days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    return days[date.weekday % 7];
  }

  @override
  bool shouldRepaint(covariant _MoodTrendPainter oldDelegate) {
    return oldDelegate.entries.length != entries.length ||
        oldDelegate.entries != entries ||
        oldDelegate.lineColor != lineColor;
  }
}
