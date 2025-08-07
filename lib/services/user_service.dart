import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../repositories/user_repository.dart';

class UserService {
  final _auth = FirebaseAuth.instance;
  final _repo = UserRepository();

  Future<UserModel?> getCurrentUser() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    return await _repo.getUser(user.uid);
  }

  Future<void> setupProfile({required String name, required String bio, required String profilePicUrl}) async {
    final user = _auth.currentUser;
    if (user == null) return;
    final userModel = UserModel(
      uid: user.uid,
      email: user.email ?? '',
      name: name,
      bio: bio,
      profilePicUrl: profilePicUrl,
      followers: 0,
      following: 0,
    );
    await _repo.createUser(userModel);
  }
}
