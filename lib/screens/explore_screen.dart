import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_1/screens/profile_screen.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({Key? key}) : super(key: key);

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  Future<List<Map<String, dynamic>>> _searchResults(String query) async {
    // Search users by name or username
    final userSnap = await FirebaseFirestore.instance
        .collection('users')
        .where('name', isGreaterThanOrEqualTo: query)
        .where('name', isLessThanOrEqualTo: query + '\uf8ff')
        .get();
    final usernameSnap = await FirebaseFirestore.instance
        .collection('users')
        .where('username', isGreaterThanOrEqualTo: query)
        .where('username', isLessThanOrEqualTo: query + '\uf8ff')
        .get();
    final users = [
      ...userSnap.docs.map((doc) => doc.data()),
      ...usernameSnap.docs.map((doc) => doc.data()),
    ];

    // Search posts by hashtag
    List<Map<String, dynamic>> hashtagPosts = [];
    if (query.startsWith('#')) {
      final tag = query.replaceFirst('#', '');
      final postSnap = await FirebaseFirestore.instance
          .collection('posts')
          .where('hashtags', arrayContains: tag)
          .get();
      hashtagPosts = postSnap.docs.map((doc) => doc.data()).toList();
    }

    // Search popular posts by likes
    List<Map<String, dynamic>> popularPosts = [];
    if (query.toLowerCase() == 'popular') {
      final popSnap = await FirebaseFirestore.instance
          .collection('posts')
          .orderBy('likes', descending: true)
          .limit(10)
          .get();
      popularPosts = popSnap.docs.map((doc) => doc.data()).toList();
    }

    return [...users, ...hashtagPosts, ...popularPosts];
    return users;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Explore'),
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
        child: ListView(
          children: [
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search users or hashtags...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.search),
                ),
                onChanged: (query) {
                  setState(() {
                    _searchQuery = query.trim();
                  });
                },
              ),
            ),
            const SizedBox(height: 24),
            if (_searchQuery.isNotEmpty)
              FutureBuilder<List<Map<String, dynamic>>>(
                future: _searchResults(_searchQuery),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  final results = snapshot.data ?? [];
                  if (results.isEmpty) {
                    return const Center(child: Text('No results found.'));
                  }
                  // Separate user and post results
                  final userResults = results.where((r) => r.containsKey('username')).toList();
                  final postResults = results.where((r) => !r.containsKey('username')).toList();

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (userResults.isNotEmpty)
                        ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: userResults.length,
                          itemBuilder: (context, index) {
                            final user = userResults[index];
                            final profilePic = user['profilePicUrl'] ?? '';
                            final username = user['username'] ?? '';
                            final name = (user['name'] != null && user['name'].toString().trim().isNotEmpty)
                                ? user['name']
                                : username;
                            final userId = user['uid'] ?? user['id'];
                            return Card(
                              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              child: ListTile(
                                leading: profilePic.isNotEmpty
                                    ? CircleAvatar(backgroundImage: NetworkImage(profilePic), radius: 28)
                                    : const CircleAvatar(radius: 28, child: Icon(Icons.person)),
                                title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                                subtitle: Text('@$username', style: const TextStyle(color: Colors.grey)),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ProfileScreen(userId: userId),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        ),
                      if (postResults.isNotEmpty)
                        ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: postResults.length,
                          itemBuilder: (context, index) {
                            final post = postResults[index];
                            final postImage = post['imageUrl'] ?? '';
                            final caption = post['caption'] ?? '';
                            final likes = (post['likes'] is List) ? post['likes'].length : 0;
                            final comments = (post['comments'] is List) ? post['comments'].length : 0;
                            final userName = post['userName'] ?? 'Unknown';
                            final userPic = post['profilePicUrl'] ?? '';
                            return Card(
                              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                              elevation: 5,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ListTile(
                                    leading: userPic.isNotEmpty
                                        ? CircleAvatar(backgroundImage: NetworkImage(userPic), radius: 24)
                                        : const CircleAvatar(radius: 24, child: Icon(Icons.person)),
                                    title: Text(userName, style: const TextStyle(fontWeight: FontWeight.bold)),
                                  ),
                                  if (postImage.isNotEmpty)
                                    ClipRRect(
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(18),
                                        topRight: Radius.circular(18),
                                      ),
                                      child: Image.network(
                                        postImage,
                                        width: double.infinity,
                                        height: 200,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                    child: Text(caption, style: const TextStyle(fontSize: 15)),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                                    child: Row(
                                      children: [
                                        Icon(Icons.favorite, color: Colors.redAccent, size: 20),
                                        const SizedBox(width: 4),
                                        Text('$likes'),
                                        const SizedBox(width: 16),
                                        Icon(Icons.comment, color: Colors.blueAccent, size: 20),
                                        const SizedBox(width: 4),
                                        Text('$comments'),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                ],
                              ),
                            );
                          },
                        ),
                    ],
                  );
                },
              ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text('Trending Hashtags', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: [
                Chip(label: Text('#flutter')),
                Chip(label: Text('#nature')),
                Chip(label: Text('#explore')),
                Chip(label: Text('#goodspace')),
              ],
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text('Popular Posts', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 220,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 4,
                itemBuilder: (context, index) => Card(
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.network(
                      'https://images.unsplash.com/photo-1506744038136-46273834b3fb',
                      width: 160,
                      height: 220,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
