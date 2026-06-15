import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:jathwa1/pages/addChild_page.dart';
import 'package:jathwa1/pages/addHome_page.dart';
import 'package:jathwa1/pages/child_page.dart';
import 'package:jathwa1/pages/homework_page.dart';
import 'package:jathwa1/pages/previousHome_page.dart';
import 'package:jathwa1/pages/switch_container.dart';
import 'package:flutter/material.dart';

class WeeklyHomework extends StatefulWidget {
  final String name;
  final String avatar;

  const WeeklyHomework({
    super.key,
    required this.name,
    required this.avatar,
    required bool isEditing,
  });

  @override
  State<WeeklyHomework> createState() => _WeeklyHomeworkState();
}

class _WeeklyHomeworkState extends State<WeeklyHomework> {
  Map<String, List<Map<String, dynamic>>> currentHomework = {};
  Map<String, List<Map<String, dynamic>>> pastHomework = {};
  bool isLoading = true;
  bool selected = true;
  bool showCurrent = true;
  bool isEnglish(String text) {
    final RegExp englishRegex = RegExp(r'^[a-zA-Z0-9\s]+$');
    return englishRegex.hasMatch(text);
  }

  // إضافة خريطة لربط المواد بالصور
  Map<String, String> subjectImages = {
    "علوم 🔬": "assets/images/science.png",
    "أدب 📜": "assets/images/literature.png",
    "دين 🕌": "assets/images/religion.png",
    "فنون 🎨": "assets/images/art.png",
  };

  @override
  void initState() {
    super.initState();
    fetchHomeworkData();
  }

  List<DateTime> completedDays = []; 
  void markHomeworkCompleted(DateTime date, Map<String, dynamic> homework) {
    setState(() {
      if (homework.containsKey('completed') && homework['completed'] == true) {
        return;
      }
      homework['completed'] = true;
      if (!completedDays.any((d) =>
          d.year == date.year && d.month == date.month && d.day == date.day)) {
        completedDays.add(date);
      }
      completedDays.sort((a, b) => a.compareTo(b));
      int consecutiveDays = 1;
      for (int i = 1; i < completedDays.length; i++) {
        if (completedDays[i].difference(completedDays[i - 1]).inDays == 1) {
          consecutiveDays++;
          if (consecutiveDays >= 3) {
            print("🎉 تم تحقيق 3 أيام متتالية! عرض الإشعار.");  
            showChallengeNotification();
            return;
          }
        } else {
          consecutiveDays = 1;
        }
      }
    });
  }

  Future<void> saveChallengeToFirebase(String message, int points) async {
    try {
      // إنشاء مرجع إلى مجموعة Firestore
      final CollectionReference challenges =
          FirebaseFirestore.instance.collection('challenges');

      // إضافة البيانات (الرسالة والنقاط)
      await challenges.add({
        'message': message,
        'points': points,
        // 'completedAt': FieldValue.serverTimestamp(), // إضافة توقيت الحفظ
      });

      print('تم حفظ الرسالة والنقاط بنجاح في Firestore');
    } catch (e) {
      print('خطأ أثناء حفظ البيانات: $e');
    }
  }

