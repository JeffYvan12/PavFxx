import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';
import 'dart:io';

class DownloadScreen extends StatefulWidget {
  final List<String> downloadedMovies;

  DownloadScreen({Key? key, required this.downloadedMovies}) : super(key: key);

  @override
  _DownloadScreenState createState() => _DownloadScreenState();
}

class _DownloadScreenState extends State<DownloadScreen> {
  int _downloadProgress = 0;
  bool _isDownloading = false;
  late VideoPlayerController _videoController;
  String? _taskId;

  @override
  void initState() {
    super.initState();
    if (widget.downloadedMovies.isNotEmpty) {
      _initializeVideoPlayer(widget.downloadedMovies.first);
    }
  }

  Future<void> _initializeVideoPlayer(String fileName) async {
    final appDocDir = await getApplicationDocumentsDirectory();
    final videoFile = File('${appDocDir.path}/$fileName');

    _videoController = VideoPlayerController.file(videoFile);
    await _videoController.initialize();
    setState(() {});
  }

  @override
  void dispose() {
    _videoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          'Downloads',
          style: TextStyle(color: Colors.red, fontSize: 24, fontWeight: FontWeight.bold),
        ),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.downloadedMovies.isNotEmpty)
              if (_videoController.value.isInitialized)
                AspectRatio(
                  aspectRatio: _videoController.value.aspectRatio,
                  child: VideoPlayer(_videoController),
                )
              else
                Center(
                  child: CircularProgressIndicator(),
                )
            else
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.cloud_download, color: Colors.grey[600], size: 100),
                    SizedBox(height: 20),
                    Text(
                      'No downloaded movies',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: _videoController.value.isInitialized
          ? FloatingActionButton(
              onPressed: () {
                setState(() {
                  _videoController.value.isPlaying
                      ? _videoController.pause()
                      : _videoController.play();
                });
              },
              backgroundColor: Colors.red,
              child: Icon(
                _videoController.value.isPlaying ? Icons.pause : Icons.play_arrow,
                color: Colors.white,
              ),
            )
          : null,
    );
  }
}