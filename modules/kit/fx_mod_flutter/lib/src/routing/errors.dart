import 'package:fx_exception/fx_exception.dart';

/// Flutter 模块路由装配错误码。
enum FxModFlutterErrorCode with Code {
  /// 多个模块声明了初始地址。
  duplicateInitialLocation(1),

  /// 多个顶层路由声明了相同路径。
  duplicateRoutePath(2),

  /// 多个路由声明了相同名称。
  duplicateRouteName(3),

  /// 顶层模块路由没有使用绝对路径。
  invalidTopRoutePath(4),

  /// 模块把路由贡献到了宿主未注册的挂载位置。
  unknownRouteMount(5),

  /// 多个模块路由声明了相同的完整路径。
  duplicateContributionPath(6),

  /// 多个模块贡献声明了相同的路由名称。
  duplicateContributionName(7),

  /// 模块路由贡献缺少有效挂载点或路由。
  invalidRouteContribution(8),

  /// 宿主要求的顶层命名路由未出现在指定挂载点。
  missingMountedRoute(9);

  /// 错误码的持久化数值。
  @override
  final int code;

  const FxModFlutterErrorCode(this.code);
}

/// Flutter 模块能力装配失败。
final class FxModFlutterException extends FxException<FxModFlutterErrorCode> {
  const FxModFlutterException(
    super.code,
    super.message, [
    super.error,
    super.stack,
  ]);

  @override
  String toString() =>
      'FxModFlutterException: [${code.name}#${code.code}] $message';
}
