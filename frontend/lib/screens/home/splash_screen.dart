import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '/screens/auth/logback.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset('assets/videos/intro_video.mp4')
      ..initialize().then((_) {
        setState(() {}); // Refresh to show the video when it's initialized
      })
      ..setLooping(false) // Play the video once
      ..play();

    // Navigate to the LoginScreen once the video ends
    _controller.addListener(() {
      if (_controller.value.position == _controller.value.duration) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginScreenss()),
        );
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
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: _controller.value.isInitialized
            ? AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: VideoPlayer(_controller),
              )
            : CircularProgressIndicator(color: Colors.redAccent),
      ),
    );
  }
}
