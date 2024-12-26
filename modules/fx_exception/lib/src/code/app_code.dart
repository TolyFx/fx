
import 'code.dart';

/// 应用层: 状态码
enum AppCode with Code {
  unknown(999),
  requestException(1000),
  netConnect(1000),
  noResponseData(1001),
  // 转换异常
  convertException(1002),
  ;

  @override
  final int code;

  const AppCode(this.code);
}

