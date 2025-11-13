import 'dart:convert';
import 'dart:io';

void main() async {
  // 需要同步的 key 和对应的翻译
  final missingTranslations = {
    'copySuccess': {
      'zh': '复制成功！',
      'es': '¡Copiado con éxito!',
      'vi': 'Sao chép thành công!',
      'zh_HK': '複製成功！',
      'zh_TW': '複製成功！',
    }
  };

  final filesToUpdate = [
    'intl_zh.arb',
    'intl_es.arb', 
    'intl_vi.arb',
    'intl_zh_HK.arb',
    'intl_zh_TW.arb',
  ];

  for (final fileName in filesToUpdate) {
    try {
      final file = File(fileName);
      final content = await file.readAsString();
      final data = json.decode(content) as Map<String, dynamic>;
      
      // 获取语言代码
      final langCode = fileName.replaceAll('intl_', '').replaceAll('.arb', '');
      
      bool updated = false;
      for (final entry in missingTranslations.entries) {
        final key = entry.key;
        final translations = entry.value;
        
        if (!data.containsKey(key) && translations.containsKey(langCode)) {
          data[key] = translations[langCode];
          updated = true;
          print('添加到 $fileName: $key = ${translations[langCode]}');
        }
      }
      
      if (updated) {
        // 排序并格式化
        final sortedData = Map.fromEntries(
          data.entries.toList()..sort((a, b) => a.key.compareTo(b.key))
        );
        
        const encoder = JsonEncoder.withIndent('  ');
        await file.writeAsString(encoder.convert(sortedData));
        print('✓ 已更新 $fileName');
      } else {
        print('- $fileName 无需更新');
      }
    } catch (e) {
      print('✗ 处理 $fileName 时出错: $e');
    }
  }
  
  print('\n同步完成！');
}