import 'package:PavFlix/models/movie.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'dart:io';

class DownloadScreen extends StatefulWidget {
  final String filePath;
  final String title;

  const DownloadScreen({Key? key, required this.filePath, required this.title, required Movie movie}) : super(key: key);

  @override
  _DownloadScreenState createState() => _DownloadScreenState();
}

class _DownloadScreenState extends State<DownloadScreen> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(File(widget.filePath))
      ..initialize().then((_) {
        setState(() {}); // Update the UI once the video is initialized
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: _controller.value.isInitialized
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AspectRatio(
                    aspectRatio: _controller.value.aspectRatio,
                    child: VideoPlayer(_controller),
                  ),
                  VideoPlayerControls(controller: _controller),
                ],
              )
            : CircularProgressIndicator(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            _controller.value.isPlaying
                ? _controller.pause()
                : _controller.play();
          });
        },
        child: Icon(
          _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
        ),
      ),
    );
  }
}

class VideoPlayerControls extends StatelessWidget {
  final VideoPlayerController controller;

  const VideoPlayerControls({Key? key, required this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: Icon(controller.value.isPlaying ? Icons.pause : Icons.play_arrow),
          onPressed: () {
            controller.value.isPlaying ? controller.pause() : controller.play();
          },
        ),
        IconButton(
          icon: Icon(Icons.stop),
          onPressed: () {
            controller.pause();
            controller.seekTo(Duration.zero);
          },
        ),
      ],
    );
  }
}