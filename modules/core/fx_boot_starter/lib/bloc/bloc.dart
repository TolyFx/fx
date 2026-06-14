import 'dart:async';

import '../data/action/app_start_action.dart';
import '../data/repository.dart';
import 'state.dart';

/// 应用启动状态管理器。
///
/// 基于 [StreamController] 实现状态分发，零第三方依赖。
/// 通过 [stream] 监听状态变化，通过 [state] 获取当前状态。
///
/// 启动流程：
/// ```
/// AppStarting → AppLoadDone → AppStartSuccess
///                    ↓
///              AppStartFailed
/// ```
class AppStartBloc<S> {
  final int minStartDurationMs;
  final AppStartRepository<S> repository;
  final AppStartAction<S> startAction;

  AppStartBloc({
    required this.repository,
    required this.startAction,
    this.minStartDurationMs = 600,
  });

  final StreamController<AppStatus> _controller = StreamController<AppStatus>.broadcast();

  AppStatus _state = const AppStarting();

  Stream<AppStatus> get stream => _controller.stream;

  AppStatus get state => _state;

  void _emit(AppStatus status) {
    _state = status;
    _controller.add(status);
  }

  int _timeRecord = 0;

  void startApp() async {
    _timeRecord = DateTime.now().millisecondsSinceEpoch;
    _emit(const AppStarting());
    S data;
    try {
      data = await repository.initApp();
    } catch (e, s) {
      _emit(AppStartFailed(e, s));
      return;
    }

    int cost = DateTime.now().millisecondsSinceEpoch - _timeRecord;
    int waitTime = minStartDurationMs - cost;
    if (waitTime > 0) {
      _emit(AppLoadDone(cost, data));
      await Future<void>.delayed(Duration(milliseconds: waitTime));
    } else {
      _emit(AppLoadDone(cost, data));
      await Future<void>.delayed(const Duration(milliseconds: 50));
    }
    _emit(AppStartSuccess(data));
  }

  void dispose() {
    _controller.close();
  }
}
