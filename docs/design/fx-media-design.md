# fx_media 设计文档

> 日期: 2026-06-14 | 层级: kit

---

## 定位

kit 层流程接口包。定义"选择/获取媒体资源"的协议，不绑定任何 picker 库。业务层面向接口编程，实现层由 App 注入。

---

## 解决的问题

1. 业务代码直接依赖具体 picker 库 → 换库时全量改
2. 不同项目用不同 picker（国内微信风格/海外系统原生/桌面 file_picker）→ 无法共享业务代码
3. 选图/选视频/选文件/拍照等流程散落各处 → 无统一入口

---

## 核心设计

### 1. 媒体资产模型（sealed class）

```dart
/// 媒体资产基类
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

  const ImageAsset({
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
  final String? thumbPath;   // 缩略图路径
  final int? width;
  final int? height;

  const VideoAsset({
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

  const AudioAsset({
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
  final String? fileName;    // 原始文件名
  final String? mimeType;    // MIME 类型

  const FileAsset({
    required this.path,
    required this.size,
    this.fileName,
    this.mimeType,
  });
}
```

### 2. Picker 接口

```dart
/// 媒体选择器协议
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
```

### 3. 配置对象

```dart
class ImagePickConfig {
  final int? maxWidth;
  final int? maxHeight;
  final int? quality;          // 0-100
  final bool enableCrop;
  final CropAspectRatio? cropRatio;

  const ImagePickConfig({
    this.maxWidth,
    this.maxHeight,
    this.quality,
    this.enableCrop = false,
    this.cropRatio,
  });
}

class VideoPickConfig {
  final Duration? maxDuration;
  final int? quality;

  const VideoPickConfig({
    this.maxDuration,
    this.quality,
  });
}

class CameraConfig {
  final bool preferFrontCamera;
  final int? maxWidth;
  final int? maxHeight;
  final Duration? maxDuration;

  const CameraConfig({
    this.preferFrontCamera = false,
    this.maxWidth,
    this.maxHeight,
    this.maxDuration,
  });
}

class CropAspectRatio {
  final double x;
  final double y;
  const CropAspectRatio(this.x, this.y);

  static const CropAspectRatio square = CropAspectRatio(1, 1);
  static const CropAspectRatio ratio16x9 = CropAspectRatio(16, 9);
  static const CropAspectRatio ratio4x3 = CropAspectRatio(4, 3);
}
```

### 4. 注册与使用

```dart
class FxMedia {
  FxMedia._();
  static FxMedia? _instance;
  factory FxMedia() => _instance ??= FxMedia._();

  MediaPicker? _picker;

  void register(MediaPicker picker) {
    _picker = picker;
  }

  MediaPicker get picker {
    assert(_picker != null, 'FxMedia: 请先调用 register 注册 MediaPicker 实现');
    return _picker!;
  }
}
```

---

## 使用示例

```dart
// === App 层注入 ===
FxMedia().register(MyPickerImpl());

// === 业务层使用 ===

// 选图
final List<ImageAsset> images = await FxMedia().picker.pickImages(maxCount: 3);

// 选视频
final VideoAsset? video = await FxMedia().picker.pickVideo(
  config: VideoPickConfig(maxDuration: Duration(seconds: 60)),
);

// 拍照
final ImageAsset? photo = await FxMedia().picker.takePhoto(
  config: CameraConfig(preferFrontCamera: true),
);

// 选文件
final List<FileAsset> files = await FxMedia().picker.pickFiles(
  allowedExtensions: ['pdf', 'docx'],
);

// switch 匹配
void handleAsset(MediaAsset asset) {
  switch (asset) {
    case ImageAsset(:final path, :final width):
      print('图片: $path, 宽: $width');
    case VideoAsset(:final duration, :final thumbPath):
      print('视频: ${duration?.inSeconds}s, 缩略图: $thumbPath');
    case AudioAsset(:final duration):
      print('音频: ${duration?.inSeconds}s');
    case FileAsset(:final fileName, :final mimeType):
      print('文件: $fileName ($mimeType)');
  }
}
```

---

## 不做什么

| 不做 | 原因 |
|------|------|
| 不内置任何 picker 实现 | 各项目选型不同，由 App 层提供 |
| 不做上传 | 上传是网络层职责（fx_dio） |
| 不做 UI（预览/编辑/画廊） | UI 是 App 层职责 |
| 不做权限请求 | 权限是独立关注点，picker 实现内部自行处理 |
| 不做压缩 | 可作为后续扩展接口 |

---

## 依赖

零依赖。纯接口定义 + 模型类。

---

## 目录结构

```
fx_media/
├── lib/
│   ├── fx_media.dart              barrel
│   └── src/
│       ├── model/
│       │   ├── image_asset.dart
│       │   ├── video_asset.dart
│       │   ├── audio_asset.dart
│       │   ├── file_asset.dart
│       │   └── media_asset.dart   sealed base
│       ├── config/
│       │   ├── image_pick_config.dart
│       │   ├── video_pick_config.dart
│       │   ├── camera_config.dart
│       │   └── crop_aspect_ratio.dart
│       ├── picker/
│       │   └── media_picker.dart  抽象接口
│       └── fx_media.dart          全局入口
├── pubspec.yaml
└── test/
```

---

## 与参考项目 media_display 的区别

| | media_display | fx_media |
|---|---|---|
| 层级 | 实现层（内嵌 6+ picker 库） | 接口层（零实现） |
| 依赖 | 10+ 个三方包 | 0 |
| 平台逻辑 | if Android / if iOS 硬编码 | 实现方自行处理 |
| 结果类型 | sealed class (Photo/Video/File) | sealed class (Image/Video/Audio/File) |
| 文件选择 | 有 | 有 |
| 音频 | 有（录音） | 有（选择接口） |
| 可替换性 | 整包替换 | 只换注册的实现类 |

---

## 后续可扩展

| 方向 | 说明 |
|------|------|
| MediaCompressor | 压缩接口（注入实现） |
| MediaEditor | 裁剪/旋转/滤镜接口 |
| 多源选择 | 一次弹窗同时支持相册+拍照+文件 |
| 录音 | `recordAudio()` 方法 |
| 缩略图生成 | `generateThumb(VideoAsset)` 接口 |
