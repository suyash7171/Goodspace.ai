import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';
import '../widgets/post_card.dart';
import '../blocs/feed_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'profile_screen.dart';
import 'explore_screen.dart';
import 'comments_screen.dart';
import 'post_create_screen.dart';

class HomeFeedScreen extends StatefulWidget {
  const HomeFeedScreen({Key? key}) : super(key: key);

  @override
  State<HomeFeedScreen> createState() => _HomeFeedScreenState();
}

class _HomeFeedScreenState extends State<HomeFeedScreen> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ExploreScreen()),
      );
    } else if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ProfileScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => FeedBloc()..add(LoadFeed()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Goodspace Feed'),
          elevation: 0,
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
        ),
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFe0eafc), Color(0xFFcfdef3)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: BlocBuilder<FeedBloc, FeedState>(
            builder: (context, state) {
              if (state is FeedLoading) {
                return ListView.builder(
                  itemCount: 4,
                  itemBuilder: (context, index) => Shimmer.fromColors(
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[100]!,
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      height: 320,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                );
              } else if (state is FeedLoaded) {
                return RefreshIndicator(
                  onRefresh: () async {
                    context.read<FeedBloc>().add(LoadFeed());
                  },
                  child: ListView.builder(
                    itemCount: state.posts.length,
                    itemBuilder: (context, index) {
                      final post = state.posts[index];
                      return PostCard(
                        imageUrl: post['imageUrl'] ?? '',
                        caption: post['caption'] ?? '',
                        userName: post['userName'] ?? 'Unknown',
                        profilePic: post['profilePic'] ?? '',
                        likes: (post['likes'] is List) ? post['likes'].length : 0,
                        isLiked: (post['likes'] is List && FirebaseAuth.instance.currentUser != null)
                            ? post['likes'].contains(FirebaseAuth.instance.currentUser!.uid)
                            : false,
                        onLike: () {
                          context.read<FeedBloc>().add(LikePost(post['id']));
                        },
                        onUnlike: () {
                          context.read<FeedBloc>().add(UnlikePost(post['id']));
                        },
                        onComment: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CommentsScreen(postId: post['id']),
                            ),
                          );
                        },
                      );
                    },
                  ),
                );
              } else if (state is FeedError) {
                return Center(child: Text('Error: ${state.message}'));
              } else {
                return const SizedBox();
              }
            },
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const PostCreateScreen()),
            );
          },
          backgroundColor: Colors.blueAccent,
          child: const Icon(Icons.add_a_photo),
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Feed',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.explore),
              label: 'Explore',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
