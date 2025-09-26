import 'package:logger/logger.dart';
import 'package:flutter/foundation.dart';

class AppLogger {
  static final bool _isDebug = kDebugMode;
  static final _logger = Logger(
    //level t -> d -> i -> w -> e -> f
    level: _isDebug ? Level.trace : Level.warning,
    printer: PrettyPrinter(
      methodCount: 2, // số dòng stack trace
      errorMethodCount: 8, // số dòng stack trace cho error
      lineLength: 120, // độ dài dòng
      colors: true, // có màu
      printEmojis: true, // in emoji
      dateTimeFormat: DateTimeFormat.dateAndTime,
    ),
  );

  static void t(dynamic message) =>
      _logger.t(message); //trace log (debug chi tiết)
  static void d(dynamic message) => _logger.d(message); //debug log
  static void i(dynamic message) => _logger.i(message); //info log
  static void w(dynamic message) => _logger.w(message); //warning
  static void e(dynamic message, {dynamic error, StackTrace? stackTrace}) =>
      _logger.e(message, error: error, stackTrace: stackTrace); //error
  static void f(dynamic message) => _logger.f(message); //fatal/crash log
}
