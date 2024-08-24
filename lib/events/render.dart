import 'package:flutter/material.dart';

class LayoutInfo {
  final Style style;
  final TypoData typoData;

  LayoutInfo({required this.style, required this.typoData});
}

class Style {
  final double left;
  final double top;
  final double width;
  final double height;
  final double borderRadius;
  final Color backgroundColor;
  final Color borderColor;
  final double borderLeftWidth;
  final double paddingLeft;

  Style({
    required this.left,
    required this.top,
    required this.width,
    required this.height,
    required this.borderRadius,
    required this.backgroundColor,
    required this.borderColor,
    required this.borderLeftWidth,
    required this.paddingLeft,
  });
}

class TypoData {
  final String text;
  final Color color;
  final List<Path> iconsPath2D;

  TypoData(
      {required this.text, required this.color, required this.iconsPath2D});
}

class EventPainter extends CustomPainter {
  final List<LayoutInfo> renderData;

  EventPainter(this.renderData);

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint();

    for (var layoutInfo in renderData) {
      final style = layoutInfo.style;
      final typoData = layoutInfo.typoData;

      canvas.save();
      canvas.translate(style.left, style.top);

      // 圆角矩形 clip 下
      final eventRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, style.width, style.height),
        Radius.circular(style.borderRadius),
      );
      canvas.clipRRect(eventRect);

      // 绘制背景和边框
      paint.color = style.backgroundColor;
      canvas.drawRect(Rect.fromLTWH(0, 0, style.width, style.height), paint);

      paint.color = style.borderColor;
      canvas.drawRect(
          Rect.fromLTWH(0, 0, style.borderLeftWidth, style.height), paint);

      // 空间太小直接不绘制文本了
      if (style.width <= style.borderLeftWidth + 6) {
        canvas.restore();
        continue;
      }

      // 绘制文本
      const double paddingTop = 4;
      final double paddingLeft = style.paddingLeft;
      final double borderLeftWidth = style.borderLeftWidth;

      const double lineHeight = 16;
      final double contentWidth = style.width - (borderLeftWidth + paddingLeft);
      final double contentHeight = style.height - paddingTop - 2;
      final int estimatedLineCount = (contentHeight / lineHeight).floor();
      final bool isMini = estimatedLineCount < 1;

      final Rect textConstraints = Rect.fromLTWH(
        borderLeftWidth + paddingLeft,
        isMini ? 0 : paddingTop,
        contentWidth,
        isMini ? style.height : contentHeight,
      );

      final int iconCount = (contentWidth / (12 + 2))
          .floor()
          .clamp(0, typoData.iconsPath2D.length);
      final Rect iconBox = Rect.fromLTWH(
        style.width - 2 - iconCount * (12 + 2),
        style.height - (isMini ? 12 : 12 + 2),
        iconCount * (12 + 2),
        isMini ? 12 : 15,
      );

      // final Rect iconBoxByConstraints = Rect.fromLTWH(
      //   iconBox.left - textConstraints.left,
      //   iconBox.top - textConstraints.top,
      //   iconBox.width,
      //   iconBox.height,
      // );

      // 开始绘制细节
      // --------------------------------------------------------------------------------------------------
      canvas.save();
      if (!isMini) {
        final Rect clipRect = Rect.fromLTWH(
            borderLeftWidth, paddingTop, contentWidth, contentHeight);
        canvas.clipRect(clipRect);
      }

      // 绘制多行文本
      drawMultiLineText(canvas, typoData.text, textConstraints, typoData.color,
          isMini ? 12 : lineHeight);

      canvas.translate(iconBox.left, iconBox.top);
      paint.color = typoData.color;
      for (int i = 0; i < iconCount; i++) {
        canvas.save();
        canvas.translate(i * (12 + 2), 0);
        canvas.drawPath(typoData.iconsPath2D[i], paint);
        canvas.restore();
      }
      canvas.restore();
      // --------------------------------------------------------------------------------------------------

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

void drawMultiLineText(Canvas canvas, String text, Rect constraints,
    Color color, double lineHeight) {
  final TextPainter textPainter = TextPainter(
    text: TextSpan(
      text: text,
      style: TextStyle(
        color: color,
        fontSize: 12,
        fontWeight: FontWeight.w600,
        fontFamily:
            '-apple-system,BlinkMacSystemFont,Helvetica Neue,Helvetica,Segoe UI,Arial,Roboto,PingFang SC,miui,Hiragino Sans GB,Microsoft Yahei,sans-serif',
      ),
    ),
    textDirection: TextDirection.ltr,
    maxLines: (constraints.height / lineHeight).floor(),
  );

  textPainter.layout(maxWidth: constraints.width);
  textPainter.paint(canvas, Offset(constraints.left, constraints.top));
}

class EventCanvas extends StatelessWidget {
  final List<LayoutInfo> renderData;

  const EventCanvas({super.key, required this.renderData});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.infinite,
      painter: EventPainter(renderData),
    );
  }
}
