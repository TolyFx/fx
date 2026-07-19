/// 上传能力抽象接口
abstract class UploadAbility {
  /// 获取上传凭证的路径
  String get tokenPath;

  /// 执行上传任务
  Future<String?> run({
    required String file,
    required String alias,
    String prefix = '',
  });
}
