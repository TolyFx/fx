```dart
import 'package:fx_dio/fx_dio.dart';

class ArticlePo {
  final int id;
  final String title;

  ArticlePo({required this.id, required this.title});

  factory ArticlePo.fromApi(dynamic map) => ArticlePo(
    id: map['id'] ?? 0,
    title: map['title'] ?? '',
  );
}

class ArticleRepository {
  final ArticleHost host = const ArticleHost();

  Future<ApiRet<List<ArticlePo>>> list({int page = 1, int pageSize = 20}) {
    return host.get<List<ArticlePo>>(
      '/articles',
      queryParameters: {'page': page, 'page_size': pageSize},
      convertor: (dynamic data) {
        final List<dynamic> list =
            (data as Map<String, dynamic>)['data'] as List<dynamic>;
        return list.map<ArticlePo>((dynamic e) => ArticlePo.fromApi(e)).toList();
      },
    );
  }

  Future<ApiRet<ArticlePo>> create({required String title}) {
    return host.post<ArticlePo>(
      '/articles',
      data: {'title': title},
      convertor: (dynamic data) =>
          ArticlePo.fromApi((data as Map<String, dynamic>)['data']),
    );
  }
}
```
