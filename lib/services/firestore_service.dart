import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String uid = FirebaseAuth.instance.currentUser!.uid;

  Future<void> addIncome(Map<String, dynamic> data) async {
    await _firestore.collection('users').doc(uid).collection('income').add(data);
  }

  Future<void> addExpense(Map<String, dynamic> data) async {
    await _firestore.collection('users').doc(uid).collection('expense').add(data);
  }

  Stream<QuerySnapshot> getIncomes() {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('income')
        .orderBy('income_date', descending: true)
        .snapshots();
  }

  Stream<QuerySnapshot> getExpenses() {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('expense')
        .orderBy('income_date', descending: true)
        .snapshots();
  }

  Future<void> updateIncome(String docId, Map<String, dynamic> data) async {
    final ref = await _firestore
        .collectionGroup('income')
        .where(FieldPath.documentId, isEqualTo: docId)
        .get();
    if (ref.docs.isNotEmpty) {
      await ref.docs.first.reference.update(data);
    }
  }

  Future<void> updateExpense(String docId, Map<String, dynamic> data) async {
    final ref = await _firestore
        .collectionGroup('expense')
        .where(FieldPath.documentId, isEqualTo: docId)
        .get();
    if (ref.docs.isNotEmpty) {
      await ref.docs.first.reference.update(data);
    }
  }
}
