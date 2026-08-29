typedef DataConvertor<T> = T Function(dynamic data);
typedef DecryptConvertor = String Function(String data);

/// 未提供自定义转换器时使用的默认行为。
///
/// `void` 请求忽略响应内容，其他类型直接透传并执行运行时类型检查。
T defaultDataConvertor<T>(dynamic data) {
  if (isVoidDataType<T>()) return null as T;
  return data as T;
}

/// 判断泛型响应是否声明为 `void`。
bool isVoidDataType<T>() => T.toString() == 'void';
