// Collects project metadata and local media selections for web-only create and edit flows.

import 'package:abdelrhman_protfolio/core/theme/app_colors.dart';
import 'package:abdelrhman_protfolio/features/portfolio/domain/entities/portfolio_project.dart';
import 'package:abdelrhman_protfolio/features/portfolio/domain/entities/portfolio_project_draft.dart';
import 'package:abdelrhman_protfolio/features/portfolio/domain/entities/project_media_file.dart';
import 'package:abdelrhman_protfolio/features/portfolio/presentation/state/portfolio_view_model.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProjectEditor extends StatefulWidget {
  const ProjectEditor({
    this.project,
    super.key,
  });

  final PortfolioProject? project;

  @override
  State<ProjectEditor> createState() => _ProjectEditorState();
}

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
        icon: const Icon(
          Icons.add_photo_alternate_outlined,
        ),
        label: const Text('Select images'),
      ),
      OutlinedButton.icon(
        onPressed: onPickVideo,
        icon: const Icon(
          Icons.video_file_outlined,
        ),
        label: const Text('Select video'),
      ),
      OutlinedButton.icon(
        onPressed: onPickDate,
        icon: const Icon(
          Icons.event_outlined,
        ),
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
              (url) => _ProjectImagePreview(
            image: Image.network(
              url,
              fit: BoxFit.cover,
            ),
            onRemove: () => onRemoveRetained(url),
          ),
        ),
        ...newImages.map(
              (file) => _ProjectImagePreview(
            image: Image.memory(
              file.bytes,
              fit: BoxFit.cover,
            ),
            onRemove: () => onRemoveNew(file),
          ),
        ),
      ],
    ),
  );
}

class _ProjectImagePreview extends StatelessWidget {
  const _ProjectImagePreview({
    required this.image,
    required this.onRemove,
  });

  final Widget image;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) => Stack(
    children: [
      SizedBox(
        width: 86,
        height: 86,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: image,
        ),
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
    trailing: IconButton(
      onPressed: onRemove,
      icon: const Icon(Icons.close),
    ),
  );
}

class _ProjectEditorState extends State<ProjectEditor> {
  final _formKey = GlobalKey<FormState>();

  late final _nameController = TextEditingController(
    text: widget.project?.name,
  );

  late final _descriptionController = TextEditingController(
    text: widget.project?.description,
  );

  late final _repoController = TextEditingController(
    text: widget.project?.repoUrl,
  );

  // ============================================================
  // TAGS
  // ============================================================

  late final _tagsController = TextEditingController(
    text: widget.project?.tags?.join(', '),
  );

  late final List<String> _retainedImages;

  final _newImages = <ProjectMediaFile>[];

  ProjectMediaFile? _video;

  bool _retainVideo = false;

  DateTime? _completedAt;

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();

    _retainedImages = [
      ...?widget.project?.imageUrls,
    ];

    _retainVideo = widget.project?.videoUrl != null;

    _completedAt = widget.project?.completedAt;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _repoController.dispose();
    _tagsController.dispose();

