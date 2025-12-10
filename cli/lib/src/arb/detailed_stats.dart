import 'dart:convert';
import 'dart:io';

void main() async {
  const arbFile = 'intl_zh.arb';
  
  try {
    final file = File(arbFile);
    final content = await file.readAsString();
    final Map<String, dynamic> data = json.decode(content);
    
    // 基本统计
    print('=== 详细 ARB 文件统计 ===');
    print('文件: $arbFile');
    print('总条目数: ${data.length}');
    print('文件大小: ${await file.length()} 字节');
    print('');
    
    // 分析条目长度
    final lengths = data.values.map((v) => v.toString().length).toList()..sort();
    print('=== 内容长度分析 ===');
    print('最短条目: ${lengths.first} 字符');
    print('最长条目: ${lengths.last} 字符');
    print('平均长度: ${(lengths.reduce((a, b) => a + b) / lengths.length).toStringAsFixed(1)} 字符');
    print('');
    
    // 查找包含参数的条目
    final withParams = data.entries.where((e) => 
      e.value.toString().contains('{') && e.value.toString().contains('}')
    ).toList();
    
    print('=== 参数化条目 ===');
    print('包含参数的条目: ${withParams.length}');
    if (withParams.isNotEmpty) {
      print('示例:');
      for (final entry in withParams.take(5)) {
        print('  ${entry.key}: ${entry.value}');
      }
    }
    print('');
    
    // 查找最长的条目
    print('=== 最长的5个条目 ===');
    final sortedByLength = data.entries.toList()
      ..sort((a, b) => b.value.toString().length.compareTo(a.value.toString().length));
    
    for (final entry in sortedByLength.take(5)) {
      final value = entry.value.toString();
      print('${entry.key} (${value.length}字符):');
      print('  ${value.length > 100 ? value.substring(0, 100) + '...' : value}');
      print('');
    }
    
    // 按前缀分组
    print('=== 按前缀分组统计 ===');
    final prefixGroups = <String, int>{};
    for (final key in data.keys) {
      final parts = key.split('_');
      final prefix = parts.length > 1 ? parts[0] : 'other';
      prefixGroups[prefix] = (prefixGroups[prefix] ?? 0) + 1;
    }
    
    final sortedPrefixes = prefixGroups.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    for (final group in sortedPrefixes.take(10)) {
      print('  ${group.key}: ${group.value} 条目');
    }
    
  } catch (e) {
    print('处理文件时出错: $e');
  }
}