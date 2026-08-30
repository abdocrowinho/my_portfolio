// Supplies picker controls and removable media previews for the project editor.
import 'package:abdelrhman_protfolio/features/portfolio/domain/entities/project_media_file.dart';
import 'package:flutter/material.dart';

class ProjectMediaControls extends StatelessWidget {
  const ProjectMediaControls({
    required this.onPickImages,
    required this.onPickVideo,
    required this.onPickDate,
    super.key,
  });
  final VoidCallback onPickImages;
  final VoidCallback onPickVideo;
  final VoidCallback onPickDate;
  @override
  Widget build(BuildContext context) => Wrap(
    spacing: 10,
    runSpacing: 10,
    children: [
      OutlinedButton.icon(
        onPressed: onPickImages,
        icon: const Icon(Icons.add_photo_alternate_outlined),
        label: const Text('Select images'),
      ),
      OutlinedButton.icon(
        onPressed: onPickVideo,
        icon: const Icon(Icons.video_file_outlined),
        label: const Text('Select video'),
      ),
      OutlinedButton.icon(
        onPressed: onPickDate,
        icon: const Icon(Icons.event_outlined),
        label: const Text('Completed date'),
      ),
    ],
  );
}

class ProjectImagePreviews extends StatelessWidget {
  const ProjectImagePreviews({
    required this.retainedUrls,
    required this.newImages,
    required this.onRemoveRetained,
    required this.onRemoveNew,
    super.key,
  });
  final List<String> retainedUrls;
  final List<ProjectMediaFile> newImages;
  final ValueChanged<String> onRemoveRetained;
  final ValueChanged<ProjectMediaFile> onRemoveNew;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 16),
    child: Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        ...retainedUrls.map(
          (url) => _Preview(
            image: Image.network(url, fit: BoxFit.cover),
            onRemove: () => onRemoveRetained(url),
          ),
        ),
        ...newImages.map(
          (file) => _Preview(
            image: Image.memory(file.bytes, fit: BoxFit.cover),
            onRemove: () => onRemoveNew(file),
          ),
        ),
      ],
    ),
  );
}

class _Preview extends StatelessWidget {
  const _Preview({required this.image, required this.onRemove});
  final Widget image;
  final VoidCallback onRemove;
  @override
  Widget build(BuildContext context) => Stack(
    children: [
      SizedBox(
        width: 86,
        height: 86,
        child: ClipRRect(borderRadius: BorderRadius.circular(8), child: image),
      ),
      Positioned(
        right: 0,
        child: IconButton.filled(
          iconSize: 14,
          padding: const EdgeInsets.all(5),
          onPressed: onRemove,
          icon: const Icon(Icons.close),
        ),
      ),
    ],
  );
}

class ProjectVideoSelection extends StatelessWidget {
  const ProjectVideoSelection({
    required this.label,
    required this.onRemove,
    super.key,
  });
  final String label;
  final VoidCallback onRemove;
  @override
  Widget build(BuildContext context) => ListTile(
    contentPadding: EdgeInsets.zero,
    leading: const Icon(Icons.video_file),
    title: Text(label),
    trailing: IconButton(onPressed: onRemove, icon: const Icon(Icons.close)),
  );
}
