import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../superscreen/playlist_detailsscreen.dart';

class PlaylistScreen extends StatefulWidget {
  const PlaylistScreen({Key? key}) : super(key: key);

  @override
  _PlaylistScreenState createState() => _PlaylistScreenState();
}

class _PlaylistScreenState extends State<PlaylistScreen> {
  final TextEditingController _playlistNameController = TextEditingController();

  // Create a new playlist
  void _createNewPlaylist() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please log in to create a playlist')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Create New Playlist'),
          content: TextField(
            controller: _playlistNameController,
            decoration: InputDecoration(
              hintText: 'Enter playlist name',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                String playlistName = _playlistNameController.text.trim();
                if (playlistName.isNotEmpty) {
                  try {
                    // Create playlist in Firestore
                    await FirebaseFirestore.instance
                        .collection('users')
                        .doc(user.uid)
                        .collection('playlists')
                        .add({
                      'name': playlistName,
                      'createdAt': Timestamp.now(),
                      'movies': [],
                    });

                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Playlist created successfully')),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to create playlist')),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Playlist name cannot be empty')),
                  );
                }
              },
              child: Text('Create'),
            ),
          ],
        );
      },
    );
  }

  // Delete a playlist
  void _deletePlaylist(String playlistId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('playlists')
          .doc(playlistId)
          .delete();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Playlist deleted successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete playlist')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text('My Playlists'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: _createNewPlaylist,
          ),
        ],
      ),
      body: user == null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Please log in to view your playlists'),
                  ElevatedButton(
                    onPressed: () {
                      // Navigate to login screen
                      // Navigator.push(context, MaterialPageRoute(builder: (context) => LoginScreen()));
                    },
                    child: Text('Login'),
                  ),
                ],
              ),
            )
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(user.uid)
                  .collection('playlists')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Text(
                      'No playlists found. Create your first playlist!',
                      textAlign: TextAlign.center,
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    var playlist = snapshot.data!.docs[index];
                    return Dismissible(
                      key: Key(playlist.id),
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
                              title: Text('Confirm Delete'),
                              content: Text('Are you sure you want to delete this playlist?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(false),
                                  child: Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(true),
                                  child: Text('Delete'),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      onDismissed: (direction) {
                        _deletePlaylist(playlist.id);
                      },
                      child: ListTile(
                        title: Text(playlist['name'] ?? 'Unnamed Playlist'),
                        subtitle: FutureBuilder<QuerySnapshot>(
                          future: FirebaseFirestore.instance
                              .collection('users')
                              .doc(user.uid)
                              .collection('playlists')
                              .doc(playlist.id)
                              .collection('movies')
                              .get(),
                          builder: (context, movieSnapshot) {
                            if (movieSnapshot.connectionState == ConnectionState.waiting) {
                              return Text('Loading...');
                            }

                            int movieCount = movieSnapshot.data?.docs.length ?? 0;
                            return Text('$movieCount movies');
                          },
                        ),
                        trailing: Icon(Icons.chevron_right),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PlaylistDetailsScreen(
                                playlistId: playlist.id,
                                playlistName: playlist['name'] ?? 'Unnamed Playlist',
                              ),
                            ),
                          );
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