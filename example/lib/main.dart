import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:windows_raw_print/windows_raw_print.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: ElevatedButton(
              onPressed: () {
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
                WindowsRawPrint.rawDataToPrinter(
                  printerName: "Generic / Text Only",
                  data: posBytes,
                  docName: "Flutter Raw",
                );
              },
              child: Text('Print "TEST ŠĐČĆŽšđčććž"')),
        ),
      ),
    );
  }
}
