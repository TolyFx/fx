class AssetsNotFindException implements Exception {
  final String assets;
  const AssetsNotFindException(this.assets);
}