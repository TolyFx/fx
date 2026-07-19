/// 权限状态
enum PermissionState {
  granted,
  denied,
  permanentlyDenied,
  restricted,
  limited,
}

/// 权限类型
enum PermissionType {
  camera,
  photos,
  microphone,
  location,
  notification,
  storage,
  contacts,
  calendar,
}

/// 权限管理能力抽象接口
abstract class PermissionAbility {
  /// 检查权限状态
  Future<PermissionState> check(PermissionType type);

  /// 请求权限
  Future<PermissionState> request(PermissionType type);

  /// 批量请求权限
  Future<Map<PermissionType, PermissionState>> requestMultiple(List<PermissionType> types);

  /// 打开应用设置页（用户永久拒绝后引导）
  Future<bool> openSettings();
}
