# Local Service Finder

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
