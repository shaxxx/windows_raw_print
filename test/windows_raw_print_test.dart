import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:windows_raw_print/windows_raw_print.dart';

void main() {
  const MethodChannel channel = MethodChannel('windows_raw_print');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('printRaw', () async {
    expect(await WindowsRawPrint.platformVersion, '42');
    var posBytes = Uint8List.fromList([
      // init printer
      0x1B, // Esc
      0x40, // @
      // select character code table
      0x1B, // Esc
      0x74, // t
      0x8, // 8  <-- location of CodePage 852 in my printer, usually 0x8 or 0x12
      0x54, // T
      0x45, // E
      0x53, // S
      0x54, // T
      0x20, // Space
      0xE6, // Š
      0xD1, // Đ
      0xAC, // Č
      0x8F, // Ć
      0xA6, // Ž
      0xE7, // š
      0xD0, // đ
      0x9F, // č
      0x86, // ć
      0xA7, // ž
      //add new line
      0x0D, // CR (carriage return)
      0x0A, // NL (new line)
      //add new line
      0x0D, // CR (carriage return)
      0x0A, // NL (new line)
      //add new line
      0x0D, // CR (carriage return)
      0x0A, // NL (new line)
      //add new line
      0x0D, // CR (carriage return)
      0x0A, // NL (new line)
      // init printer
      0x1B, // Esc
      0x40, // @
    ]);
    expect(
        WindowsRawPrint.rawDataToPrinter(
          printerName: "Generic / Text Only",
          data: posBytes,
          docName: "Flutter Raw",
        ),
        true);
  });
}
