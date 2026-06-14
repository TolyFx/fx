/// 媒体资产基类。
///
/// 所有媒体类型（图片、视频、音频、文件）的共同协议。
/// 使用 sealed class 支持 Dart 3 的 `switch` 穷举匹配：
///
/// ```dart
/// switch (asset) {
///   case ImageAsset(:final path): ...
///   case VideoAsset(:final duration): ...
///   case AudioAsset(:final duration): ...
///   case FileAsset(:final fileName): ...
/// }
/// ```
sealed class MediaAsset {
  /// 本地文件路径
  String get path;

  /// 文件大小（字节）
  int get size;
}

/// 图片资产
class ImageAsset extends MediaAsset {
  @override
  final String path;
  @override
  final int size;
  final int? width;
  final int? height;

  ImageAsset({
    required this.path,
    required this.size,
    this.width,
    this.height,
  });
}

/// 视频资产
class VideoAsset extends MediaAsset {
  @override
  final String path;
  @override
  final int size;
  final Duration? duration;
  final String? thumbPath;
  final int? width;
  final int? height;

  VideoAsset({
    required this.path,
    required this.size,
    this.duration,
    this.thumbPath,
    this.width,
    this.height,
  });
}

/// 音频资产
class AudioAsset extends MediaAsset {
  @override
  final String path;
  @override
  final int size;
  final Duration? duration;

  AudioAsset({
    required this.path,
    required this.size,
    this.duration,
  });
}

/// 文件资产（文档、压缩包等）
class FileAsset extends MediaAsset {
  @override
  final String path;
  @override
  final int size;
  final String? fileName;
  final String? mimeType;

  FileAsset({
    required this.path,
    required this.size,
    this.fileName,
    this.mimeType,
  });
}
