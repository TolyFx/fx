import 'dart:io';
import 'package:path/path.dart' as path;
import 'api_generator_config.dart';

class TestGenerator {
  final ApiGeneratorConfig config;
  
  const TestGenerator(this.config);
  
  Future<void> generate() async {
    print('Generating Test class...');
    print('Test file: ${config.testFilePath}');
    print('');
    
    _generateTestFile();
    
    print('Test class generated successfully!');
  }
  
  void _generateTestFile() {
    final buffer = StringBuffer();
    
    // 添加导入
    buffer.writeln("import 'package:flutter_test/flutter_test.dart';");
    buffer.writeln("import 'package:${config.moduleName.toLowerCase()}_module/src/repository/api/${config.moduleName.toLowerCase()}_request.dart';");
    buffer.writeln();
    
    // 生成测试类
    buffer.writeln('void main() {');
    buffer.writeln('  group(\'${config.requestClassName} Tests\', () {');
    buffer.writeln('    late ${config.requestClassName} request;');
    buffer.writeln();
    buffer.writeln('    setUp(() {');
    buffer.writeln('      request = ${config.requestClassName}();');
    buffer.writeln('    });');
    buffer.writeln();
    buffer.writeln('    // TODO: Add specific test cases for each API method');
    buffer.writeln('    test(\'should initialize request class\', () {');
    buffer.writeln('      expect(request, isNotNull);');
    buffer.writeln('    });');
    buffer.writeln('  });');
    buffer.writeln('}');
    
    // 写入文件
    final file = File(config.testFilePath);
    file.parent.createSync(recursive: true);
    file.writeAsStringSync(buffer.toString());
    print('Generated: ${config.testFilePath}');
  }
}

void main([List<String>? args]) {
  args ??= [];
  
  try {
    String testFilePath = 'test/request/apply_request_test.dart';
    
    if (args.isNotEmpty) {
      testFilePath = args[0];
    }
    
    final config = ApiGeneratorConfig(
      moduleName: 'Apply',
      yamlPath: path.join('doc', 'dev', 'request', 'apis.yaml'),
      outputDir: 'lib/src/repository/api',
    );
    
    final generator = TestGenerator(config);
    generator.generate();
    
  } catch (e) {
    print('Error: $e');
  }
}