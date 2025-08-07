import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_1/screens/profile_setup_screen.dart';


class ProfileScreen extends StatelessWidget {
  final String? userId;
  const ProfileScreen({Key? key, this.userId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    final profileUserId = userId ?? currentUser?.uid;
    if (profileUserId == null) {
      return const Scaffold(
        body: Center(child: Text('No user found')),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFe0eafc), Color(0xFFcfdef3)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance.collection('users').doc(profileUserId).get(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || !snapshot.data!.exists) {
                    return const Center(child: Text('User data not found'));
                  }
                  final data = snapshot.data!.data() as Map<String, dynamic>;
                  final profilePic = data['profilePicUrl'] ?? '';
                  final name = data['name'] ?? 'Unknown';
                  final bio = data['bio'] ?? '';
                  final followersList = data['followers'] is List ? List<String>.from(data['followers']) : <String>[];
                  final followingList = data['following'] is List ? List<String>.from(data['following']) : <String>[];
                  final followers = followersList.length.toString();
                  final following = followingList.length.toString();
                  final currentUserId = currentUser?.uid ?? '';
                  final isOwnProfile = profileUserId == currentUserId;
                  final isFollowing = followersList.contains(currentUserId);
                  return Column(
                    children: [
                      const SizedBox(height: 32),
                      CircleAvatar(
                        radius: 48,
                        backgroundImage: (profilePic != null && profilePic.isNotEmpty)
                            ? NetworkImage(profilePic)
                            : null,
                        child: (profilePic == null || profilePic.isEmpty)
                            ? const Icon(Icons.person, size: 48)
                            : null,
                      ),
                      const SizedBox(height: 16),
                      Text(name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text(bio, style: const TextStyle(fontSize: 16)),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildStat('Followers', followers),
                          _buildStat('Following', following),
                        ],
                      ),
                      const SizedBox(height: 24),
                      isOwnProfile
                          ? ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blueAccent,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(builder: (context) => ProfileSetupScreen()),
                                );
                              },
                              child: const Text('Edit Profile'),
                            )
                          : ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isFollowing ? Colors.grey : Colors.blueAccent,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              onPressed: () async {
                                final userRef = FirebaseFirestore.instance.collection('users').doc(profileUserId);
                                if (isFollowing) {
                                  await userRef.update({
                                    'followers': FieldValue.arrayRemove([currentUserId]),
                                  });
                                  await FirebaseFirestore.instance.collection('users').doc(currentUserId).update({
                                    'following': FieldValue.arrayRemove([profileUserId]),
                                  });
                                } else {
                                  await userRef.update({
                                    'followers': FieldValue.arrayUnion([currentUserId]),
                                  });
                                  await FirebaseFirestore.instance.collection('users').doc(currentUserId).update({
                                    'following': FieldValue.arrayUnion([profileUserId]),
                                  });
                                }
                              },
                              child: Text(isFollowing ? 'Unfollow' : 'Follow'),
                            ),
                      const SizedBox(height: 24),
                      // Show user's posts
                      Expanded(
                        child: StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('posts')
                              .where('userId', isEqualTo: profileUserId)
                              .orderBy('createdAt', descending: true)
                              .snapshots(),
                          builder: (context, postSnapshot) {
                            if (postSnapshot.connectionState == ConnectionState.waiting) {
                              return const Center(child: CircularProgressIndicator());
                            }
                            if (postSnapshot.hasError) {
                              return Center(child: Text('Error: \\${postSnapshot.error}'));
                            }
                            if (!postSnapshot.hasData || postSnapshot.data!.docs.isEmpty) {
                              return const Center(child: Text('No posts yet.'));
                            }
                            final posts = postSnapshot.data!.docs;
                            return ListView.builder(
                              itemCount: posts.length,
                              itemBuilder: (context, index) {
                                final postDoc = posts[index];
                                final post = postDoc.data() as Map<String, dynamic>;
                                final imageUrl = post['imageUrl'] ?? '';
                                final caption = post['caption'] ?? '';
                                final createdAt = post['createdAt'] != null
                                    ? DateTime.tryParse(post['createdAt'].toString())
                                    : null;
                                return Card(
                                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                  child: ListTile(
                                    leading: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: imageUrl.isNotEmpty
                                          ? Image.network(imageUrl, width: 56, height: 56, fit: BoxFit.cover)
                                          : Container(width: 56, height: 56, color: Colors.grey[300], child: const Icon(Icons.image)),
                                    ),
                                    title: Text(caption),
                                    subtitle: Text(createdAt != null
                                        ? '${createdAt.day}/${createdAt.month}/${createdAt.year}'
                                        : ''),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
      ),
    );
  }

  Widget _buildStat(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }
}
