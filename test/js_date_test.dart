import 'package:flutter_application_1/utils/js_date.dart';
import 'package:flutter_application_1/utils/lunar.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Date Tests', () {
    test('Default constructor should use current date', () {
      JsDate date = JsDate();
      DateTime now = DateTime.now();
      expect(date.getFullYear(), now.year);
      expect(date.getMonth(), now.month - 1); // Dart 中的月份是 1-12
      expect(date.getDate(), now.day);
    });

    test('Constructor with milliseconds since epoch', () {
      JsDate date = JsDate(1672531199000); // 2023-01-01 00:00:00
      expect(date.getFullYear(), 2023);
      expect(date.getMonth(), 0); // January
      expect(date.getDate(), 1);
    });

    test('getDay method should return the correct day of the week', () {
      Date date = Date(2023, 8, 10); // Thursday
      expect(date.getDay(), 4); // 0=Sunday, 4=Thursday
    });

    test('getUTCFullYear should return the correct UTC year', () {
      Date date = Date(2023, 8, 10);
      DateTime utcDate = DateTime(2023, 8, 10);
      expect(date.getUTCFullYear(), utcDate.year);
    });

    test('getUTCMonth should return the correct UTC month', () {
      Date date = Date(2023, 8, 10);
      DateTime utcDate = DateTime(2023, 8, 10);
      expect(date.getUTCMonth(), utcDate.month - 1); // 0-11
    });

    test('getUTCDate should return the correct UTC date', () {
      Date date = Date(2023, 8, 10);
      // 由于在东八区，2023年8月10日的UTC日期是9
      DateTime utcDate = DateTime(2023, 8, 10);
      expect(date.getUTCDate(), utcDate.toUtc().day); // 直接使用 UTC 日期
    });

    test('setFullYear should update the year correctly', () {
      Date date = Date(2023, 8, 10);
      date.setFullYear(2025);
      expect(date.getFullYear(), 2025);
    });

    test('setMonth should update the month correctly', () {
      Date date = Date(2023, 8, 10);
      date.setMonth(11); // December
      expect(date.getMonth(), 11); // 11对应的是12月
    });

    test('setDate should update the date correctly', () {
      Date date = Date(2023, 8, 10);
      date.setDate(15);
      expect(date.getDate(), 15);
    });

    test('utc method should return the correct UTC timestamp', () {
      int utcTimestamp = Date.UTC(2023, 8, 10);
      expect(utcTimestamp,
          DateTime.utc(2023, 9, 10).millisecondsSinceEpoch); // 注意月份是1-12
    });
  });
}
