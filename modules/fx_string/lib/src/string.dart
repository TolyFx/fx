
extension TextChackExt on String {

  bool get isMarkdown => checkMarkdown();

  bool checkMarkdown({int min = 1}) {
    // 定义所有 Markdown 语法正则规则
    final patterns = [
      RegExp(r'^#{1,6}\s+.+$', multiLine: true), // 标题（如 # Heading）
      RegExp(r'^[-*+]\s+.+$', multiLine: true), // 无序列表（如 - Item）
      RegExp(r'^\d+\.\s+.+$', multiLine: true), // 有序列表（如 1. Item）
      RegExp(r'\*\*.*?\*\*|__.*?__'), // 粗体（**text** 或 __text__）
      RegExp(r'\*.*?\*|_.*?_'), // 斜体（*text* 或 _text_）
      RegExp(r'~~.*?~~'), // 删除线（~~text~~）
      RegExp(r'!?\[.*?\]\(.*?\)'), // 链接或图片（[text](url)）
      RegExp(r'^> .+$', multiLine: true), // 引用块（> Quote）
      RegExp(r'^```.*$|^ {4,}.*$', multiLine: true), // 代码块（``` 或 4空格缩进）
      RegExp(r'^-{3,}$|^\*{3,}$|^_{3,}$', multiLine: true), // 分隔线（---, ***）
      RegExp(r'\|.*?\|'), // 表格（| Col |）
      RegExp(r'`[^`]+`'), // 行内代码（`code`）
    ];

    // 记录匹配到的不同规则（避免重复计数）
    final Set<RegExp> matchedPatterns = {};

    for (final pattern in patterns) {
      if (pattern.hasMatch(this)) {
        matchedPatterns.add(pattern);
      }
    }

    // 至少匹配 [min] 种不同规则才判定为 Markdown
    return matchedPatterns.length >= min;
  }
}
