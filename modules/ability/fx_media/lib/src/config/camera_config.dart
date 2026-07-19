/// 相机配置（拍照/录视频）
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
