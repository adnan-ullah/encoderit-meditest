import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

/// Realtime Database disk persistence / keepSynced are not supported on web.
void enableFirebaseDbPersistence() {
  if (kIsWeb) return;
  FirebaseDatabase.instance.setPersistenceEnabled(true);
}

void keepDbSynced(DatabaseReference ref) {
  if (kIsWeb) return;
  ref.keepSynced(true);
}
