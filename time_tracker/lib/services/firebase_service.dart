import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  // Configuration Firebase
  static final FirebaseOptions firebaseOptions = FirebaseOptions(
    apiKey: 'AIzaSyBtGdDM0RbjEKpNKYsoe-k4-yeU7g-xUTw',
    appId: '1:201416967335:web:XXXXXXXXXXXXXXX', 
    messagingSenderId: '201416967335',
    projectId: 'timetracker-c8392',
    storageBucket: 'timetracker-c8392.appspot.com',
  );

  // Initialiser Firebase
  static Future<void> initializeFirebase() async {
    await Firebase.initializeApp(options: firebaseOptions);
  }

  // Sauvegarder les données de temps dans Firestore
  static Future<void> saveTimeRecord(Map<String, dynamic> timeData) async {
    try {
      await FirebaseFirestore.instance.collection('time_records').add(timeData);
    } catch (e) {
      print('Erreur lors de la sauvegarde des données: $e');
      rethrow;
    }
  }
}
