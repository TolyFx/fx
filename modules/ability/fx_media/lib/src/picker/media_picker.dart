import '../config/camera_config.dart';
import '../config/image_pick_config.dart';
import '../config/video_pick_config.dart';
import '../model/media_asset.dart';

/// 媒体选择器协议。
///
/// 定义选择/获取媒体资源的统一接口。App 层实现此接口并通过
/// [FxMedia.register] 注入，业务层只面向此协议编程。
///
/// ```dart
/// class MyPickerImpl implements MediaPicker {
///   @override
///   Future<List<ImageAsset>> pickImages({...}) async { ... }
///   // ...
/// }
///
/// FxMedia().register(MyPickerImpl());
/// ```
abstract class MediaPicker {
  /// 从相册选择图片
  Future<List<ImageAsset>> pickImages({
    int maxCount = 9,
    ImagePickConfig config = const ImagePickConfig(),
  });

  /// 从相册选择视频
  Future<VideoAsset?> pickVideo({
    VideoPickConfig config = const VideoPickConfig(),
  });

  /// 拍照
  Future<ImageAsset?> takePhoto({
    CameraConfig config = const CameraConfig(),
  });

  /// 录视频
  Future<VideoAsset?> takeVideo({
    CameraConfig config = const CameraConfig(),
  });

  /// 选择文件（文档、压缩包等）
  Future<List<FileAsset>> pickFiles({
    List<String>? allowedExtensions,
    int maxCount = 1,
  });

  /// 选择音频
  Future<AudioAsset?> pickAudio();
}
