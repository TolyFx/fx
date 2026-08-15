import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:fx_event/fx_event.dart';

import 'registry.dart';

/// Navigator 报告的稳定路由栈动作。
enum FxRouteAction { push, pop, replace, remove }

/// 模块路由观察流中的一条脱敏事件。
final class FxRouteEvent extends FxEvent {
  /// 当前观察器进程内单调递增的序号。
  final int sequence;

  /// 事件所属的 Navigator 范围标识。
  final String navigatorId;

  /// RouteSettings 携带的稳定路由名称。
  final String? routeName;

  /// 声明该命名路由的模块标识。
  final String? ownerModuleId;

  /// 本次路由栈动作。
  final FxRouteAction action;

  /// 事件发生时间。
  final DateTime occurredAt;

  const FxRouteEvent({
    required this.sequence,
    required this.navigatorId,
    required this.routeName,
    required this.ownerModuleId,
    required this.action,
    required this.occurredAt,
  }) : super();
}

/// 将多个 NavigatorObserver 汇总为统一模块路由事件流。
final class FxRouteObserverHub implements FxEventSource<FxRouteEvent> {
  /// 当前观察器独占并负责释放的同步事件域。
  final FxEmitter _emitter = FxEmitter.scoped(sync: true);

  /// 用于解析命名路由归属的只读注册表。
  final FxRouteRegistry? registry;

  /// 当前进程内最后分配的事件序号。
  int _sequence = 0;

  FxRouteObserverHub({this.registry});

  /// 脱敏路由事件广播流。
  @override
  Stream<FxRouteEvent> get events => _emitter.eventsOf<FxRouteEvent>();

  /// 为一个 Navigator 创建独立观察器。
  NavigatorObserver observer(String navigatorId) {
    return _FxNavigatorObserver(hub: this, navigatorId: navigatorId);
  }

  /// 释放事件广播流。
  Future<void> dispose() => _emitter.dispose();

  /// 接收 Navigator 动作并生成统一事件。
  void record(String navigatorId, Route<dynamic>? route, FxRouteAction action) {
    if (_emitter.isDisposed) return;
    final String? routeName = route?.settings.name;
    _emitter.emit(
      FxRouteEvent(
        sequence: ++_sequence,
        navigatorId: navigatorId,
        routeName: routeName,
        ownerModuleId: routeName == null ? null : registry?.ownerOf(routeName),
        action: action,
        occurredAt: DateTime.now(),
      ),
    );
  }
}

/// 单个 Navigator 使用的轻量观察器。
final class _FxNavigatorObserver extends NavigatorObserver {
  /// 接收当前 Navigator 事件的聚合器。
  final FxRouteObserverHub hub;

  /// 当前 Navigator 的稳定范围标识。
  final String navigatorId;

  _FxNavigatorObserver({required this.hub, required this.navigatorId});

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    hub.record(navigatorId, route, FxRouteAction.push);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    hub.record(navigatorId, route, FxRouteAction.pop);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    hub.record(navigatorId, newRoute, FxRouteAction.replace);
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    hub.record(navigatorId, route, FxRouteAction.remove);
  }
}
