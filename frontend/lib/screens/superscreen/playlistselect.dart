import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/playlist.dart';
import '../../models/movie.dart';// Ensure you have the Playlist model defined

class PlaylistSelectionScreen extends StatelessWidget {
  final Movie movie; // Assume you have a Movie class
  const PlaylistSelectionScreen({Key? key, required this.movie}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Playlist'),
      ),
      body: FutureBuilder<List<PlaylistModel>>(
        future: _fetchPlaylists(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final playlists = snapshot.data ?? [];

          return ListView.builder(
            itemCount: playlists.length,
            itemBuilder: (context, index) {
              final playlist = playlists[index];
              return ListTile(
                title: Text(playlist.name),
                onTap: () => _addToPlaylist(context, playlist),
              );
            },
          );
        },
      ),
    );
  }

  Future<List<PlaylistModel>> _fetchPlaylists() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return [];

    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('playlists')
        .get();

    return snapshot.docs.map((doc) {
      return PlaylistModel.fromMap(doc.data()..['id'] = doc.id);
    }).toList();
  }

  Future<void> _addToPlaylist(BuildContext context, PlaylistModel playlist) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to add to a playlist')),
      );
      return;
    }

    try {
      // Assuming the PlaylistModel has a method to add a movie
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('playlists')
          .doc(playlist.id)
          .update({
        'movies': FieldValue.arrayUnion([movie.toMap()]) // Convert movie to map as needed
      });

      Navigator.pop(context); // Close the screen
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Added to "${playlist.name}" playlist')),
      );
    } catch (e) {
      print('Error adding to playlist: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to add to playlist')),
      );
    }
  }
}