  void showChallengeNotification() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(40),
            ),
            contentPadding: EdgeInsets.zero,
            content: Container(
              width: 300,
              padding: const EdgeInsets.all(15.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/images/days.png'),
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    '🎉 ! تهانينا',
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'لقد أكملت الواجبات اليومية لمدة 3 أيام متتالية',
                    style: TextStyle(
                      fontSize: 19,
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'لقد حصلت على 10 نقاط',
                    style: TextStyle(fontSize: 17, color: Colors.black),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      // تخزين الرسالة والنقاط
                      await saveChallengeToFirebase(
                        '!!لقد أكملت الواجبات اليومية لمدة 3 أيام متتالية',
                        10, // النقاط
                      );
                      Navigator.of(context).pop(); // إغلاق الإشعار
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.lightGreen,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'حسنًا',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    });
  }

  Future<void> fetchChildData(BuildContext context, String name) async {
    try {
      // البحث عن الطفل باستخدام الاسم
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('children')
          .where('name', isEqualTo: name) // البحث بناءً على الاسم
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        // إذا تم العثور على الطفل
        Map<String, dynamic> childData =
            querySnapshot.docs.first.data() as Map<String, dynamic>;

        // طباعة البيانات للتأكد
        print("Child Data: $childData");

        // قم باستخدام البيانات كما تريد (مثل التنقل إلى صفحة أخرى)
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Addchild(
              isEditing: true,
              childData: childData,
              childId: querySnapshot.docs.first.id, // يمكنك تمرير المعرف أيضًا
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('لم يتم العثور على بيانات لهذا الطفل')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حدث خطأ أثناء جلب البيانات: $e')),
      );
    }
  }

  Future<void> fetchHomeworkData() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('homeworks')
          .where('name', isEqualTo: widget.name)
          .orderBy('date')
          .get();

      if (querySnapshot.docs.isEmpty) {
        print('No homework data found for the user: ${widget.name}');
      }

      Map<String, List<Map<String, dynamic>>> groupedCurrent = {};
      Map<String, List<Map<String, dynamic>>> groupedPast = {};

      DateTime now = DateTime.now();

      for (var doc in querySnapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

        if (!data.containsKey('date') ||
            !data.containsKey('subjectName') ||
            !data.containsKey('activity') ||
            !data.containsKey('minutes')) {
          print('Missing required fields in document: ${doc.id}');
          continue;
        }

        DateTime date = (data['date'] as Timestamp).toDate();
        String dayOfWeek = getDayOfWeek(date);

        int duration = int.tryParse(data['minutes'].toString()) ?? 0;

        if (date.isBefore(now)) {
          if (!groupedPast.containsKey(dayOfWeek)) {
            groupedPast[dayOfWeek] = [];
          }
          groupedPast[dayOfWeek]?.add({
            'subject': data['subject'] ?? "غير محدد",
            'subjectName': data['subjectName'] ?? "غير محدد",
            'activity': data['activity'] ?? "غير محدد",
            'duration': duration,
            'date': date,
          });
        } else {
          if (!groupedCurrent.containsKey(dayOfWeek)) {
            groupedCurrent[dayOfWeek] = [];
          }
          groupedCurrent[dayOfWeek]?.add({
            'subject': data['subject'] ?? "غير محدد",
            'subjectName': data['subjectName'] ?? "غير محدد",
            'activity': data['activity'] ?? "غير محدد",
            'duration': duration,
            'date': date,
          });
        }
      }

      setState(() {
        currentHomework = groupedCurrent;
        pastHomework = groupedPast;
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching data: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حدث خطأ أثناء جلب البيانات: $e')),
      );
      setState(() {
        isLoading = false;
      });
    }
  }

  String getDayOfWeek(DateTime date) {
    const days = ['الأحد', 'الإثنين', 'الثلاثاء', 'الأربعاء', 'الخميس'];

    if (date.weekday < 1 || date.weekday > 5) {
      return 'غير معروف';
    }

    return days[date.weekday - 1];
  }

