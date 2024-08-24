import 'package:flutter/foundation.dart';
import 'package:flutter_mobile_calendar/utils/lunar.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Lunar Tests', () {
    test('solar2lunar', () {
      var expected = {
        "date": "2024-8-10",
        "lunarDate": "2024-7-7",
        "festival": null,
        "lunarFestival": "七夕节",
        "lYear": 2024,
        "lMonth": 7,
        "lDay": 7,
        "Animal": "龙",
        "IMonthCn": "七月",
        "IDayCn": "初七",
        "cYear": 2024,
        "cMonth": 8,
        "cDay": 10,
        "gzYear": "甲辰",
        "gzMonth": "壬申",
        "gzDay": "丙午",
        "isToday": false,
        "isLeap": false,
        "nWeek": 6,
        "ncWeek": "星期六",
        "isTerm": false,
        "Term": null,
        "astro": "狮子座"
      };

      expect(
          mapEquals(CalendarUtils.solar2lunar(2024, 8, 10), expected), isTrue);
    });

    test('lunar2solar', () {
      var expected = {
        "date": "2024-8-10",
        "lunarDate": "2024-7-7",
        "festival": null,
        "lunarFestival": "七夕节",
        "lYear": 2024,
        "lMonth": 7,
        "lDay": 7,
        "Animal": "龙",
        "IMonthCn": "七月",
        "IDayCn": "初七",
        "cYear": 2024,
        "cMonth": 8,
        "cDay": 10,
        "gzYear": "甲辰",
        "gzMonth": "壬申",
        "gzDay": "丙午",
        "isToday": false,
        "isLeap": false,
        "nWeek": 6,
        "ncWeek": "星期六",
        "isTerm": false,
        "Term": null,
        "astro": "狮子座"
      };

      expect(mapEquals(CalendarUtils.lunar2solar(2024, 7, 7, false), expected),
          isTrue);
    });
  });
}
