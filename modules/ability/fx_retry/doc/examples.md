# 使用示例

## 网络请求重试

### HTTP 请求重试

```dart
import 'package:http/http.dart' as http;
import 'package:fx_retry/fx_retry.dart';

// 基础HTTP请求重试
Future<String> fetchUserData(String userId) async {
  final response = await FxRetry.execute(
    () => http.get(Uri.parse('https://api.example.com/users/$userId')),
    maxAttempts: 3,
    policy: ExponentialBackoffPolicy(
      initialDelay: Duration(seconds: 1),
      multiplier: 2.0,
      maxDelay: Duration(seconds: 10),
    ),
    condition: HttpStatusCondition([500, 502, 503, 504]),
    onRetry: (attempt, error, delay) {
      print('HTTP请求重试第 $attempt 次，延迟 ${delay.inSeconds}s');
    },
  );
  
  if (response.statusCode == 200) {
    return response.body;
  } else {
    throw HttpException('请求失败: ${response.statusCode}');
  }
}
```

### Dio 请求重试

```dart
import 'package:dio/dio.dart';
import 'package:fx_retry/fx_retry.dart';

class ApiService {
  final Dio _dio = Dio();
  
  Future<Map<String, dynamic>> getData(String endpoint) async {
    final response = await FxRetry.builder<Response>()
      .maxAttempts(3)
      .exponentialBackoff(
        initialDelay: Duration(milliseconds: 500),
        multiplier: 1.5,
      )
      .retryOnAny([
        DioException,
        SocketException,
        TimeoutException,
      ])
      .timeout(Duration(seconds: 30))
      .onRetry((attempt, error, delay) {
        print('API请求重试: $endpoint, 第 $attempt 次');
      })
      .execute(() => _dio.get(endpoint));
    
    return response.data;
  }
}
```

## 数据库操作重试

### SQLite 操作重试

```dart
import 'package:sqflite/sqflite.dart';
import 'package:fx_retry/fx_retry.dart';

class DatabaseService {
  Database? _database;
  
  Future<List<Map<String, dynamic>>> queryUsers() async {
    return await FxRetry.execute(
      () async {
        final db = await _getDatabase();
        return await db.query('users');
      },
      maxAttempts: 3,
      policy: FixedDelayPolicy(delay: Duration(milliseconds: 100)),
      condition: ExceptionCondition<DatabaseException>(),
      onRetry: (attempt, error, delay) {
        print('数据库查询重试第 $attempt 次: $error');
      },
    );
  }
  
  Future<Database> _getDatabase() async {
    if (_database == null || !_database!.isOpen) {
      _database = await openDatabase('app.db');
    }
    return _database!;
  }
}
```

## 文件操作重试

### 文件读写重试

```dart
import 'dart:io';
import 'package:fx_retry/fx_retry.dart';

class FileService {
  Future<String> readConfigFile(String path) async {
    return await FxRetry.execute(
      () => File(path).readAsString(),
      maxAttempts: 3,
      policy: LinearBackoffPolicy(
        initialDelay: Duration(milliseconds: 100),
        increment: Duration(milliseconds: 50),
      ),
      condition: ExceptionCondition<FileSystemException>(),
      onRetry: (attempt, error, delay) {
        print('文件读取重试: $path, 第 $attempt 次');
      },
    );
  }
  
  Future<void> writeConfigFile(String path, String content) async {
    await FxRetry.execute(
      () => File(path).writeAsString(content),
      maxAttempts: 3,
      condition: ExceptionCondition<FileSystemException>(),
    );
  }
}
```

## 复杂业务场景

### 用户登录重试

```dart
import 'package:fx_retry/fx_retry.dart';

class AuthService {
  Future<UserToken> login(String username, String password) async {
    return await FxRetry.builder<UserToken>()
      .maxAttempts(3)
      .exponentialBackoff(
        initialDelay: Duration(seconds: 1),
        multiplier: 1.5,
        maxDelay: Duration(seconds: 5),
      )
      .retryOnAny([
        SocketException,
        TimeoutException,
        ServerException,
      ])
      .timeout(Duration(seconds: 20))
      .onRetry((attempt, error, delay) {
        // 记录登录重试日志
        _logRetry('login', attempt, error);
      })
      .execute(() async {
        final response = await _apiClient.post('/auth/login', {
          'username': username,
          'password': password,
        });
        
        if (response.statusCode == 401) {
          throw AuthenticationException('用户名或密码错误');
        }
        
        return UserToken.fromJson(response.data);
      });
  }
  
  void _logRetry(String operation, int attempt, Exception error) {
    print('[$operation] 重试第 $attempt 次: ${error.toString()}');
  }
}
```

### 图片上传重试

