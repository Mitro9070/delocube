import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/capsule_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Получение данных о капсулах
  Future<List<Capsule>> getCapsules() async {
    final QuerySnapshot result = await _firestore.collection('Capsules').get();

    final List<Capsule> capsules = result.docs.map((doc) {
      return Capsule.fromFirestore(doc);
    }).toList();

    return capsules;
  }
}