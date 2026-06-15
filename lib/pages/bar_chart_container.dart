import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:jathwa1/pages/colors.dart';
import 'package:jathwa1/pages/textutils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

class BarChartContainer extends StatelessWidget {
  final int weeknum;
  final int monthnum;
  final String childID; // 🔹 إضافة معرف الطفل لتصفية البيانات بشكل صحيح

  const BarChartContainer({
    super.key,
    required this.weeknum,
    required this.monthnum,
    required this.childID,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('tasks')
          .where('childID', isEqualTo: childID) // 🔹 تصفية بناءً على الطفل
          .where('week', isEqualTo: weeknum) // 🔹 تصفية بناءً على الأسبوع
          .where('month', isEqualTo: monthnum) // 🔹 تصفية بناءً على الشهر
          .snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Text('❌ خطأ في جلب البيانات: ${snapshot.error}');
        } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('لا يوجد واجبات لهذا الأسبوع.'));
        }

        // ✅ حساب نسبة الواجبات المكتملة وغير المكتملة
        final tasks = snapshot.data!.docs;
        int completedTasks = tasks.where((task) {
          final data = task.data() as Map<String, dynamic>;
          return data.containsKey('isCompleted') && data['isCompleted'] == true;
        }).length;

        int totalTasks = tasks.length;
        double progress = totalTasks > 0 ? completedTasks / totalTasks : 0.0;
        int completedPercentage = (progress * 100).toInt();
        int notCompletedPercentage = 100 - completedPercentage;

        // ✅ تغيير لون الشريط بناءً على نسبة التقدم
        Color progressColor = MyColors.lineprogressred; // اللون الافتراضي للأقل من 50%
        if (completedPercentage > 50 && completedPercentage < 80) {
          progressColor = Colors.orange; // نسبة متوسطة
        } else if (completedPercentage >= 80) {
          progressColor = MyColors.lineprogressgreen; // ✅ نسبة عالية جدًا
        }

        return Container(
         
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('الواجبات غير المكتملة', style: Textutils.title12),
                  Text('الواجبات المكتملة', style: Textutils.title12),
                ],
              ),
              SizedBox(height: 8.h),
              LinearPercentIndicator(
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                barRadius: Radius.circular(12.r),
                lineHeight: 14.h,
                backgroundColor: MyColors.lineprogressred,
                progressColor: progressColor, // ✅ تغيير اللون ديناميكيًا
                percent: progress,
                center: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4.w),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('$notCompletedPercentage%', style: Textutils.title10),
                      Text('$completedPercentage%', style: Textutils.title10),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}