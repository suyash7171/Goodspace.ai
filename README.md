
# Goodspace.ai Flutter Social Media App

A modern Instagram-style social media app built with Flutter and Firebase. Features include:

## Features (Implemented)
- Real-time social feed (posts, images, likes, comments)
- User authentication (Firebase Auth)
- Profile setup and editing
- Explore page: search users by name/username, hashtags, trending topics
- Like/unlike posts
- Add, delete, and like comments
- Follow/unfollow users
- View user profiles and their posts
- Responsive UI with gradients

## Getting Started

### Prerequisites
- Flutter SDK (3.x recommended)
- Firebase project (Firestore, Auth, Storage enabled)

### Setup
1. Clone this repo:
   ```sh
   git clone https://github.com/suyash7103/Goodspace.ai.git
   cd Goodspace.ai
   ```
2. Install dependencies:
   ```sh
   flutter pub get
   ```
3. Add your Firebase config files:
   - `android/app/google-services.json`
   - `ios/Runner/GoogleService-Info.plist`
4. Ensure assets are listed in `pubspec.yaml`:
   ```yaml
   flutter:
     assets:
       - assets/default_profile.png
   ```
5. Run the app:
   ```sh
   flutter run
   ```

## Folder Structure
```
lib/
  blocs/           # BLoC state management
  models/          # Data models (User, Post, Comment)
  repositories/    # Firestore/Firebase logic
  screens/         # UI screens (Feed, Profile, Explore, Comments, etc.)
  services/        # Business logic/services
  widgets/         # Reusable UI widgets
  utils/           # Utility functions
  firebase_options.dart # Firebase config
```

## Firestore Structure
- `users`: User profiles
- `posts`: User posts
- `comments`: Comments per post

## Contributing
Pull requests are welcome! For major changes, please open an issue first to discuss what you would like to change.

## License
MIT

---
Made with ❤️ using Flutter & Firebase.
