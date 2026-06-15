import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:jathwa1/pages/addChild_page.dart';
import 'package:jathwa1/pages/child_page.dart';
import 'package:jathwa1/pages/homeTwo_page.dart';
import 'package:jathwa1/pages/profile_page.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<Map<String, List<Map<String, dynamic>>>>
    fetchChallengesAndRewards() async {
  try {
    final challengesSnapshot =
        await FirebaseFirestore.instance.collection('challenges').get();
    final challenges = challengesSnapshot.docs.map((doc) {
      final data = doc.data();
      return {
        'message': data['message'] ?? 'بدون رسالة',
        'points': data['points'] ?? 0,
        'completedAt': data['completedAt']?.toDate() ?? DateTime.now(),
      };
    }).toList();

    final rewardsResponse =
        await Supabase.instance.client.from('rewards').select();

    final rewards = (rewardsResponse as List).map((reward) {
      return {
        'name': reward['name'] ?? 'بدون اسم',
        'imageUrl': reward['imageUrl'] ?? '',
        'week': reward['week'] ?? 0,
        'month': reward['month'] ?? 0,
      };
    }).toList();

    return {
      'challenges': challenges,
      'rewards': rewards,
    };
  } catch (e) {
    print('Error fetching challenges and rewards: $e');
    return {
      'challenges': [],
      'rewards': [],
    };
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
    );
  }
}

class Rewards extends StatelessWidget {
  final String name;
  final String avatar;

