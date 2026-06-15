import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:jathwa1/pages/bar_chart_container.dart';
import 'package:jathwa1/pages/bar_chart_widget.dart';
import 'package:jathwa1/pages/colors.dart';
import 'package:jathwa1/pages/task_model.dart';
import 'package:jathwa1/pages/textutils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:timeline_tile/timeline_tile.dart';

class PreviousHomework extends StatefulWidget {
  final String childID; // 🔹 إضافة معرف الطفل لتمييز بياناته

  const PreviousHomework({Key? key, required this.childID}) : super(key: key);

  @override
  State<PreviousHomework> createState() => _PreviousHomeworkState();
}

class _PreviousHomeworkState extends State<PreviousHomework> {
  String? selectedValue;
  int selectedIndex = 0;
  int weeknum = 1;
  int? monthnum = DateTime.now().month;
  late Future<List<Task>> futureTasks;
  Map<String, int> activityCounts = {};

  List<String> months = [
    'يناير',
    "فبراير",
    "مارس",
    "ابريل",
    "مايو",
    "يونيو",
    "يوليو",
    "اغسطس",
    "سبتمبر",
    "اكتوبر",
    "نوفمبر",
    "ديسمبر"
  ];
  List<String> week = ['الاسبوع 1', 'الاسبوع 2', 'الاسبوع 3', 'الاسبوع 4'];

  final Map<String, int> monthsMap = {
    "يناير": 1,
    "فبراير": 2,
    "مارس": 3,
    "أبريل": 4,
    "مايو": 5,
    "يونيو": 6,
    "يوليو": 7,
    "أغسطس": 8,
    "سبتمبر": 9,
    "أكتوبر": 10,
    "نوفمبر": 11,
    "ديسمبر": 12,
  };

  @override
  void initState() {
    super.initState();
    futureTasks = fetchTasksByChild(widget.childID, weeknum, monthnum!);

    ;
  }

  /// 🔹 تحديث البيانات عند تغيير الأسبوع أو الشهر
  void updateTasks() {
    setState(() {
      futureTasks = fetchTasksByChild(widget.childID, weeknum, monthnum!);
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Task>>(
      future: futureTasks,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('❌ خطأ: ${snapshot.error}'));
        } else {
          final tasks = snapshot.data!;
          return Column(
            children: [
              BarChartContainer(
                  weeknum: weeknum,
                  monthnum: monthnum!,
                  childID: widget.childID),
              SizedBox(height: 10.h),
              Row(
                children: [
                  Container(
                    margin: EdgeInsets.only(left: 8.w),
                    padding: EdgeInsets.symmetric(horizontal: 8.w),
                    height: 18.h,
                    width: 90.w,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: MyColors.lightgrey),
                    child: DropdownButton<String>(
                      isExpanded: true,
                      underline: Container(),
                      menuMaxHeight: 300.h,
                      value: selectedValue,
                      hint: Text(months.first),
                      dropdownColor: MyColors.lightgrey,
                      icon: Row(
                        children: [
                          SizedBox(width: 18.w),
                          const Icon(Icons.arrow_drop_down),
                        ],
                      ),
                      alignment: Alignment.centerLeft,
                      style: Textutils.title12
                          .copyWith(fontWeight: FontWeight.bold),
                      items: months.map((String item) {
                        return DropdownMenuItem<String>(
                          value: item,
                          child: Text(item),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedValue = newValue;
                          if (newValue != null) {
                            monthnum = monthsMap[newValue];
                            updateTasks();
                          }
                        });
                      },
                    ),
                  ),
                  SizedBox(
                    height: 18.h,
                    width: 230.w,
                    child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: week.length,
                        itemBuilder: (context, index) {
                          bool isSelected = selectedIndex == index;
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedIndex = index;
                                weeknum = index + 1;
                                updateTasks();
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              alignment: Alignment.center,
                              margin: EdgeInsets.only(left: 8.w),
                              height: 18.h,
                              width: 50.w,
                              decoration: BoxDecoration(
                                  color: isSelected
                                      ? MyColors.barchartYellow
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(12.r),
                                  border: Border.all(color: Colors.black26)),
                              child: Text(
                                week[index],
                                style: Textutils.title10
                                    .copyWith(fontWeight: FontWeight.bold),
                              ),
                            ),
                          );
                        }),
                  )
                ],
              ),

              /// ✅ عرض قائمة الواجبات السابقة
              Container(
                margin: EdgeInsets.only(top: 8.h),
                height: 250,
                child: tasks.isEmpty
                    ? const Center(child: Text('لا توجد واجبات لهذا الأسبوع'))
                    : ListView.builder(
                        itemCount: tasks.length,
                        itemBuilder: (context, index) {
                          return TimelineTile(
                            indicatorStyle: const IndicatorStyle(width: 10),
                            afterLineStyle: const LineStyle(thickness: 2),
                            beforeLineStyle: const LineStyle(thickness: 2),
                            alignment: TimelineAlign.manual,
                            lineXY: 0.2,
                            isFirst: index == 0,
                            isLast: index == tasks.length - 1,
                            startChild: Column(
                              children: [
                                Text(tasks[index].day,
                                    style: Textutils.title18),
                                Text(
                                  '${tasks[index].date.day}/${tasks[index].date.month}',
                                  style: Textutils.title12,
                                ),
                              ],
                            ),
                            endChild: Row(
                              children: [
                                Column(
                                  children: [
                                    Container(
                                      margin: const EdgeInsets.only(
                                          bottom: 16, left: 16),
                                      width: 230.w,
                                      decoration: BoxDecoration(
                                        color: tasks[index].isCompleted
                                            ? MyColors.lineprogressgreen
                                            : MyColors.lineprogressred,
                                        borderRadius:
                                            BorderRadius.circular(30.r),
                                      ),
                                      child: Padding(
                                        padding: EdgeInsets.only(right: 8.w),
                                        child: Row(
                                          children: [
                                            Image.asset(
                                              'assets/images/task.png',
                                              height: 35,
                                            ),
                                            SizedBox(width: 10.w),
                                            Column(
                                              children: [
                                                Transform.translate(
                                                    offset: const Offset(0, 5),
                                                    child: Text(
                                                      tasks[index].subject,
                                                      style: Textutils.title18,
                                                    )),
                                                Text(
                                                  tasks[index].activity,
                                                  style: Textutils.title12
                                                      .copyWith(fontSize: 14),
                                                ),
                                                Text(
                                                  '🕐 ${tasks[index].duration}',
                                                  style: Textutils.title12,
                                                ),
                                              ],
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
              Divider(indent: 20.w, endIndent: 20.w),
              Text('مخطط الأنشطة:',
                  style: Textutils.title18.copyWith(fontSize: 16)),
              Align(
                alignment: Alignment.centerRight,
                child: Text("المواد العلمية",
                    style: Textutils.title18.copyWith(fontSize: 16)),
              ),
              BarChartWidget(
                childID: widget.childID,
                weeknum: weeknum,
                monthnum: monthnum!,
              )
            ],
          );
        }
      },
    );
  }
}
