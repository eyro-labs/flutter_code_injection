import 'dart:async';

import 'package:flutter/services.dart';

final FlutterCodeInjection flutterCodeInjection = FlutterCodeInjection._();

class FlutterCodeInjection {
  static const MethodChannel _channel =
      const MethodChannel('flutter.eyro.co.id/flutter_code_injection');

  FlutterCodeInjection._();

  Future<List<String>> get whiteListLibraries async {
    final list = await _channel.invokeMethod('getWhiteListLibraries');
    if (list is List) {
      return list.map((e) => e.toString()).toList();
    }

    return null;
  }

  Future<bool> checkWhiteListLibraries(List<String> whiteListLibraries) async {
    assert(whiteListLibraries != null);
    try {
      final result = await _channel.invokeMethod(
        'checkWhiteListLibraries',
        whiteListLibraries,
      );
      return result == true || result == 1;
    } on PlatformException catch (e) {
      throw FlutterCodeInjectionException(e);
    }
  }
}

class FlutterCodeInjectionException implements Exception {
  @pragma("vm:entry-point")
  FlutterCodeInjectionException(PlatformException e)
      : code = e.code,
        message = e.message,
        unListedLibraries = _parseDetail(e.details);

  final String code;
  final String message;
  final List<String> unListedLibraries;

  static List<String> _parseDetail(dynamic details) {
    if (details is List) {
      return details.map((d) => d.toString()).toList();
    }
    return null;
  }

  @override
  String toString() {
    return message;
  }
}
