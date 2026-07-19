/// 本地键值存储能力抽象接口
abstract class StorageAbility {
  /// 读取字符串
  Future<String?> getString(String key);

  /// 写入字符串
  Future<bool> setString(String key, String value);

  /// 读取布尔值
  Future<bool?> getBool(String key);

  /// 写入布尔值
  Future<bool> setBool(String key, bool value);

  /// 读取整数
  Future<int?> getInt(String key);

  /// 写入整数
  Future<bool> setInt(String key, int value);

  /// 读取双精度浮点
  Future<double?> getDouble(String key);

  /// 写入双精度浮点
  Future<bool> setDouble(String key, double value);

  /// 删除指定 key
  Future<bool> remove(String key);

  /// 清空所有数据
  Future<bool> clear();

  /// 是否包含指定 key
  Future<bool> containsKey(String key);
}
