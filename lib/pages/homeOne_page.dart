import 'package:jathwa1/pages/addChild_page.dart';
//import 'package:first_app/child_page.dart';
import 'package:jathwa1/pages/homeTwo_page.dart';
import 'package:jathwa1/pages/profile_page.dart';
import 'package:flutter/material.dart';

class homeOne extends StatefulWidget {
  const homeOne({super.key});

  @override
  State<homeOne> createState() => _home0neState();
}

class _home0neState extends State<homeOne> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // الخلفية
          SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: Image.asset(
              'images/Background.jpg',
              fit: BoxFit.cover,
            ),
          ),

          Positioned(
            top: 60, // المسافة من الأعلى
            left: 210, // المسافة من اليمين
            child: Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Text(
                    ":أطفالك",
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 20),
                  IconButton(
                    icon: Container(
                      width: 30, // العرض
                      height: 30, // الارتفاع
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(
                            255, 187, 221, 108), // لون الخلفية
                        shape: BoxShape.circle, // جعلها دائرة
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5), // ظل خفيف
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: const Offset(0, 3), // تحديد موقع الظل
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.add, // الأيقونة
                        color: Colors.black, // لون الأيقونة
                        size: 30, // حجم الأيقونة
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                const Addchild(isEditing: false)),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),

          // المحتوى
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(top: 120),
              child: Container(
                width: 430,
                height: 800, // عرض المستطيل
                padding: const EdgeInsets.all(20), // حشو العناصر
                decoration: BoxDecoration(
                  color: Colors.white, // لون الخلفية
                  borderRadius: BorderRadius.circular(32), // استدارة الحواف
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    ),

                    const SizedBox(height: 200),
                    // البيانات
                    Center(
                      child: Column(
                        children: [
                          const Text(
                            "لا يوجد أطفال مضافين بعد",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          //const SizedBox(height: 10),

                          const SizedBox(height: 50),

                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const Addchild(
                                          isEditing: false,
                                        )),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color.fromARGB(
                                  255, 187, 221, 108), // لون الزر
                              foregroundColor: Colors.black, // لون النص
                            ),
                            child: const Text(
                              'أضف طفلي',
                              style: TextStyle(
                                  fontSize: 17, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // مستطيل التنقل
          Positioned(
            bottom: 20,
            left: 110,
            child: Align(
              alignment: AlignmentDirectional.bottomCenter,
              child: Container(
                width: 172, // عرض المستطيل
                height: 58, // ارتفاع المستطيل
                padding:
                    const EdgeInsets.symmetric(horizontal: 10), // حشو داخلي
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 34, 166, 215), // لون الخلفية
                  borderRadius: BorderRadius.circular(18), // استدارة الحواف
                ),
                child: Center(
                  child: Row(
                    mainAxisAlignment:
                        MainAxisAlignment.center, // توسيط الأيقونات أفقيًا
                    crossAxisAlignment:
                        CrossAxisAlignment.center, // توسيط الأيقونات عموديًا
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.grid_view_rounded, // الأيقونة الأولى
                          size: 40,
                          color: Color.fromARGB(
                              255, 183, 224, 255), // لون الأيقونة
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const homeTwo()),
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
                            MaterialPageRoute(builder: (context) => Profile()),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // عرض الـ Color Picker
}
