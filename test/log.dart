import 'dart:io';
import 'dart:convert';

void main() async {
  // String model = 'tolyui_feedback';
  // final File changelogFile = File('d:/Projects/Flutter/Fx/toly_ui/modules/$model/CHANGELOG.md');
  // final String content = await changelogFile.readAsString();
  //
  // Map<String, dynamic> result = parseChangelog(content);
  //
  // final File outputFile = File('d:/Projects/Flutter/Fx/toly_ui/modules/$model/doc/changelog.json');
  // if(!outputFile.existsSync()){
  //   outputFile.createSync(recursive: true);
  // }
  // await outputFile.writeAsString(JsonEncoder.withIndent('  ').convert(result));
  const path = 'D:/Projects/Flutter/Fx/toly_ui/modules/tolyui_feedback/doc/changelog.json';

  // 添加小版本更新
  // await addVersion('0.3.6+3', '0.3.6+3: Fix some bugs');
  // 添加新版本
  // await addVersion(path,'0.3.7', 'Add new feature');

  const jsonPath = 'd:/Projects/Flutter/Fx/toly_ui/modules/tolyui_feedback/doc/changelog.json';
  const mdPath = 'd:/Projects/Flutter/Fx/toly_ui/modules/tolyui_feedback/CHANGELOG.md';
  await jsonToMarkdown(jsonPath,mdPath);
}


Future<void> jsonToMarkdown(String jsonPath,String mdPath) async {

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
        buffer.writeln('* $version$change');
      } else {
        buffer.writeln('* $change');
      }
    }
    buffer.writeln('\n');
  }

  await File(mdPath).writeAsString(buffer.toString());
}

Map<String, dynamic> parseChangelog(String content) {
  Map<String, List<String>> versions = {};
  String currentVersion = '';

  final lines = content.split('\n');

  for (String line in lines) {
    line = line.trim();
    if (line.isEmpty) continue;

    if (line.startsWith('## ')) {
      currentVersion = line.substring(3).trim();
      versions[currentVersion] = [];
    } else if (line.startsWith('*') && currentVersion.isNotEmpty) {
      versions[currentVersion]?.add(line.substring(1).trim());
    }
  }

  return {
    'versions': versions.map((version, changes) {
      return MapEntry(version, {
        'changes': changes,
        'timestamp': DateTime.now().toIso8601String(),
      });
    }),
  };
}


Future<void> addVersion(String path ,String version, String change) async {
  final file = File(path);

  if (!await file.exists()) {
    // 文件不存在，创建新文件
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
    if(changes.isNotEmpty && changes.first.startsWith(version)) return;
    changes.insert(0, change);
  } else {
    // 添加新版本
    versions[version] = {
      "changes": [change],
      "timestamp": DateTime.now().toIso8601String()
    };
    // 重新排序版本
    final sortedVersions = Map.fromEntries(
        versions.entries.toList()
          ..sort((a, b) => compareVersions(b.key, a.key))
    );
    json['versions'] = sortedVersions;
  }

  // 写入文件
  await file.writeAsString(JsonEncoder.withIndent('  ').convert(json));
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