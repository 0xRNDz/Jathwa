import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PointsProvider with ChangeNotifier {
  int _points = 0; // النقاط الحالية
  double _progress = 0.0; // شريط التقدم (نسبة)

  int get points => _points;
  double get progress => _progress;

  // دالة لتحديث النقاط من Firebase
  Future<void> fetchPoints() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
      final snapshot = await userRef.get();
      if (snapshot.exists) {
        _points = snapshot.data()?['points'] ?? 0;
        _progress = _points / 100.0; // مثلا، 100 هو الحد الأقصى
        notifyListeners();
      }
    }
  }

  // دالة لإضافة النقاط للمستخدم
  Future<void> addPoints(int pointsToAdd) async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
      try {
        await FirebaseFirestore.instance.runTransaction((transaction) async {
          final snapshot = await transaction.get(userRef);
          if (!snapshot.exists) {
            transaction.set(userRef, {'points': pointsToAdd});
          } else {
            final currentPoints = snapshot.data()?['points'] ?? 0;
            transaction.update(userRef, {'points': currentPoints + pointsToAdd});
          }
        });

        // بعد تحديث النقاط، نقوم بتحديث الحالة في الواجهة
        _points += pointsToAdd;
        _progress = _points / 100.0; // تحديث نسبة شريط التقدم
        notifyListeners(); // إعلام الواجهة بتحديث البيانات
      } catch (e) {
        print('Error updating points: $e');
      }
    }
  }
}
