import 'dart:typed_data';

/// 分享能力抽象接口
abstract class ShareAbility {
  /// 分享文本
  Future<void> shareText(String text, {String? subject});

  /// 分享图片
  Future<void> shareImage(Uint8List bytes, {String? name, String? text});

  /// 分享文件
  Future<void> shareFile(String filePath, {String? mimeType, String? text});
}
