import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/watchlater.dart';



class WatchLaterScreen extends StatefulWidget {
  const WatchLaterScreen({Key? key}) : super(key: key);

  @override
  _WatchLaterScreenState createState() => _WatchLaterScreenState();
}

class _WatchLaterScreenState extends State<WatchLaterScreen> {
  List<WatchLaterModel> _watchLaterMovies = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchWatchLaterMovies();
  }

  void _fetchWatchLaterMovies() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final snapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('watchLater')
            .orderBy('addedAt', descending: true)
            .get();

        setState(() {
          _watchLaterMovies = snapshot.docs
              .map((doc) => WatchLaterModel.fromMap(doc.data()))
              .toList();
          _isLoading = false;
        });
      } catch (e) {
        print('Error fetching watch later movies: $e');
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _removeFromWatchLater(WatchLaterModel movie) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('watchLater')
            .doc(movie.movieId)
            .delete();

        setState(() {
          _watchLaterMovies.remove(movie);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Removed from Watch Later')),
        );
      } catch (e) {
        print('Error removing from watch later: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Watch Later'),
        backgroundColor: Colors.red,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _watchLaterMovies.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.watch_later_outlined, size: 100, color: Colors.grey),
                      SizedBox(height: 20),
                      Text(
                        'No movies saved for later',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: _watchLaterMovies.length,
                  itemBuilder: (context, index) {
                    final movie = _watchLaterMovies[index];
                    return Dismissible(
                      key: Key(movie.movieId),
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        child: Padding(
                          padding: EdgeInsets.only(right: 20),
                          child: Icon(Icons.delete, color: Colors.white),
                        ),
                      ),
                      direction: DismissDirection.endToStart,
                      onDismissed: (direction) {
                        _removeFromWatchLater(movie);
                      },
                      child: ListTile(
                        leading: Image.network(
                          movie.posterUrl,
                          width: 50,
                          height: 75,
                          fit: BoxFit.cover,
                        ),
                        title: Text(movie.title),
                        subtitle: Row(
                          children: [
                            Icon(Icons.star, color: Colors.amber, size: 16),
                            Text(movie.rating.toString()),
                          ],
                        ),
                        trailing: IconButton(
                          icon: Icon(Icons.remove_circle_outline, color: Colors.red),
                          onPressed: () => _removeFromWatchLater(movie),
                        ),
                        onTap: () {
                          // Navigate to movie details
                          // You'll need to modify this to work with your Movie model
                          // Assuming you can fetch full movie details by ID
                        },
                      ),
                    );
                  },
                ),
    );
  }
}