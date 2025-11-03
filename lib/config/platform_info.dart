// Conditional export: use the IO implementation on native platforms,
// and the web implementation when `dart:html` is available.
export 'platform_info_io.dart'
    if (dart.library.html) 'platform_info_web.dart';