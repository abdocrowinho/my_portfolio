// Exposes the correct CV download implementation for each supported platform.
export 'cv_downloader_stub.dart'
    if (dart.library.html) 'cv_downloader_web.dart';
