import 'package:cloud_firestore/cloud_firestore.dart';

class Movie {
  final String id;
  final String title;
  final String description;
  final String genre;
  final String releaseDate;
  final int rating;
  final String director;
  final String overview;
  final List<String> photoUrls;
  final List<String> videoUrls;

  Movie({
    required this.id,
    required this.title,
    required this.description,
    required this.genre,
    required this.releaseDate,
    required this.rating,
    required this.director,
    required this.overview,
    required this.photoUrls,
    required this.videoUrls,
  });

  // Optionally, add a method to convert Firestore documents to Movie instances
  factory Movie.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    return Movie(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      genre: data['genre'] ?? '',
      releaseDate: data['releaseDate'] ?? '',
      rating: data['rating'] ?? 0,
      director: data['director'] ?? '',
      overview: data['overview'] ?? '',
      photoUrls: List<String>.from(data['photoUrls'] ?? []),
      videoUrls: List<String>.from(data['videoUrls'] ?? []),
    );
  }



  static Movie fromSnapshot(DocumentSnapshot<Map<String, dynamic>> movieSnapshot) {
    return Movie(
      id: movieSnapshot.id,
      title: movieSnapshot['title'],
      description: movieSnapshot['description'],
      genre: movieSnapshot['genre'],
      releaseDate: movieSnapshot['releaseDate'],
      rating: movieSnapshot['rating'],
      director: movieSnapshot['director'],
      overview: movieSnapshot['overview'],
      photoUrls: List<String>.from(movieSnapshot['photoUrls']),
      videoUrls: List<String>.from(movieSnapshot['videoUrls']),
    );
  }

  toMap() {
    
  }

}