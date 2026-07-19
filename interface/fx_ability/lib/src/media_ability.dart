import 'dart:typed_data';

/// 媒体文件选择结果
class MediaResult {
  final String? path;
  final Uint8List? bytes;
  final String? name;
  final String? mimeType;

  const MediaResult({this.path, this.bytes, this.name, this.mimeType});
}

/// 图片选择配置
class ImagePickConfig {
  final double? maxWidth;
  final double? maxHeight;
  final int? quality;
  final bool preferFrontCamera;

  const ImagePickConfig({
    this.maxWidth,
    this.maxHeight,
    this.quality,
    this.preferFrontCamera = false,
  });
}

/// 媒体能力抽象接口
abstract class MediaAbility {
  /// 从相册选择图片
  Future<MediaResult?> pickImage([ImagePickConfig config = const ImagePickConfig()]);

  /// 从相册选择多张图片
  Future<List<MediaResult>> pickImages({int maxCount = 9, ImagePickConfig config = const ImagePickConfig()});

  /// 拍照
  Future<MediaResult?> takePhoto([ImagePickConfig config = const ImagePickConfig()]);

  /// 保存图片到相册
  Future<bool> saveImage(Uint8List bytes, {String? name});

  /// 选择视频
  Future<MediaResult?> pickVideo({Duration? maxDuration});

  /// 录制视频
  Future<MediaResult?> recordVideo({Duration? maxDuration});
}
