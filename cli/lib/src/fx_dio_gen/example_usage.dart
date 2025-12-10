import 'api_gen_all.dart';
import 'api_generator_config.dart';

/// 使用示例：生成不同模块的 API 代码
void main() async {
  // 示例1: 生成 Apply 模块
  await generateApplyModule();
  
  // 示例2: 生成 User 模块  
  await generateUserModule();
  
  // 示例3: 生成 Order 模块
  await generateOrderModule();
}

/// 生成 Apply 模块的 API 代码
Future<void> generateApplyModule() async {
  final config = ApiGeneratorConfig(
    moduleName: 'Apply',
    yamlPath: 'doc/dev/request/apply_apis.yaml',
    outputDir: 'lib/src/repository/api',
  );
  
  final generator = ApiGenerator(config);
  await generator.generateAll();
}

/// 生成 User 模块的 API 代码
Future<void> generateUserModule() async {
  final config = ApiGeneratorConfig(
    moduleName: 'User',
    yamlPath: 'doc/dev/request/user_apis.yaml',
    outputDir: 'lib/src/repository/api',
    enumClassName: 'UserApi',
    requestClassName: 'UserRequest',
  );
  
  final generator = ApiGenerator(config);
  await generator.generateAll();
}

/// 生成 Order 模块的 API 代码
Future<void> generateOrderModule() async {
  final config = ApiGeneratorConfig(
    moduleName: 'Order',
    yamlPath: 'doc/dev/request/order_apis.yaml',
    outputDir: 'lib/src/repository/api',
  );
  
  final generator = ApiGenerator(config);
  await generator.generateAll();
}