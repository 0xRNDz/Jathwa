
import 'package:jathwa1/pages/homeTwo_page.dart';
import 'package:jathwa1/pages/profile_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Addchild extends StatefulWidget {
  final bool isEditing;
  final Map<String, dynamic>? childData;
  final String? childId;

  const Addchild({
    Key? key,
    required this.isEditing,
    this.childData,
    this.childId,
  }) : super(key: key);

  @override
  State<Addchild> createState() => _AddchildState();
}

class _AddchildState extends State<Addchild> {
  final TextEditingController _nameController = TextEditingController();
  Color _favoriteColor = Colors.grey;
  String avatarPath = 'assets/images/profile.jpg';

  // وظيفة لحفظ بيانات الطفل في Firestore
  Future<void> saveChildToDatabase() async {
    String childName = _nameController.text.trim();

    if (childName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى إدخال اسم الطفل')),
      );
      return;
    }

    try {
      if (widget.isEditing && widget.childId != null) {
        // تحديث بيانات الطفل
        await FirebaseFirestore.instance
            .collection('children')
            .doc(widget.childId)
            .update({
          'name': childName,
          'favorite_color': _favoriteColor.value.toString(),
          'avatar': avatarPath,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم تعديل بيانات الطفل بنجاح')),
        );
      } else {
        // إضافة طفل جديد
        await FirebaseFirestore.instance.collection('children').add({
          'name': childName,
          'favorite_color': _favoriteColor.value.toString(),
          'avatar': avatarPath,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تمت إضافة الطفل بنجاح')),
        );
      }

      // الانتقال إلى الصفحة الرئيسية بعد الحفظ
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const homeTwo()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حدث خطأ: $e')),
      );
    }
  }

