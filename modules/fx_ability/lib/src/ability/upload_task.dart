abstract class UploadTask {
  String get tokenPath;

  Future<String?> run({
    required String file,
    required String alias,
    String prefix = '',
  });
}
