import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:jathwa1/pages/addChild_page.dart';
import 'package:jathwa1/pages/child_page.dart';
import 'package:jathwa1/pages/homeTwo_page.dart';
import 'package:jathwa1/pages/profile_page.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
    );
  }
}

class Addrewards extends StatefulWidget {
  final String name;
  final String avatar;

  const Addrewards({
    Key? key,
    required this.name,
    required this.avatar,
  }) : super(key: key);

  @override
  _AddrewardsState createState() => _AddrewardsState();
}

class _AddrewardsState extends State<Addrewards> {
  final List<TextEditingController> nameControllers = [];
  final List<File?> imageFiles = List.generate(3, (index) => null);

  Future<void> pickImage(int index) async {
    final ImagePicker picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        imageFiles[index] = File(pickedFile.path);
      });
    }
  }

  // تخزين الجوائز في قائمة
  void saveRewards() async {
    try {
      final List<Map<String, dynamic>> rewards = [];
      for (int i = 0; i < 3; i++) {
        if (nameControllers[i].text.isNotEmpty && imageFiles[i] != null) {
          final fileName =
              'reward_image_${i}_${DateTime.now().millisecondsSinceEpoch}.jpg';
          print('Attempting to upload image with filename: $fileName');

          final imageUrl =
              await uploadImageToSupabase(imageFiles[i]!, fileName);
          print('Received imageUrl: $imageUrl');

          // إضافة الجائزة للقائمة
          if (imageUrl != null) {
            rewards.add({
              'name': nameControllers[i].text,
              'imageUrl': imageUrl,
              'week': i + 1,
              'month': DateTime.now().month,
            });
            print('Added to rewards array: ${rewards.last}');
          } else {
            print('Failed to get imageUrl for reward $i');
          }
        }
      }

      // التحقق من أن هناك جوائز لحفظها
      if (rewards.isNotEmpty) {
        for (var reward in rewards) {
          // إدخال كل جائزة على حدة
          final response = await Supabase.instance.client
              .from('rewards')
              .insert(reward)
              .select(); 

          if (response != null) {
            print('تم إدخال الجائزة بنجاح: $response');
          } else {
            print('خطأ أثناء إدخال الجائزة');
          }
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تم حفظ جميع الجوائز بنجاح!'),
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('لم يتم العثور على جوائز صالحة للحفظ!'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      print('Error saving rewards: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('حدث خطأ أثناء حفظ الجوائز!'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<String?> uploadImageToSupabase(File image, String fileName) async {
    try {
      // Debug print before upload
      print('Starting upload for file: $fileName');
      print('File path: ${image.path}');

      // Upload file to Supabase storage
      final response =
          await Supabase.instance.client.storage.from('images').upload(
                fileName,
                image,
                fileOptions: FileOptions(cacheControl: '3600', upsert: true),
              );

      print('Upload response: $response');

      // Get public URL after successful upload
      final publicUrl = await Supabase.instance.client.storage
          .from('images')
          .getPublicUrl(fileName);

      print('Generated public URL: $publicUrl');
      return publicUrl;
    } catch (e) {
      print('Error in uploadImageToSupabase: $e');
      return null;
    }
  }

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < 3; i++) {
      nameControllers.add(TextEditingController());
    }
  }

  @override
  void dispose() {
    for (var controller in nameControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> fetchChildData(String name) async {
    try {
      // البحث عن الطفل باستخدام الاسم
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('children')
          .where('name', isEqualTo: name) // البحث بناءً على الاسم
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
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 185, 207, 217),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(
                left: 20, right: 20, top: 65),
            child: Row(
              mainAxisAlignment:
                  MainAxisAlignment.end,
              children: [
                Row(
                  children: [
                    Text(
                      widget.name,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(
                        width: 10),
                    Stack(
                      clipBehavior: Clip
                          .none,
                      children: [
                        CircleAvatar(
                          radius: 31,
                          backgroundImage: AssetImage(widget.avatar),
                        ),
                        Positioned(
                          bottom: -2, 
                          right: -5,
                          child: GestureDetector(
                            onTap: () {
                              fetchChildData(widget
                                  .name);
                            },
                            child: Container(
                              width: 25,
                              height: 25,
                              decoration: const BoxDecoration(
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
                              child: Icon(
                                Icons.edit,
                                size: 16,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              child: Stack(children: [
                Positioned.fill(
                  child: Container(
                    margin: const EdgeInsets.only(top: 20),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back_ios,
                                color: Colors.black),
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
                            'إلغاء',
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          const Padding(
                            padding: EdgeInsets.only(
                                top: 13),
                            child: Text(
                              'إضافة جوائز',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const SizedBox(height: 1),
                            ListView.builder(
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: 3,
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 16),
                                  child: RewardInputCard(
                                    week: index + 1,
                                    nameController: nameControllers[index],
                                    onPickImage: () => pickImage(index),
                                    image: imageFiles[index],
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 20),

                            Center(
                              child: ElevatedButton(
                                onPressed: saveRewards,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.lightGreen,
                                  minimumSize: Size(150, 40),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                ),
                                child: Text(
                                  'حفظ',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            buildBottomNavigationBar(context)
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class RewardInputCard extends StatelessWidget {
  final int week;
  final TextEditingController nameController;
  final VoidCallback onPickImage;
  final File? image;

  const RewardInputCard({
    required this.week,
    required this.nameController,
    required this.onPickImage,
    required this.image,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          ' : جائزة الأسبوع $week (المستوى ${getLevel(week)})',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: TextField(
                controller: nameController,
                textAlign: TextAlign.right,
                decoration: InputDecoration(
                  hintText: ': اسم الجائزة',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 1,
              child: GestureDetector(
                onTap: onPickImage,
                child: Container(
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: image == null
                      ? const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_photo_alternate_outlined,
                                size: 40, color: Colors.black),
                            Text(
                              'اضغط لإضافة صورة',
                              style: TextStyle(color: Colors.black54),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.file(
                            image!,
                            fit: BoxFit.cover,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  String getLevel(int week) {
    switch (week) {
      case 1:
        return 'الأول';
      case 2:
        return 'الثاني';
      case 3:
        return 'الثالث';
      default:
        return '';
    }
  }
}

Widget buildBottomNavigationBar(BuildContext context) {
  return Positioned(
    left: 115,
    top: 660,
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
                  MaterialPageRoute(builder: (context) => const homeTwo()),
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
  );
}
