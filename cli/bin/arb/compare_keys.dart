import 'dart:convert';
import 'dart:io';

void main(List<String> args) async {
  if (args.length < 2) {
    print('用法: dart compare_keys.dart <文件1> <文件2>');
    print('示例: dart compare_keys.dart intl_zh.arb intl_es.arb');
    return;
  }

  try {
    final comparison = await compareArbKeys(args[0], args[1]);
    comparison.printReport();
  } catch (e) {
    print('错误: $e');
  }
}

Future<KeyComparison> compareArbKeys(String file1Path, String file2Path) async {
  final file1 = File(file1Path);
  final file2 = File(file2Path);
  
  if (!await file1.exists()) throw Exception('文件不存在: $file1Path');
  if (!await file2.exists()) throw Exception('文件不存在: $file2Path');

  final data1 = json.decode(await file1.readAsString()) as Map<String, dynamic>;
  final data2 = json.decode(await file2.readAsString()) as Map<String, dynamic>;
  
  final keys1 = data1.keys.where((k) => !k.startsWith('@@')).toSet();
  final keys2 = data2.keys.where((k) => !k.startsWith('@@')).toSet();
  
  return KeyComparison(
    file1Path: file1Path,
    file2Path: file2Path,
    file1Count: keys1.length,
    file2Count: keys2.length,
    onlyInFile1: keys1.difference(keys2).toList()..sort(),
    onlyInFile2: keys2.difference(keys1).toList()..sort(),
    common: keys1.intersection(keys2).toList()..sort(),
  );
}

class KeyComparison {
  final String file1Path;
  final String file2Path;
  final int file1Count;
  final int file2Count;
  final List<String> onlyInFile1;
  final List<String> onlyInFile2;
  final List<String> common;

  KeyComparison({
    required this.file1Path,
    required this.file2Path,
    required this.file1Count,
    required this.file2Count,
    required this.onlyInFile1,
    required this.onlyInFile2,
    required this.common,
  });

  void printReport() {
    print('=== ARB 文件 Key 对比报告 ===');
    print('文件1: $file1Path ($file1Count keys)');
    print('文件2: $file2Path ($file2Count keys)');
    print('共同 keys: ${common.length}');
    print('仅在文件1: ${onlyInFile1.length}');
    print('仅在文件2: ${onlyInFile2.length}');
    print('覆盖率: ${(common.length / (file1Count > file2Count ? file1Count : file2Count) * 100).toStringAsFixed(1)}%');
    print('');
    
    if (onlyInFile1.isNotEmpty) {
      print('=== 仅在 ${_getFileName(file1Path)} 中的 keys (${onlyInFile1.length}个) ===');
      for (final key in onlyInFile1) {
        print('  - $key');
      }
      print('');
    }
    
    if (onlyInFile2.isNotEmpty) {
      print('=== 仅在 ${_getFileName(file2Path)} 中的 keys (${onlyInFile2.length}个) ===');
      for (final key in onlyInFile2) {
        print('  - $key');
      }
    }
  }
  
  String _getFileName(String path) => path.split('\\').last.split('/').last;
}