import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_code_injection/flutter_code_injection.dart';

void main() {
  const MethodChannel channel = MethodChannel('flutter.eyro.co.id/flutter_code_injection');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      if (methodCall.method == 'getWhiteListLibraries') {
        return ['/lib/1', '/lib/2'];
      }

      if (methodCall.method == 'checkWhiteListLibraries') {
        return methodCall.arguments is List && methodCall.arguments.length == 2;
      }

      if (methodCall.method == 'checkDynamicLibrary') {
        return false;
      }
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getWhiteListLibraries', () async {
    expect(await flutterCodeInjection.whiteListLibraries, ['/lib/1', '/lib/2']);
  });

  test('checkWhiteListLibraries', () async {
    expect(await flutterCodeInjection.checkWhiteListLibraries(['/lib/1', '/lib/2']), true);
  });

  test('checkDynamicLibrary', () async {
    expect(await flutterCodeInjection.checkDynamicLibrary(), false);
  });
}
