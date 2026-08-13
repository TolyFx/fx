/// 模块向宿主声明的能力贡献。
///
/// fx_mod 不解释贡献内容。路由、本地化、Provider 等上层框架可以定义自己的
/// 贡献子类型，再通过 [FxModRuntime.contributions] 聚合。
abstract interface class FxModContribution {
  const FxModContribution();
}