    super.dispose();
  }

  // ============================================================
  // IMAGES
  // ============================================================

  Future<void> _pickImages() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: true,
      withData: true,
    );

    if (result == null) return;

    setState(
          () => _newImages.addAll(
        result.files
            .where(
              (file) => file.bytes != null,
        )
            .map(_toMedia),
      ),
    );
  }

  // ============================================================
  // VIDEO
  // ============================================================

  Future<void> _pickVideo() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.video,
      withData: true,
    );

    final file = result?.files.singleOrNull;

    if (file?.bytes == null) return;

    setState(() {
      _video = _toMedia(file!);
      _retainVideo = false;
    });
  }

  ProjectMediaFile _toMedia(PlatformFile file) =>
      ProjectMediaFile(
        name: file.name,
        bytes: file.bytes!,
        mimeType: file.extension == null
            ? null
            : 'application/${file.extension}',
      );

  // ============================================================
  // TAGS
  // ============================================================

  List<String> _getTags() {
    return _tagsController.text
        .split(',')
        .map((tag) => tag.trim())
        .where((tag) => tag.isNotEmpty)
        .toSet()
        .toList();
  }

  // ============================================================
  // SUBMIT
  // ============================================================

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final draft = PortfolioProjectDraft(
      name: _nameController.text.trim(),

      description: _descriptionController.text.trim(),

      newImages: _newImages,

      video: _video,

      repoUrl: _emptyToNull(
        _repoController.text,
      ),

      completedAt: _completedAt,

      // ==========================================================
      // TAGS
      // ==========================================================

      tags: _getTags(),
    );

    final viewModel = context.read<PortfolioViewModel>();

    final result = widget.project == null
        ? await viewModel.createProject(draft)
        : await viewModel.updateProject(
      widget.project!,
      draft,
      retainedImageUrls: _retainedImages,
      retainVideo: _retainVideo,
    );

    if (!mounted) return;

    setState(() {
      _isSubmitting = false;
    });

    if (result != null) {
      Navigator.pop(context);
    }
  }

  String? _emptyToNull(String value) {
    return value.trim().isEmpty
        ? null
        : value.trim();
  }

  // ============================================================
  // UI
  // ============================================================

  @override
  Widget build(BuildContext context) => Dialog(
    backgroundColor: AppColors.surface,
    child: ConstrainedBox(
      constraints: const BoxConstraints(
        maxWidth: 700,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.project == null
                    ? 'Add project'
                    : 'Edit project',
                style: Theme.of(context)
                    .textTheme
                    .headlineMedium,
              ),

              const SizedBox(height: 22),

              // ==================================================
              // NAME
              // ==================================================

              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Project name',
                ),
                validator: _required,
              ),

              const SizedBox(height: 14),

              // ==================================================
              // DESCRIPTION
              // ==================================================

              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                ),
                validator: _required,
                minLines: 3,
                maxLines: 6,
              ),

              const SizedBox(height: 14),

              // ==================================================
              // REPOSITORY
              // ==================================================

              TextFormField(
                controller: _repoController,
                decoration: const InputDecoration(
                  labelText: 'Repository URL (optional)',
                ),
                keyboardType: TextInputType.url,
              ),

              const SizedBox(height: 14),

              // ==================================================
              // TAGS
              // ==================================================

              TextFormField(
                controller: _tagsController,
                decoration: const InputDecoration(
                  labelText: 'Tags',
                  hintText:
                  'Flutter, Dart, Firebase, Clean Architecture',
                  helperText:
                  'Separate tags with commas',
                  prefixIcon: Icon(
                    Icons.sell_outlined,
                  ),
                ),
                minLines: 1,
                maxLines: 3,
              ),

              const SizedBox(height: 16),

              // ==================================================
              // MEDIA CONTROLS
              // ==================================================

              ProjectMediaControls(
                onPickImages: _pickImages,
                onPickVideo: _pickVideo,
                onPickDate: _pickDate,
              ),

              // ==================================================
              // IMAGE PREVIEWS
              // ==================================================

              if (_retainedImages.isNotEmpty ||
                  _newImages.isNotEmpty)
                ProjectImagePreviews(
                  retainedUrls: _retainedImages,
                  newImages: _newImages,
                  onRemoveRetained: (url) {
                    setState(
                          () => _retainedImages.remove(url),
                    );
                  },
                  onRemoveNew: (file) {
                    setState(
                          () => _newImages.remove(file),
                    );
                  },
                ),

              // ==================================================
              // VIDEO
              // ==================================================

              if (_video != null || _retainVideo)
                ProjectVideoSelection(
                  label: _video?.name ?? 'Current video',
                  onRemove: () {
                    setState(() {
                      _video = null;
                      _retainVideo = false;
                    });
                  },
                ),

              // ==================================================
              // COMPLETED DATE
              // ==================================================

              if (_completedAt case final date?)
                Padding(
                  padding: const EdgeInsets.only(
                    top: 12,
                  ),
                  child: Text(
                    'Completed: '
                        '${date.toLocal().toString().split(' ').first}',
                  ),
                ),

              const SizedBox(height: 24),

              // ==================================================
              // ACTIONS
              // ==================================================

              Row(
                children: [
                  TextButton(
                    onPressed: _isSubmitting
                        ? null
                        : () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),

                  const Spacer(),

                  FilledButton(
                    onPressed:
                    _isSubmitting ? null : _submit,
                    child: Text(
                      _isSubmitting
                          ? 'Uploading…'
                          : widget.project == null
                          ? 'Create project'
                          : 'Save changes',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );

  String? _required(String? value) {
    return value == null ||
        value.trim().isEmpty
        ? 'Required'
        : null;
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (date != null) {
      setState(() {
        _completedAt = date;
      });
    }
  }
}