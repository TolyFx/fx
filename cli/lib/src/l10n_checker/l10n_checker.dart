import 'dart:io';
import 'dart:convert';
import 'package:path/path.dart' as path;
import 'package:yaml/yaml.dart';

class ConsoleColors {
  static const String reset = '\x1B[0m';
  static const String bold = '\x1B[1m';
  static const String dim = '\x1B[2m';
  static const String red = '\x1B[31m';
  static const String green = '\x1B[32m';
  static const String yellow = '\x1B[33m';
  static const String blue = '\x1B[34m';
  static const String magenta = '\x1B[35m';
  static const String cyan = '\x1B[36m';
  static const String white = '\x1B[37m';
  static const String gray = '\x1B[90m';
  
  static String colorize(String text, String color, {bool enabled = true}) {
    return enabled ? '$color$text$reset' : text;
  }
  
  static String success(String text, {bool enabled = true}) => colorize(text, green, enabled: enabled);
  static String error(String text, {bool enabled = true}) => colorize(text, red, enabled: enabled);
  static String warning(String text, {bool enabled = true}) => colorize(text, yellow, enabled: enabled);
  static String info(String text, {bool enabled = true}) => colorize(text, blue, enabled: enabled);
  static String highlight(String text, {bool enabled = true}) => colorize(text, bold + cyan, enabled: enabled);
  static String muted(String text, {bool enabled = true}) => colorize(text, gray, enabled: enabled);
}

class L10nIssue {
  final String file;
  final int line;
  final int column;
  final String content;
  final String context;

  L10nIssue({
    required this.file,
    required this.line,
    required this.column,
    required this.content,
    required this.context,
  });

  Map<String, dynamic> toJson() => {
    'file': file,
    'line': line,
    'column': column,
    'content': content,
    'context': context,
  };
}

class L10nChecker {
  static final _stringPattern = RegExp(r'''(['"]((?:\\.|(?!\1)[^\\])*?)\1''');
  static final _commentPattern = RegExp(r'//.*$|/\*[\s\S]*?\*/');
  
  List<String> _ignorePatterns = [];
  bool _showChecking = true;
  bool _colorOutput = true;
  String _basePath = '';
  String? _outputFile;
  String _outputFormat = 'json';
  bool _ignorePrint = false;
  List<String> _ignoreChars = [];

  Future<List<L10nIssue>> checkDirectory(String dirPath) async {
    await _loadIgnoreConfig(dirPath);
    _basePath = path.absolute(dirPath);
    final issues = <L10nIssue>[];
    final dir = Directory(dirPath);
    
    if (!dir.existsSync()) {
      throw Exception('Directory not found: $dirPath');
    }

    // 只在非 JSON 格式时显示扫描信息
    if (_outputFormat != 'json') {
      print(ConsoleColors.info('🔍 Scanning directory: $dirPath', enabled: _colorOutput));
    }
    var fileCount = 0;
    var skippedCount = 0;

    await for (final entity in dir.list(recursive: true)) {
      if (entity is File && entity.path.endsWith('.dart')) {
        if (_shouldSkipFile(entity.path)) {
          skippedCount++;
          continue;
        }
        fileCount++;
        if (_showChecking && _outputFormat != 'json') {
          print(ConsoleColors.muted('Checking: ${path.relative(entity.path, from: _basePath).replaceAll('\\', '/')}', enabled: _colorOutput));
        }
        issues.addAll(await _checkFile(entity));
      }
    }
    
    if (_outputFormat != 'json') {
      print(ConsoleColors.info('📊 Scanned $fileCount .dart files (skipped $skippedCount)', enabled: _colorOutput));
    }
    return issues;
  }

  Future<void> _loadIgnoreConfig(String dirPath) async {
    final configFile = File(path.join(dirPath, 'fx.yaml'));
    if (!configFile.existsSync()) return;
    
    try {
      final content = await configFile.readAsString();
      final yamlConfig = loadYaml(content);
      final config = yamlConfig['l10n_check'];
      
      // 先设置输出格式
      if (config['output_format'] != null) {
        _outputFormat = config['output_format'];
      }
      
      if (config['ignore'] != null) {
        _ignorePatterns = List<String>.from(config['ignore']);
        if (_outputFormat != 'json') {
          print(ConsoleColors.success('📋 Loaded ${_ignorePatterns.length} ignore patterns from fx.yaml', enabled: _colorOutput));
        }
      }
      
      if (config['show_checking'] != null) {
        _showChecking = config['show_checking'];
      }
      
      if (config['color_output'] != null) {
        _colorOutput = config['color_output'];
      }
      
      if (config['output_file'] != null) {
        _outputFile = config['output_file'];
      }
      
      if (config['ignore_print'] != null) {
        _ignorePrint = config['ignore_print'] == true;
      }
      
      if (config['ignore_chars'] != null) {
        _ignoreChars = List<String>.from(config['ignore_chars']);
      }
    } catch (e) {
      if (_outputFormat != 'json') {
        print(ConsoleColors.warning('⚠️  Error loading fx.yaml: $e', enabled: _colorOutput));
      }
    }
  }

