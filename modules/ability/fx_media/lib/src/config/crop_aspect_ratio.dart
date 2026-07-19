/// 裁剪比例
class CropAspectRatio {
  final double x;
  final double y;
  const CropAspectRatio(this.x, this.y);

  static const CropAspectRatio square = CropAspectRatio(1, 1);
  static const CropAspectRatio ratio16x9 = CropAspectRatio(16, 9);
  static const CropAspectRatio ratio4x3 = CropAspectRatio(4, 3);
  static const CropAspectRatio ratio3x4 = CropAspectRatio(3, 4);
  static const CropAspectRatio ratio9x16 = CropAspectRatio(9, 16);
}
