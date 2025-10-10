import 'dart:io';
import 'dart:typed_data';
import 'package:args/args.dart';
import 'package:path/path.dart' as path;
import 'package:archive/archive.dart';
import 'dart:isolate';

const String version = '0.0.1';

String? _cachedTemplateDir;

ArgParser buildParser() {
  return ArgParser()
    ..addFlag('help', abbr: 'h', negatable: false, help: 'Print usage information.')
    ..addFlag('version', negatable: false, help: 'Print version.')
    ..addCommand('create')
      ..commands['create']!.addFlag('module', abbr: 'm', negatable: false, help: 'Create as module.');
}

void printUsage() {
  print('Usage: fx_cli <command> [arguments]');
  print('\nCommands:');
  print('  create <name> -m    Create a Flutter module with example');
  print('\nOptions:');
  print('  -h, --help         Show help');
  print('  --version          Show version');
}

Future<void> createModule(String name) async {
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

    print('📋 步骤 3/5: 创建示例应用...');
    final exampleResult = await Process.run(flutterCmd, ['create', 'example','--offline'], workingDirectory: name);
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
    await applyTemplates(name);
    print('✅ 自定义模板应用完成');

    print('🎉 模块 $name 创建成功!');
    print('📁 示例应用位置: $name/example/');
    print('💡 提示: 进入 $name/example/ 目录运行 flutter run 来测试模块');
  } catch (e) {
    print('❌ 错误: 未找到 Flutter 命令。请确保 Flutter 已安装并添加到 PATH 环境变量中。');
    print('详细信息: $e');
  }
}

Future<void> applyTemplates(String moduleName) async {
  print('  🔍 查找模板文件...');
  final templateDir = await extractTemplates();
  final variables = {
    '{{MODULE_NAME}}': moduleName,
    '{{MODULE_NAME_CAPITALIZED}}': moduleName[0].toUpperCase() + moduleName.substring(1),
  };

  print('  📝 应用模板变量替换...');
  await copyAndReplaceTemplates(templateDir, moduleName, variables);
}

Future<String> extractTemplates() async {
  if (_cachedTemplateDir != null && await Directory(_cachedTemplateDir!).exists()) {
    print('  ♻️  使用已缓存的模板文件');
    return _cachedTemplateDir!;
  }

  final tempDir = Directory.systemTemp.createTempSync('fx_cli_templates');
  final templateZip = await getTemplateZip();

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

Future<Uint8List?> getTemplateZip() async {
  try {
    final packageUri = await Isolate.resolvePackageUri(Uri.parse('package:fx_cli/template.zip'));
    if (packageUri != null) {
      final file = File.fromUri(packageUri);
      if (await file.exists()) {
        return await file.readAsBytes();
      }
    }
  } catch (e) {
    // Fallback to local file
  }

  final zipFile = File('template.zip');
  if (await zipFile.exists()) {
    return await zipFile.readAsBytes();
  }

  final sourceDir = Directory('template_source');
  if (await sourceDir.exists()) {
    return await createZipFromDirectory(sourceDir);
  }

  return null;
}

Future<Uint8List> createZipFromDirectory(Directory dir) async {
  final archive = Archive();
  await addDirectoryToArchive(archive, dir, '');
  return Uint8List.fromList(ZipEncoder().encode(archive)!);
}

Future<void> addDirectoryToArchive(Archive archive, Directory dir, String prefix) async {
  await for (final entity in dir.list()) {
    final name = path.basename(entity.path);
    final fullPath = prefix.isEmpty ? name : '$prefix/$name';

    if (entity is File) {
      final bytes = await entity.readAsBytes();
      archive.addFile(ArchiveFile(fullPath, bytes.length, bytes));
    } else if (entity is Directory) {
      await addDirectoryToArchive(archive, entity, fullPath);
    }
  }
}

Future<void> copyAndReplaceTemplates(String templateDir, String moduleName, Map<String, String> variables) async {
  final sourceDir = Directory(templateDir);
  if (!await sourceDir.exists()) {
    print('  ⚠️  模板目录不存在，跳过模板应用');
    return;
  }

  int fileCount = 0;
  await for (final entity in sourceDir.list(recursive: true)) {
    if (entity is File) {
      final relativePath = path.relative(entity.path, from: templateDir);
      final targetPath = replaceVariables(relativePath, variables);
      final targetFile = File(path.join(moduleName, targetPath));

      await targetFile.create(recursive: true);

      final content = await entity.readAsString();
      final replacedContent = replaceVariables(content, variables);
      await targetFile.writeAsString(replacedContent);
      fileCount++;
    }
  }

  if (fileCount > 0) {
    print('  ✅ 已处理 $fileCount 个模板文件');
  }
}

String replaceVariables(String text, Map<String, String> variables) {
  String result = text;
  variables.forEach((key, value) {
    result = result.replaceAll(key, value);
  });
  return result;
}

Future<void> replaceFromTemplate(String templatePath, String targetPath, Map<String, String> replacements) async {
  final templateFile = File(templatePath);
  if (!await templateFile.exists()) return;

  String content = await templateFile.readAsString();
  replacements.forEach((key, value) {
    content = content.replaceAll(key, value);
  });

  await File(targetPath).writeAsString(content);
}



void main(List<String> arguments) async {
  final parser = buildParser();

  try {
    final results = parser.parse(arguments);

    if (results.flag('help')) {
      printUsage();
      return;
    }

    if (results.flag('version')) {
      print('fx_cli version: $version');
      return;
    }

    if (results.command?.name == 'create') {
      final createResults = results.command!;
      if (createResults.rest.isEmpty) {
        print('Error: Module name required');
        printUsage();
        return;
      }

      final moduleName = createResults.rest.first;
      if (createResults.flag('module')) {
        await createModule(moduleName);
      } else {
        print('Error: Use -m flag to create module');
        printUsage();
      }
    } else {
      printUsage();
    }
  } on FormatException catch (e) {
    print('Error: $e');
    printUsage();
  } catch (e) {
    print('Error: $e');
    printUsage();
  }
}
