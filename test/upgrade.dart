import 'dart:io';
import 'dart:convert';
import 'package:path/path.dart' as p;

void main() async {
  final String versionJsonPath =
      'd:/Projects/Flutter/Fx/toly_ui/modules/publish/tolyui_0.0.4+7.json';
  final File versionFile = File(versionJsonPath);
  final String content = await versionFile.readAsString();
  final Map<String, dynamic> versionInfo = json.decode(content);

  // 构建版本映射表，方便查询
  Map<String, String> versionMap = {};
  buildVersionMap(versionInfo, versionMap);

  // 递归更新模块版本
  await updateModuleVersion(versionInfo, versionMap);
}

void buildVersionMap(
    Map<String, dynamic> moduleInfo, Map<String, String> versionMap) {
  String moduleName = moduleInfo['name'];
  String version = moduleInfo['version'];
  versionMap[moduleName] = version;

  if (moduleInfo.containsKey('children')) {
    List<dynamic> children = moduleInfo['children'];
    for (var child in children) {
      buildVersionMap(child, versionMap);
    }
  }
}

Future<void> updateModuleVersion(
    Map<String, dynamic> moduleInfo, Map<String, String> versionMap) async {
  String moduleName = moduleInfo['name'];
  String version = moduleInfo['version'];
  String changLog = moduleInfo['changLog'] ?? '';

  String modulePath = 'd:/Projects/Flutter/Fx/toly_ui/modules/$moduleName';

  // 更新 CHANGELOG.md
  if (changLog.isNotEmpty) {
    String changeMdPath = p.join(modulePath, 'CHANGELOG.md');
    String changeJsonPath = p.join(modulePath, 'doc', 'changelog.json');
    File changelogFile = File('$modulePath/CHANGELOG.md');
    if (!await changelogFile.exists()) {
      await changelogFile.create();
    }
    await addVersion(changeJsonPath, version, changLog);
    await jsonToMarkdown(changeJsonPath, changeMdPath);
    print('已更新 $moduleName 的 CHANGELOG.md');
  }

  File pubspecFile = File('$modulePath/pubspec.yaml');

  if (await pubspecFile.exists()) {
    String content = await pubspecFile.readAsString();
    bool hasChanges = false;

    // 更新模块自身版本
    RegExp versionRegex = RegExp(r'version:\s*([\d\.+]+)');
    String currentVersion = versionRegex.firstMatch(content)?.group(1) ?? '';

    if (currentVersion != version) {
      content = content.replaceFirst(versionRegex, 'version: $version');
      hasChanges = true;
      print('已更新 $moduleName 版本至 $version');
    }

    // 更新依赖版本
    RegExp depsRegex =
        RegExp(r'dependencies:[\s\S]*?dev_dependencies:', multiLine: true);
    Match? depsMatch = depsRegex.firstMatch(content);

    if (depsMatch != null) {
      RegExp tolyuiDepsRegex = RegExp(r'(tolyui_\w+):\s*\^?([\d\.+]+)');

      content = content.replaceAllMapped(tolyuiDepsRegex, (match) {
        String depName = match.group(1) ?? '';
        String newVersion = versionMap[depName] ?? match.group(2) ?? '';
        if (newVersion != match.group(2)) {
          hasChanges = true;
          print('在 $moduleName 中更新依赖 $depName 版本至 $newVersion');
        }
        return '$depName: ^$newVersion';
      });
    }

    if (hasChanges) {
      await pubspecFile.writeAsString(content);
    }
  }

  // 递归处理子模块
  if (moduleInfo.containsKey('children')) {
    List<dynamic> children = moduleInfo['children'];
    for (var child in children) {
      await updateModuleVersion(child, versionMap);
    }
  }
}

Future<void> addVersion(String path, String version, String change) async {
  final file = File(path);

  if (!await file.exists()) {
    // 文件不存在，创建新文件
    await file.create(recursive: true);
    final json = {
      "versions": {
        version: {
          "changes": [change],
          "timestamp": DateTime.now().toIso8601String()
        }
      }
    };
    await file.writeAsString(jsonEncode(json));
    return;
  }

  // 读取现有文件
  final content = await file.readAsString();
  final json = jsonDecode(content) as Map<String, dynamic>;
  final versions = json['versions'] as Map<String, dynamic>;

  // 检查是否为最新版本的小版本更新
  final latestVersion = versions.keys.first;
  if (version.startsWith(latestVersion.split('+')[0])) {
    // 添加到现有版本的 changes
    List<dynamic> changes = versions[latestVersion]['changes'];
    if (changes.isNotEmpty && changes.first.startsWith(version)) return;
    changes.insert(0, change);
  } else {
    // 添加新版本
    versions[version] = {
      "changes": [change],
      "timestamp": DateTime.now().toIso8601String()
    };
    // 重新排序版本
    final sortedVersions = Map.fromEntries(versions.entries.toList()
      ..sort((a, b) => compareVersions(b.key, a.key)));
    json['versions'] = sortedVersions;
  }

  // 写入文件
  await file.writeAsString(JsonEncoder.withIndent('  ').convert(json));
}

Future<void> jsonToMarkdown(String jsonPath, String mdPath) async {
  final file = File(jsonPath);
  if (!await file.exists()) return;

  final content = await file.readAsString();
  final json = jsonDecode(content) as Map<String, dynamic>;
  final versions = json['versions'] as Map<String, dynamic>;

  final StringBuffer buffer = StringBuffer();

  for (final entry in versions.entries) {
    final version = entry.key;
    final data = entry.value as Map<String, dynamic>;
    final changes = data['changes'] as List;

    buffer.writeln('## $version\n');
    for (final change in changes) {
      // 处理小版本号格式
      if (change.toString().startsWith('+')) {
        buffer.writeln('$version$change');
      } else {
        buffer.writeln('$change');
      }
    }
    buffer.writeln('\n');
  }

  await File(mdPath).writeAsString(buffer.toString());
}

int compareVersions(String v1, String v2) {
  final v1Parts = v1.split('+')[0].split('.');
  final v2Parts = v2.split('+')[0].split('.');

  for (var i = 0; i < 3; i++) {
    final num1 = int.parse(v1Parts[i]);
    final num2 = int.parse(v2Parts[i]);
    if (num1 != num2) return num1.compareTo(num2);
  }

  // 比较小版本号
  final v1Build = v1.contains('+') ? int.parse(v1.split('+')[1]) : 0;
  final v2Build = v2.contains('+') ? int.parse(v2.split('+')[1]) : 0;
  return v1Build.compareTo(v2Build);
}
