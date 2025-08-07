class UserModel {
  final String uid;
  final String email;
  final String name;
  final String bio;
  final String profilePicUrl;
  final int followers;
  final int following;

  UserModel({
    required this.uid,
    required this.email,
    required this.name,
    required this.bio,
    required this.profilePicUrl,
    required this.followers,
    required this.following,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      bio: map['bio'] ?? '',
      profilePicUrl: map['profilePicUrl'] ?? '',
      followers: map['followers'] ?? 0,
      following: map['following'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'bio': bio,
      'profilePicUrl': profilePicUrl,
      'followers': followers,
      'following': following,
    };
  }
}
