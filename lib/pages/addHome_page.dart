import 'package:firebase_core/firebase_core.dart';
import 'package:jathwa1/pages/addChild_page.dart';
import 'package:jathwa1/pages/child_page.dart';
import 'package:jathwa1/pages/homeTwo_page.dart';
import 'package:jathwa1/pages/profile_page.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
}

class addHomework extends StatefulWidget {
  final bool isEditing;
  final Map<String, dynamic>? homeworkData;
  final String? homeworkId;
  final String name;
  final String avatar;

  const addHomework({
    Key? key,
    required this.isEditing,
    this.homeworkData,
    this.homeworkId,
    required this.name,
    required this.avatar,
  }) : super(key: key);

  @override
  State<addHomework> createState() => _AddhomeworkState();
}

class _AddhomeworkState extends State<addHomework> {
  static const List<String> subjects = [
    "علوم 🔬",
    "أدب 📜",
    "دين 🕌",
    "فنون 🎨"
  ]; // قائمة الخيارات
  static const List<String> activities = [
    "نط الحبل",
    "رقص",
    "Jumping jacks",
    "جري",
    "Cross body",
    "Game by VR"
  ];
  static const List<String> minutes = ["60", "45", "30", "20"];
  String? _selectedSubject;
  String? _selectedActivity;
  String? _selectedMinutes;
  String? _subjectName;
  DateTime selectedDate = DateTime.now();

  void initState() {
    super.initState();
    if (widget.isEditing && widget.homeworkData != null) {
      _subjectName = widget.homeworkData!['subjectName'];
      _selectedSubject = widget.homeworkData!['subject'];
      _selectedActivity = widget.homeworkData!['activity'];
      _selectedMinutes = widget.homeworkData!['minutes'];

      // التأكد من تحويل التاريخ بشكل صحيح
      var date = widget.homeworkData!['date'];
      if (date is Timestamp) {
        selectedDate = date.toDate(); 
      } else if (date is String) {
        selectedDate = DateTime.parse(date); 
      }
    }
  }

