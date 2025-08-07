import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/comment_model.dart';

class CommentRepository {
  CollectionReference getCommentsRef(String postId) =>
      FirebaseFirestore.instance.collection('posts').doc(postId).collection('comments');

  Future<void> addComment(String postId, CommentModel comment) async {
    await getCommentsRef(postId).doc(comment.commentId).set(comment.toMap());
  }

  Stream<List<CommentModel>> getCommentsStream(String postId) {
    return getCommentsRef(postId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => CommentModel.fromMap(doc.data() as Map<String, dynamic>)).toList());
  }
}
