import 'arb_analyzer.dart';

void main() async {
  // 当前目录下的 ARB 文件路径
  const arbFile = 'intl_zh.arb';
  
  try {
    // 1. 统计当前 ARB 文件
    print('正在分析 ARB 文件...\n');
    final stats = await ArbAnalyzer.analyzeFile(arbFile);
    stats.printStats();
    
    print('\n' + '='*50 + '\n');
    
    // 2. 格式化文件（可选）
    print('是否要格式化文件？这将重新排序键并美化 JSON 格式。');
    print('注意：这会修改原文件！');
    // 取消注释下面的行来执行格式化
    // await ArbAnalyzer.formatFile(arbFile);
    // print('文件已格式化完成！');
    
  } catch (e) {
    print('处理文件时出错: $e');
  }
}