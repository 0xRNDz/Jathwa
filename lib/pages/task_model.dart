 import'package:cloud_firestore/cloud_firestore.dart';

class Task {
  final String subject;
  final String activity;
  final DateTime date;
  final String duration;
  final bool isCompleted;
  final String childID;
  final String day;
  final int week;
  final int month;

  Task({
    required this.subject,
    required this.activity,
    required this.date,
    required this.duration,
    required this.isCompleted,
    required this.childID,
    required this.day,
    required this.week,
    required this.month,
  });

  factory Task.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Task(
      subject: data['subject'] ?? '',
      activity: data['activity'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
      duration: data['duration'] ?? '',
      isCompleted: data['isCompleted'] ?? false,
      childID: data['childID'] ?? '',
      day: data['day'] ?? '',
      week: data['week'] ?? 1,
      month: data['month'] ?? 1,
    );
  }
}

/// 🔹 هذه الدالة تسترجع الواجبات السابقة بناءً على `childID`، `weeknum` و `monthnum`
Future<List<Task>> fetchTasksByChild(String childID, int weeknum, int monthnum) async {
  try {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('tasks')
        .where('childID', isEqualTo: childID)  // 🔹 تصفية بناءً على الطفل
        .where('week', isEqualTo: weeknum)    // 🔹 تصفية بناءً على الأسبوع
        .where('month', isEqualTo: monthnum)  // 🔹 تصفية بناءً على الشهر
        .get();

    return querySnapshot.docs.map((doc) => Task.fromFirestore(doc)).toList();
  } catch (e) {
    print('❌ خطأ أثناء جلب البيانات: $e');
    return [];
  }
}

