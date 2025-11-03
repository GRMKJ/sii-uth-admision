// Conditional export: native implementation uses dart:io HttpClient; web
// implementation uses the browser-friendly `package:http` client.
export 'api_client_io.dart'
    if (dart.library.html) 'api_client_web.dart';
