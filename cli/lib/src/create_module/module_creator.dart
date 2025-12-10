import 'dart:io';
import 'dart:typed_data';
import 'package:path/path.dart' as path;
import 'package:archive/archive.dart';
import 'package:fx_cli/src/template/template_reader.dart';

class ModuleCreator {
  static String? _cachedTemplateDir;

  static Future<void> createModule(String name, {String platforms = 'android,ios'}) async {
    print('🚀 开始创建 Flutter 模块: $name');
    print('📋 步骤 1/5: 检查 Flutter 环境...');

    final flutterCmd = Platform.isWindows ? 'flutter.bat' : 'flutter';

    try {
      print('📋 步骤 2/5: 创建 Flutter 包模块...');
      final moduleResult = await Process.run(flutterCmd, ['create', '--template=package', name,'--offline']);
      if (moduleResult.stdout.isNotEmpty) {
        print(moduleResult.stdout);
      }
      if ( moduleResult.exitCode != 0) {
        print('❌ 创建模块失败: ${moduleResult.stderr}');
        return;
      }
      print('✅ Flutter 包模块创建完成');

      print('📋 步骤 3/5: 创建示例应用 (平台: $platforms)...');
      final platformArgs = platforms.split(',').expand((p) => ['--platforms', p.trim()]).toList();
      final exampleResult = await Process.run(flutterCmd, ['create', 'example', '--offline', ...platformArgs], workingDirectory: name);
      if (exampleResult.stdout.isNotEmpty) {
        print(exampleResult.stdout);
      }
      if (exampleResult.exitCode != 0) {
        print('❌ 创建示例应用失败: ${exampleResult.stderr}');
        return;
      }
      print('✅ 示例应用创建完成');

      print('📋 步骤 4/5: 配置示例应用依赖...');
      final examplePubspec = File('$name/example/pubspec.yaml');
      final content = await examplePubspec.readAsString();
      final lineEnding = content.contains('\r\n') ? '\r\n' : '\n';
      final updatedContent = content.replaceFirst(
        'dependencies:${lineEnding}  flutter:${lineEnding}    sdk: flutter',
        'dependencies:${lineEnding}  flutter:${lineEnding}    sdk: flutter${lineEnding}  $name:${lineEnding}    path: ../',
      );
      await examplePubspec.writeAsString(updatedContent);
      print('✅ 示例应用依赖配置完成');

      print('📋 步骤 5/5: 应用自定义模板...');
      await _applyTemplates(name);
      print('✅ 自定义模板应用完成');

      print('🎉 模块 $name 创建成功!');
      print('📁 示例应用位置: $name/example/');
      print('💡 提示: 进入 $name/example/ 目录运行 flutter run 来测试模块');
    } catch (e) {
      print('❌ 错误: 未找到 Flutter 命令。请确保 Flutter 已安装并添加到 PATH 环境变量中。');
      print('详细信息: $e');
    }
  }

  static Future<void> _applyTemplates(String moduleName) async {
    print('  🔍 查找模板文件...');
    final templateDir = await _extractTemplates();
    final variables = {
      '{{MODULE_NAME}}': moduleName,
      '{{MODULE_NAME_CAPITALIZED}}': moduleName[0].toUpperCase() + moduleName.substring(1),
      '{{name}}': moduleName,
    };

    print('  📝 应用模板变量替换...');
    await _copyAndReplaceTemplates(templateDir, moduleName, variables);
  }

  static Future<String> _extractTemplates() async {
    if (_cachedTemplateDir != null && await Directory(_cachedTemplateDir!).exists()) {
      print('  ♻️  使用已缓存的模板文件');
      return _cachedTemplateDir!;
    }

    final tempDir = Directory.systemTemp.createTempSync('fx_cli_templates');
    final templateZip = await _getTemplateZip();

    if (templateZip != null) {
      print('  📦 解压模板文件...');
      final archive = ZipDecoder().decodeBytes(templateZip);
      for (final file in archive) {
        final filename = file.name;
        if (file.isFile) {
          final data = file.content as List<int>;
          final targetFile = File(path.join(tempDir.path, filename));
          await targetFile.create(recursive: true);
          await targetFile.writeAsBytes(data);
        }
      }
      print('  ✅ 模板文件解压完成');
      _cachedTemplateDir = tempDir.path;
    } else {
      print('  ⚠️  未找到模板文件，使用默认配置');
    }

    return tempDir.path;
  }

  static Future<Uint8List?> _getTemplateZip() async {
    try {
      return TemplateReader.getTemplateZip();
    } catch (e) {
      return null;
    }
  }

  static Future<void> _copyAndReplaceTemplates(String templateDir, String moduleName, Map<String, String> variables) async {
    final sourceDir = Directory(templateDir);
    if (!await sourceDir.exists()) {
      print('  ⚠️  模板目录不存在，跳过模板应用');
      return;
    }

    int fileCount = 0;
    await for (final entity in sourceDir.list(recursive: true)) {
      if (entity is File) {
        final relativePath = path.relative(entity.path, from: templateDir);
        final targetPath = _replaceVariables(relativePath, variables);
        final targetFile = File(path.join(moduleName, targetPath));

        await targetFile.create(recursive: true);

        final content = await entity.readAsString();
        final replacedContent = _replaceVariables(content, variables);
        await targetFile.writeAsString(replacedContent);
        fileCount++;
      }
    }

    if (fileCount > 0) {
      print('  ✅ 已处理 $fileCount 个模板文件');
    }
  }

  static String _replaceVariables(String text, Map<String, String> variables) {
    String result = text;
    variables.forEach((key, value) {
      result = result.replaceAll(key, value);
    });
    return result;
  }

  static Future<void> validateTemplate() async {
    final templateZip = await _getTemplateZip();
    if (templateZip != null) {
      final size = templateZip.length;
      print('✅ 模板文件存在 (大小: ${(size / 1024).toStringAsFixed(1)} KB)');
    } else {
      print('❌ 未找到模板文件');
      exit(1);
    }
  }
}