import 'package:cloud_firestore/cloud_firestore.dart';

class WatchLaterModel {
  final String movieId;
  final String title;
  final String posterUrl;
  final int rating;
  final DateTime addedAt;

  WatchLaterModel({
    required this.movieId,
    required this.title,
    required this.posterUrl,
    required this.rating,
    DateTime? addedAt,
  }) : addedAt = addedAt ?? DateTime.now();

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'movieId': movieId,
      'title': title,
      'posterUrl': posterUrl,
      'rating': rating,
      'addedAt': addedAt,
    };
  }

  // Create from Firestore document
  factory WatchLaterModel.fromMap(Map<String, dynamic> map) {
    return WatchLaterModel(
      movieId: map['movieId'],
      title: map['title'],
      posterUrl: map['posterUrl'],
      rating: map['rating'],
      addedAt: (map['addedAt'] as Timestamp).toDate(),
    );
  }
}