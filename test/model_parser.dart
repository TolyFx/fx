import 'dart:convert';
import 'dart:io';
import 'package:yaml/yaml.dart';
import 'package:path/path.dart' as path;

class UpdateInfo {
  final String moduleName;
  final String newVersion;
  final String changLog;
  final List<String> childUpdates;

  UpdateInfo({
    required this.moduleName,
    required this.newVersion,
    required this.changLog,
    this.childUpdates = const [],
  });
}

class Module {
  final String name;
  final String description;
  String version;
  String changLog = '';
  final List<Module> children;

  Module({
    required this.name,
    required this.version,
    required this.description,
    this.children = const [],
    this.changLog ='',
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'version': version,
        'description': description,
        'changLog': changLog,
        if (children.isNotEmpty)
          'children': children.map((e) => e.toJson()).toList(),
      };

  String displayTree({String prefix = '', bool isLast = true}) {
    final buffer = StringBuffer();
    final marker = isLast ? '└──' : '├──';
    buffer.writeln('$prefix$marker $name ($version)');

    if (children.isNotEmpty) {
      final childPrefix = prefix + (isLast ? '    ' : '│   ');
      for (var i = 0; i < children.length; i++) {
        buffer.write(children[i].displayTree(
          prefix: childPrefix,
          isLast: i == children.length - 1,
        ));
      }
    }

    return buffer.toString();
  }


  bool updateVersion(List<UpdateInfo> updates) {
    bool hasUpdates = false;
    StringBuffer childrenChanges = StringBuffer();

    // 检查当前模块是否在更新列表中
    final updateInfo = updates.where((u) => u.moduleName == name).firstOrNull;
    if (updateInfo != null) {
      version = updateInfo.newVersion;
      changLog = updateInfo.changLog;
      hasUpdates = true;
    }

    // 检查子模块更新
    for (var child in children) {
      if (child.updateVersion(updates)) {
        if (!hasUpdates) {
          _incrementVersion();
        }
        childrenChanges.writeln('* $version: ${child.name} -> ${child.version}');
        hasUpdates = true;
      }
    }

    // 如果有子模块更新，将子模块信息添加到父模块的更新记录中
    if (childrenChanges.isNotEmpty) {
      if (changLog.isEmpty) {
        changLog = childrenChanges.toString();
      } else {
        changLog += '\n$childrenChanges';
      }
    }

    return hasUpdates;
  }

  void _incrementVersion() {
    final parts = version.split('+');
    if (parts.length > 1) {
      // 处理带有 build number 的版本号
      final buildNumber = int.parse(parts[1]);
      version = '${parts[0]}+${buildNumber + 1}';
    } else {
      // 处理普通版本号
      version += "+1";
    }
  }
}

Future<void> main() async {
  String modulesPath = 'd:\\Projects\\Flutter\\Fx\\toly_ui\\modules';
  String root = path.join(modulesPath, 'tolyui');
  Module? moduleJson = await processModule(Directory(root));
  if (moduleJson == null) return;
  print(moduleJson.displayTree());
  File outputFile = File(path.join(modulesPath, 'publish','tolyui_${moduleJson.version}.json'));
  String data1 = const JsonEncoder.withIndent('  ').convert(moduleJson.toJson());

  await outputFile.writeAsString(data1);

  //'tolyui_message', '0.2.5'
  moduleJson.updateVersion([
    UpdateInfo(
      moduleName: 'tolyui_message',
      newVersion: '0.2.5',
      changLog: '修复一些 bug',
    ),
    UpdateInfo(
      moduleName: 'tolyui_color',
      newVersion: '0.0.2',
      changLog: '优化颜色选择器',
    ),
  ]);

  String data = const JsonEncoder.withIndent('  ').convert(moduleJson.toJson());
  print(data);
  print(moduleJson.displayTree());
   outputFile = File(path.join(modulesPath, 'publish','tolyui_${moduleJson.version}.json'));

  await outputFile.writeAsString(data);
}

Future<Module?> processModule(Directory dir) async {
  if (!await dir.exists()) return null;

  // 2. 读取并解析 pubspec.yaml
  final pubspecFile = File(path.join(dir.path, 'pubspec.yaml'));
  if (!await pubspecFile.exists()) return null;
  final yaml = loadYaml(await pubspecFile.readAsString());
  // 3. 创建当前模块
  final module = Module(
      name: yaml['name'],
      version: yaml['version'],
      description: yaml['description'],
      children: []);

  // 扫描依赖
  YamlMap dependencies = yaml['dependencies'];

  // 5. 递归处理子模块
  for (final dep in dependencies.keys) {
    if (dep.startsWith('tolyui_')) {
      Directory subModelDir = Directory(path.join(dir.path, '..', dep));
      final childModule = await processModule(subModelDir);
      if (childModule != null) {
        module.children.add(childModule);
      }
    }
  }
  return module;
}
