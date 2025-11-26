import 'dart:typed_data';

import 'file_delivery_stub.dart'
    if (dart.library.html) 'file_delivery_web.dart';

Future<void> deliverFileToClient(
  Uint8List bytes, {
  required String filename,
  required String mimeType,
}) {
  return platformDeliverFile(
    bytes,
    filename: filename,
    mimeType: mimeType,
  );
}
