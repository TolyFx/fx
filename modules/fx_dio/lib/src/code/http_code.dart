import 'code.dart';

/// HTTP 通用状态码
enum HttpCode with Code {
  // 2xx 成功
  ok(200), // 请求成功
  created(201), // 已创建
  accepted(202), // 已接受
  noContent(204), // 无内容

  // 3xx 重定向
  movedPermanently(301), // 永久重定向
  found(302), // 临时重定向
  notModified(304), // 未修改

  // 4xx 客户端错误
  badRequest(400), // 错误请求
  unauthorized(401), // 未授权
  forbidden(403), // 禁止访问
  notFound(404), // 未找到
  methodNotAllowed(405), // 方法不被允许
  conflict(409), // 冲突
  gone(410), // 资源已删除
  unsupportedMediaType(415), // 不支持的媒体类型

  // 5xx 服务器错误
  internalServerError(500), // 服务器内部错误
  notImplemented(501), // 未实现
  badGateway(502), // 网关错误
  serviceUnavailable(503), // 服务不可用
  gatewayTimeout(504); // 网关超时

  @override
  final int code;

  const HttpCode(this.code);
}
