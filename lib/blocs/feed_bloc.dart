import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Events
abstract class FeedEvent {}
class LoadFeed extends FeedEvent {}
class LikePost extends FeedEvent {
  final String postId;
  LikePost(this.postId);
}
class UnlikePost extends FeedEvent {
  final String postId;
  UnlikePost(this.postId);
}

// States
abstract class FeedState {}
class FeedLoading extends FeedState {}
class FeedLoaded extends FeedState {
  final List<Map<String, dynamic>> posts;
  FeedLoaded(this.posts);
}
class FeedError extends FeedState {
  final String message;
  FeedError(this.message);
}

class FeedBloc extends Bloc<FeedEvent, FeedState> {
  FeedBloc() : super(FeedLoading()) {
    on<LoadFeed>(_onLoadFeed);
    on<LikePost>(_onLikePost);
    on<UnlikePost>(_onUnlikePost);
  }

  Future<void> _onLoadFeed(LoadFeed event, Emitter<FeedState> emit) async {
    emit(FeedLoading());
    try {
      final snapshot = await FirebaseFirestore.instance.collection('posts').orderBy('createdAt', descending: true).get();
      final posts = snapshot.docs.map((doc) => doc.data()..['id'] = doc.id).toList();
      emit(FeedLoaded(posts));
    } catch (e) {
      emit(FeedError(e.toString()));
    }
  }

  Future<void> _onLikePost(LikePost event, Emitter<FeedState> emit) async {
    try {
      await FirebaseFirestore.instance.collection('posts').doc(event.postId).update({
        'likes': FieldValue.increment(1),
      });
      add(LoadFeed());
    } catch (e) {
      emit(FeedError(e.toString()));
    }
  }

  Future<void> _onUnlikePost(UnlikePost event, Emitter<FeedState> emit) async {
    try {
      await FirebaseFirestore.instance.collection('posts').doc(event.postId).update({
        'likes': FieldValue.increment(-1),
      });
      add(LoadFeed());
    } catch (e) {
      emit(FeedError(e.toString()));
    }
  }
}
