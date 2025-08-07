import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/comment_model.dart';
import '../repositories/comment_repository.dart';

class CommentsScreen extends StatefulWidget {
  final String postId;
  const CommentsScreen({Key? key, required this.postId}) : super(key: key);

  @override
  State<CommentsScreen> createState() => _CommentsScreenState();
}

class _CommentsScreenState extends State<CommentsScreen> {
  final TextEditingController commentController = TextEditingController();
  final CommentRepository commentRepo = CommentRepository();

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Comments'),
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
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder<List<CommentModel>>(
                stream: commentRepo.getCommentsStream(widget.postId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: \\${snapshot.error}'));
                  }
                  final comments = snapshot.data ?? [];
                  if (comments.isEmpty) {
                    return const Center(child: Text('No comments yet.'));
                  }
                  return ListView.builder(
                    itemCount: comments.length,
                    itemBuilder: (context, index) {
                      final comment = comments[index];
                      return FutureBuilder<DocumentSnapshot>(
                        future: FirebaseFirestore.instance.collection('users').doc(comment.userId).get(),
                        builder: (context, userSnap) {
                          final userData = userSnap.data?.data() as Map<String, dynamic>?;
                          final profilePic = userData?['profilePicUrl'] ?? '';
                          final username = userData?['username'] ?? '';
                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            child: ListTile(
                              leading: profilePic.isNotEmpty
                                  ? CircleAvatar(backgroundImage: NetworkImage(profilePic))
                                  : const CircleAvatar(child: Icon(Icons.person)),
                              title: Row(
                                children: [
                                  Text('@$username ', style: const TextStyle(fontWeight: FontWeight.bold)),
                                  Expanded(child: Text(comment.text)),
                                ],
                              ),
                              subtitle: Text(comment.createdAt.toString()),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(comment.likes.length.toString()),
                                  IconButton(
                                    icon: Icon(
                                      comment.likes.contains(currentUser?.uid)
                                          ? Icons.favorite
                                          : Icons.favorite_border,
                                      color: Colors.redAccent,
                                    ),
                                    onPressed: () async {
                                      final commentsRef = commentRepo.getCommentsRef(widget.postId);
                                      final docRef = commentsRef.doc(comment.commentId);
                                      if (comment.likes.contains(currentUser?.uid)) {
                                        await docRef.update({
                                          'likes': FieldValue.arrayRemove([currentUser?.uid]),
                                        });
                                      } else {
                                        await docRef.update({
                                          'likes': FieldValue.arrayUnion([currentUser?.uid]),
                                        });
                                      }
                                    },
                                  ),
                                  if (comment.userId == currentUser?.uid)
                                    IconButton(
                                      icon: const Icon(Icons.delete, color: Colors.grey),
                                      onPressed: () async {
                                        final commentsRef = commentRepo.getCommentsRef(widget.postId);
                                        await commentsRef.doc(comment.commentId).delete();
                                      },
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: commentController,
                      decoration: InputDecoration(
                        hintText: 'Add a comment...',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () async {
                      if (commentController.text.isNotEmpty && currentUser != null) {
                        final newComment = CommentModel(
                          commentId: DateTime.now().millisecondsSinceEpoch.toString(),
                          postId: widget.postId,
                          userId: currentUser.uid,
                          text: commentController.text,
                          likes: [],
                          createdAt: DateTime.now(),
                        );
                        await commentRepo.addComment(widget.postId, newComment);
                        commentController.clear();
                      }
                    },
                    child: const Text('Send'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
