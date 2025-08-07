import 'package:cloud_firestore/cloud_firestore.dart';

class PostModel {
  final String postId;
  final String userId;
  final String imageUrl;
  final String caption;
  final List<String> likes;
  final DateTime createdAt;
  final List<String> hashtags;

  PostModel({
    required this.postId,
    required this.userId,
    required this.imageUrl,
    required this.caption,
    required this.likes,
    required this.createdAt,
    required this.hashtags,
  });

  factory PostModel.fromMap(Map<String, dynamic> map) {
    return PostModel(
      postId: map['postId'] ?? '',
      userId: map['userId'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      caption: map['caption'] ?? '',
      likes: List<String>.from(map['likes'] ?? []),
      createdAt: map['createdAt'] is Timestamp
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.tryParse(map['createdAt'].toString()) ?? DateTime.now(),
      hashtags: List<String>.from(map['hashtags'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'postId': postId,
      'userId': userId,
      'imageUrl': imageUrl,
      'caption': caption,
      'likes': likes,
      'createdAt': createdAt,
      'hashtags': hashtags,
    };
  }
}