```dart
import 'dart:io';
import 'package:fx_retry/fx_retry.dart';

class ImageUploadService {
  Future<String> uploadImage(File imageFile) async {
    return await FxRetry.execute(
      () async {
        final bytes = await imageFile.readAsBytes();
        final response = await _httpClient.post(
          '/upload/image',
          body: bytes,
          headers: {'Content-Type': 'image/jpeg'},
        );
        
        if (response.statusCode != 200) {
          throw UploadException('上传失败: ${response.statusCode}');
        }
        
        final result = jsonDecode(response.body);
        return result['url'] as String;
      },
      maxAttempts: 5,
      policy: ExponentialBackoffPolicy(
        initialDelay: Duration(seconds: 2),
        multiplier: 2.0,
        maxDelay: Duration(seconds: 30),
      ),
      condition: ExceptionCondition.anyOf([
        SocketException,
        TimeoutException,
        UploadException,
      ]),
      timeout: Duration(minutes: 5),
      onRetry: (attempt, error, delay) {
        print('图片上传重试第 $attempt 次，文件: ${imageFile.path}');
      },
    );
  }
}
```

## 批量操作重试

### 批量数据同步

```dart
import 'package:fx_retry/fx_retry.dart';

class DataSyncService {
  Future<void> syncUserData(List<User> users) async {
    final results = await Future.wait(
      users.map((user) => _syncSingleUser(user)),
    );
    
    print('同步完成: ${results.length} 个用户');
  }
  
  Future<bool> _syncSingleUser(User user) async {
    try {
      await FxRetry.execute(
        () => _uploadUserData(user),
        maxAttempts: 3,
        policy: FixedDelayPolicy(delay: Duration(seconds: 1)),
        condition: ExceptionCondition.anyOf([
          SocketException,
          TimeoutException,
          ServerException,
        ]),
        onRetry: (attempt, error, delay) {
          print('用户 ${user.id} 同步重试第 $attempt 次');
        },
      );
      return true;
    } catch (e) {
      print('用户 ${user.id} 同步失败: $e');
      return false;
    }
  }
  
  Future<void> _uploadUserData(User user) async {
    // 实际的上传逻辑
    final response = await _apiClient.post('/sync/user', user.toJson());
    if (response.statusCode != 200) {
      throw ServerException('同步失败');
    }
  }
}
```

## 自定义重试条件

### 基于响应内容的重试

```dart
import 'package:fx_retry/fx_retry.dart';

class CustomRetryCondition implements RetryCondition {
  @override
  bool shouldRetry(Exception exception, int attempt) {
    if (exception is HttpException) {
      // 基于HTTP状态码判断
      return exception.statusCode >= 500;
    }
    
    if (exception is ApiException) {
      // 基于API错误码判断
      return exception.errorCode == 'RATE_LIMITED' ||
             exception.errorCode == 'TEMPORARY_ERROR';
    }
    
    return exception is SocketException || 
           exception is TimeoutException;
  }
}

// 使用自定义条件
Future<ApiResponse> callApi() async {
  return await FxRetry.execute(
    () => _makeApiCall(),
    maxAttempts: 5,
    policy: ExponentialBackoffPolicy(initialDelay: Duration(seconds: 1)),
    condition: CustomRetryCondition(),
  );
}
```

## 监控和统计

### 重试统计收集

```dart
import 'package:fx_retry/fx_retry.dart';

class RetryStatistics {
  int totalRetries = 0;
  int successfulRetries = 0;
  int failedRetries = 0;
  Map<String, int> errorCounts = {};
  
  void recordRetry(String operation, int attempt, Exception error) {
    totalRetries++;
    errorCounts[error.runtimeType.toString()] = 
        (errorCounts[error.runtimeType.toString()] ?? 0) + 1;
  }
  
  void recordSuccess(String operation) {
    successfulRetries++;
  }
  
  void recordFailure(String operation) {
    failedRetries++;
  }
}

class MonitoredApiService {
  final RetryStatistics _stats = RetryStatistics();
  
  Future<T> executeWithMonitoring<T>(
    String operation,
    Future<T> Function() action,
  ) async {
    try {
      final result = await FxRetry.execute(
        action,
        maxAttempts: 3,
        onRetry: (attempt, error, delay) {
          _stats.recordRetry(operation, attempt, error);
        },
      );
      
      _stats.recordSuccess(operation);
      return result;
    } catch (e) {
      _stats.recordFailure(operation);
      rethrow;
    }
  }
  
  void printStatistics() {
    print('重试统计:');
    print('总重试次数: ${_stats.totalRetries}');
    print('成功重试: ${_stats.successfulRetries}');
    print('失败重试: ${_stats.failedRetries}');
    print('错误分布: ${_stats.errorCounts}');
  }
}
```