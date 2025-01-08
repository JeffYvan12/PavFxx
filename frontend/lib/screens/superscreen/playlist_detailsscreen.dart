import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';



class PlaylistDetailsScreen extends StatefulWidget {
  final String playlistId;
  final String playlistName;

  const PlaylistDetailsScreen({
    Key? key,
    required this.playlistId,
    required this.playlistName,
  }) : super(key: key);

  @override
  _PlaylistDetailsScreenState createState() => _PlaylistDetailsScreenState();
}

class _PlaylistDetailsScreenState extends State<PlaylistDetailsScreen> {
  // Remove a movie from the playlist
  void _removeMovieFromPlaylist(String movieId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('playlists')
          .doc(widget.playlistId)
          .collection('movies')
          .doc(movieId)
          .delete();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Movie removed from playlist')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to remove movie')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.playlistName),
      ),
      body: user == null
          ? Center(child: Text('Please log in to view playlist details'))
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(user.uid)
                  .collection('playlists')
                  .doc(widget.playlistId)
                  .collection('movies')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Text(
                      'No movies in this playlist',
                      textAlign: TextAlign.center,
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    var movieData = snapshot.data!.docs[index];
                    
                    return Dismissible(
                      key: Key(movieData.id),
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Icon(
                          Icons.delete,
                          color: Colors.white,
                        ),
                      ),
                      direction: DismissDirection.endToStart,
                      confirmDismiss: (direction) async {
                        return await showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text('Remove Movie'),
                              content: Text('Are you sure you want to remove this movie from the playlist?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(false),
                                  child: Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(true),
                                  child: Text('Remove'),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      onDismissed: (direction) {
                        _removeMovieFromPlaylist(movieData.id);
                      },
                      child: ListTile(
                        leading: movieData['posterUrl'] != null
                            ? Image.network(
                                movieData['posterUrl'],
                                width: 50,
                                height: 75,
                                fit: BoxFit.cover,
                              )
                            : null,
                        title: Text(movieData['title'] ?? 'Unknown Movie'),
                        subtitle: Text('Rating: ${movieData['rating'] ?? 'N/A'}'),
                        trailing: Icon(Icons.more_vert),
                        onTap: () {
                          // TODO: Navigate to movie details
                        },
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}