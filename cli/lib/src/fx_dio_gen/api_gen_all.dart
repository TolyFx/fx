import '01_generate_request_files.dart';
import '02_generate_url_enum.dart';
import '03_generate_request.dart';
import '04_generate_test.dart';
import 'api_generator_config.dart';

class ApiGenerator {
  final ApiGeneratorConfig config;
  
  const ApiGenerator(this.config);
  
  Future<void> generateAll() async {
    print('='.padRight(60, '='));
    print('API Generation Pipeline - ${config.moduleName}');
    print('='.padRight(60, '='));
    print('');
    
    try {
      await _step1GenerateRequestFiles();
      await _step2GenerateUrlEnum();
      await _step3GenerateRequestClass();
      await _step4GenerateTestCases();
      
      _printSuccess();
    } catch (e) {
      print('✗ Pipeline failed: $e');
      rethrow;
    }
  }
  
  Future<void> _step1GenerateRequestFiles() async {
    print('Step 1: Generate Request Files');
    print('从 ${config.yamlPath} 解析并生成 markdown 文件');
    print('-'.padRight(60, '-'));
    
    final generator = RequestFileGenerator(config);
    await generator.generate();
    
    print('✓ Step 1 completed successfully\n');
  }
  
  Future<void> _step2GenerateUrlEnum() async {
    print('Step 2: Generate URL Enum');
    print('生成 ${config.enumClassName} 枚举');
    print('-'.padRight(60, '-'));
    
    final generator = UrlEnumGenerator(config);
    await generator.generate();
    
    print('✓ Step 2 completed successfully\n');
  }
  
  Future<void> _step3GenerateRequestClass() async {
    print('Step 3: Generate Request Class');
    print('生成 ${config.requestClassName} 类');
    print('-'.padRight(60, '-'));
    
    final generator = RequestClassGenerator(config);
    await generator.generate();
    
    print('✓ Step 3 completed successfully\n');
  }
  
  Future<void> _step4GenerateTestCases() async {
    print('Step 4: Generate Test Cases');
    print('生成测试用例文件');
    print('-'.padRight(60, '-'));
    
    final generator = TestGenerator(config);
    await generator.generate();
    
    print('✓ Step 4 completed successfully\n');
  }
  
  void _printSuccess() {
    print('='.padRight(60, '='));
    print('All steps completed successfully!');
    print('='.padRight(60, '='));
    print('');
    print('Generated files:');
    print('  - ${config.docsDir}/**/*.md');
    print('  - ${config.enumFilePath}');
    print('  - ${config.requestFilePath}');
    print('  - ${config.testFilePath}');
    print('');
    print('Next steps:');
    print('  1. Review generated files');
    print('  2. Run tests: flutter test ${config.testFilePath}');
    print('  3. Check API documentation in ${config.docsDir}/');
  }
}

// 示例用法
void main() async {
  final config = ApiGeneratorConfig(
    moduleName: 'Apply',
    yamlPath: 'doc/dev/request/apis.yaml',
    outputDir: 'lib/src/repository/api',
  );
  
  final generator = ApiGenerator(config);
  await generator.generateAll();
}