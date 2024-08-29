class QueryArgs {
  final Map<String, dynamic>? argsMap;
  final int page;
  final int pageSize;

  const QueryArgs({
    this.argsMap,
    this.page = 1,
    this.pageSize = 20,
  });

  (String, List<Object?>?) get parserSql {
    String args = '';
    List<String> conditions = [];
    List<Object?>? arguments = [];
    if (argsMap != null) {
      argsMap!.forEach((String key, dynamic value) {
        if (value != null) {
          conditions.add('$key like ?');
          arguments.add('%$value%');
        }
      });
    }

    if (conditions.isNotEmpty) {
      args = 'WHERE ';
    }
    args += conditions.join(' AND ');
    args += ' ORDER BY update_at DESC LIMIT ? OFFSET ?';
    arguments.add(pageSize);
    arguments.add((page - 1) * pageSize);
    return (args, arguments);
  }
}
