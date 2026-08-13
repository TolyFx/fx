import 'package:fx_mod/fx_mod.dart';
import 'package:test/test.dart';

void main() {
  group('FxModRuntime 装配', () {
    test('按依赖拓扑顺序启动并逆序释放', () async {
      final List<String> calls = <String>[];
      final FxModRuntime runtime = FxModRuntime(<FxModule>[
        _TestModule('feature', calls, dependencies: <String>{'core'}),
        _TestModule('core', calls),
      ]);

      await runtime.start();
      await runtime.dispose();

      expect(calls, <String>[
        'prepare:core',
        'prepare:feature',
        'start:core',
        'start:feature',
        'dispose:feature',
        'dispose:core',
      ]);
      expect(runtime.phase, FxModPhase.disposed);
    });

    test('拒绝重复标识、缺失依赖和循环依赖', () {
      final List<String> calls = <String>[];
      expect(
        () => FxModRuntime(<FxModule>[
          _TestModule('same', calls),
          _TestModule('same', calls),
        ]),
        throwsA(_fxModCode(FxModErrorCode.duplicateId)),
      );
      expect(
        () => FxModRuntime(<FxModule>[
          _TestModule('feature', calls, dependencies: <String>{'missing'}),
        ]),
        throwsA(_fxModCode(FxModErrorCode.missingDependency)),
      );
      expect(
        () => FxModRuntime(<FxModule>[
          _TestModule('a', calls, dependencies: <String>{'b'}),
          _TestModule('b', calls, dependencies: <String>{'a'}),
        ]),
        throwsA(_fxModCode(FxModErrorCode.dependencyCycle)),
      );
    });

    test('启动失败时逆序回滚已经准备的模块', () async {
      final List<String> calls = <String>[];
      final FxModRuntime runtime = FxModRuntime(<FxModule>[
        _TestModule('core', calls),
        _TestModule('broken', calls, failOnStart: true),
      ]);

      await expectLater(
        runtime.start(),
        throwsA(_fxModCode(FxModErrorCode.startFailed)),
      );

      expect(calls, <String>[
        'prepare:core',
        'prepare:broken',
        'start:core',
        'start:broken',
        'dispose:broken',
        'dispose:core',
      ]);
      expect(runtime.phase, FxModPhase.failed);
    });
  });

  test('上下文、贡献和运行时事件保持类型化', () async {
    final List<String> calls = <String>[];
    final FxModContext context = FxModContext()..provide<String>('viewx');
    final FxModRuntime runtime = FxModRuntime(
      <FxModule>[
        _TestModule(
          'core',
          calls,
          contributions: const <FxModContribution>[_LabelContribution('a')],
        ),
      ],
      context: context,
    );

    await runtime.start();
    await runtime.dispatch(const _RefreshEvent());

    expect(context.read<String>(), 'viewx');
    expect(
      runtime
          .contributions<_LabelContribution>()
          .map((_LabelContribution item) => item.label),
      <String>['a'],
    );
    expect(calls, contains('event:core'));
  });
}

Matcher _fxModCode(FxModErrorCode code) {
  return isA<FxModException>().having(
    (FxModException error) => error.code,
    'code',
    code,
  );
}

class _TestModule extends FxModule {
  /// 测试模块标识。
  @override
  final String id;

  /// 记录生命周期调用的列表。
  final List<String> calls;

  /// 当前模块依赖的模块标识。
  @override
  final Set<String> dependencies;

  /// 当前模块提供的测试贡献。
  @override
  final Iterable<FxModContribution> contributions;

  /// 是否在启动阶段主动失败。
  final bool failOnStart;

  const _TestModule(
    this.id,
    this.calls, {
    this.dependencies = const <String>{},
    this.contributions = const <FxModContribution>[],
    this.failOnStart = false,
  });

  @override
  void onPrepare(FxModContext context) => calls.add('prepare:$id');

  @override
  void onStart(FxModContext context) {
    calls.add('start:$id');
    if (failOnStart) throw StateError('broken');
  }

  @override
  void onEvent(FxModContext context, FxModEvent event) {
    calls.add('event:$id');
  }

  @override
  void onDispose(FxModContext context) => calls.add('dispose:$id');
}

class _LabelContribution implements FxModContribution {
  /// 测试贡献携带的标签。
  final String label;

  const _LabelContribution(this.label);
}

class _RefreshEvent implements FxModEvent {
  const _RefreshEvent();
}
