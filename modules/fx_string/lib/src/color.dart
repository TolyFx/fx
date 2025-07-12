import 'dart:ui';

extension ColorStringExt on String {
  static Color kDefaultColor = Color(0xff000000);

  Color get color {
    String value = this;

    if (startsWith('#')) {
      value = substring(1);
    }
    int? colorValue = int.tryParse(value, radix: 16);
    if (colorValue == null) return kDefaultColor;
    return Color(colorValue);
  }
}

extension ColortoStringExt on Color {
  String get toHex {
    return '#'
        '${(a * 255.0).round().toRadixString(16).padLeft(2, '0')}'
        '${(r * 255.0).round().toRadixString(16).padLeft(2, '0')}'
        '${(g * 255.0).round().toRadixString(16).padLeft(2, '0')}'
        '${(b * 255.0).round().toRadixString(16).padLeft(2, '0')}';
  }
}