// **🎨 تحديث `getDayColor` لاستدعاء `markHomeworkCompleted()`**
  Color getDayColor(String day, Map<String, dynamic> homework) {
    if (homework.containsKey('completed') && homework['completed'] == true) {
      return Colors.green; // ✅ يتحول للأخضر بعد الضغط
    }

    switch (day) {
      case 'الأحد':
        return const Color(0xFFFEDDD8);
      case 'الإثنين':
        return const Color(0xFFF0ECC7);
      case 'الثلاثاء':
        return const Color(0xFFDBC0E8);
      case 'الأربعاء':
        return const Color(0xFFDCE8C0);
      case 'الخميس':
        return const Color(0xFFC0D4E8);
      default:
        return Colors.white;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFFB9CBD9),
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: const Color(0xFFB9CBD9),
          elevation: 0,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                widget.name,
                style: const TextStyle(color: Colors.black),
              ),
              const SizedBox(width: 8),
              Positioned(
                left: 300,
                top: 18,
                child: GestureDetector(
                  onTap: () {
                    fetchChildData(context, widget.name);
                  },
                  child: CircleAvatar(
                    radius: 30, // تقليل حجم الصورة
                    backgroundImage: AssetImage(widget.avatar),
                  ),
                ),
              ),
            ],
          ),
        ),
        body: Stack(
          children: [
            Positioned(
              left: 0,
              top: 20,
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height - 80,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(32),
                ),
              ),
            ),
            Positioned(
              left: 30,
              top: 100,
              child: Container(
                padding: const EdgeInsets.all(8), // مسافة صغيرة داخل الحاوية
                height: 45,
                width: MediaQuery.of(context).size.width -
                    45, // العرض مع مراعاة الهوامش
                decoration: BoxDecoration(
                  color: Colors.grey.shade200, // اللون الخلفي العام
                  borderRadius: BorderRadius.circular(24), // الزوايا الدائرية
                ),
                child: Row(
                  children: [
                    Expanded(
                      // الزر الثاني (السابقه)
                      child: SwitchContainer(
                        text: 'السابقه',
                        ontap: () {
                          setState(() {
                            selected = false;
                          });
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PrevioushomePage(
                                name: widget.name,
                                avatar: widget.avatar,
                              ),
                            ),
                          );
                        },
                        color: !selected
                            ? Colors.white
                            : Colors.transparent, // لون الزر
                      ),
                    ),
                    Expanded(
                      // الزر الأول (الحالية)
                      child: SwitchContainer(
                        text: 'الحالية',
                        ontap: () {
                          setState(() {
                            selected = true;
                          });
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => WeeklyHomework(
                                name: widget.name,
                                avatar: widget.avatar,
                                isEditing: false,
                              ),
                            ),
                          );
                        },
                        color: selected
                            ? Colors.white
                            : Colors.transparent, // لون الزر
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 20,
              top: 160,
              right: 20,
              bottom: 20,
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      itemCount: (showCurrent ? currentHomework : pastHomework)
                          .keys
                          .length,
                      itemBuilder: (context, index) {
                        String day =
                            (showCurrent ? currentHomework : pastHomework)
                                .keys
                                .elementAt(index);
                        List<Map<String, dynamic>> dailyHomework = (showCurrent
                            ? currentHomework
                            : pastHomework)[day]!;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 8.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "${dailyHomework[0]['date'].day}/${dailyHomework[0]['date'].month}/${dailyHomework[0]['date'].year}",
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  Text(
                                    day,
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            ...dailyHomework.map((homework) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 8.0, horizontal: 5.0),
                                child: GestureDetector(
                                  onTap: () {
                                    DateTime homeworkDate;

                                    if (homework['date'] is Timestamp) {
                                      homeworkDate =
                                          (homework['date'] as Timestamp)
                                              .toDate();
                                    } else if (homework['date'] is DateTime) {
                                      homeworkDate = homework['date'];
                                    } else {
                                      return;
                                    }
                                    // ✅ تسجيل اليوم عند الضغط على المستطيل + تحديث اللون
                                    markHomeworkCompleted(
                                        homeworkDate, homework);
                                  },
                                  child: Container(
                                    width:
                                        MediaQuery.of(context).size.width * 1,
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: getDayColor(day,
                                          homework), // ✅ تحديث اللون عند الضغط
                                      borderRadius: BorderRadius.circular(40),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.3),
                                          spreadRadius: 1,
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              // ✅ زر التشغيل
                                              Container(
                                                padding:
                                                    const EdgeInsets.all(2),
                                                decoration: BoxDecoration(
                                                  color: const Color.fromARGB(
                                                      255, 118, 193, 137),
                                                  borderRadius:
                                                      BorderRadius.circular(25),
                                                ),
                                                child: IconButton(
                                                    icon: const Icon(
                                                        Icons.play_arrow,
                                                        size: 24),
                                                    color: Colors.white,
                                                    onPressed: () {
                                                      DateTime homeworkDate;

                                                      if (homework['date']
                                                          is Timestamp) {
                                                        homeworkDate =
                                                            (homework['date']
                                                                    as Timestamp)
                                                                .toDate();
                                                      } else if (homework[
                                                          'date'] is DateTime) {
                                                        homeworkDate =
                                                            homework['date'];
                                                      } else {
                                                        return;
                                                      }
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (context) =>
                                                              DoHomework(
                                                            subject: homework[
                                                                'subjectName'],
                                                            activity: homework[
                                                                'activity'],
                                                            minutes: homework[
                                                                    'duration']
                                                                .toString(),
                                                            name: widget.name,
                                                            avatar:
                                                                widget.avatar,
                                                          ),
                                                        ),
                                                      );
                                                    }),
                                              ),

                                              const SizedBox(width: 53),

                                              // ✅ الانتقال إلى صفحة حل الواجب
                                              // صورة القسم
                                              Image.asset(
                                                subjectImages[
                                                        homework['subject']] ??
                                                    'assets/images/icon.png',
                                                width: 30,
                                                height: 30,
                                              ),
                                              const SizedBox(width: 8),
                                              // اسم المادة
                                              Text(
                                                homework['subjectName'] ??
                                                    'غير محدد',
                                                style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ],
                                          ),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "مدة الواجب ${homework['duration']} دقيقة",
                                                style: const TextStyle(
                                                    fontSize: 12),
                                              ),
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment
                                                    .start, // لضمان المحاذاة الصحيحة
                                                children: [
                                                  if (isEnglish(
                                                      homework['activity']))
                                                    Text(
                                                      homework['activity'],
                                                      style: const TextStyle(
                                                          fontSize: 12),
                                                    ),
                                                  Text(
                                                    " :النشاط",
                                                    style: const TextStyle(
                                                        fontSize: 12),
                                                  ),
                                                  if (!isEnglish(
                                                      homework['activity']))
                                                    Text(
                                                      homework['activity'],
                                                      style: const TextStyle(
                                                          fontSize: 12),
                                                    ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ]),
                                  ),
                                ),
                              );
                            }).toList(),
                          ],
                        );
                      },
                    ),
            ),
            Positioned(
              top: 40,
              right: 25,
              child: Text(
                ":الواجبات",
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: !showCurrent ? Colors.white : const Color(0xFF333333),
                ),
              ),
            ),
            Positioned(
              top: 30,
              left: 10,
              child: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
