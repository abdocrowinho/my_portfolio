// Displays a remote project video with native Flutter controls when one is available.
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class ProjectMediaPlayer extends StatefulWidget {
  const ProjectMediaPlayer({required this.videoUrl, super.key});
  final String videoUrl;

  @override
  State<ProjectMediaPlayer> createState() => _ProjectMediaPlayerState();
}

class _ProjectMediaPlayerState extends State<ProjectMediaPlayer> {
  late final VideoPlayerController _controller =
      VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl));

  @override
  void initState() {
    super.initState();
    _controller.initialize().then((_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_controller.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }
    return AspectRatio(
      aspectRatio: _controller.value.aspectRatio,
      child: Stack(
        alignment: Alignment.center,
        children: [
          VideoPlayer(_controller),
          IconButton.filled(
            onPressed: () => setState(
              () => _controller.value.isPlaying
                  ? _controller.pause()
                  : _controller.play(),
            ),
            icon: Icon(
              _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
            ),
          ),
        ],
      ),
    );
  }
}
