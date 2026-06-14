class Paginate {
  final int total;
  const Paginate({required this.total});
}

abstract class PaginateParser {
  const PaginateParser();
  Paginate? parse(dynamic data);
}

class DefaultPaginateParser extends PaginateParser {
  const DefaultPaginateParser();

  @override
  Paginate? parse(dynamic data) {
    if (data is! Map<String, dynamic>) return null;
    final dynamic p = data['paginate'];
    final dynamic total = p is Map<String, dynamic> ? p['total'] : data['total'];
    if (total == null) return null;
    return Paginate(total: total is int ? total : int.tryParse('$total') ?? 0);
  }
}
