extension NumberStringExt on String {
  /// 数字每 [interval] 位添加 ','
  /// 如: 1,234,567
  String separator({int interval = 3}) {
    List<String> valueList = [];
    int current = length;
    while (current >= interval) {
      valueList.add(substring(current - interval, current));
      current -= interval;
    }
    if (current != 0) {
      valueList.add(substring(0, current));
    }
    return valueList.reversed.join(",");
  }
}
