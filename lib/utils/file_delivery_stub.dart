import 'dart:typed_data';

import 'package:url_launcher/url_launcher.dart';

Future<void> platformDeliverFile(
  Uint8List bytes, {
  required String filename,
  required String mimeType,
}) async {
  final uri = Uri.dataFromBytes(
    bytes,
    mimeType: mimeType,
    parameters: {'filename': filename},
  );

  final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
  if (!launched) {
    throw Exception('No se pudo abrir el archivo en este dispositivo.');
  }
}
