import '../code.dart';
import '../trace.dart';

/// 模块异常的通用基类，统一承载错误码、说明、根因与堆栈。
abstract class FxException<C extends Code> with Trace implements Exception {
  /// 所属模块定义的错误码。
  @override
  final C code;

  /// 适合展示或记录的异常说明。
  @override
  final String? message;

  /// 被包装的原始异常。
  @override
  final Object? error;

  /// 原始异常发生时的调用堆栈。
  @override
  final StackTrace? stack;

  /// 创建统一结构的模块异常。
  const FxException(
    this.code,
    this.message, [
    this.error,
    this.stack,
  ]);
}
