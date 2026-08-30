// Represents a picked media file without exposing picker-specific types to the domain.
import 'dart:typed_data';

class ProjectMediaFile {
  const ProjectMediaFile({
    required this.name,
    required this.bytes,
    required this.mimeType,
  });

  final String name;
  final Uint8List bytes;
  final String? mimeType;
}
