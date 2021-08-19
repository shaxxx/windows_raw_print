import 'dart:async';
import 'dart:ffi';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:win32/win32.dart';
import 'package:ffi/ffi.dart';

import 'src/printer_names.dart';

export 'src/printer_names.dart';

class WindowsRawPrint {
  static const MethodChannel _channel =
      const MethodChannel('windows_raw_print');

  static Future<String?> get platformVersion async {
    final String? version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  static Future<List<String>> listPrinters() async {
    final printerNames = PrinterNames(PRINTER_ENUM_LOCAL);
    var result = <String>[];
    for (final name in printerNames.all()) {
      result.add(name);
    }
    return result;
  }

  static bool rawDataToPrinter({
    required String printerName,
    required Uint8List data,
    String docName = "Flutter Document",
  }) {
    var szPrinterName = printerName.toNativeUtf16();
    Pointer<IntPtr> hPrinter = calloc();
    Pointer<DOC_INFO_1> docInfo = calloc<DOC_INFO_1>();
    Pointer<Uint8> pData = calloc<Uint8>(data.length);
    for (var i = 0; i < data.length; i++) {
      pData[i] = data[i];
    }
    docInfo.ref.pDocName = docName.toNativeUtf16();
    docInfo.ref.pOutputFile = nullptr;
    docInfo.ref.pDatatype = "RAW".toNativeUtf16();
    var dwBytesWritten = calloc<Uint32>();
    var isError = false;
    try {
      var openPrinterResult = OpenPrinter(szPrinterName, hPrinter, nullptr);
      if (openPrinterResult == 0) {
        isError = true;
      }

      if (!isError) {
        if (StartDocPrinter(hPrinter.value, 1, docInfo) == 0) {
          ClosePrinter(hPrinter.value);
          isError = true;
        }
      }

      if (!isError) {
        if (StartPagePrinter(hPrinter.value) == 0) {
          EndDocPrinter(hPrinter.value);
          ClosePrinter(hPrinter.value);
          isError = true;
        }
      }

      if (!isError) {
        if (WritePrinter(hPrinter.value, pData, data.length, dwBytesWritten) ==
            0) {
          EndPagePrinter(hPrinter.value);
          EndDocPrinter(hPrinter.value);
          ClosePrinter(hPrinter.value);
          isError = true;
        }
      }

      if (!isError) {
        // End the page.
        if (EndPagePrinter(hPrinter.value) == 0) {
          print('EndPagePrinter Error: ${GetLastError()}');
          EndDocPrinter(hPrinter.value);
          ClosePrinter(hPrinter.value);
          isError = true;
        }
      }

      if (!isError) {
        // Inform the spooler that the document is ending.
        if (EndDocPrinter(hPrinter.value) == 0) {
          print('EndDocPrinter Error: ${GetLastError()}');
          ClosePrinter(hPrinter.value);
          isError = true;
        }
      }

      if (!isError) {
        // Tidy up the printer handle.
        ClosePrinter(hPrinter.value);
        // Check to see if correct number of bytes were written.
        if (dwBytesWritten.value != data.length) {
          print(
              "Wrote ${dwBytesWritten.value} bytes instead of requested ${data.length} bytes.\n");
          isError = true;
        }
      }
    } finally {
      free(szPrinterName);
      free(hPrinter);
      free(docInfo);
      free(pData);
      free(dwBytesWritten);
    }
    return !isError;
  }
}
