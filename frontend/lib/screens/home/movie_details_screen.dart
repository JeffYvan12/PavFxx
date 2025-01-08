import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:share_plus/share_plus.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/movie.dart';

class MovieDetailsScreen extends StatefulWidget {
  final Movie movie;
  final Function(String) onDownload; // Callback function to handle download

  const MovieDetailsScreen({Key? key, required this.movie, required this.onDownload}) : super(key: key);

  @override
  _MovieDetailsScreenState createState() => _MovieDetailsScreenState();
}

class _MovieDetailsScreenState extends State<MovieDetailsScreen> {
  bool _isDarkMode = false;
  bool _isLiked = false; // To track if the movie is liked
  int _likeCount = 0; // To track number of likes
  final TextEditingController _commentController = TextEditingController();
  final List<Map<String, dynamic>> _comments = []; // Local comments list

  @override
  void initState() {
    super.initState();
    _fetchLikeStatus();
    _fetchComments();
    _fetchLikeCount();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _shareMovie() {
    final String shareText = '''
Check out this movie: ${widget.movie.title}
Description: ${widget.movie.description}
Rating: ${widget.movie.rating}
Watch the trailer: ${widget.movie.videoUrls.isNotEmpty ? widget.movie.videoUrls[0] : 'No trailer available'}
''';
    Share.share(shareText);
  }

  void _toggleDarkMode() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
  }

