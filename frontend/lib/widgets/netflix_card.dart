import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; 
import 'package:path_provider/path_provider.dart'; // For file storage
import 'dart:io'; // For file handling
import 'package:http/http.dart' as http; // For downloading files
import 'package:share_plus/share_plus.dart';// Add this line for sharing functionality

import '../../models/movie.dart';
import '../../models/watchLater.dart';
import '../../models/playlist.dart';
import '../screens/superscreen/watchlaterscreen.dart';
import '../screens/superscreen/playlistscreen.dart';
import '../screens/superscreen/playlistselect.dart';
import '../screens/superscreen/downloadscreen.dart'; // New screen for downloads

class NetflixCard extends StatelessWidget {
  final Movie movie;
  final VoidCallback onTap;

  const NetflixCard({
    Key? key,
    required this.movie,
    required this.onTap,
  }) : super(key: key);

  void _showMoreOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildListTile(
                context,
                Icons.watch_later,
                'Save to Watch Later',
                () {
                  _saveToWatchLater(context);
                  Navigator.pop(context);
                },
              ),
              _buildListTile(
                context,
                Icons.playlist_add,
                'Add to Playlist',
                () {
                  Navigator.pop(context);
                  _showPlaylistDialog(context);
                },
              ),
              _buildListTile(
                context,
                Icons.share,
                'Share',
                () {
                  _shareMovie(context);
                  Navigator.pop(context);
                },
              ),
              _buildListTile(
                context,
                Icons.download,
                'Download',
                () {
                  _downloadMovie(context);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  ListTile _buildListTile(BuildContext context, IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.red),
      title: Text(title),
      onTap: onTap,
    );
  }

  void _shareMovie(BuildContext context) {
    final String shareContent = 'Check out this movie: ${movie.title}\nWatch it here: ${movie.videoUrls}';
    Share.share(shareContent);
  }

  void _downloadMovie(BuildContext context) async {
    final directory = await getExternalStorageDirectory(); // Get the storage directory
    final filePath = '${directory!.path}/${movie.title}.mp4'; // Create a file path

    try {
      final response = await http.get(Uri.parse(movie.videoUrls as String)); // Download the video
      if (response.statusCode == 200) {
        final File file = File(filePath);
        await file.writeAsBytes(response.bodyBytes); // Save the video to the file

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DownloadScreen(filePath: filePath, movie: movie, title: '',),
          ),
        );
      } else {
        _showSnackBar(context, 'Failed to download video.');
      }
    } catch (e) {
      print('Error downloading video: $e');
      _showSnackBar(context, 'Error downloading video.');
    }
  }

  void _showPlaylistDialog(BuildContext context) {
    final TextEditingController _playlistController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add to Playlist'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _playlistController,
                decoration: InputDecoration(hintText: 'Enter playlist name'),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  _createAndAddToPlaylist(context, _playlistController.text.trim());
                },
                child: Text('Create Playlist'),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PlaylistSelectionScreen(movie: movie),
                    ),
                  );
                },
                child: Text('Select Existing Playlist'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _createAndAddToPlaylist(BuildContext context, String playlistName) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _showSnackBar(context, 'Please log in to create a playlist');
      return;
    }

    if (playlistName.isEmpty) {
      _showSnackBar(context, 'Playlist name cannot be empty');
      return;
    }

    try {
      PlaylistModel playlistModel = PlaylistModel(
        id: '',
        name: playlistName,
        userId: user.uid,
        movies: [movie],
        createdAt: Timestamp.now(),
      );

      final playlistRef = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('playlists')
          .add(playlistModel.toMap());

      await playlistRef.update({'id': playlistRef.id});

      Navigator.pop(context);
      _showSnackBar(context, 'Playlist "$playlistName" created', actionLabel: 'View', action: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => PlaylistScreen()));
      });
    } catch (e) {
      print('Error creating playlist: $e');
      _showSnackBar(context, 'Failed to create playlist');
    }
  }

  void _saveToWatchLater(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final watchLaterMovie = WatchLaterModel(
          movieId: movie.id,
          title: movie.title,
          posterUrl: movie.photoUrls.isNotEmpty ? movie.photoUrls[0] : '',
          rating: movie.rating,
        );

        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('watchLater')
            .doc(movie.id)
            .set(watchLaterMovie.toMap());

        _showSnackBar(context, 'Added to Watch Later', actionLabel: 'View', action: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => WatchLaterScreen()));
        });
      } catch (e) {
        print('Error saving to watch later: $e');
        _showSnackBar(context, 'Failed to add to Watch Later');
      }
    } else {
      _showSnackBar(context, 'Please log in to use Watch Later');
    }
  }

  void _showSnackBar(BuildContext context, String message, {String? actionLabel, VoidCallback? action}) {
    final snackBar = SnackBar(
      content: Text(message),
      action: actionLabel != null && action != null
          ? SnackBarAction(label: actionLabel, onPressed: action)
          : null,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        color: Colors.transparent,
        elevation: 10,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            children: [
              Positioned.fill(
                child: Image.network(
                  movie.photoUrls.isNotEmpty ? movie.photoUrls[0] : '',
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(child: CircularProgressIndicator());
                  },
                ),
              ),
              Positioned(
                bottom: 10,
                left: 10,
                child: _buildMovieInfo(),
              ),
              Positioned(
                top: 10,
                right: 10,
                child: GestureDetector(
                  onTap: () => _showMoreOptions(context),
                  child: _buildMoreOptionsButton(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Column _buildMovieInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          movie.title,
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(blurRadius: 10.0, color: Colors.black, offset: Offset(2.0, 2.0)),
            ],
          ),
        ),
        SizedBox(height: 5),
        _buildRatingStars(),
      ],
    );
  }

  Row _buildRatingStars() {
    int roundedRating = movie.rating.round();
    return Row(
      children: List.generate(
        5,
        (index) => Icon(
          index < roundedRating ? Icons.star : Icons.star_border,
          color: Colors.amber,
          size: 16,
        ),
      ),
    );
  }

  Container _buildMoreOptionsButton() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black54,
        shape: BoxShape.circle,
      ),
      padding: EdgeInsets.all(4),
      child: Icon(
        Icons.more_vert,
        color: Colors.white,
        size: 20,
      ),
    );
  }
}