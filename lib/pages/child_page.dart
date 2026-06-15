import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:jathwa1/pages/achieve_page.dart';
import 'package:jathwa1/pages/addChild_page.dart';
import 'package:jathwa1/pages/addHome_page.dart';
import 'package:jathwa1/pages/addPrize_page.dart';
import 'package:jathwa1/pages/currentHome_page.dart';
import 'package:jathwa1/pages/homeTwo_page.dart';
import 'package:jathwa1/pages/homework_page.dart';
import 'package:jathwa1/pages/profile_page.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Child extends StatefulWidget {
  final String name;
  final String avatar;

  const Child({
    Key? key,
    required this.name,
    required this.avatar,
    required bool isEditing,
  }) : super(key: key);

  @override
  _ChildState createState() => _ChildState();
}

class _ChildState extends State<Child> {
  int completedAssignments = 0;
  int totalPoints = 0;
  int progress = 0;
  String prize = ''; // سيتم تخزين الجائزة هنا
  String week = '';
  bool isDialogShown = false;

  @override
  void initState() {
    super.initState();
    fetchChildData();
  }

  Future<void> fetchChildName(String name) async {
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

  Future<void> fetchChildData() async {
    try {
      // 🔹 1️⃣ جلب بيانات الطفل من Firestore
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('children')
          .where('name', isEqualTo: widget.name) // ✅ البحث باستخدام الاسم
          .get();

      if (querySnapshot.docs.isEmpty) {
        print("❌ لم يتم العثور على بيانات الطفل!");
        return;
      }

      DocumentSnapshot snapshot = querySnapshot.docs.first;

      setState(() {
        completedAssignments = snapshot['completedTasks'] ?? 0;
        totalPoints = snapshot['points'] ?? 0;
        progress = totalPoints;
      });

      print("📌 بيانات الطفل من Firestore: ${snapshot.data()}");

      checkAndShowRewardNotification(totalPoints);
    } catch (e) {
      print("❌ خطأ أثناء جلب البيانات: $e");
    }
  }

  Future<String?> fetchRewardImage(int week) async {
    try {
      final response = await Supabase.instance.client
          .from('rewards') // ✅ تأكد أن الجدول اسمه `rewards`
          .select('imageUrl') // 🔹 جلب رابط الصورة فقط
          .eq('week', 1) // 🔹 جلب الجائزة بناءً على الأسبوع المحدد
          .maybeSingle();

      if (response != null) {
        return response['imageUrl']; // ✅ إرجاع رابط الصورة
      } else {
        print("❌ لم يتم العثور على جائزة للأسبوع $week!");
        return null;
      }
    } catch (e) {
      print("❌ خطأ أثناء جلب صورة الجائزة: $e");
      return null;
    }
  }

  void checkAndShowRewardNotification(int totalPoints) async {
    if (isDialogShown)
      return; 

    final prefs = await SharedPreferences.getInstance();
    bool hasShownReward = prefs.getBool('hasShownReward') ?? false;

    if (!hasShownReward) {
      if (totalPoints == 20 ||
          totalPoints == 40 ||
          totalPoints == 80 ||
          totalPoints >= 100) {
        isDialogShown = true;
        prefs.setBool('hasShownReward', true); 
        showPointsDialog();
      }
    }
  }

  Widget buildFlameImage(int totalPoints, String flamePosition) {
    WidgetsBinding.instance.addPostFrameCallback((_) {});

    if ((flamePosition == 'first' && totalPoints >= 20) ||
        (flamePosition == 'second' && totalPoints >= 40) ||
        (flamePosition == 'third' && totalPoints >= 60) ||
        (flamePosition == 'fourth' && totalPoints >= 80)) {
      return Image.asset(
        'assets/images/Fire.png',
        width: 28,
        height: 40,
        fit: BoxFit.cover,
      );
    }

    return totalPoints >= 100
        ? Image.network(
            'assets/images/prize.png',
            width: 28,
            height: 40,
            fit: BoxFit.cover,
          )
        : Image.asset(
            'assets/images/WhiteFire.png',
            width: 28,
            height: 40,
            fit: BoxFit.cover,
          );
  }

  // تحديث الواجبات والنقاط في قاعدة البيانات
  Future<void> updateProgress(String childId, int points) async {
    try {
      DocumentReference childRef =
          FirebaseFirestore.instance.collection('children').doc(childId);

      await FirebaseFirestore.instance.runTransaction((transaction) async {
        DocumentSnapshot snapshot = await transaction.get(childRef);
        if (!snapshot.exists) {
          print("❌ الطفل غير موجود في قاعدة البيانات");
          return;
        }
        int completedTasks = snapshot['completedTasks'] ?? 0;
        int totalPoints = snapshot['points'] ?? 0;
        int newTotalPoints = totalPoints + points;
        transaction.update(childRef, {
          'completedTasks': completedTasks + 1,
          'points': newTotalPoints,
        });
        print("✅ تم تحديث النقاط إلى: $newTotalPoints");
        if (newTotalPoints >= 100) {
          print("🎉 الطفل وصل إلى 100 نقطة! تحديث الجائزة...");

          final rewardResponse = await Supabase.instance.client
              .from('rewards')
              .select('imageUrl')
              .eq('week', 3)
              .maybeSingle();
          if (rewardResponse != null) {
            String newPrize = rewardResponse['imageUrl'] ?? '';

            transaction.update(childRef, {
              'prize': newPrize,
            });
            print("🏆 الجائزة الجديدة: $newPrize");
            setState(() {
              prize = newPrize;
            });
            Future.delayed(const Duration(seconds: 1), () {
              showPointsDialog();
            });
          } else {
            print("❌ لم يتم العثور على جائزة لهذا الأسبوع في Supabase!");
          }
        }
      });

      // ✅ تحديث البيانات بعد التعديل
      await fetchChildData();
    } catch (e) {
      print("❌ خطأ أثناء تحديث التقدم: $e");
    }
  }

  void navigateToHomeworkPage() async {
    bool? updated = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => DoHomework(
                subject: "الرياضيات",
                minutes: "20",
                activity: "نط الحبل",
                name: widget.name,
                avatar: widget.avatar,
              )),
    );