  const Rewards({
    Key? key,
    required this.name,
    required this.avatar,
  }) : super(key: key);

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

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Addchild(
              isEditing: true,
              childData: childData,
              childId: querySnapshot.docs.first.id,
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

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 185, 207, 217),
      body: FutureBuilder<Map<String, List<Map<String, dynamic>>>>(
        future: fetchChallengesAndRewards(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError || !snapshot.hasData) {
            return Center(
              child: Text('حدث خطأ أثناء تحميل البيانات.'),
            );
          }

          final challenges = snapshot.data!['challenges']!;
          final rewards = snapshot.data!['rewards']!;

          return Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                top: 110,
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  height: 700,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(32),
                      topRight: Radius.circular(32),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 40,
                right: 20,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    CircleAvatar(
                      radius: 31,
                      backgroundImage: AssetImage(avatar),
                    ),
                    Positioned(
                      bottom: 0,
                      right: -5,
                      child: GestureDetector(
                        onTap: () {
                          fetchChildData(
                              context, name); // استدعاء الدالة وتمرير اسم الطفل
                        },
                        child: Container(
                          width: 25,
                          height: 25,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(3.8),
                            child: Image.asset(
                              'assets/images/edit.png',
                              width: 16,
                              height: 16,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 50,
                right: 90,
                child: Text(
                  name,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Positioned(
                top: 120,
                left: 16,
                right: 16,
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back, color: Colors.black),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Child(
                              name: name,
                              avatar: avatar,
                              isEditing: false,
                            ),
                          ),
                        );
                      },
                    ),
                    Spacer(),
                    Text(
                      'الإنجازات',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 180,
                left: 16,
                right: 16,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.3),
                        spreadRadius: 2,
                        blurRadius: 6,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          Row(
                            children: [
                              Image.asset(
                                'assets/images/Completed.png',
                                width: 40,
                                height: 40,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                ':الواجبات المكتملة',
                                style: TextStyle(
                                  color: Color(0xFF868686),
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 4),
                          Text(
                            '        0',
                            style: TextStyle(
                              color: Color(0xFF333333),
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        width: 1,
                        height: 40,
                        color: Colors.grey.shade300,
                      ),
                      Column(
                        children: [
                          Row(
                            children: [
                              Image.asset(
                                'assets/images/Medal.png',
                                width: 40,
                                height: 40,
                              ),
                              SizedBox(width: 8),
                              Text(
                                ':النقاط المستحقة',
                                style: TextStyle(
                                  color: Color(0xFF868686),
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 4),
                          Text(
                            '        0',
                            style: TextStyle(
                              color: Color(0xFF333333),
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              Positioned(
                left: 35,
                top: 310,
                child: Container(
                  width: 311,
                  height: 13,
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
              Positioned(
                left: 35,
                top: 310,
                child: Container(
                  width: 311,
                  height: 13,
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
              Positioned(
                left: 40,
                top: 310,
                child: SizedBox(
                  width: 43,
                  height: 16,
                  child: Text(
                    '0%',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 76,
                top: 278,
                child: Image.asset(
                  'assets/images/WhiteFire.png',
                  width: 28,
                  height: 40,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                left: 218,
                top: 278,
                child: Image.asset(
                  'assets/images/WhiteFire.png',
                  width: 28,
                  height: 40,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                left: 147,
                top: 278,
                child: Image.asset(
                  'assets/images/WhiteFire.png',
                  width: 28,
                  height: 40,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                left: 288,
                top: 278,
                child: Image.asset(
                  'assets/images/WhiteFire.png',
                  width: 28,
                  height: 40,
                  fit: BoxFit.cover,
                ),
              ),

              Positioned(
                left: 317,
                top: 250,
                child: Image.asset(
                  'assets/images/Empty.jpg',
                  width: 80,
                  height: 80,
                ),
              ),

              // Method call for challenges and rewards below the fire line

              Positioned(
                top: 360,
                left: 16,
                right: 16,
                bottom: 0,
                child: SizedBox(
                  height: MediaQuery.of(context).size.height - 360,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      buildChallengesAndRewards(challenges, rewards),
                      Positioned(
                        left: 115,
                        top: MediaQuery.of(context).size.height - 70,
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
                                          builder: (context) => Profile()),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget buildChallengesAndRewards(List<Map<String, dynamic>> challenges,
      List<Map<String, dynamic>> rewards) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  ':التحديات المكتملة',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.right,
                ),
                SizedBox(height: 16),
                ...challenges.asMap().entries.map((entry) {
                  final index = entry.key;
                  final challenge = entry.value;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      buildChallengeText(
                        challenge['message'],
                        challenge['points'],
                        challenge['completedAt'],
                      ),
                      if (index != challenges.length - 1)
                        Divider(thickness: 1, color: Colors.grey.shade300),
                    ],
                  );
                }),
              ],
            ),
          ),
          Container(
            width: 1,
            color: Colors.grey.shade300,
            margin: EdgeInsets.symmetric(horizontal: 16),
          ),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  ':الجوائز السابقة',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.right,
                ),
                SizedBox(height: 16),
                ...rewards.asMap().entries.map((entry) {
                  final index = entry.key;
                  final reward = entry.value;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      buildRewardItem(
                        reward['name'],
                        reward['imageUrl'],
                        reward['week'],
                        reward['month'],
                      ),
                      if (index != rewards.length - 1)
                        Divider(thickness: 1, color: Colors.grey.shade300),
                    ],
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildChallengeText(String message, int points, DateTime completedAt) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            message,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            textAlign: TextAlign.right,
          ),
          SizedBox(height: 4),
          Text(
            'النقاط المكتسبة: $points',
            style: TextStyle(fontSize: 12, color: Colors.grey),
            textAlign: TextAlign.right,
          ),
          Text(
            'تاريخ الإكمال: ${completedAt.toLocal().toString().split(' ')[0]}',
            style: TextStyle(fontSize: 12, color: Colors.grey),
            textAlign: TextAlign.right,
          ),
        ],
      ),
    );
  }

  Widget buildRewardItem(String name, String imageUrl, int week, int month) {
    const List<String> monthNames = [
      'يناير',
      'فبراير',
      'مارس',
      'أبريل',
      'مايو',
      'يونيو',
      'يوليو',
      'أغسطس',
      'سبتمبر',
      'أكتوبر',
      'نوفمبر',
      'ديسمبر'
    ];

    String monthName =
        (month >= 1 && month <= 12) ? monthNames[month - 1] : 'غير معروف';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                name,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.right,
              ),
              SizedBox(height: 4),
              Text(
                'الأسبوع: $week - الشهر: $monthName',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.right,
              ),
            ],
          ),
        ),
        SizedBox(width: 16),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            imageUrl,
            width: 50,
            height: 50,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) =>
                Icon(Icons.image_not_supported),
          ),
        ),
      ],
    );
  }

  Widget buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
        height: 1,
        color: Colors.grey.shade300,
      ),
    );
  }
}
