import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:jathwa1/pages/colors.dart';
import 'package:jathwa1/pages/textutils.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';


class BarChartWidget extends StatefulWidget {
  final String childID;
  final int weeknum;
  final int monthnum;
  


  const BarChartWidget({
    Key? key,
    required this.childID,
    required this.weeknum,
    required this.monthnum, 
  }) : super(key: key);

  @override
  State<BarChartWidget> createState() => _BarChartWidgetState();
}



class _BarChartWidgetState extends State<BarChartWidget> {
    late Future<Map<String, int>> futureActivityCounts;


void updateTasks() {
  print("🔍 تحديث المهام لـ: weeknum=$widget.weeknum, monthnum=$widget.monthnum");
  fetchActivityCounts(widget.childID, widget.weeknum, widget.monthnum!);
}

 @override
void initState() {
  super.initState();
    futureActivityCounts = fetchActivityCounts(widget.childID, widget.weeknum, widget.monthnum);
}

Future<Map<String, int>> fetchActivityCounts(String childID, int weeknum, int monthnum) async {
  try {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('tasks')
        .where('childID', isEqualTo: childID) 
        .where('week', isEqualTo: weeknum) 
        .where('month', isEqualTo: monthnum) 
        .get();

    final counts = <String, int>{};

    // 🔹 جلب الأنشطة المخزنة
    for (var doc in querySnapshot.docs) {
      final activity = doc['activity'] as String? ?? 'غير معروف';
      if (counts.containsKey(activity)) {
        counts[activity] = counts[activity]! + 1;
      } else {
        counts[activity] = 1;
      }
    }

  

    print("✅ الأنشطة المسترجعة لهذا الأسبوع: $counts");
    return counts;
  } catch (e) {
    print('❌ خطأ أثناء جلب الأنشطة: $e');
    return {};
  }
}




  @override
    Widget build(BuildContext context) {
    return FutureBuilder<Map<String, int>>(
      future: futureActivityCounts,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('❌ خطأ في جلب الأنشطة: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('لا توجد بيانات للأنشطة لهذا الأسبوع'));
        }

        final activityCounts = snapshot.data!;
        final activities = activityCounts.keys.toList(); // 🏋️‍♂️ الأنشطة الفعلية المخزنة
        final values = activityCounts.values.toList(); // 🔢 عدد مرات كل نشاط

        return SizedBox(
          height: 200.h,
          width: 230.w,
          child: BarChart(
            BarChartData(
              gridData: const FlGridData(show: false),
              alignment: BarChartAlignment.spaceAround,
              maxY: (values.isNotEmpty) ? values.reduce((a, b) => a > b ? a : b).toDouble() + 2 : 10,
              barTouchData: BarTouchData(enabled: false),
              titlesData: FlTitlesData(
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 28,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        value.toInt().toString(),
                        style: const TextStyle(color: Colors.black, fontSize: 12),
                      );
                    },
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    getTitlesWidget: (value, meta) {
                      final index = value.toInt();
                      if (index < activities.length) {
                        return Transform.rotate(
                          angle: -45,
                          child: Container(
                              padding: const EdgeInsets.all(8),
                              width: 50,
                              child: Text(
                                activities[index],
                                style: Textutils.title10,
                                softWrap: true,
                                overflow: TextOverflow.visible,
                                maxLines: 2,
                              )),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ),
              ),
              borderData: FlBorderData(
                border: const Border(
                  top: BorderSide.none,
                  right: BorderSide.none,
                  bottom: BorderSide(),
                  left: BorderSide(),
                ),
                show: true,
              ),
              barGroups: List.generate(activities.length, (index) {
                final activity = activities[index];
                final count = activityCounts[activity] ?? 0;
                return _buildBarGroup(index, count.toDouble(), _getColorForActivity(index));
              }),
            ),
          ),
        );
      },
    );
  }

  BarChartGroupData _buildBarGroup(int x, double y, Color color) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          width: 37.w,
          toY: y,
          color: color,
          borderRadius: BorderRadius.circular(2.r),
        ),
      ],
    );
  }

  Color _getColorForActivity(int index) {
    final colors = [
      MyColors.barchartRed,
      MyColors.barchartBlue,
      MyColors.barchartYellow,
      MyColors.barchartGreen,
      MyColors.barchartBrown,
      MyColors.barchartPurple,
    ];
    return colors[index % colors.length];
  }
}