  Future<void> _saveHomework() async {
    if (_selectedSubject == null ||
        _selectedActivity == null ||
        _selectedMinutes == null ||
        _subjectName == null ||
        _subjectName!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('الرجاء إكمال جميع الحقول')));
      return;
    }

    selectedDate = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      23,
      59,
    );

    final homework = {
      'subjectName': _subjectName,
      'subject': _selectedSubject,
      'activity': _selectedActivity,
      'minutes': _selectedMinutes,
      'name': widget.name,
      'addedAt': FieldValue.serverTimestamp(),
      'date': Timestamp.fromDate(selectedDate), 
    };

    try {
      if (widget.isEditing && widget.homeworkId != null) {
        await FirebaseFirestore.instance
            .collection('homeworks')
            .doc(widget.homeworkId)
            .update(homework);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم تعديل الواجب بنجاح')),
        );
      } else {
        // إضافة واجب جديد
        await FirebaseFirestore.instance.collection('homeworks').add(homework);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تمت إضافة الواجب بنجاح')),
        );
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) =>  Child(name:widget.name , avatar: widget.avatar, isEditing: false,)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حدث خطأ: $e')),
      );
    }
  }

  // عرض وقت الإضافة عند استرداد البيانات
  Widget _buildHomeworkCard(Map<String, dynamic> homeworkData) {
    final timestamp =
        homeworkData['addedAt'] as Timestamp?; // استرداد الطابع الزمني
    final addedAt = timestamp != null
        ? DateFormat('yyyy-MM-dd HH:mm').format(timestamp.toDate())
        : 'غير معروف'; // تحويل الطابع الزمني إلى نص

    return Card(
      child: ListTile(
        title: Text(homeworkData['subjectName'] ?? 'واجب بدون اسم'),
        subtitle: Text('تمت الإضافة في: $addedAt'),
      ),
    );
  }

  void _deleteHomework(String homeworkId) async {
    // دالة لحذف الواجب
    try {
      await FirebaseFirestore.instance
          .collection('homeworks')
          .doc(homeworkId)
          .delete();
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => const homeTwo()));
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('تم حذف الواجب بنجاح')));
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('حدث خطأ أثناء الحذف: $e')));
    }
  }

  void _showDeletConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('هل تريد حذف الواجب؟'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('إلغاء'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                _deleteHomework("homeworkId"); // Call the delete function
              },
              child: const Text('نعم'),
            ),
          ],
        );
      },
    );
  }

  Future<void> fetchChildData(String name) async {
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

  @override
  Widget build(BuildContext context) {
    String formattedDate = DateFormat('yyyy/MM/dd')
        .format(selectedDate); // استخدام selectedDate هنا
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 185, 203, 217),
      body: Stack(
        children: [
          Positioned(
            top: 40, // المسافة من الأعلى
            left: 210, // المسافة من اليمين
            child: Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Positioned(
                    left: 230,
                    top: 40,
                    child: Text(
                      widget.name,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color.fromARGB(255, 0, 0, 0),
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  //avatar
                  Stack(
                    alignment: AlignmentDirectional.bottomEnd,
                    children: [
                      Container(
                        width: 80, // عرض الصورة مع الإطار
                        height: 80, // ارتفاع الصورة مع الإطار

                        child: CircleAvatar(
                          radius: 22, // تقليل حجم الصورة
                          backgroundImage: AssetImage(widget.avatar),
                        ),
                      ),
                      // زر تعديل المعلومات
                      Positioned(
                        child: Container(
                          width: 25,
                          height: 25,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle, // جعل الزر دائريًا
                            color: Colors.white, // لون الخلفية
                          ),
                          child: IconButton(
                            icon: const Icon(
                              Icons.edit,
                              size: 15,
                              color: Colors.black,
                            ),
                            onPressed: () {
                              fetchChildData(widget
                                  .name); // استدعاء الدالة وتمرير اسم الطفل
                            },
                          ),
                        ),
                      ),
                    ],
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
                height: 620, // عرض المستطيل
                padding: const EdgeInsets.all(20), // حشو العناصر
                decoration: BoxDecoration(
                  color: Colors.white, // لون الخلفية
                  borderRadius: BorderRadius.circular(32), // استدارة الحواف
                ),
                child: ListView(
                  children: [
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
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => Child(
                                      name: widget.name,
                                      avatar: widget.avatar,
                                       isEditing: false,
                                    ), // الصفحة التي تريد الانتقال إليها
                                  ),
                                );
                              },
                            ),
                            const Text(
                              ":إضافة واجب",
                              style: TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // البيانات
                        Center(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Text(
                                ":اسم المادة",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 10),
                              SizedBox(
                                height: 45,
                                child: TextField(
                                  onChanged: (value) {
                                    setState(() {
                                      _subjectName = value;
                                    });
                                  },
                                  decoration: InputDecoration(
                                    hintText: "اسم المادة",
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
                              // قسم المادة
                              const Text(
                                ":قسم المادة",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment
                                    .spaceBetween, // مسافة بين الخيارات
                                children: subjects.map((choice) {
                                  return ChoiceChip(
                                    label: Text(choice),
                                    selected: _selectedSubject ==
                                        choice, // اختيار الخيار الحالي
                                    selectedColor: const Color.fromARGB(
                                        255, 207, 227, 226),
                                    backgroundColor: Colors.white,
                                    onSelected: (isSelected) {
                                      setState(() {
                                        _selectedSubject =
                                            isSelected ? choice : null;
                                      });
                                    },
                                  );
                                }).toList(),
                              ),

                              const SizedBox(
                                height: 18,
                              ),

                              //المدة
                              const Text(
                                ":(بالدقائق)المدة",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              //المؤقت
                              Row(
                                mainAxisAlignment: MainAxisAlignment
                                    .spaceBetween, // مسافة بين الخيارات
                                children: minutes.map((choice) {
                                  return ChoiceChip(
                                    label: Text(choice),
                                    selected: _selectedMinutes ==
                                        choice, // اختيار الخيار الحالي
                                    selectedColor: const Color.fromARGB(
                                        255, 207, 227, 226),
                                    backgroundColor: Colors.white,
                                    onSelected: (isSelected) {
                                      setState(() {
                                        _selectedMinutes =
                                            isSelected ? choice : null;
                                      });
                                    },
                                  );
                                }).toList(),
                              ),
                              const SizedBox(
                                height: 18,
                              ),

                              //التاريخ
                              Text(
                                formattedDate, // عرض التاريخ المنسق
                                style: const TextStyle(
                                    fontSize: 17, fontWeight: FontWeight.w300),
                              ),
                              const Text(
                                ":التاريخ",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              ElevatedButton(
                                onPressed: () async {
                                  DateTime? pickedDate = await showDatePicker(
                                    context: context,
                                    initialDate: selectedDate,
                                    firstDate: DateTime(2000),
                                    lastDate: DateTime(2101),
                                  );

                                  if (pickedDate != null &&
                                      pickedDate != selectedDate &&
                                      pickedDate.weekday != DateTime.friday &&
                                      pickedDate.weekday != DateTime.saturday) {
                                    setState(() {
                                      selectedDate = pickedDate;
                                    });
                                  } else if (pickedDate != null &&
                                      (pickedDate.weekday == DateTime.friday ||
                                          pickedDate.weekday ==
                                              DateTime.saturday)) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                            'لا يمكن اختيار يوم الجمعة أو السبت'),
                                      ),
                                    );
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  foregroundColor: Colors.black,
                                  backgroundColor: Colors.white, // لون الخلفية
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize
                                      .min, // تصغير الحجم ليتناسب مع المحتوى
                                  children: [
                                    Text(
                                      formattedDate, // عرض التاريخ المنسق
                                      style: const TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.w300),
                                    ),
                                    const SizedBox(
                                        width: 10), // مسافة بين النص والأيقونة
                                    const Icon(
                                      Icons.edit, // الأيقونة بجانب التاريخ
                                      size: 20,
                                      color: Colors.black, // لون الأيقونة
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(
                                height: 18,
                              ),

                              //نوع النشاط
                              const Text(
                                ":نوع النشاط",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Center(
                                child: Wrap(
                                  // استخدام Wrap لتجنب تجاوز العناصر
                                  spacing: 30.0, // مسافة أفقية بين العناصر
                                  runSpacing: 4.0, // مسافة رأسية بين الصفوف
                                  children: activities.map((choice) {
                                    return ChoiceChip(
                                      label: Text(choice),
                                      selected: _selectedActivity == choice,
                                      selectedColor: const Color.fromARGB(
                                          255, 207, 227, 226),
                                      backgroundColor: Colors.white,
                                      onSelected: (isSelected) {
                                        setState(() {
                                          _selectedActivity =
                                              isSelected ? choice : null;
                                        });
                                      },
                                    );
                                  }).toList(),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            _showDeletConfirmationDialog(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color.fromARGB(
                                255, 255, 137, 119), // لون الزر
                            foregroundColor: Colors.black, // لون النص
                          ),
                          child: const Text(
                            "حذف",
                            style: TextStyle(
                                fontSize: 17, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(
                          width: 20,
                        ),
                        ElevatedButton(
                          onPressed: () {
                            _saveHomework();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color.fromARGB(
                                255, 187, 221, 108), // لون الزر
                            foregroundColor: Colors.black, // لون النص
                          ),
                          child: const Text(
                            "حفظ",
                            style: TextStyle(
                                fontSize: 17, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 80)
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
                            MaterialPageRoute(
                                builder: (context) => const Profile()),
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
}

// رسالة التأكيد عند الحذف
