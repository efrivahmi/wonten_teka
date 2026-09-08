import 'package:flutter/foundation.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';

class FirebaseMessagingService {
  static final FirebaseMessagingService _instance = FirebaseMessagingService._internal();

  factory FirebaseMessagingService() {
    return _instance;
  }

  FirebaseMessagingService._internal();

  Future<void> initialize() async {
    if (kDebugMode) {
      debugPrint('Push notification provider is not configured.');
    }
  }

  Future<String?> getToken() async {
    return null;
  }
}
