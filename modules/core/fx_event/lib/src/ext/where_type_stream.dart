import 'dart:async';

/// Stream 类型过滤扩展。
///
/// 功能等价于 `stream_transform` 包的 `whereType<S>()`，
/// 但零依赖、单层 controller、延迟订阅。
///
/// 仅在有人 listen 返回的 stream 时才订阅源 stream，
/// 取消时自动取消源订阅。
///
/// ```dart
/// final Stream<LoginEvent> logins = eventStream.whereType<LoginEvent>();
/// ```
extension WhereTypeStream<T> on Stream<T> {
  /// 过滤出类型为 [S] 的事件，返回 `Stream<S>`。
  Stream<S> whereType<S>() {
    final StreamController<S> controller = isBroadcast
        ? StreamController<S>.broadcast(sync: true)
        : StreamController<S>(sync: true);
    StreamSubscription<T>? sub;
    controller.onListen = () {
      sub = listen(
        (T event) {
          if (event is S) controller.add(event);
        },
        onError: controller.addError,
        onDone: controller.close,
      );
      if (!isBroadcast) {
        controller
          ..onPause = sub!.pause
          ..onResume = sub!.resume;
      }
    };
    controller.onCancel = () => sub?.cancel();
    return controller.stream;
  }
}
