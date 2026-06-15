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
  ];
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
        MaterialPageRoute(
            builder: (context) => Child(
                  name: widget.name,
                  avatar: widget.avatar,
                  isEditing: false,
                )),
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

  // دالة لحذف الواجب
  void _deleteHomework(String homeworkId) async {
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
                Navigator.of(context).pop();
                _deleteHomework("homeworkId"); // Call the delete function
              },
              child: const Text('نعم'),
            ),
          ],
        );
      },
    );
  }

  // البحث عن الطفل باستخدام الاسم
  Future<void> fetchChildData(String name) async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('children')
          .where('name', isEqualTo: name)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        Map<String, dynamic> childData =
            querySnapshot.docs.first.data() as Map<String, dynamic>;

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

  @override
  Widget build(BuildContext context) {
    String formattedDate = DateFormat('yyyy/MM/dd').format(selectedDate);
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 185, 203, 217),
      body: Stack(
        children: [
          Positioned(
            top: 40,
            left: 210,
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
                  Stack(
                    alignment: AlignmentDirectional.bottomEnd,
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        child: CircleAvatar(
                          radius: 22,
                          backgroundImage: AssetImage(widget.avatar),
                        ),
                      ),
                      Positioned(
                        child: Container(
                          width: 25,
                          height: 25,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                          ),
                          child: IconButton(
                            icon: const Icon(
                              Icons.edit,
                              size: 15,
                              color: Colors.black,
                            ),
                            onPressed: () {
                              fetchChildData(widget.name);
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
                height: 620,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(32),
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
                                    ),
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
                              const Text(
                                ":قسم المادة",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: subjects.map((choice) {
                                  return ChoiceChip(
                                    label: Text(choice),
                                    selected: _selectedSubject == choice,
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

                              const Text(
                                ":(بالدقائق)المدة",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              //المؤقت
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: minutes.map((choice) {
                                  return ChoiceChip(
                                    label: Text(choice),
                                    selected: _selectedMinutes == choice,
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
                                formattedDate,
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
                                  backgroundColor: Colors.white,
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      formattedDate,
                                      style: const TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.w300),
                                    ),
                                    const SizedBox(width: 10),
                                    const Icon(
                                      Icons.edit,
                                      size: 20,
                                      color: Colors.black,
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
                                  spacing: 30.0,
                                  runSpacing: 4.0,
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
                            backgroundColor:
                                const Color.fromARGB(255, 255, 137, 119),
                            foregroundColor: Colors.black,
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
                            backgroundColor:
                                const Color.fromARGB(255, 187, 221, 108),
                            foregroundColor: Colors.black,
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

          Positioned(
            bottom: 20,
            left: 110,
            child: Align(
              alignment: AlignmentDirectional.bottomCenter,
              child: Container(
                width: 172,
                height: 58,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 34, 166, 215),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
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
