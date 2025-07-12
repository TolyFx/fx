class SnowflakeIdGenerator {
  final int datacenterId;
  final int workerId;

  static const int workerIdBits = 5;
  static const int datacenterIdBits = 5;
  static const int sequenceBits = 12;

  static const int maxWorkerId = ~(-1 << workerIdBits); // 31
  static const int maxDatacenterId = ~(-1 << datacenterIdBits); // 31
  static const int maxSequence = ~(-1 << sequenceBits); // 4095

  static const int workerIdShift = sequenceBits;
  static const int datacenterIdShift = sequenceBits + workerIdBits;
  static const int timestampShift =
      sequenceBits + workerIdBits + datacenterIdBits;

  static final int twepoch = DateTime.utc(2020, 1, 1).millisecondsSinceEpoch;

  int _sequence = 0;
  int _lastTimestamp = -1;

  SnowflakeIdGenerator(this.datacenterId, this.workerId) {
    if (workerId > maxWorkerId || workerId < 0) {
      throw ArgumentError('workerId must be between 0 and $maxWorkerId');
    }
    if (datacenterId > maxDatacenterId || datacenterId < 0) {
      throw ArgumentError(
          'datacenterId must be between 0 and $maxDatacenterId');
    }
  }

  /// 生成下一个 ID
  int nextId() {
    int timestamp = _currentTimeMillis;

    if (timestamp < _lastTimestamp) {
      throw StateError(
          'Clock moved backwards. Refusing to generate id for ${_lastTimestamp - timestamp} ms');
    }

    if (_lastTimestamp == timestamp) {
      _sequence = (_sequence + 1) & maxSequence;
      if (_sequence == 0) {
        // 同一毫秒内超过 4096，等待下一毫秒
        timestamp = _waitUntilNextMillis(_lastTimestamp);
      }
    } else {
      _sequence = 0;
    }

    _lastTimestamp = timestamp;

    return ((timestamp - twepoch) << timestampShift) |
        (datacenterId << datacenterIdShift) |
        (workerId << workerIdShift) |
        _sequence;
  }

  /// 当前时间（毫秒）
  int get _currentTimeMillis => DateTime.now().toUtc().millisecondsSinceEpoch;

  /// 等待下一毫秒
  int _waitUntilNextMillis(int lastTimestamp) {
    int timestamp = _currentTimeMillis;
    while (timestamp <= lastTimestamp) {
      timestamp = _currentTimeMillis;
    }
    return timestamp;
  }
}
