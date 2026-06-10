import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:flutter/services.dart';

final globalNotificationListenerProvider = Provider<void>((ref) {
  // We don't return anything, just initialize the listener.
  _NotificationService.init();
});

class _NotificationService {
  static bool _initialized = false;
  static Timestamp? _appStartTime;

  static void init() {
    if (_initialized) return;
    _initialized = true;
    _appStartTime = Timestamp.now();

    FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user != null) {
        _listenToNotifications(user.uid);
      }
    });
  }

  static void _listenToNotifications(String uid) {
    FirebaseFirestore.instance
        .collection('notifications')
        .where('userId', isEqualTo: uid)
        .where('createdAt', isGreaterThan: _appStartTime)
        .snapshots()
        .listen((snapshot) {
      for (var change in snapshot.docChanges) {
        if (change.type == DocumentChangeType.added) {
          final data = change.doc.data();
          if (data != null && data['isRead'] == false) {
            _playNotificationSoundAndHaptic();
          }
        }
      }
    });
    
    // Also listen to merchant notifications
    FirebaseFirestore.instance
        .collection('notifications')
        .where('merchantId', isEqualTo: uid)
        .where('createdAt', isGreaterThan: _appStartTime)
        .snapshots()
        .listen((snapshot) {
      for (var change in snapshot.docChanges) {
        if (change.type == DocumentChangeType.added) {
          final data = change.doc.data();
          if (data != null && data['isRead'] == false) {
            _playNotificationSoundAndHaptic();
          }
        }
      }
    });
  }

  static void _playNotificationSoundAndHaptic() {
    // Play default notification sound
    FlutterRingtonePlayer().playNotification();
    // Heavy haptic feedback
    HapticFeedback.heavyImpact();
  }
}
