import 'crop_aspect_ratio.dart';

/// 图片选择配置
class ImagePickConfig {
  final int? maxWidth;
  final int? maxHeight;
  final int? quality;
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
