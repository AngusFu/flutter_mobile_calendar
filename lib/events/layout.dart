import 'package:flutter/material.dart';
import 'package:flutter_mobile_calendar/models/layouts.dart';

class Style {
  String boxSizing;
  String position;
  double left;
  double top;
  double width;
  double height;
  double paddingLeft;
  double borderRadius;
  double borderLeftWidth;
  String borderLeftStyle;
  String overflow;

  Color color;
  Color backgroundColor;
  Color borderColor;

  Style({
    required this.boxSizing,
    required this.position,
    required this.left,
    required this.top,
    required this.width,
    required this.height,
    required this.paddingLeft,
    required this.borderRadius,
    required this.borderLeftWidth,
    required this.borderLeftStyle,
    required this.overflow,
    required this.color,
    required this.backgroundColor,
    required this.borderColor,
  });
}

List<Style> getDayEventsLayout({
  required double width,
  required double height,
  required List<LayoutGroup> groups,
}) {
  const dayRange = 24 * 60 * 60 * 1000;
  final canvasHeight = (height / 25) * 24;

  return groups.expand((group) {
    final columnWidth = width / group.columnCount!;
    final groupHeight = ((group.end! - group.start!) / dayRange) * canvasHeight;
    final groupY = (group.start! / dayRange) * canvasHeight;
    const groupX = 0;

    return group.items!.map((el) {
      const space = 2;

      final itemHeight = el.event!.end! - el.event!.start! < 30 * 60 * 1000
          ? (1.04167 / 100) * canvasHeight - space
          : el.height! * groupHeight - space;

      return Style(
        boxSizing: 'border-box',
        position: 'absolute',
        left: groupX + el.column! * columnWidth,
        top: groupY + el.top! * groupHeight,
        width: columnWidth - space,
        height: itemHeight,
        paddingLeft: 2,
        borderRadius: 3,
        borderLeftWidth: 3,
        borderLeftStyle: 'solid',
        overflow: 'hidden',
        color: const Color.fromRGBO(58, 100, 255, 1),
        backgroundColor: const Color.fromRGBO(58, 100, 255, 0.15),
        borderColor: const Color.fromRGBO(58, 100, 255, 0.15),
      );
    });
  }).toList();
}
