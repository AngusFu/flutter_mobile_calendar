class JsDate {
  DateTime _dateTime;

  // 构造函数
  /// 目前只支持一个、三个参数的存在的情况
  JsDate([int? year, int? month, int? day])
      : _dateTime = year != null && month == null && day == null
            ? DateTime.fromMillisecondsSinceEpoch(year)
            : DateTime(year ?? DateTime.now().year,
                month ?? DateTime.now().month, day ?? DateTime.now().day);

  // 获取当前年份
  int getFullYear() {
    return _dateTime.year;
  }

  // 获取当前月份（JavaScript中是0-11，Java中是1-12）
  int getMonth() {
    return _dateTime.month - 1; // 转换为0-11
  }

  // 获取当前星期几（0-6，0表示星期日，6表示星期六）
  int getDay() {
    return _dateTime.weekday % 7; // 转换为0-6，0表示星期日
  }

  // 获取当前日期
  int getDate() {
    return _dateTime.day;
  }

  // 获取当前小时
  int getHours() {
    return _dateTime.hour;
  }

  // 获取当前分钟
  int getMinutes() {
    return _dateTime.minute;
  }

  // 获取当前秒
  int getSeconds() {
    return _dateTime.second;
  }

  // 获取当前毫秒
  int getMilliseconds() {
    return _dateTime.millisecond;
  }

// 获取UTC年份
  int getUTCFullYear() {
    return _dateTime.toUtc().year;
  }

  // 获取UTC月份（JavaScript中是0-11，Java中是1-12）
  int getUTCMonth() {
    return _dateTime.toUtc().month - 1; // 转换为0-11
  }

  // 获取UTC日期
  int getUTCDate() {
    return _dateTime.toUtc().day;
  }

  // 转换为时间戳（毫秒）
  int getTime() {
    return _dateTime.millisecondsSinceEpoch;
  }

  // 设置年份
  void setFullYear(int year) {
    _dateTime = DateTime(year, _dateTime.month, _dateTime.day);
  }

  // 设置月份
  void setMonth(int month) {
    _dateTime = DateTime(_dateTime.year, month + 1, _dateTime.day);
  }

  // 设置日期
  void setDate(int date) {
    _dateTime = DateTime(_dateTime.year, _dateTime.month, date);
  }

  // 转换为字符串
  @override
  String toString() {
    return _dateTime.toIso8601String();
  }

  // 静态方法：返回UTC时间戳
  static int UTC(int year, int month,
      [int? day, int? hour, int? minute, int? second, int? millisecond]) {
    DateTime utcDateTime = DateTime.utc(
        year,
        month + 1, // Dart中的月份是1-12
        day ?? 1, // 默认日期为1
        hour ?? 0, // 默认小时为0
        minute ?? 0, // 默认分钟为0
        second ?? 0, // 默认秒为0
        millisecond ?? 0 // 默认毫秒为0
        );
    return utcDateTime.millisecondsSinceEpoch;
  }
}