  void _changeAvatar(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('ما الصورة المناسبة لي؟'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: List.generate(9, (index) {
                    final imagePath = 'assets/images/face${index + 1}.jpeg';
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          avatarPath = imagePath;
                        });
                        Navigator.of(context).pop();
                      },
                      child: ClipOval(
                        child: Image.asset(
                          imagePath,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('إلغاء'),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();

    if (widget.isEditing && widget.childData != null) {
      // استرجاع البيانات من الحقول
      _nameController.text = widget.childData!['name'] ?? '';
      avatarPath = widget.childData!['avatar'] ?? 'assets/images/profile.jpg';
      _favoriteColor = widget.childData!['favorite_color'] != null
          ? Color(int.parse(widget.childData!['favorite_color']))
          : Colors.grey;
    }
  }

  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: Image.asset(
              'assets/images/Background.jpg',
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            top: 60,
            left: 210,
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
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 187, 221, 108),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.add,
                        color: Colors.black,
                        size: 30,
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const Addchild(
                                  isEditing: false,
                                )),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(top: 120),
              child: Container(
                width: 430,
                height: 800,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(32),
                ),
                child: ListView(children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: const Text("إلغاء",
                                style: TextStyle(
                                  fontSize: (20),
                                  color: Colors.red,
                                )),
                            onPressed: () {
                              if (widget.isEditing) {
                                // إذا كان في وضع التعديل، أعده إلى صفحة Child
                                Navigator.pop(context);
                              } else {
                                // إذا لم يكن في وضع التعديل، أعده إلى الصفحة الافتراضية homeTwo
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const homeTwo()),
                                );
                              }
                            },
                          ),
                          const Text(
                            ":إضافة طفل",
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 50),
                      Center(
                        child: Stack(
                          alignment: AlignmentDirectional.bottomEnd,
                          children: [
                            Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.black,
                                  width: 2,
                                ),
                              ),
                              child: ClipOval(
                                child: Image.asset(
                                  avatarPath,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 5,
                              right: 5,
                              child: Container(
                                width: 35,
                                height: 35,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                ),
                                child: IconButton(
                                  icon: const Icon(
                                    Icons.edit,
                                    size: 20,
                                    color: Colors.black,
                                  ),
                                  onPressed: () {
                                    _changeAvatar(context);
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Center(
                        child: Column(
                          children: [
                            const Text(
                              "ما اسمي؟",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 10),
                            SizedBox(
                              height: 45,
                              width: 190,
                              child: TextField(
                                controller: _nameController,
                                decoration: InputDecoration(
                                  hintText: 'اسم الطفل',
                                  hintStyle: const TextStyle(fontSize: 16),
                                  filled: true,
                                  fillColor: Colors.white,
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(
                                      color: Colors.grey,
                                      width: 1.5,
                                    ),
                                  ),
                                ),
                                textAlign: TextAlign.end,
                              ),
                            ),
                            const SizedBox(height: 18),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    _showColorPicker(context);
                                  },
                                  child: Container(
                                    width: 30,
                                    height: 30,
                                    decoration: BoxDecoration(
                                      color: _favoriteColor,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                const Text(
                                  "ما لوني المفضل؟",
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.right,
                                ),
                              ],
                            ),
                            const SizedBox(height: 18),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ElevatedButton(
                                  onPressed: () {
                                    _showDeletConfirmationDialog(context);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color.fromARGB(
                                        255, 255, 137, 119),
                                    foregroundColor: Colors.black,
                                  ),
                                  child: const Text(
                                    "حذف",
                                    style: TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                const SizedBox(width: 20),
                                ElevatedButton(
                                  onPressed:
                                      saveChildToDatabase, // الدالة المسؤولة عن الحفظ أو التعديل
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color.fromARGB(
                                        255, 187, 221, 108), // لون الزر
                                    foregroundColor: Colors.black, // لون النص
                                  ),
                                  child: Text(
                                    widget.isEditing
                                        ? 'تعديل'
                                        : 'أضف طفلي', // النص يتغير حسب وضع الصفحة
                                    style: const TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 80),
                          ],
                        ),
                      ),
                    ],
                  ),
                ]),
              ),
            ),
          ),
          //مستطيل التنقل
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
                                builder: (context) =>
                                    const homeTwo()), // الانتقال إلى صفحة الأطفال
                          );
                        },
                      ),
                      const SizedBox(width: 20), // مسافة بين الأيقونات
                      IconButton(
                        icon: const Icon(
                          Icons.person, // الأيقونة الثانية
                          size: 40,
                          color: Color.fromARGB(
                              255, 183, 224, 255), // لون الأيقونة
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const Profile()), // الانتقال إلى صفحة الملف الشخصي
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  void _showColorPicker(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("اختيار اللون المفضل"),
          content: SingleChildScrollView(
            child: BlockPicker(
              pickerColor: _favoriteColor,
              onColorChanged: (color) {
                setState(() {
                  _favoriteColor = color;
                });
              },
            ),
          ),
          actions: [
            TextButton(
              child: const Text("إغلاق"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

 void _showDeletConfirmationDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: const Text('هل أنت متأكد أنك تريد حذف بيانات الطفل؟'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // إغلاق نافذة التأكيد
            },
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () async {
              try {
                Navigator.of(context).pop(); // إغلاق نافذة التأكيد
                
                // التحقق إذا كان في وضع التعديل ولديه معرف الطفل
                if (widget.isEditing && widget.childId != null) {
                  // حذف الطفل من قاعدة البيانات
                  await FirebaseFirestore.instance
                      .collection('children')
                      .doc(widget.childId) // حذف بناءً على معرف الطفل
                      .delete();

                  // عرض رسالة نجاح
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('تم حذف الطفل بنجاح')),
                  );

                  // إعادة التوجيه إلى صفحة homeTwo
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const homeTwo()),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('تعذر حذف الطفل: المعرف غير موجود')),
                  );
                }
              } catch (e) {
                // عرض رسالة خطأ
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('حدث خطأ أثناء الحذف: $e')),
                );
              }
            },
            child: const Text('حذف'),
          ),
        ],
      );
    },
  );
}
}