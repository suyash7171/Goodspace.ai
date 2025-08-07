import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/post_model.dart';

class PostRepository {
  final _posts = FirebaseFirestore.instance.collection('posts');

  Future<void> createPost(PostModel post) async {
    await _posts.doc(post.postId).set(post.toMap());
  }

  Stream<List<PostModel>> getPostsStream() {
    return _posts.orderBy('createdAt', descending: true).snapshots().map(
      (snapshot) => snapshot.docs.map((doc) => PostModel.fromMap(doc.data())).toList(),
    );
  }
}
