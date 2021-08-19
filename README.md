# windows_raw_print

Flutter plugin to print RAW data to Windows printer.
Implemented as Dart FFI plugin to Windows native winspool API.

## Getting Started

Use `listPrinters()` to list printers installed on local windows machine.

Use  `rawDataToPrinter(String printerName, Uint8List data, String docName = "Flutter Document")` 
to send list of bytes to specifed printer.

Raw data printing is Dart FFI implementation of [Microsoft Example](https://docs.microsoft.com/en-us/troubleshoot/windows/win32/win32-raw-data-to-printer)

List printers is taken from [win32 FFI plugin](https://github.com/timsneath/win32/blob/main/example/printer_list.dart)

