import 'package:flutter/material.dart';
import 'package:flutter_mobile_calendar/calendar_three_day_view.dart';
import 'package:flutter_mobile_calendar/multi_view_app.dart';

void main() {
  runWidget(MultiViewApp(
    viewBuilder: (BuildContext context) => const CalendarThreeDayViewApp(),
  ));
}
