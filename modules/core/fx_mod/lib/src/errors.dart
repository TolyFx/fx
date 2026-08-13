import 'package:fx_exception/fx_exception.dart';

/// fx_mod 的稳定错误码。
enum FxModErrorCode with Code {
  /// 模块声明了空标识。
  emptyId(1),

  /// 多个模块声明了相同标识。
  duplicateId(2),

  /// 模块声明的依赖未包含在本次装配中。
  missingDependency(3),

  /// 模块依赖图中存在环路。
  dependencyCycle(4),

  /// 当前生命周期阶段不允许执行目标操作。
  invalidPhase(5),

  /// 模块准备或启动过程失败。
  startFailed(6),

  /// 一个或多个模块释放资源失败。
  disposeFailed(7),
  ;

  /// 错误码的持久化数值。
  @override
  final int code;

  const FxModErrorCode(this.code);
}

/// fx_mod 装配或生命周期执行失败。
final class FxModException extends FxException<FxModErrorCode> {
  const FxModException(
    super.code,
    super.message, [
    super.error,
    super.stack,
  ]);

  @override
  String toString() => 'FxModException: [${code.name}#${code.code}] $message';
}
