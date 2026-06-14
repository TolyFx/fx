import 'picker/media_picker.dart';

/// 全局媒体选择入口。
///
/// 单例模式。App 启动时注册 [MediaPicker] 实现，业务层通过
/// `FxMedia().picker` 获取并调用。
///
/// ```dart
/// // 注册
/// FxMedia().register(MyPickerImpl());
///
/// // 使用
/// final images = await FxMedia().picker.pickImages(maxCount: 3);
/// ```
class FxMedia {
  FxMedia._();

  static FxMedia? _instance;

  factory FxMedia() => _instance ??= FxMedia._();

  MediaPicker? _picker;

  /// 注册媒体选择器实现
  void register(MediaPicker picker) {
    _picker = picker;
  }

  /// 获取已注册的选择器
  MediaPicker get picker {
    assert(_picker != null, 'FxMedia: 请先调用 register 注册 MediaPicker 实现');
    return _picker!;
  }
}
