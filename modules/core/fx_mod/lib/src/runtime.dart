import 'context.dart';
import 'contribution.dart';
import 'errors.dart';
import 'module.dart';

/// 模块运行时所处的生命周期阶段。
enum FxModPhase {
  /// 运行时已创建，但尚未开始准备模块。
  created,

  /// 正在按依赖顺序准备模块。
  preparing,

  /// 所有模块均已完成准备。
  prepared,

  /// 正在按依赖顺序启动模块。
  starting,

  /// 所有模块已启动，可以接收运行时事件。
  running,

  /// 正在按启动的相反顺序释放模块。
  disposing,

  /// 所有已准备模块均已完成释放。
  disposed,

  /// 准备或启动失败，且已执行回滚释放。
  failed,
}

/// 以确定性顺序组装和驱动一组 [FxModule]。
class FxModRuntime {
  /// 模块间共享的类型化上下文。
  final FxModContext context;

  /// 按依赖拓扑排序后的模块列表。
  late final List<FxModule> _modules;

  /// 已完成准备、尚需在失败时释放的模块。
  final List<FxModule> _preparedModules = <FxModule>[];

  /// 当前生命周期阶段。
  FxModPhase _phase = FxModPhase.created;

  FxModRuntime(
    Iterable<FxModule> modules, {
    FxModContext? context,
  }) : context = context ?? FxModContext() {
    _modules = _sortAndValidate(modules);
  }

  /// 当前生命周期阶段。
  FxModPhase get phase => _phase;

  /// 依赖有序且不可修改的模块快照。
  List<FxModule> get modules => List<FxModule>.unmodifiable(_modules);

  /// 获取指定类型的第一个模块。
  T? find<T extends FxModule>() {
    for (final FxModule module in _modules) {
      if (module is T) return module;
    }
    return null;
  }

  /// 按模块依赖顺序聚合指定类型的贡献。
  Iterable<T> contributions<T extends FxModContribution>() sync* {
    for (final FxModule module in _modules) {
      for (final FxModContribution contribution in module.contributions) {
        if (contribution is T) yield contribution;
      }
    }
  }

  /// 依次准备并启动全部模块；任一阶段失败都会逆序释放已准备模块。
  Future<void> start() async {
    if (_phase != FxModPhase.created) {
      throw FxModException(
        FxModErrorCode.invalidPhase,
        '只有 created 状态可以启动，当前状态为 ${_phase.name}',
      );
    }

    try {
      _phase = FxModPhase.preparing;
      for (final FxModule module in _modules) {
        await module.onPrepare(context);
        _preparedModules.add(module);
      }
      _phase = FxModPhase.prepared;

      _phase = FxModPhase.starting;
      for (final FxModule module in _modules) {
        await module.onStart(context);
      }
      _phase = FxModPhase.running;
    } catch (error, stackTrace) {
      _phase = FxModPhase.failed;
      await _disposePreparedModules();
      throw FxModException(
        FxModErrorCode.startFailed,
        '模块运行时启动失败',
        error,
        stackTrace,
      );
    }
  }

  /// 按依赖顺序向所有运行中模块广播事件。
  Future<void> dispatch(FxModEvent event) async {
    if (_phase != FxModPhase.running) {
      throw FxModException(
        FxModErrorCode.invalidPhase,
        '只有 running 状态可以派发事件，当前状态为 ${_phase.name}',
      );
    }
    for (final FxModule module in _modules) {
      await module.onEvent(context, event);
    }
  }

  /// 按启动的相反顺序释放全部模块。
  Future<void> dispose() async {
    if (_phase == FxModPhase.disposed) return;
    if (_phase == FxModPhase.created) {
      _phase = FxModPhase.disposed;
      return;
    }
    if (_phase == FxModPhase.preparing ||
        _phase == FxModPhase.starting ||
        _phase == FxModPhase.disposing) {
      throw FxModException(
        FxModErrorCode.invalidPhase,
        '当前状态 ${_phase.name} 不允许释放',
      );
    }
    _phase = FxModPhase.disposing;
    final List<Object> errors = await _disposePreparedModules();
    _phase = FxModPhase.disposed;
    if (errors.isNotEmpty) {
      throw FxModException(
        FxModErrorCode.disposeFailed,
        '${errors.length} 个模块释放失败',
        errors.first,
      );
    }
  }

  /// 逆序释放已准备模块，并尽量完成全部清理。
  Future<List<Object>> _disposePreparedModules() async {
    final List<Object> errors = <Object>[];
    for (final FxModule module in _preparedModules.reversed) {
      try {
        await module.onDispose(context);
      } catch (error) {
        errors.add(error);
      }
    }
    _preparedModules.clear();
    return errors;
  }

  /// 校验模块身份和依赖，并生成稳定拓扑顺序。
  static List<FxModule> _sortAndValidate(Iterable<FxModule> source) {
    final List<FxModule> input = List<FxModule>.of(source);
    final Map<String, FxModule> byId = <String, FxModule>{};
    for (final FxModule module in input) {
      if (module.id.trim().isEmpty) {
        throw const FxModException(FxModErrorCode.emptyId, '模块标识不能为空');
      }
      if (byId.containsKey(module.id)) {
        throw FxModException(
          FxModErrorCode.duplicateId,
          '模块标识 ${module.id} 重复',
        );
      }
      byId[module.id] = module;
    }
    for (final FxModule module in input) {
      for (final String dependency in module.dependencies) {
        if (!byId.containsKey(dependency)) {
          throw FxModException(
            FxModErrorCode.missingDependency,
            '模块 ${module.id} 缺少依赖 $dependency',
          );
        }
      }
    }

    final List<FxModule> ordered = <FxModule>[];
    final Set<String> visiting = <String>{};
    final Set<String> visited = <String>{};

    void visit(FxModule module) {
      if (visited.contains(module.id)) return;
      if (!visiting.add(module.id)) {
        throw FxModException(
          FxModErrorCode.dependencyCycle,
          '模块 ${module.id} 存在循环依赖',
        );
      }
      for (final String dependency in module.dependencies) {
        visit(byId[dependency]!);
      }
      visiting.remove(module.id);
      visited.add(module.id);
      ordered.add(module);
    }

    for (final FxModule module in input) {
      visit(module);
    }
    return ordered;
  }
}
