import 'package:PavFlix/models/movie.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PlaylistModel {
  final String id;
  final String name;
  final String userId;
  final List<Movie> movies;
  final Timestamp createdAt;

  PlaylistModel({
    required this.id,
    required this.name,
    required this.userId,
    required this.movies,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'userId': userId,
      'movies': movies.map((movie) => movie.toMap()).toList(),
      'createdAt': createdAt,
    };
  }
  factory PlaylistModel.fromMap(Map<String, dynamic> data) {
    return PlaylistModel(id: data['id'], name: data['name'],userId: data['userid'],movies:data['movie'],createdAt:data['createdAt']);
  }
 
}



