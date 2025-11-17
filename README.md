# Local Service Finder


A Flutter mobile application that connects users with local service providers instantly.

## Features

### ✅ **Authentication System**
- **Login Screen**: Email/password authentication with validation
- **Signup Screen**: Complete registration form with terms acceptance
- **Splash Screen**: Professional app loading screen
- **Session Management**: Simple authentication state management

### ✅ **Service Discovery**
- **Category Browser**: Browse services by category (Plumbing, Electrical, Cleaning, etc.)
- **Service Provider List**: View all providers in each category
- **Search Functionality**: Search providers by name, category, or services
- **Provider Details**: Complete provider information with contact details

### ✅ **Contact & Communication**
- **Direct Calling**: One-tap phone calls to service providers
- **Email Integration**: Send emails directly to providers
- **Contact Information**: Full contact details display

### ✅ **User Experience**
- **Favorites System**: Bookmark favorite service providers
- **Reviews & Ratings**: View provider ratings and customer reviews
- **Availability Status**: See if providers are currently available
- **Simple UI**: Clean, intuitive interface for easy navigation

### ✅ **Data Management**
- **Mock Data**: Pre-populated with sample service providers
- **Service Categories**: 8 different service categories
- **Provider Profiles**: Complete provider information
- **Review System**: Customer reviews and ratings

## Getting Started

### Prerequisites
- Flutter SDK (3.8.1 or higher)
- Dart SDK
- Android Studio / VS Code with Flutter extensions

### Installation
1. Clone the repository
2. Navigate to the project directory
3. Run `flutter pub get` to install dependencies
4. Run `flutter run` to start the app

### Project Structure
```
lib/
├── main.dart                    # App entry point
├── models/
│   └── service_provider.dart    # Data models
├── data/
│   └── mock_data.dart          # Sample data
├── services/
│   ├── auth_service.dart       # Authentication logic
│   └── favorites_service.dart  # Favorites management
└── screens/
    ├── splash_screen.dart      # App splash screen
    ├── home_screen.dart        # Main home screen
    ├── search_screen.dart      # Search functionality
    ├── favorites_screen.dart   # Favorites list
    ├── providers_list_screen.dart  # Provider listings
    ├── provider_detail_screen.dart # Provider details
    └── auth/
        ├── login_screen.dart   # Login UI
        └── signup_screen.dart  # Signup UI
```

## Current Status
- ✅ Complete authentication system
- ✅ Service discovery and browsing
- ✅ Search functionality
- ✅ Contact integration (phone/email)
- ✅ Favorites system
- ✅ Reviews and ratings display
- ✅ Simple, clean UI design

## App Flow
1. **Splash Screen** → Shows app branding
2. **Login/Signup** → User authentication
3. **Home Screen** → Browse service categories
4. **Provider List** → View providers in selected category
5. **Provider Detail** → Complete provider information
6. **Search** → Find specific services or providers
7. **Favorites** → Manage bookmarked providers

## Key Features
- **Simple UI**: Clean, intuitive design
- **Full Functionality**: All core features implemented
- **Mock Data**: Pre-populated with sample providers
- **Contact Integration**: Direct calling and email
- **Favorites**: Bookmark favorite providers
- **Search**: Find services by name or category
=======
A small Flutter app that lists local service providers (electrician, plumber, carpenter, builder, etc.) and lets users call them. The provider list is read-only.

Quick start
1. flutter pub get
2. flutter run

Screenshots: add images to screenshots/ if you want to show the UI.

Call example (uses url_launcher):
```dart
import 'package:url_launcher/url_launcher.dart';

Future<void> callNumber(String number) async {
  final uri = Uri(scheme: 'tel', path: number);
  if (!await launchUrl(uri)) throw 'Could not launch $uri';
}
```
>>>>>>> 126046072e52773cdde6c0583aa824d555ead61a
