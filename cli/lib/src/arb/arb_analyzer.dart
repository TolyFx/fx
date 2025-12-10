import 'dart:convert';
import 'dart:io';

class ArbAnalyzer {
  /// 统计 ARB 文件数据
  static Future<ArbStats> analyzeFile(String filePath) async {
    final file = File(filePath);
    if (!await file.exists()) {
      throw Exception('文件不存在: $filePath');
    }

    final content = await file.readAsString();
    final Map<String, dynamic> data = json.decode(content);
    
    // 过滤掉元数据（以 @@ 开头的键）
    final entries = data.entries.where((e) => !e.key.startsWith('@@')).toList();
    
    return ArbStats(
      filePath: filePath,
      totalEntries: entries.length,
      entries: Map.fromEntries(entries),
      hasMetadata: data.keys.any((k) => k.startsWith('@@')),
    );
  }

  /// 格式化 ARB 文件
  static Future<void> formatFile(String filePath, {bool sortKeys = true}) async {
    final file = File(filePath);
    if (!await file.exists()) {
      throw Exception('文件不存在: $filePath');
    }

    final content = await file.readAsString();
    final Map<String, dynamic> data = json.decode(content);
    
    Map<String, dynamic> formatted;
    if (sortKeys) {
      // 分离元数据和普通条目
      final metadata = <String, dynamic>{};
      final entries = <String, dynamic>{};
      
      for (final entry in data.entries) {
        if (entry.key.startsWith('@@')) {
          metadata[entry.key] = entry.value;
        } else {
          entries[entry.key] = entry.value;
        }
      }
      
      // 排序并合并
      final sortedEntries = Map.fromEntries(
        entries.entries.toList()..sort((a, b) => a.key.compareTo(b.key))
      );
      
      formatted = {...metadata, ...sortedEntries};
    } else {
      formatted = data;
    }
    
    // 格式化 JSON
    const encoder = JsonEncoder.withIndent('  ');
    final formattedJson = encoder.convert(formatted);
    
    await file.writeAsString(formattedJson);
  }

  /// 比较两个 ARB 文件
  static Future<ArbComparison> compareFiles(String file1Path, String file2Path) async {
    final stats1 = await analyzeFile(file1Path);
    final stats2 = await analyzeFile(file2Path);
    
    final keys1 = stats1.entries.keys.toSet();
    final keys2 = stats2.entries.keys.toSet();
    
    return ArbComparison(
      file1: stats1,
      file2: stats2,
      onlyInFile1: keys1.difference(keys2).toList()..sort(),
      onlyInFile2: keys2.difference(keys1).toList()..sort(),
      common: keys1.intersection(keys2).toList()..sort(),
    );
  }
}

class ArbStats {
  final String filePath;
  final int totalEntries;
  final Map<String, dynamic> entries;
  final bool hasMetadata;

  ArbStats({
    required this.filePath,
    required this.totalEntries,
    required this.entries,
    required this.hasMetadata,
  });

  void printStats() {
    print('=== ARB 文件统计 ===');
    print('文件路径: $filePath');
    print('总条目数: $totalEntries');
    print('包含元数据: ${hasMetadata ? "是" : "否"}');
    print('');
    
    if (totalEntries > 0) {
      print('前10个条目:');
      final keys = entries.keys.take(10);
      for (final key in keys) {
        final value = entries[key].toString();
        final displayValue = value.length > 50 ? '${value.substring(0, 50)}...' : value;
        print('  $key: $displayValue');
      }
      
      if (totalEntries > 10) {
        print('  ... 还有 ${totalEntries - 10} 个条目');
      }
    }
  }
}

class ArbComparison {
  final ArbStats file1;
  final ArbStats file2;
  final List<String> onlyInFile1;
  final List<String> onlyInFile2;
  final List<String> common;

  ArbComparison({
    required this.file1,
    required this.file2,
    required this.onlyInFile1,
    required this.onlyInFile2,
    required this.common,
  });

  void printComparison() {
    print('=== ARB 文件比较 ===');
    print('文件1: ${file1.filePath} (${file1.totalEntries} 条目)');
    print('文件2: ${file2.filePath} (${file2.totalEntries} 条目)');
    print('共同条目: ${common.length}');
    print('仅在文件1中: ${onlyInFile1.length}');
    print('仅在文件2中: ${onlyInFile2.length}');
    print('');
    
    if (onlyInFile1.isNotEmpty) {
      print('仅在文件1中的条目:');
      for (final key in onlyInFile1.take(10)) {
        print('  - $key');
      }
      if (onlyInFile1.length > 10) {
        print('  ... 还有 ${onlyInFile1.length - 10} 个');
      }
      print('');
    }
    
    if (onlyInFile2.isNotEmpty) {
      print('仅在文件2中的条目:');
      for (final key in onlyInFile2.take(10)) {
        print('  - $key');
      }
      if (onlyInFile2.length > 10) {
        print('  ... 还有 ${onlyInFile2.length - 10} 个');
      }
    }
  }
}

// 命令行工具
void main(List<String> args) async {
  if (args.isEmpty) {
    print('用法:');
    print('  dart arb_analyzer.dart analyze <arb文件路径>     # 统计文件');
    print('  dart arb_analyzer.dart format <arb文件路径>      # 格式化文件');
    print('  dart arb_analyzer.dart compare <文件1> <文件2>   # 比较两个文件');
    return;
  }

  try {
    switch (args[0]) {
      case 'analyze':
        if (args.length < 2) {
          print('请提供 ARB 文件路径');
          return;
        }
        final stats = await ArbAnalyzer.analyzeFile(args[1]);
        stats.printStats();
        break;
        
      case 'format':
        if (args.length < 2) {
          print('请提供 ARB 文件路径');
          return;
        }
        await ArbAnalyzer.formatFile(args[1]);
        print('文件格式化完成: ${args[1]}');
        break;
        
      case 'compare':
        if (args.length < 3) {
          print('请提供两个 ARB 文件路径');
          return;
        }
        final comparison = await ArbAnalyzer.compareFiles(args[1], args[2]);
        comparison.printComparison();
        break;
        
      default:
        print('未知命令: ${args[0]}');
    }
  } catch (e) {
    print('错误: $e');
  }
}