import 'dart:io';
import 'dart:convert';
import 'package:archive/archive.dart';
import 'package:path/path.dart' as path;

void main() async {
  final templateDir = Directory('modules_template');
  if (!await templateDir.exists()) {
    print('❌ modules_template 目录不存在');
    exit(1);
  }

  print('📦 正在压缩 modules_template 目录...');
  final bytes = await createZipFromDirectory(templateDir);
  final base64Data = base64Encode(bytes);
  print('✅ 压缩完成，大小: ${(bytes.length / 1024).toStringAsFixed(1)} KB');

  final dartCode = '''
// 自动生成的模板数据文件
// 请勿手动修改此文件

import 'dart:convert';
import 'dart:typed_data';

class TemplateReader {
  static const String _templateData = '$base64Data';
  
  static Uint8List getTemplateZip() {
    return base64Decode(_templateData);
  }
  
  static int get size => getTemplateZip().length;
}
''';

  final outputFile = File('lib/src/template/template_reader.dart');
  await outputFile.writeAsString(dartCode);

  print('✅ 模板已嵌入到 lib/src/template/template_reader.dart');
  print('📊 模板大小: ${(bytes.length / 1024).toStringAsFixed(1)} KB');
}

Future<List<int>> createZipFromDirectory(Directory dir) async {
  final archive = Archive();
  await addDirectoryToArchive(archive, dir, '');
  return ZipEncoder().encode(archive)!;
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