  bool _shouldSkipFile(String filePath) {
    final skipPatterns = [
      '${Platform.pathSeparator}build${Platform.pathSeparator}',
      '${Platform.pathSeparator}.dart_tool${Platform.pathSeparator}',
      '${Platform.pathSeparator}.git${Platform.pathSeparator}',
      '${Platform.pathSeparator}packages${Platform.pathSeparator}'
    ];
    
    // Check default skip patterns
    if (skipPatterns.any((pattern) => filePath.contains(pattern))) {
      return true;
    }
    
    // Check custom ignore patterns
    final relativePath = path.relative(filePath).replaceAll('\\', '/');
    return _ignorePatterns.any((pattern) {
      // Directory pattern (ends with /)
      if (pattern.endsWith('/')) {
        return relativePath.startsWith(pattern) || relativePath.contains('/$pattern');
      }
      // File pattern
      return relativePath.contains(pattern) || 
             path.basename(filePath) == pattern ||
             _matchesGlob(relativePath, pattern);
    });
  }
  
  bool _matchesGlob(String filePath, String pattern) {
    if (!pattern.contains('*')) return false;
    final regex = RegExp(pattern.replaceAll('*', '.*'));
    return regex.hasMatch(path.basename(filePath));
  }

  Future<List<L10nIssue>> _checkFile(File file) async {
    final issues = <L10nIssue>[];
    final lines = await file.readAsLines();
    
    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];
      final cleanLine = _removeComments(line);
      
      for (final match in _stringPattern.allMatches(cleanLine)) {
        final content = match.group(2) ?? '';
        if (_containsNonEnglish(content)) {
          // 检查是否忽略print语句
          if (_ignorePrint && _isPrintStatement(line)) {
            continue;
          }
          
          issues.add(L10nIssue(
            file: path.relative(file.path, from: _basePath).replaceAll('\\', '/'),
            line: i + 1,
            column: match.start + 1,
            content: match.group(0) ?? '',
            context: line.trim(),
          ));
        }
      }
    }
    
    return issues;
  }

  String _removeComments(String line) {
    return line.replaceAll(_commentPattern, '');
  }

  bool _containsNonEnglish(String text) {
    // 先移除忽略的字符
    String filteredText = text;
    for (final char in _ignoreChars) {
      filteredText = filteredText.replaceAll(char, '');
    }
    
    return filteredText.runes.any((rune) => rune > 127);
  }
  
  bool _isPrintStatement(String line) {
    final trimmed = line.trim();
    return trimmed.startsWith('print(') || 
           trimmed.contains('debugPrint(') ||
           trimmed.contains('FxTrace().emit(TipTrace(');
  }

  Future<void> printResults(List<L10nIssue> issues, {bool verbose = false, String? outputFormat}) async {
    final format = outputFormat ?? _outputFormat;
    
    // JSON 格式输出
    if (format == 'json' || _outputFormat == 'json') {
      final jsonOutput = formatAsJson(issues);
      print(jsonOutput);
      
      // 写入文件
      if (_outputFile != null) {
        await _writeToFile(jsonOutput);
      }
      return;
    }
    
    // 文本格式输出
    final output = StringBuffer();
    
    if (issues.isEmpty) {
      final message = '✅ No non-English strings found.';
      print(ConsoleColors.success(message, enabled: _colorOutput));
      output.writeln(message);
    } else {
      final header = '🔍 Found ${issues.length} non-English string(s):';
      print(ConsoleColors.error(header, enabled: _colorOutput));
      output.writeln(header);
      print('');
      output.writeln('');
      
      for (final issue in issues) {
        final location = '📍 ${issue.file}:${issue.line}:${issue.column}';
        final content = '   ${issue.content}';
        
        print(ConsoleColors.highlight(location, enabled: _colorOutput));
        print(ConsoleColors.warning(content, enabled: _colorOutput));
        output.writeln(location);
        output.writeln(content);
        
        if (verbose) {
          final context = '   Context: ${issue.context}';
          print(ConsoleColors.muted(context, enabled: _colorOutput));
          output.writeln(context);
        }
        print('');
        output.writeln('');
      }
      
      final fileCount = issues.map((i) => i.file).toSet().length;
      final summary = '📊 Summary: ${issues.length} issues in $fileCount file(s)';
      print(ConsoleColors.info(summary, enabled: _colorOutput));
      output.writeln(summary);
    }
    
    // 写入文件
    if (_outputFile != null) {
      await _writeToFile(output.toString());
    }
  }

  Future<void> _writeToFile(String content) async {
    try {
      final filePath = path.isAbsolute(_outputFile!) 
          ? _outputFile! 
          : path.join(_basePath, _outputFile!);
      
      final file = File(filePath);
      await file.writeAsString(content);
      if (_outputFormat != 'json') {
        print(ConsoleColors.success('💾 Output saved to: ${path.absolute(filePath)}', enabled: _colorOutput));
      }
    } catch (e) {
      if (_outputFormat != 'json') {
        print(ConsoleColors.warning('⚠️  Failed to write output file: $e', enabled: _colorOutput));
      }
    }
  }

  String formatAsJson(List<L10nIssue> issues) {
    final uniqueStrings = issues
        .map((i) => i.content.replaceAll('"', '').replaceAll("'", ''))
        .toSet()
        .toList()..sort();
    
    return jsonEncode({
      'issues': issues.map((i) => i.toJson()).toList(),
      'summary': {
        'total_issues': issues.length,
        'affected_files': issues.map((i) => i.file).toSet().length,
      },
      'unique_strings': uniqueStrings,
      'count': uniqueStrings.length,
    });
  }
}