import 'dart:async';
import 'dart:io';
import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:jathwa1/pages/currentHome_page.dart';
import 'package:jathwa1/pages/homework_page.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:process_run/shell.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await FirebaseAppCheck.instance.activate();
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
  ));
}

class JumpPage extends StatefulWidget {
  final String subjectName;
  final String name;
  final String avatar;
  final String activity;
  final int remainingTimeFromHomework;
  final String minutes;

  JumpPage({
    required this.subjectName,
    required this.name,
    required this.avatar,
    required this.activity,
    required this.minutes,
    required this.remainingTimeFromHomework,
  });

  @override
  _TimerPageState createState() => _TimerPageState();
}

class _TimerPageState extends State<JumpPage> {
  late int totalTimeInSeconds;
  late int remainingTime; 
  Timer? _timer;
  bool isRunning = false; // Check if the timer is running or paused
  String selectedExercise = 'subjectName';
  bool hasStarted = false; // متغير للتحقق من إذا بدأ المؤقت مسبقًا أم لا
  final AudioPlayer _audioPlayer = AudioPlayer(); 

  double get progress => remainingTime / totalTimeInSeconds;

  // List of exercises with corresponding GIF paths
  final Map<String, String> exercises = {
    "نط الحبل": 'assets/images/JumpRope.gif',
    "رقص": 'assets/images/Dance.gif',
    "Jumping jacks": "assets/images/JumpinJacks.gif",
    "جري": 'assets/images/runinng.gif',
    "Cross body": 'assets/images/CrossBody.gif',
    "Game by VR": 'assets/images/vr.png'
  };

  // Toggle timer (Start/Pause)
  void toggleTimer() {
    if (isRunning) {
      pauseTimer();
    } else {
      startTimer();
    }
  }

  // Start timer
  Future<void> startTimer() async {
    if (!hasStarted) {
      hasStarted = true;
      for (int i = 4; i > 0; i--) {
        await playStartSound(i);
        await Future.delayed(Duration(seconds: 1));
      }
    }
    if (!isRunning) {
      setState(() {
        isRunning = true;
      });
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {
          if (remainingTime > 0) {
            remainingTime--;
            if (remainingTime == 0) {
              _timer!.cancel();
              isRunning = false;
              navigateBackToHomework();
            }
            if (remainingTime <= 10 && remainingTime > 0) {
              playNumberSound(remainingTime);
            }
          } else {
            _timer!.cancel();
            isRunning = false;
            showEndOfTimeNotification(context);
          }
        });
      });
    }
  }

  void navigateBackToHomework() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => DoHomework(
          subject: widget.subjectName,
          activity: widget.activity,
          minutes: widget.minutes,
          name: widget.name,
          avatar: widget.avatar,
        ),
      ),
    );
  }

// Pause timer
  void pauseTimer() {
    if (_timer != null && isRunning) {
      _timer?.cancel();
      setState(() {
        isRunning = false;
      });
    }
  }

// Play start sound for countdown
  Future<void> playStartSound(int number) async {
    try {
      await _audioPlayer.play(AssetSource('sound/start.mp3'));
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

  // إشعار بانتهاء الوقت
  void showEndOfTimeNotification(BuildContext context) {
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
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.timer_off,
                  size: 50,
                  color: Colors.red,
                ),
                SizedBox(height: 10),
                Text(
                  '!انتهى الوقت',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8),
                Text(
                  'لقد انتهى الوقت المخصص لإداء الواجب',
                  style: TextStyle(fontSize: 16, color: Colors.black),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.lightGreen,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
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

  @override
  void dispose() {
    _timer?.cancel(); // Clean up timer when exiting
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    // تحويل الوقت الإجمالي (minutes) إلى ثواني
    totalTimeInSeconds = int.parse(widget.minutes) * 60;

    // إذا كان هناك وقت متبقٍ وارد من صفحة الواجب، استخدمه، وإلا استخدم الوقت الكامل
    remainingTime = widget.remainingTimeFromHomework != null
        ? widget.remainingTimeFromHomework
        : totalTimeInSeconds;

    // إعداد اسم التمرين
    selectedExercise = widget.subjectName;

    // التأكد من إعداد صورة التمرين المناسبة
    if (!exercises.containsKey(widget.activity)) {
      exercises[widget.activity] =
          'images/vr.png'; // تعيين صورة افتراضية إذا لم تكن موجودة
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color.fromRGBO(187, 222, 251, 1),
        appBar: AppBar(
          backgroundColor: const Color.fromRGBO(187, 222, 251, 1),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => DoHomework(
                          name: widget.name,
                          avatar: widget.avatar,
                          subject: widget.subjectName,
                          activity: widget.activity,
                          minutes: widget.minutes,
                        )),
              );
            },
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "تمارين رياضية",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),

              const SizedBox(height: 10),

              // Timer display
              Text(
                "${(remainingTime ~/ 60).toString().padLeft(2, '0')}:${(remainingTime % 60).toString().padLeft(2, '0')}",
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),

              const SizedBox(height: 20),

              // Dropdown menu to select exercise
              Text(
                widget.activity,
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.grey,
                ),
              ),

              const SizedBox(height: 20),

              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 200,
                    height: 200,
                    child: CircularProgressIndicator(
                      value: progress, // Current progress value
                      strokeWidth: 10,
                      backgroundColor: Colors.grey.shade300,
                      valueColor:
                          const AlwaysStoppedAnimation<Color>(Colors.blue),
                    ),
                  ),
                  // Display selected exercise GIF
                  ClipOval(
                    child: Image.asset(
                      exercises[widget.activity] ?? 'assets/images/vr.png',
                      width: 150,
                      height: 150,
                      fit: BoxFit.cover,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Task description
              Text(
                " واجب الـ${widget.subjectName}",

                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 5),
              Text(
                "تبقى ${(remainingTime ~/ 60)} دقائق للعودة إلى الواجب",
                style: TextStyle(fontSize: 16, color: Colors.grey[700]),
              ),

              const SizedBox(height: 30),

              // Control buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Stop button
                  ElevatedButton(
                    onPressed: pauseTimer,
                    style: ElevatedButton.styleFrom(
                      shape: const CircleBorder(),
                      padding: const EdgeInsets.all(20),
                    ),
                    child: const Icon(Icons.stop, size: 30),
                  ),
                  const SizedBox(width: 20),
                  // Play/Pause button
                  ElevatedButton(
                    onPressed: toggleTimer,
                    style: ElevatedButton.styleFrom(
                      shape: const CircleBorder(),
                      padding: const EdgeInsets.all(20),
                    ),
                    child: Icon(
                      isRunning ? Icons.pause : Icons.play_arrow,
                      size: 30,
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
