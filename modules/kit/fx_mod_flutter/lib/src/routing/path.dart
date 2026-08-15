/// 将父路由与当前路由拼接成稳定完整路径。
String fxJoinRoutePath(String parentPath, String routePath) {
  if (parentPath.isEmpty || routePath.startsWith('/')) return routePath;
  final String normalizedParent = parentPath.endsWith('/')
      ? parentPath.substring(0, parentPath.length - 1)
      : parentPath;
  final String normalizedRoute = routePath.startsWith('/')
      ? routePath.substring(1)
      : routePath;
  return '$normalizedParent/$normalizedRoute';
}
