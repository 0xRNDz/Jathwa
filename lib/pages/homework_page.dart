import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:jathwa1/pages/child_page.dart';
import 'package:flutter/material.dart';
import 'package:jathwa1/pages/Jump_page.dart';
import 'package:jathwa1/pages/currentHome_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
}

class DoHomework extends StatefulWidget {
  final String subject;
  final String activity;
  final String minutes;
  final String name;
  final String avatar;

  const DoHomework({
    super.key,
    required this.subject,
    required this.activity,
    required this.minutes,
    required this.name,
    required this.avatar,
  });

  @override
  _DoHomeworkState createState() => _DoHomeworkState();
}

class _DoHomeworkState extends State<DoHomework> {
  late int totalTimeInSeconds;
  late int remainingTime;
  late List<Map<String, dynamic>> sections;
  int currentSectionIndex = 0;
  Timer? _timer;
  bool isRunning = false;
  bool hasStarted = true; // متغير للتحقق من إذا بدأ المؤقت مسبقًا أم لا
  final AudioPlayer _audioPlayer = AudioPlayer(); // مشغل الصوت
  int totalPoints = 0;
  int completedAssignments = 0;
  int progress = 0;

  // خريطة للـ GIFs بناءً على النشاط
  final Map<String, String> activityGifs = {
    "نط الحبل": 'images/JumpRope.gif',
    "رقص": 'images/Dance.gif',
    "Jumping jacks": 'images/JumpinJacks.gif',
    "جري": 'images/runinng.gif',
    "Cross body": 'images/CrossBody.gif',
    "Game by VR": 'images/vr.png',
  };

  @override
  void initState() {
    super.initState();
    totalTimeInSeconds = int.parse(widget.minutes) * 60;
    configureSections();
    remainingTime = sections[currentSectionIndex]['duration'];
  }

  void configureSections() {
    int totalMinutes = int.parse(widget.minutes);
    if (totalMinutes == 20) {
      sections = [
        {'task': widget.subject, 'duration': 1 * 60},
        {'task': widget.activity, 'duration': 1 * 60},
        {'task': widget.subject, 'duration': 1 * 60},
      ];
    } else if (totalMinutes == 30) {
      sections = [
        {'task': widget.subject, 'duration': 15 * 60},
        {'task': widget.activity, 'duration': 5 * 60},
        {'task': widget.subject, 'duration': 15 * 60},
      ];
    } else if (totalMinutes == 45) {
      sections = [
        {'task': widget.subject, 'duration': 15 * 60},
        {'task': widget.activity, 'duration': 5 * 60},
        {'task': widget.subject, 'duration': 15 * 60},
        {'task': widget.subject, 'duration': 5 * 60},
        {'task': widget.subject, 'duration': 15 * 60},
      ];
    } else if (totalMinutes == 60) {
      sections = [
        {'task': widget.subject, 'duration': 15 * 60},
        {'task': widget.activity, 'duration': 5 * 60},
        {'task': widget.subject, 'duration': 15 * 60},
        {'task': widget.subject, 'duration': 5 * 60},
        {'task': widget.subject, 'duration': 15 * 60},
        {'task': widget.subject, 'duration': 5 * 60},
        {'task': widget.subject, 'duration': 15 * 60},
      ];
    } else {
      sections = [
        {'task': widget.subject, 'duration': totalMinutes * 60},
      ];
    }
  }

  Future<void> startTimer() async {
    if (!hasStarted) {
      hasStarted = false;
      for (int i = 4; i > 0; i--) {
        await playStartSound(i);
        await Future.delayed(Duration(seconds: 1));
      }
    }
    setState(() {
      isRunning = true;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (remainingTime > 0) {
          remainingTime--;
          if (remainingTime <= 10 && remainingTime > 0) {
            playNumberSound(remainingTime);
          }
        } else {
          timer.cancel();
          moveToNextSection();
        }
      });
    });
  }

  Future<void> moveToNextSection() async {
    if (currentSectionIndex + 1 < sections.length) {
      setState(() {
        currentSectionIndex++;
        remainingTime = sections[currentSectionIndex]['duration'];
        isRunning = false; // ✅ تأكد من أن المؤقت لا يبدأ تلقائيًا
        _timer?.cancel(); // ✅ أوقف المؤقت قبل التنقل للقسم التالي
      });
    } else {
      showCompletionDialog();
    }
  }

  void stopTimer() {
    _timer?.cancel();
    setState(() {
      isRunning = false;
    });
  }

  void resetTimer() {
    _timer?.cancel();
    setState(() {
      currentSectionIndex = 0;
      remainingTime = sections[currentSectionIndex]['duration'];
      isRunning = false;
    });
  }
