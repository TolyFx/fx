import 'api_gen_all.dart';
import 'api_generator_config.dart';

/// 批量 API 生成器
class BatchApiGenerator {
  final List<ApiGeneratorConfig> configs;
  
  const BatchApiGenerator(this.configs);
  
  /// 批量生成所有模块的 API 代码
  Future<void> generateAll() async {
    print('Starting batch generation for ${configs.length} modules...\n');
    
    for (int i = 0; i < configs.length; i++) {
      final config = configs[i];
      print('[${ i + 1}/${configs.length}] Processing ${config.moduleName} module...');
      
      try {
        final generator = ApiGenerator(config);
        await generator.generateAll();
        print('✓ ${config.moduleName} module completed\n');
      } catch (e) {
        print('✗ ${config.moduleName} module failed: $e\n');
        rethrow;
      }
    }
    
    print('🎉 All modules generated successfully!');
  }
}

/// 使用示例
void main() async {
  final configs = [
    ApiGeneratorConfig(
      moduleName: 'Apply',
      yamlPath: 'doc/dev/request/apply_apis.yaml',
      outputDir: 'lib/src/repository/api',
    ),
    ApiGeneratorConfig(
      moduleName: 'User',
      yamlPath: 'doc/dev/request/user_apis.yaml',
      outputDir: 'lib/src/repository/api',
    ),
    ApiGeneratorConfig(
      moduleName: 'Order',
      yamlPath: 'doc/dev/request/order_apis.yaml',
      outputDir: 'lib/src/repository/api',
    ),
  ];
  
  final batchGenerator = BatchApiGenerator(configs);
  await batchGenerator.generateAll();
}