  void _downloadMovie() {
    widget.onDownload(widget.movie.title); // Call the download function
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${widget.movie.title} downloaded!')),
    );
  }

  void _toggleLike() {
    setState(() {
      _isLiked = !_isLiked;
      _updateLikeStatus();
    });
  }

  void _fetchLikeStatus() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final snapshot = await FirebaseFirestore.instance
          .collection('movies')
          .doc(widget.movie.id)
          .collection('likes')
          .doc(user.uid)
          .get();
      setState(() {
        _isLiked = snapshot.exists;
      });
    }
  }

  void _updateLikeStatus() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      FirebaseFirestore.instance
          .collection('movies')
          .doc(widget.movie.id)
          .collection('likes')
          .doc(user.uid)
          .set({
        'liked': _isLiked,
        'timestamp': FieldValue.serverTimestamp(),
      }).then((_) {
        _fetchLikeCount(); // Update like count after toggling
      });
    }
  }

  void _fetchLikeCount() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('movies')
        .doc(widget.movie.id)
        .collection('likes')
        .get();
    setState(() {
      _likeCount = snapshot.docs.length;
    });
  }

  void _fetchComments() {
    FirebaseFirestore.instance
        .collection('movies')
        .doc(widget.movie.id)
        .collection('comments')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .listen((snapshot) {
      setState(() {
        _comments.clear();
        for (final doc in snapshot.docs) {
          _comments.add({
            'comment': doc['comment'],
            'username': doc['username'],
          });
        }
      });
    });
  }

  void _addComment() async {
    if (_commentController.text.isNotEmpty) {
      final user = await FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance.collection('movies')
            .doc(widget.movie.id)
            .collection('comments')
            .add({
          'comment': _commentController.text,
          'username': user.displayName ?? user.email!.split('@')[0],
          'timestamp': FieldValue.serverTimestamp(),
        });
        _commentController.clear(); // Clear the input field
      }
    }
  }

  void _playTrailer() {
    if (widget.movie.videoUrls.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => VideoPlayerScreen(
            videoUrl: widget.movie.videoUrls[0],
            videoTitle: widget.movie.title,
            videoDescription: widget.movie.description,
            videoSource: '', // Optional, add if needed
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color backgroundColor = _isDarkMode ? Colors.black : Colors.white;
    final Color textColor = _isDarkMode ? Colors.white : Colors.black;
    final Color buttonColor = _isDarkMode ? Colors.redAccent : Colors.red;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.movie.title, style: TextStyle(color: textColor)),
        backgroundColor: buttonColor,
        actions: [
          IconButton(
            icon: Icon(
              _isDarkMode ? Icons.light_mode : Icons.dark_mode,
              color: textColor,
            ),
            onPressed: _toggleDarkMode,
          ),
          IconButton(
            icon: Icon(Icons.share, color: textColor),
            onPressed: _shareMovie,
          ),
        ],
      ),
      body: Container(
        color: backgroundColor,
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.network(
                widget.movie.photoUrls.isNotEmpty ? widget.movie.photoUrls[0] : '',
                fit: BoxFit.cover,
                height: 200,
                width: double.infinity,
                errorBuilder: (context, error, stackTrace) {
                  return const Center(child: Text('Image not available', style: TextStyle(color: Colors.red)));
                },
              ),
              const SizedBox(height: 16.0),
              Text(widget.movie.title, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: textColor)),
              const SizedBox(height: 8.0),
              Text(widget.movie.description, style: TextStyle(fontSize: 16, color: textColor)),
              const SizedBox(height: 8.0),
              Text("Genre: ${widget.movie.genre}", style: TextStyle(color: textColor)),
              Text("Director: ${widget.movie.director}", style: TextStyle(color: textColor)),
              Text("Release Date: ${widget.movie.releaseDate}", style: TextStyle(color: textColor)),
              Text("Rating: ${widget.movie.rating.toString()}", style: TextStyle(color: textColor)),
              const SizedBox(height: 16.0),

              // Like Button and Count
              Row(
                children: [
                  IconButton(
                    icon: Icon(
                      _isLiked ? Icons.favorite : Icons.favorite_border,
                      color: _isLiked ? Colors.red : textColor,
                    ),
                    onPressed: _toggleLike,
                  ),
                  Text('$_likeCount', style: TextStyle(color: textColor)),
                ],
              ),

              // Watch Trailer Button
              if (widget.movie.videoUrls.isNotEmpty)
                ElevatedButton(
                  onPressed: _playTrailer,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                  child: const Text('Watch Trailer', style: TextStyle(color: Colors.white)),
                ),

              // Comments Section
              const SizedBox(height: 16),
              Text("Comments:", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textColor)),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _comments.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(_comments[index]['comment'], style: TextStyle(color: textColor)),
                    subtitle: Text(_comments[index]['username'], style: TextStyle(color: textColor)),
                  );
                },
              ),

              // Comment Input
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _commentController,
                      decoration: InputDecoration(
                        labelText: 'Add a comment',
                        labelStyle: TextStyle(color: textColor),
                        enabledBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey),
                        ),
                      ),
                      style: TextStyle(color: textColor),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.send, color: buttonColor),
                    onPressed: _addComment,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class VideoPlayerScreen extends StatefulWidget {
 final String videoUrl;
 final String videoTitle;
 final String videoDescription;
 final String videoSource;

 const VideoPlayerScreen({
   Key? key,
   required this.videoUrl,
   required this.videoTitle,
   required this.videoDescription,
   required this.videoSource,
 }) : super(key: key);

 @override
 _VideoPlayerScreenState createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
 late VideoPlayerController _controller;
 bool _isInitialized = false;
 bool _hasError = false;

 @override
 void initState() {
   super.initState();
   _initializeVideoPlayer();
 }

 @override
 void dispose() {
   _controller.dispose();
   super.dispose();
 }

 void _initializeVideoPlayer() {
   // Validate and clean the video URL
   String cleanUrl = _sanitizeVideoUrl(widget.videoUrl);

   _controller = VideoPlayerController.network(cleanUrl)
     ..initialize().then((_) {
       setState(() {
         _isInitialized = true;
       });
       _controller.play();
     }).catchError((error) {
       print('Video initialization error: $error');
       setState(() {
         _hasError = true;
       });
       ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(content: Text('Failed to load video: $error')),
       );
     });
 }

 String _sanitizeVideoUrl(String url) {
   // Remove Google Drive view link and convert to direct download
   if (url.contains('drive.google.com/file/d/')) {
     final id = url.split('/d/')[1].split('/')[0];
     return 'https://drive.google.com/uc?export=download&id=$id';
   }

   // Add more URL sanitization if needed
   return url;
 }

 @override
 Widget build(BuildContext context) {
   return Scaffold(
     appBar: AppBar(
       title: Text(widget.videoTitle),
     ),
     body: _hasError
         ? Center(
             child: Column(
               mainAxisAlignment: MainAxisAlignment.center,
               children: [
                 const Text('Failed to load video'),
                 Text('URL: ${widget.videoUrl}'),
               ],
             ),
           )
         : _isInitialized
             ? Center(
                 child: AspectRatio(
                   aspectRatio: _controller.value.aspectRatio,
                   child: VideoPlayer(_controller),
                 ),
               )
             : const Center(child: CircularProgressIndicator()),
   );
 }
}