// Play start sound for countdown

  Future<void> playStartSound(int number) async {
    try {
      await _audioPlayer.play(AssetSource(
          'sound/start.mp3')); // تأكد من وضع الملف الصوتي في المجلد الصحيح
    } catch (e) {
      print("Error playing start sound: $e");
    }
  }

  Future<void> playNumberSound(int number) async {
    try {
      await _audioPlayer.play(AssetSource('sound/alarm.mp3'));
    } catch (e) {
      print("Error playing sound: $e");
    }
  }

  void showPointsDialog() {
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
                      image: AssetImage('images/Medal.png'),
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
                  '👏 أنت مثال للتفوق',
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
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => WeeklyHomework(
                                name: widget.name,
                                avatar: widget.avatar,
                                isEditing: false,
                              )),
                    );
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
  }

  String getDayOfWeek(DateTime date) {
    const days = ['الأحد', 'الإثنين', 'الثلاثاء', 'الأربعاء', 'الخميس'];

    if (date.weekday < 1 || date.weekday > 5) {
      return 'غير معروف'; // تجنب إدخال الجمعة والسبت
    }

    return days[date.weekday - 1];
  }

  int getWeekOfMonth(DateTime date) {
    // حساب بداية الأسبوع الأول من الشهر
    DateTime firstDayOfMonth = DateTime(date.year, date.month, 1);
    int firstWeekday = firstDayOfMonth.weekday;

    // حساب اليوم المعدل بناءً على بداية الشهر
    int adjustedDay = date.day + (firstWeekday - 1);

    // حساب الأسبوع (يبدأ من 1 إلى 5)
    int week = ((adjustedDay - 1) ~/ 7) + 1;

    // تحديد الحد الأقصى للأسبوع ليكون 4 فقط
    return week > 4 ? 4 : week;
  }

  Future<void> saveCompletionToFirebase(bool isCompleted) async {
    try {
      // 🔹 البحث عن الطفل باستخدام الاسم لاسترجاع `Document ID`
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('children')
          .where('name', isEqualTo: widget.name)
          .get();

      if (querySnapshot.docs.isEmpty) {
        print("❌ لم يتم العثور على الطفل في Firestore!");
        return;
      }

      // 🔹 الحصول على `Document ID` الصحيح للطفل
      String childId = querySnapshot.docs.first.id;
      DocumentReference userRef =
          FirebaseFirestore.instance.collection('children').doc(childId);

      await FirebaseFirestore.instance.runTransaction((transaction) async {
        DocumentSnapshot userSnapshot = await transaction.get(userRef);

        if (userSnapshot.exists) {
          // ✅ التحقق مما إذا كانت `points` و `completedTasks` موجودة، وإذا لم تكن، يتم إضافتها بالقيمة الافتراضية 0.
          Map<String, dynamic> userData =
              userSnapshot.data() as Map<String, dynamic>;

          int currentPoints =
              userData.containsKey('points') ? userData['points'] as int : 0;
          int completedHomework = userData.containsKey('completedTasks')
              ? userData['completedTasks'] as int
              : 0;

          // ✅ تحديث النقاط والواجبات المكتملة في Firestore
          transaction.update(userRef, {
            'points': currentPoints + 10, // ✅ إضافة 10 نقاط جديدة
            'completedTasks':
                completedHomework + 1, // ✅ زيادة عدد الواجبات المكتملة
          });
        } else {
          // 🔹 إذا لم يكن المستند موجودًا، أنشئه مع القيم الافتراضية
          transaction.set(userRef, {
            'points': 10, // ✅ بدء النقاط من 10 (لأنه أكمل أول واجب)
            'completedTasks': 1, // ✅ بدء العد من 1
          });
        }

        // ✅ تسجيل الواجب المكتمل في Firestore
        final taskData = {
          'subject': widget.subject,
          'activity': widget.activity,
          'date': Timestamp.now(),
          'duration': widget.minutes,
          'isCompleted': isCompleted,
          'childID': childId, // ✅ استخدام Document ID بدلاً من الاسم
          'day': getDayOfWeek(DateTime.now()),
          'week': getWeekOfMonth(DateTime.now()),
          'month': DateTime.now().month,
        };

        print("🔹 البيانات التي سيتم حفظها: $taskData");

        await FirebaseFirestore.instance.collection('tasks').add(taskData);
      });

      print(isCompleted
          ? '✅ تم حفظ الواجب المكتمل بنجاح في Firestore'
          : '❌ تم حفظ الواجب لكنه غير مكتمل (isCompleted: false)');
    } catch (e) {
      print('❌ خطأ أثناء حفظ الواجب: $e');
    }
  }

  void completeHomework() async {
    await saveCompletionToFirebase(true);
    Navigator.pop(
        context, true); // ✅ إرجاع قيمة true لتحديث البيانات عند العودة
  }

  void showCompletionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('🎉 ! تهانينا'),
        content: const Text('👏 هل أكملت الواجب والنشاط البدني يا مجتهد؟'),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () async {
              await saveCompletionToFirebase(false); // 🔹 حفظ الواجب غير مكتمل
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
              print(
                  '❌ المستخدم لم يكمل الواجب، تم الحفظ بحالة isCompleted: false');
            },
            child: const Text('لا', style: TextStyle(color: Colors.white)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.lightGreen),
            onPressed: () async {
              await saveCompletionToFirebase(true); // 🔹 حفظ الواجب مكتمل
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
              showPointsDialog(); // 🔹 عرض إشعار النقاط
            },
            child: const Text('نعم', style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double progress =
        1 - (remainingTime / sections[currentSectionIndex]['duration']);

    // تحديد الصورة المناسبة بناءً على المهمة الحالية
    String currentImage =
        sections[currentSectionIndex]['task'] == widget.subject
            ? 'images/Study.png' // عرض study.png أثناء وقت الواجب
            : activityGifs[widget.activity] ??
                'images/Study.png'; // عرض الـ GIF أثناء وقت التمرين

    // الحصول على الوقت الكلي للمهمة الحالية
    int durationInSeconds = sections[currentSectionIndex]['duration'];

    String durationString = durationInSeconds == 1
        ? "1 minute"
        : "\u200F${(durationInSeconds ~/ 60)} دقيقة"; // عرض "minute" أو "minutes" بناءً على القيمة

    return Scaffold(
      appBar: AppBar(backgroundColor: const Color(0xFF9DC7E7)),
      backgroundColor: const Color(0xFF9DC7E7),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              // عرض اسم المادة أو التمرين فوق المؤقت الدائري
              Text(
                sections[currentSectionIndex]['task'] == widget.subject
                    ? "📚  واجب  ${widget.subject}" // 🔹 إذا كان واجبًا، أضف كلمة "واجب"
                    : "🏃‍♂️ ${widget.activity}", // 🔹 إذا كان نشاطًا، اعرض النشاط مباشرةً
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 20),
              // عرض المؤقت الدائري
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 300,
                    height: 300,
                    child: CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 8,
                      backgroundColor: Colors.grey[300],
                      valueColor:
                          const AlwaysStoppedAnimation<Color>(Colors.blue),
                    ),
                  ),
                  ClipOval(
                    child: Image.asset(
                      currentImage, // عرض الـ study.png أو الـ GIF
                      width: 230,
                      height: 230,
                      fit: BoxFit.cover,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // عرض الوقت الإجمالي للمهمة الحالية

              Text(
                "${(durationInSeconds ~/ 60)}:00",
                textDirection: TextDirection.ltr,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              // عرض الوقت المتبقي بتنسيق mm:ss
              Text(
                "تبقى ${(remainingTime ~/ 60)} دقائق و ${(remainingTime % 60)} ثوانٍ",
                textDirection: TextDirection.rtl,
                style: const TextStyle(
                  fontSize: 20,
                  color: Color.fromARGB(255, 125, 125, 125),
                ),
              ),
              const SizedBox(height: 30),
              // الأزرار
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: isRunning ? null : startTimer,
                    child: const Text('البدء'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green, // زر البدء أحمر
                      foregroundColor: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: isRunning
                        ? () {
                            stopTimer();
                          }
                        : null,
                    child: const Text('التوقف'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red, // زر التخطي أحمر
                      foregroundColor: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: moveToNextSection,
                    child: const Text('تخطي'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue, // زر التخطي أحمر
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
