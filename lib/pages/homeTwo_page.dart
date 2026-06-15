import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:jathwa1/pages/addChild_page.dart';
import 'package:jathwa1/pages/child_page.dart';
import 'package:jathwa1/pages/homeOne_page.dart';
import 'package:jathwa1/pages/profile_page.dart';
import 'package:flutter/material.dart';

class homeTwo extends StatefulWidget {
  const homeTwo({super.key});

  @override
  State<homeTwo> createState() => _homeTwoState();
}

class _homeTwoState extends State<homeTwo> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: Image.asset(
              'images/Background.jpg',
              fit: BoxFit.cover,
            ),
          ),

          // Header Section (Title + "+" Button)
          Positioned(
            top: 60,
            right: 20,
            child: Row(
              children: [
                const Text(
                  ":أطفالك",
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 20),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => Addchild(
                                isEditing: false,
                              )),
                    );
                  },
                  child: Container(
                    width: 50,
                    height: 50,
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
                ),
              ],
            ),
          ),

          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
              height: 600,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(32),
                  topRight: Radius.circular(32),
                ),
              ),
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('children')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    Future.delayed(Duration.zero, () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const homeOne(),
                        ),
                      );
                    });
                  }

                  final children = snapshot.data!.docs;

                  return GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 3.6 / 2.6,
                    ),
                    itemCount: children.length,
                    itemBuilder: (context, index) {
                      final child =
                          children[index].data() as Map<String, dynamic>;
                      final String name = child['name'] ?? 'بدون اسم';
                      final String avatar = child['avatar'] ?? '';
                      final int favoriteColorValue =
                          int.parse(child['favorite_color'] ?? '0');
                      final Color favoriteColor = Color(favoriteColorValue);

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => Child(
                                      name: name,
                                      avatar: avatar,
                                      isEditing: false,
                                    )),
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: favoriteColor,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 4,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: Stack(
                            children: [
                              Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    CircleAvatar(
                                      radius: 36, 
                                      backgroundImage: AssetImage(avatar),
                                      backgroundColor: Colors.white,
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      name,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Positioned(
                                top: 8,
                                right: 8,
                                child: Row(
                                  children: const [
                                    Text(
                                      "3",
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.yellow,
                                      ),
                                    ),
                                    SizedBox(width: 4),
                                    Icon(
                                      Icons.star_outlined,
                                      color: Colors.yellow,
                                      size: 15,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
          Positioned(
            bottom: 7,
            left: 110,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                margin: const EdgeInsets.only(bottom: 20),
                width: 172,
                height: 58,
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
        ],
      ),
    );
  }
}
