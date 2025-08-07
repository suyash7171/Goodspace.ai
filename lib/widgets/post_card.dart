import 'package:flutter/material.dart';

class PostCard extends StatelessWidget {
  final String imageUrl;
  final String caption;
  final String userName;
  final String profilePic;
  final int likes;
  final VoidCallback? onLike;
  final VoidCallback? onUnlike;
  final VoidCallback? onComment;
  final bool isLiked;

  const PostCard({
    Key? key,
    required this.imageUrl,
    required this.caption,
    required this.userName,
    required this.profilePic,
    required this.likes,
    this.onLike,
    this.onUnlike,
    this.onComment,
    this.isLiked = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 6,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            child: (imageUrl.isNotEmpty)
                ? Image.network(
                    imageUrl,
                    height: 220,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, progress) {
                      if (progress == null) return child;
                      return Container(
                        height: 220,
                        color: Colors.grey[200],
                        child: const Center(child: CircularProgressIndicator()),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 220,
                        color: Colors.grey[300],
                        child: const Center(child: Icon(Icons.broken_image, size: 60)),
                      );
                    },
                  )
                : Container(
                    height: 220,
                    width: double.infinity,
                    color: Colors.grey[300],
                    child: const Center(child: Icon(Icons.image, size: 60)),
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundImage: (profilePic.isNotEmpty)
                      ? NetworkImage(profilePic)
                      : const AssetImage('assets/default_profile.png') as ImageProvider,
                  radius: 22,
                ),
                const SizedBox(width: 10),
                Text(userName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const Spacer(),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        isLiked ? Icons.favorite : Icons.favorite_border,
                        color: Colors.redAccent,
                      ),
                      onPressed: isLiked ? onUnlike : onLike,
                    ),
                    Text('$likes', style: const TextStyle(color: Colors.redAccent)),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.comment_outlined, color: Colors.blueAccent),
                  onPressed: onComment,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4),
            child: Text(caption, style: const TextStyle(fontSize: 15)),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
