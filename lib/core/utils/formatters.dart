class Formatters {
  static String won(num value) {
    final sign = value < 0 ? '-' : '';
    final digits = value.abs().round().toString();
    final buffer = StringBuffer();

    for (var i = 0; i < digits.length; i++) {
      final remaining = digits.length - i;
      buffer.write(digits[i]);
      if (remaining > 1 && remaining % 3 == 1) {
        buffer.write(',');
      }
    }

    return '$sign${buffer.toString()}원';
  }

  static String percent(double value) {
    return '${value.toStringAsFixed(1)}%';
  }

  static String monthDay(DateTime date) {
    return '${date.month}월 ${date.day}일';
  }
}
