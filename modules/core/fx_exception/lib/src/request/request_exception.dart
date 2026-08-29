import '../code.dart';
import '../exception/fx_exception.dart';

/// 请求模块的统一异常。
class RequestException extends FxException<RequestErrorCode> {
  /// 服务端返回的 HTTP 状态码。
  final int? httpStatus;

  /// 服务端返回的稳定业务错误码。
  final String? serverCode;

  /// 创建请求模块异常。
  const RequestException(
    super.code,
    super.message, [
    super.error,
    super.stack,
    this.httpStatus,
    this.serverCode,
  ]);

  @override
  String toString() => 'RequestException: [${code.name}#${code.code}] $message';
}

/// 框架级请求错误码。
enum RequestErrorCode with Code {
  convert(0),
  emptyData(1),
  exception(2);

  @override
  final int code;

  const RequestErrorCode(this.code);
}
