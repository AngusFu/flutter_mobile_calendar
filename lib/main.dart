import 'package:flutter/material.dart';
import 'package:flutter_application_1/calendar_three_day_view.dart';
import 'package:flutter_application_1/multi_view_app.dart';

void main() {
  runWidget(MultiViewApp(
    viewBuilder: (BuildContext context) => const CalendarThreeDayViewApp(),
  ));
}
