import 'package:flutter/material.dart';

class _EventGridPaperPainter extends CustomPainter {
  const _EventGridPaperPainter({
    required this.color,
    required this.width,
    required this.height,
  });

  final Color color;
  final double width;
  final double height;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint linePaint = Paint()..color = color;

    linePaint.strokeWidth = 0.1;
    canvas.drawLine(const Offset(.1, 0.0), Offset(.1, size.height), linePaint);
    for (double y = height; y <= size.height + 0.1; y += height) {
      canvas.drawLine(Offset(0.0, y), Offset(size.width, y), linePaint);
    }
  }

  @override
  bool shouldRepaint(_EventGridPaperPainter oldPainter) {
    return oldPainter.color != color ||
        oldPainter.width != width ||
        oldPainter.height != height;
  }

  @override
  bool hitTest(Offset position) => false;
}

class EventsGridPaper extends StatelessWidget {
  const EventsGridPaper({
    super.key,
    this.color = const Color(0xffe3e3e3),
    required this.width,
    required this.height,
    this.child,
  });

  final Color color;
  final double width;
  final double height;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      foregroundPainter: _EventGridPaperPainter(
        color: color,
        width: width,
        height: height,
      ),
      child: child,
    );
  }
}
