import 'package:flutter_test/flutter_test.dart';
import 'package:fx_media_picker/fx_media_picker.dart';

void main() {
  group('FxMediaPickerImpl', () {
    test('实现了 MediaPicker 接口', () {
      final FxMediaPickerImpl picker = FxMediaPickerImpl();
      expect(picker, isA<MediaPicker>());
    });

    test('可注册到 FxMedia', () {
      FxMedia().register(FxMediaPickerImpl());
      expect(FxMedia().picker, isA<FxMediaPickerImpl>());
    });
  });
}