    if (updated == true) {
      fetchChildData(); // ✅ تحديث البيانات بعد الرجوع من صفحة الواجب
    }
  }

  void showPointsDialog() async {
    String? rewardImage =
        await fetchRewardImage(3); // ✅ جلب صورة الجائزة للأسبوع 3

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: Colors.transparent,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Stack(
          children: [
            Positioned(
              top: MediaQuery.of(context).size.height * 0.3,
              left: MediaQuery.of(context).size.width * 0.1,
              width: MediaQuery.of(context).size.width * 0.8,
              child: Material(
                color: Colors.transparent,
                child: Container(
                  padding: const EdgeInsets.all(15.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(40),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      rewardImage != null
                          ? Image.network(
                              rewardImage, // ✅ استخدام صورة الجائزة الفعلية
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Image.asset(
                                  'assets/images/icon.png', // 🔹 صورة افتراضية عند فشل التحميل
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                );
                              },
                            )
                          : Image.asset(
                              'assets/images/Medal.png', // 🔹 صورة افتراضية
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                            ),
                      const SizedBox(height: 10),
                      const Text(
                        '🎉 تهانينا!',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        '👏 لقد حصلت على الجائزة الكبرى!',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.black,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          'حسنًا',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SafeArea(
        child: Scaffold(
          backgroundColor: const Color(0xFFB0C4DE),
          body: SafeArea(
            child: Container(
              width: 400,
              height: 800,
              clipBehavior: Clip.hardEdge,
              decoration: const BoxDecoration(
                color: Color(0xFFB9CBD9),
              ),
              child: Padding(
                padding: const EdgeInsets.only(top: 0.0), // رفع المحتوى لأعلى
                child: SizedBox(
                  width: double.infinity,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Positioned(
                        left: 0,
                        top: 270,
                        child: Container(
                          width: 400,
                          height: 500,
                          clipBehavior: Clip.hardEdge,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(32),
                          ),
                        ),
                      ),
                      ////////////////////////////// مربع النقاط والواجبات /////////////////////////////
                      Positioned(
                        left: 42,
                        top: 115,
                        child: Container(
                          width: 315,
                          height: 59,
                          clipBehavior: Clip.hardEdge,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(32),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x19000000),
                                spreadRadius: 0,
                                offset: Offset(2, 4),
                                blurRadius: 10,
                              )
                            ],
                          ),
                        ),
                      ),
                      ////////////////////////////// اسم الطفل /////////////////////////////
                      Positioned(
                        left: 230,
                        top: 40,
                        child: Text(
                          widget.name,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Color(0xFF333333),
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      ////////////////////////////// مربع البار اللي تحت  /////////////////////////////
                      Positioned(
                        left: 115,
                        top: 680,
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 20),
                            width: 172,
                            height: 55,
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(255, 34, 166, 215),
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.grid_view_rounded,
                                    size: 40,
                                    color: Color.fromARGB(255, 183, 224, 255),
                                  ),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const homeTwo()),
                                    );
                                  },
                                ),
                                const SizedBox(width: 20),
                                IconButton(
                                  icon: const Icon(
                                    Icons.person,
                                    size: 40,
                                    color: Color.fromARGB(255, 183, 224, 255),
                                  ),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const Profile()),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      Positioned(
                        left: 300,
                        top: 20,
                        child: CircleAvatar(
                          radius: 36, // تقليل حجم الصورة
                          backgroundImage: AssetImage(widget.avatar),
                        ),
                      ),

                      Positioned(
                        left: 355,
                        top: 71,
                        child: Container(
                          width: 19,
                          height: 19,
                          clipBehavior: Clip.hardEdge,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x3F000000),
                                spreadRadius: 0,
                                offset: Offset(0, 4),
                                blurRadius: 4,
                              )
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        left: 357,
                        top: 73,
                        child: GestureDetector(
                          onTap: () {
                            // Navigate to the profile page when the image is tapped
                            fetchChildName(widget.name);
                          },
                          child: Image.network(
                            'https://firebasestorage.googleapis.com/v0/b/codeless-app.appspot.com/o/projects%2F0RjDuTVp_UGTv6g3KECl%2Fba24ec6574b4758dd07547e08bd5a1a6f606b760pencil%201.png?alt=media&token=4201fea5-038b-4cf2-84c8-d6659c7129d8',
                            width: 14,
                            height: 14,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),

                      Positioned(
                        left: 61,
                        top: 123,
                        child: Image.network(
                          'https://firebasestorage.googleapis.com/v0/b/codeless-app.appspot.com/o/projects%2F0RjDuTVp_UGTv6g3KECl%2F4f2894f698c80d904be55fc5f29ee14bb4868dcbsuccess.png?alt=media&token=b0ba33d7-1585-41ff-8fb6-fa78fb91e35f',
                          width: 41,
                          height: 41,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        left: 215,
                        top: 152,
                        child: Image.network(
                          'https://storage.googleapis.com/codeless-app.appspot.com/uploads%2Fimages%2F0RjDuTVp_UGTv6g3KECl%2F99b398e6-4ff4-44fb-a7d3-38368838a1f1.png',
                          width: 0,
                          height: 45,
                          fit: BoxFit.contain,
                        ),
                      ),
                      Positioned(
                        left: 219,
                        top: 123,
                        child: Image.network(
                          'https://firebasestorage.googleapis.com/v0/b/codeless-app.appspot.com/o/projects%2F0RjDuTVp_UGTv6g3KECl%2Fdd7bddfca95a70360896ca2837fd2a8bd4929fa7star-medal%202.png?alt=media&token=8f83b222-bed8-4827-8b43-acd477d5ead7',
                          width: 39,
                          height: 45,
                          fit: BoxFit.cover,
                        ),
                      ),
                      ////////////////////////////// الواجبات المكتملة /////////////////////////////
                      const Positioned(
                        left: 115,
                        top: 120, // تعديل الموضع الأعلى للنص
                        child: Text(
                          'الواجبات المكتملة',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFF868686),
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Positioned(
                        left: 150,
                        top: 140, // تعديل الموضع للأسفل لعدد الواجبات
                        child: Text(
                          '$completedAssignments', // عرض الواجبات المكتملة
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Color(0xFF333333),
                            fontSize: 14, // يمكن تعديل حجم الخط حسب الرغبة
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      ////////////////////////////// النقاط المستحقة /////////////////////////////
                      const Positioned(
                        left: 270,
                        top: 120, // تعديل الموضع الأعلى للنص
                        child: Text(
                          'النقاط المستحقة',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFF868686),
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Positioned(
                        left: 300,
                        top: 140, // تعديل الموضع للأسفل لعدد النقاط
                        child: Text(
                          '$totalPoints', // عرض النقاط المستحقة
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Color(0xFF333333),
                            fontSize: 14, // يمكن تعديل حجم الخط حسب الرغبة
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      ////////////////////////////// مربع إضافة الجوائز /////////////////////////////
                      Positioned(
                        left: 20,
                        top: 285,
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => Addrewards(
                                        name: widget.name,
                                        avatar: widget.avatar,
                                      )), // استبدل NextPage بالصفحة المستهدفة
                            );
                          },
                          child: Container(
                            width: 170,
                            height: 170,
                            clipBehavior: Clip.hardEdge,
                            decoration: BoxDecoration(
                              color: const Color(0xFFDBC0E8),
                              borderRadius: BorderRadius.circular(32),
                            ),
                          ),
                        ),
                      ),
                      const Positioned(
                        left: 55,
                        top: 305,
                        child: SizedBox(
                          width: 138,
                          height: 31,
                          child: Text(
                            'إضافة جوائز ',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Color(0xFF333333),
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 120,
                        top: 350,
                        child: Container(
                          width: 106,
                          height: 112,
                          clipBehavior: Clip.hardEdge,
                          decoration: const BoxDecoration(
                            image: DecorationImage(
                              image: NetworkImage(
                                'https://firebasestorage.googleapis.com/v0/b/codeless-app.appspot.com/o/projects%2F0RjDuTVp_UGTv6g3KECl%2Fae94e6f648fa4d1dd3484dc643097d59c7c77cd2gift-box%201.png?alt=media&token=df86943e-2d06-4243-b3f4-289bbd8b51a0',
                              ),
                              fit: BoxFit.cover,
                            ),
                          ),
                          transform: Matrix4.identity()
                            ..scale(-1.0, 1.0), // Horizontal flip
                        ),
                      ),
                      ////////////////////////////// مربع إضافة واجب  /////////////////////////////
                      Positioned(
                        left: 205,
                        top: 285,
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => addHomework(
                                        name: widget.name,
                                        avatar: widget.avatar,
                                        isEditing: false,
                                      )), // استبدل NextPage بالصفحة المستهدفة
                            );
                          },
                          child: Container(
                            width: 170,
                            height: 170,
                            clipBehavior: Clip.hardEdge,
                            decoration: BoxDecoration(
                              color: const Color(0xFFCFE3E2),
                              borderRadius: BorderRadius.circular(32),
                            ),
                          ),
                        ),
                      ),
                      const Positioned(
                        left: 240,
                        top: 305,
                        child: SizedBox(
                          width: 138,
                          height: 31,
                          child: Text(
                            'إضافة واجب',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Color(0xFF333333),
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 305,
                        top: 350,
                        child: Container(
                          width: 106,
                          height: 112,
                          clipBehavior: Clip.hardEdge,
                          decoration: const BoxDecoration(
                            image: DecorationImage(
                              image: NetworkImage(
                                'https://firebasestorage.googleapis.com/v0/b/codeless-app.appspot.com/o/projects%2F0RjDuTVp_UGTv6g3KECl%2Faa2fca06dcc8834eabcb6042ce3acfa60cee3dc8homework.png?alt=media&token=a1783e49-9d26-4a91-bb75-751af4551bea',
                              ),
                              fit: BoxFit.cover,
                            ),
                          ),
                          transform: Matrix4.identity()
                            ..scale(-1.0, 1.0), // Horizontal flip
                        ),
                      ),
                      Positioned(
                        left: 20,
                        top: 490,
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => Rewards(
                                        name: widget.name,
                                        avatar: widget.avatar,
                                      )), // استبدل NextPage بالصفحة المستهدفة
                            );
                          },
                          child: Container(
                            width: 170,
                            height: 170,
                            clipBehavior: Clip.hardEdge,
                            decoration: BoxDecoration(
                              color: const Color(0xFFCCBEB7),
                              borderRadius: BorderRadius.circular(32),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 120,
                        top: 350,
                        child: Container(
                          width: 106,
                          height: 112,
                          clipBehavior: Clip.hardEdge,
                          decoration: const BoxDecoration(
                            image: DecorationImage(
                              image: NetworkImage(
                                'https://firebasestorage.googleapis.com/v0/b/codeless-app.appspot.com/o/projects%2F0RjDuTVp_UGTv6g3KECl%2Fae94e6f648fa4d1dd3484dc643097d59c7c77cd2gift-box%201.png?alt=media&token=df86943e-2d06-4243-b3f4-289bbd8b51a0',
                              ),
                              fit: BoxFit.cover,
                            ),
                          ),
                          transform: Matrix4.identity()
                            ..scale(-1.0, 1.0), // Horizontal flip
                        ),
                      ),
                      const Positioned(
                        left: 295,
                        top: 610,
                        child: SizedBox(
                          width: 60,
                          height: 31,
                          child: Text(
                            'الجوائز',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Color(0xFF333333),
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      ////////////////////////////// الخط الفاصل  /////////////////////////////
                      Positioned(
                        left: 30,
                        top: 473,
                        child: Image.network(
                          'https://storage.googleapis.com/codeless-app.appspot.com/uploads%2Fimages%2F0RjDuTVp_UGTv6g3KECl%2F25d23895-396b-4ba2-9a35-26f647dbe835.png',
                          width: 335,
                          height: 2,
                          fit: BoxFit.contain,
                        ),
                      ),
                      ///////////////////////////// شريط التقدم /////////////////////////////
                      Positioned(
                        left: 45,
                        top: 230,
                        child: Container(
                          width: 311,
                          height: 12,
                          clipBehavior: Clip.hardEdge,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(32),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x19000000),
                                spreadRadius: 0,
                                offset: Offset(2, 4),
                                blurRadius: 10,
                              )
                            ],
                          ),
                          child: LinearProgressIndicator(
                            value: totalPoints /
                                100, // تحديث النسبة بناءً على النقاط
                            backgroundColor: Colors.grey, // لون الخلفية
                            valueColor: AlwaysStoppedAnimation<Color>(
                              totalPoints >= 80
                                  ? Colors.green[
                                      800]! // اللون الأخضر الداكن عند 80-100 نقطة
                                  : totalPoints >= 60
                                      ? Colors.green[
                                          600]! // اللون الأخضر عند 60-79 نقطة
                                      : totalPoints >= 40
                                          ? Colors.yellow[
                                              700]! // اللون الأصفر عند 40-59 نقطة
                                          : totalPoints >= 20
                                              ? Colors.orange[
                                                  700]! // اللون البرتقالي عند 20-39 نقطة
                                              : Colors
                                                  .blue, // اللون الأزرق عند أقل من 20 نقطة
                            ),
                          ),
                        ),
                      ),
                      ///////////////////////////// نسبة شريط التقدم /////////////////////////////
                      Positioned(
                        left: 40,
                        top: 229,
                        child: SizedBox(
                          width: 43,
                          height: 16,
                          child: Text(
                            '${(totalPoints / 100 * 100).toStringAsFixed(0)}%', // النسبة المئوية للنقاط
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),

                      ////////////////////////////// الشعلات الخمسة  /////////////////////////////
                      Positioned(
                        left: 76,
                        top: 198,
                        child: buildFlameImage(progress, 'first'),
                      ),

                      Positioned(
                        left: 147,
                        top: 198,
                        child: buildFlameImage(progress, 'second'),
                      ),

                      Positioned(
                        left: 218,
                        top: 198,
                        child: buildFlameImage(progress, 'third'),
                      ),

                      Positioned(
                        left: 288,
                        top: 198,
                        child: buildFlameImage(progress, 'fourth'),
                      ),

                      Positioned(
                        left: 330,
                        top: 176,
                        child: Image.asset(
                          totalPoints >= 100
                              ? 'assets/images/prize.png' // ✅ تغيير الصورة عند الوصول إلى 100 نقطة
                              : 'assets/images/WhitePrize.png', // 🔹 الصورة الافتراضية
                          width: 70,
                          height: 70,
                          fit: BoxFit.contain,
                          alignment: Alignment.topLeft,
                        ),
                      ),

                      ////////////////////////////// نص الواجبات  /////////////////////////////
                      Positioned(
                        left: 205,
                        top: 490,
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => WeeklyHomework(
                                        name: widget.name,
                                        avatar: widget.avatar,
                                        isEditing: false,
                                      )), // استبدل NextPage بالصفحة المستهدفة
                            );
                          },
                          child: Container(
                            width: 170,
                            height: 170,
                            clipBehavior: Clip.hardEdge,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEDDD8),
                              borderRadius: BorderRadius.circular(32),
                            ),
                          ),
                        ),
                      ),
                      const Positioned(
                        left: 250,
                        top: 515,
                        child: SizedBox(
                          width: 138,
                          height: 31,
                          child: Text(
                            'الواجبات',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Color(0xFF333333),
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 200,
                        top: 560,
                        child: Container(
                          width: 106,
                          height: 112,
                          clipBehavior: Clip.hardEdge,
                          decoration: const BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage('assets/images/Homework.png'),
                              fit: BoxFit.cover,
                            ),
                          ),
                          transform: Matrix4.identity()
                            ..scale(1.0, 1.0), // Horizontal flip
                        ),
                      ),
                      const Positioned(
                        left: 70,
                        top: 515,
                        child: SizedBox(
                          width: 138,
                          height: 35,
                          child: Text(
                            'الجوائز',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Color(0xFF333333),
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 1,
                        top: 558,
                        child: Container(
                          width: 115,
                          height: 125,
                          clipBehavior: Clip.hardEdge,
                          decoration: const BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage('assets/images/Prize2.png'),
                              fit: BoxFit.cover,
                            ),
                          ),
                          transform: Matrix4.identity()
                            ..scale(1.0, 1.0), // Horizontal flip
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
