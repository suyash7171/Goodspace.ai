import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../screens/comments_screen.dart';

class PostDetailScreen extends StatelessWidget {
  final String postId;
  const PostDetailScreen({Key? key, required this.postId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Post'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('posts').doc(postId).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Post not found'));
          }
          final post = snapshot.data!.data() as Map<String, dynamic>;
          final imageUrl = post['imageUrl'] ?? '';
          final caption = post['caption'] ?? '';
          final likes = (post['likes'] is List) ? post['likes'].length : 0;
          final userName = post['userName'] ?? 'Unknown';
          final profilePic = post['profilePicUrl'] ?? '';
          return ListView(
            children: [
              ListTile(
                leading: profilePic.isNotEmpty
                    ? CircleAvatar(backgroundImage: NetworkImage(profilePic), radius: 24)
                    : const CircleAvatar(radius: 24, child: Icon(Icons.person)),
                title: Text(userName, style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
              if (imageUrl.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: Image.network(
                    imageUrl,
                    width: double.infinity,
                    height: 300,
                    fit: BoxFit.cover,
                  ),
                ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(caption, style: const TextStyle(fontSize: 16)),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Row(
                  children: [
                    Icon(Icons.favorite, color: Colors.redAccent, size: 20),
                    const SizedBox(width: 4),
                    Text('$likes'),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.comment, color: Colors.blueAccent),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CommentsScreen(postId: postId),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const Divider(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text('Comments', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              ),
              SizedBox(
                height: 320,
                child: CommentsScreen(postId: postId),
              ),
            ],
          );
        },
      ),
    );
  }
}
