import 'dart:convert';
import 'dart:io';

void main() async {
  final arbFiles = [
    'intl_zh.arb',
    'intl_en.arb', 
    'intl_es.arb',
    'intl_ja.arb',
    'intl_ko.arb',
    'intl_vi.arb',
    'intl_zh_HK.arb',
    'intl_zh_TW.arb',
  ];

  print('=== 批量 ARB 文件 Key 同步检查 ===\n');
  
  final allKeys = <String, Set<String>>{};
  final fileCounts = <String, int>{};
  
  // 读取所有文件的 keys
  for (final file in arbFiles) {
    try {
      final data = json.decode(await File(file).readAsString()) as Map<String, dynamic>;
      final keys = data.keys.where((k) => !k.startsWith('@@')).toSet();
      allKeys[file] = keys;
      fileCounts[file] = keys.length;
      print('${file.padRight(20)} ${keys.length} keys');
    } catch (e) {
      print('${file.padRight(20)} 读取失败: $e');
    }
  }
  
  print('\n=== Key 差异分析 ===');
  
  // 找出所有唯一的 keys
  final allUniqueKeys = <String>{};
  for (final keys in allKeys.values) {
    allUniqueKeys.addAll(keys);
  }
  
  print('总共唯一 keys: ${allUniqueKeys.length}');
  
  // 检查每个文件缺失的 keys
  for (final entry in allKeys.entries) {
    final file = entry.key;
    final keys = entry.value;
    final missing = allUniqueKeys.difference(keys);
    
    if (missing.isNotEmpty) {
      print('\n${file} 缺失 ${missing.length} 个 keys:');
      for (final key in missing.toList()..sort()) {
        print('  - $key');
      }
    }
  }
  
  // 检查每个文件独有的 keys
  print('\n=== 独有 Keys 分析 ===');
  for (final entry in allKeys.entries) {
    final file = entry.key;
    final keys = entry.value;
    final unique = <String>{};
    
    for (final key in keys) {
      bool isUnique = true;
      for (final otherEntry in allKeys.entries) {
        if (otherEntry.key != file && otherEntry.value.contains(key)) {
          isUnique = false;
          break;
        }
      }
      if (isUnique) unique.add(key);
    }
    
    if (unique.isNotEmpty) {
      print('\n${file} 独有 ${unique.length} 个 keys:');
      for (final key in unique.toList()..sort()) {
        print('  - $key');
      }
    }
  }
}