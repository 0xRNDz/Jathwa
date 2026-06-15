import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:jathwa1/pages/homeTwo_page.dart';
import 'package:jathwa1/pages/login_page.dart';
import 'package:flutter/material.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  bool _isPasswordObscured = true; // للتحكم في عرض/إخفاء كلمة المرور
  bool _isEditing = false; // للتحكم في تحرير النصوص

  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  String password = '';

  @override
  void initState() {
    super.initState();
    fetchUserData().then((data) {
      setState(() {
        firstNameController.text = data['firstName'] ?? '';
        lastNameController.text = data['lastName'] ?? '';
        emailController.text = data['email'] ?? '';
        phoneController.text = data['phone'] ?? '';
        password = data['password'] ?? '';
      });
    });
  }

  Future<Map<String, dynamic>> fetchUserData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final docSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        if (docSnapshot.exists) {
          return docSnapshot.data()!;
        }
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
    return {};
  }

  Future<void> updateUserData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final Map<String, dynamic> updatedData = {};

        if (firstNameController.text.isNotEmpty) {
          updatedData['firstName'] = firstNameController.text;
        }
        if (lastNameController.text.isNotEmpty) {
          updatedData['lastName'] = lastNameController.text;
        }
        if (emailController.text.isNotEmpty) {
          updatedData['email'] = emailController.text;
        }
        if (phoneController.text.isNotEmpty) {
          updatedData['phone'] = phoneController.text;
        }

        if (updatedData.isNotEmpty) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .update(updatedData);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم تحديث البيانات بنجاح!'),
              duration: Duration(seconds: 2),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('لم يتم إجراء أي تعديل.'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      print('Error updating user data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('حدث خطأ أثناء تحديث البيانات!'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
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
            top: 50,
            left: 130,
            child: const Text(
              ": معلوماتك الشخصية",
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w700,
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
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          // أيقونة التعديل
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.edit,
                                  size: 25,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _isEditing = !_isEditing;
                                  });
                                },
                              ),
                              // أيقونة تسجيل الخروج
                              IconButton(
                                icon: const Icon(
                                  Icons.logout,
                                  size: 30,
                                  color: Colors.red,
                                ),
                                onPressed: () {
                                  _showConfirmationDialog(
                                    context,
                                    title: "هل تريد تسجيل الخروج؟",
                                    onConfirm: () async {
                                      await FirebaseAuth.instance.signOut();
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => LoginPage(),
                                        ),
                                      );
                                    },
                                  );
                                },
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),

                          Row(
                            children: [
                              Expanded(
                                child: _buildTextField(
                                  label: ": الاسم الأخير",
                                  controller: lastNameController,
                                  enabled: _isEditing,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _buildTextField(
                                  label: ": الاسم الأول",
                                  controller: firstNameController,
                                  enabled: _isEditing,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),
                          _buildTextField(
                            label: ": الإيميل",
                            controller: emailController,
                            keyboardType: TextInputType.emailAddress,
                            enabled: _isEditing,
                          ),
                          const SizedBox(height: 18),
                          _buildPasswordField(
                            label: ": كلمة المرور",
                            hint: password.replaceAll(RegExp('.'), '*'),
                            enabled: _isEditing,
                          ),
                          const SizedBox(height: 18),
                          _buildTextField(
                            enabled: _isEditing,
                            label: ": رقم الجوال",
                            controller: phoneController,
                            keyboardType: TextInputType.phone,
                          ),
                          const SizedBox(height: 20),
                          if (_isEditing)
                            Center(
                              child: ElevatedButton(
                                onPressed: () {
                                  _showConfirmationDialog(
                                    context,
                                    title: "هل تريد تحديث البيانات؟",
                                    onConfirm: () async {
                                      await updateUserData();
                                      setState(() {
                                        _isEditing = false;
                                      });
                                      Navigator.of(context).pop();
                                    },
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      const Color.fromARGB(255, 187, 221, 108),
                                  foregroundColor: Colors.black,
                                ),
                                child: const Text(
                                  "تحديث البيانات",
                                  style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
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
                    children: [
                      IconButton(
                        icon: const Icon(Icons.grid_view_rounded,
                            size: 40,
                            color: Color.fromARGB(255, 183, 224, 255)),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => homeTwo()),
                          );
                        },
                      ),
                      const SizedBox(width: 20),
                      IconButton(
                        icon: const Icon(Icons.person,
                            size: 40,
                            color: Color.fromARGB(255, 183, 224, 255)),
                        onPressed: () {
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

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    bool enabled = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        SizedBox(
          height: 45,
          child: TextField(
            enabled: enabled,
            controller: controller,
            decoration: InputDecoration(
              hintText: controller.text,
              filled: true,
              fillColor: Colors.white,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Colors.grey, width: 1.5),
              ),
            ),
            keyboardType: keyboardType,
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField({
    required String label,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    bool enabled = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        SizedBox(
          height: 45,
          child: TextField(
            enabled: enabled,
            obscureText: _isPasswordObscured,
            decoration: InputDecoration(
              hintText: hint,
              filled: true,
              fillColor: Colors.white,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Colors.grey, width: 1.5),
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  _isPasswordObscured ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: () {
                  setState(() {
                    _isPasswordObscured = !_isPasswordObscured;
                  });
                },
              ),
            ),
            keyboardType: keyboardType,
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }

  void _showConfirmationDialog(BuildContext context,
      {required String title, required VoidCallback onConfirm}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('إلغاء'),
            ),
            TextButton(
              onPressed: onConfirm,
              child: const Text('تأكيد'),
            ),
          ],
        );
      },
    );
  }
}
