import 'dart:typed_data';

/// Stub for non-web platforms
/// This file is imported on mobile/desktop platforms
void downloadFile(Uint8List bytes, String filename) {
  throw UnsupportedError('File download is only supported on web');
}
