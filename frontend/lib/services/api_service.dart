import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/movie.dart';
import '../models/watchlist.dart';

class ApiService {
  // Define the Firestore collections within the PavApp collection
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  final watchlistCollection = FirebaseFirestore.instance
      .collection("PavApp")
      .doc("watchlists")
      .collection("watchlists")
      .withConverter<Watchlist>(
        fromFirestore: (snapshot, _) => Watchlist.fromSnapshot(snapshot),
        toFirestore: (value, options) => value.toMap(),
      );

  // CREATE: Add a new movie
  Future<void> addMovie(Movie movie) async {
    await _db.collection('movies').add({
      'title': movie.title,
      'description': movie.description,
      'genre': movie.genre,
      'releaseDate': movie.releaseDate,
      'rating': movie.rating,
      'director': movie.director,
      'overview': movie.overview,
      'photoUrls': movie.photoUrls,
      'videoUrls': movie.videoUrls,
    });

     // Create a notification
    await _db.collection('notifications').add({
      'movieTitle': movie.title,
      'message': 'New movie added: ${movie.title}',
      'date': FieldValue.serverTimestamp(),
    });
  }

  // CREATE: Create a new watchlist
  Future<void> createWatchlist(Watchlist watchlist) async {
    try {
      await watchlistCollection.add(watchlist);
    } catch (e) {
      throw Exception('Failed to create watchlist: $e');
    }
  }

  // READ: Get all watchlists
  Stream<List<Watchlist>> getUserWatchlists() {
    return watchlistCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => doc.data()).toList();
    });
  }

  // ADD: Add a movie to an existing watchlist
  Future<void> addToWatchlist(String userId, Movie movie) async {
    await _db.collection('watchlists').doc(userId).collection('items').add({
      'movieId': movie.id,  // Assuming you have an ID for the movie
      'title': movie.title,
      'description': movie.description,
      'genre': movie.genre,
      'releaseDate': movie.releaseDate,
      'rating': movie.rating,
      'director': movie.director,
      'overview': movie.overview,
      'photoUrls': movie.photoUrls,
      'videoUrls': movie.videoUrls,
    });
  }

  // Display on screen
  Stream<List<Movie>> getAllMovies() {
    return _db.collection('movies').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Movie.fromFirestore(doc);
      }).toList();
    });
  }

  // Get movies based on search query
  Future<List<Movie>> searchMovies(String query) async {
    final snapshot = await _db.collection('movies')
        .where('title', isGreaterThanOrEqualTo: query)
        .where('title', isLessThanOrEqualTo: query + '\uf8ff') // To match the query
        .get();

    return snapshot.docs.map((doc) {
      return Movie.fromFirestore(doc);
    }).toList();
  }

  // Display watchlist on screen
  Stream<List<Movie>> getWatchlist(String userId) {
    return _db.collection('watchlists').doc(userId).collection('items').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Movie.fromFirestore(doc); // Ensure Movie.fromFirestore can handle this data
      }).toList();
    });
  }

  
}