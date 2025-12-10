class ApiGeneratorConfig {
  final String moduleName;
  final String yamlPath;
  final String outputDir;
  final String enumClassName;
  final String requestClassName;
  final String testClassName;
  
  const ApiGeneratorConfig({
    required this.moduleName,
    required this.yamlPath,
    required this.outputDir,
    String? enumClassName,
    String? requestClassName,
    String? testClassName,
  }) : 
    enumClassName = enumClassName ?? '${moduleName}Api',
    requestClassName = requestClassName ?? '${moduleName}Request',
    testClassName = testClassName ?? '${moduleName}RequestTest';
  
  String get enumFilePath => '$outputDir/${_lowerModuleName}_url.dart';
  String get requestFilePath => '$outputDir/${_lowerModuleName}_request.dart';
  String get testFilePath => 'test/request/${_lowerModuleName}_request_test.dart';
  String get docsDir => 'doc/dev/request/api/$_lowerModuleName';
  
  String get _lowerModuleName => moduleName.toLowerCase();
}