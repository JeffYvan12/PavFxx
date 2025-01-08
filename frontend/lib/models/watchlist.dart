import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:PavFlix/models/movie.dart';

class Watchlist {
  final String userId; // User ID for who owns the watchlist
  final String name; // Name of the watchlist
  final List<String> movieIds; // List of movie document IDs in Firestore

  Watchlist({
    required this.userId,
    required this.name, // Include name in the constructor
    required this.movieIds,
  });

  // Get all movies from the watchlist based on movieIds
  Future<List<Movie>> getMovies(FirebaseFirestore firestore) async {
    List<Movie> movies = [];
    for (String movieId in movieIds) {
      // Get the document snapshot for the movie
      DocumentSnapshot<Map<String, dynamic>> movieSnapshot =
          await firestore.collection('movies').doc(movieId).get();
      if (movieSnapshot.exists) {
        // Create a Movie object from the snapshot
        Movie movie = Movie.fromSnapshot(movieSnapshot);
        movies.add(movie);
      }
    }
    return movies;
  }

  // Add a movie to the watchlist (updates Firestore)
  Future<void> addMovie(FirebaseFirestore firestore, String movieId) async {
    // Check if movie already exists in the watchlist
    if (!movieIds.contains(movieId)) {
      // Add the movie ID to the watchlist
      movieIds.add(movieId);
      // Update the watchlist document in Firestore
      await firestore.collection('watchlists').doc(userId).update({
        'movieIds': movieIds,
      });
    }
  }

  // Remove a movie from the watchlist (updates Firestore)
  Future<void> removeMovie(FirebaseFirestore firestore, String movieId) async {
    // Remove the movie ID from the watchlist
    movieIds.remove(movieId);
    // Update the watchlist document in Firestore
    await firestore.collection('watchlists').doc(userId).update({
      'movieIds': movieIds,
    });
  }

  // Create a Watchlist object from a Firestore document snapshot
  factory Watchlist.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> doc) {
    return Watchlist(
      userId: doc['userId'],
      name: doc['name'], // Retrieve name from the snapshot
      movieIds: List<String>.from(doc['movieIds']),
    );
  }

  // Optional: Convert Watchlist to a Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'name': name, // Include name in the map
      'movieIds': movieIds,
    };
  }

  static Watchlist fromJson(Map<String, dynamic> json) {
    return Watchlist(
      userId: json['userId'],
      name: json['name'], // Include name in JSON parsing
      movieIds: List<String>.from(json['movieIds']),
    );
  }
}