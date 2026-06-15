import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:jathwa1/pages/homeOne_page.dart';
import 'package:jathwa1/pages/login_page.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class RegisterForm extends StatefulWidget {
  const RegisterForm({super.key});

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();

  @override
  void initState() {
    super.initState();

    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user == null) {
        print('User is currently signed out!');
      } else {
        print('User is signed in!');
      }
    });
  }

  void saveUserToFirestore(String uid) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'firstName': firstNameController.text,
        'lastName': lastNameController.text,
        'email': emailController.text,
        'phone': phoneNumberController.text,
        'password': passwordController.text,
      });
      print('User data saved to Firestore successfully!');
    } catch (e) {
      print('Error saving user to Firestore: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      routes: {
        '/sign up': (context) => RegisterForm(),
        '/log in': (context) => LoginPage(),
        '/hommeOne': (context) => homeOne(),
      },
      home: SafeArea(
        child: Scaffold(
          backgroundColor: const Color(0xFFB0C4DE),
          body: SafeArea(
            child: Container(
              width: double.infinity,
              height: double.infinity,
              clipBehavior: Clip.hardEdge,
              decoration: const BoxDecoration(
                color: Colors.white,
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    left: -500,
                    top: -486,
                    child: Image.asset(
                      'assets/images/Background.jpg',
                      width: 1284,
                      height: 1473,
                      fit: BoxFit.contain,
                    ),
                  ),
                  Positioned(
                    left: 0,
                    top: 115,
                    child: Container(
                      width: 400,
                      height: 700,
                      clipBehavior: Clip.hardEdge,
                      decoration: BoxDecoration(
                        color: Colors.white60,
                        borderRadius: BorderRadius.circular(50),
                      ),
                    ),
                  ),
                  const Positioned(
                    left: 95,
                    top: 130,
                    child: Text(
                      'إنشاء حساب جديد',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFF333333),
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Positioned(
                    left: 215,
                    top: 195,
                    child: _buildTextField(
                      label: 'الاسم الأول',
                      hint: 'إسمك الأول',
                      controller:
                          firstNameController,
                    ),
                  ),
                  Positioned(
                    left: 28,
                    top: 195,
                    child: _buildTextField(
                      label: 'الاسم الأخير',
                      hint: 'إسمك الأخير',
                      controller:
                          lastNameController,
                    ),
                  ),
                  Positioned(
                    left: 28,
                    top: 275,
                    child: _buildEmailField(),
                  ),
                  Positioned(
                    child: _buildPasswordWithConfirm(),
                  ),
                  Positioned(
                    child: _buildPasswordWithConfirm(),
                  ),
                  Positioned(
                    left: 28,
                    top: 540,
                    child: _buildPhoneNumberField(
                      controller:
                          phoneNumberController,
                    ),
                  ),
                  Positioned(
                    left: 130,
                    top: 680,
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: const TextStyle(
                          color: Color(0xFF333333),
                          fontSize: 15,
                        ),
                        children: [
                          const TextSpan(text: 'لديك حساب؟ '),
                          TextSpan(
                              text: 'سجل الدخول',
                              style: const TextStyle(
                                color: Color(0xFFBBDD6C),
                                decoration: TextDecoration.underline,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => LoginPage()),
                                  );
                                }),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    left: 50,
                    top: 630, 
                    child: GestureDetector(
                      onTap: () async {
                        try {
                          final credential = await FirebaseAuth.instance
                              .createUserWithEmailAndPassword(
                            email: emailController.text,
                            password: passwordController.text,
                          );

                          // الحصول على UID المستخدم
                          String uid = credential.user!.uid;
                          saveUserToFirestore(uid);
                          FirebaseAuth.instance.currentUser!
                              .sendEmailVerification();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => LoginPage(),
                            ),
                          );
                        } on FirebaseAuthException catch (e) {
                          if (e.code == 'weak-password') {
                            print('The password provided is too weak.');
                          } else if (e.code == 'email-already-in-use') {
                            print('The account already exists for that email.');
                          }
                        } catch (e) {
                          print(e);
                        }
                        print('إنشاء حساب');
                      },
                      child: Container(
                        width: 300,
                        height: 39,
                        clipBehavior: Clip.hardEdge,
                        decoration: BoxDecoration(
                          color: const Color(0xFFBBDD6C),
                          borderRadius: BorderRadius.circular(32),
                        ),
                        child: const Center(
                          child: Text(
                            'إنشاء حساب',
                            style: TextStyle(
                              color: Color(0xFF333333),
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    required TextEditingController controller, 
    bool obscureText = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          ':$label',
          style: const TextStyle(
            color: Colors.black,
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 5),
        Container(
          width: 153,
          height: 35,
          decoration: BoxDecoration(
            color: const Color(0xE5FFFFFF),
            border: Border.all(
              color: const Color(0x19000000),
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: TextField(
            controller: controller,
            obscureText: obscureText,
            textAlign: TextAlign.right,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(
                color: Color(0xFF5E5E5E),
                fontSize: 12,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.only(
                  left: 5, top: -15),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmailField() {
    String? emailError; 

    return StatefulBuilder(
      builder: (context, setState) => Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const Text(
            ':الإيميل',
            style: TextStyle(
              color: Colors.black,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          Container(
            width: 340,
            height: 35,
            decoration: BoxDecoration(
              color: const Color(0xE5FFFFFF),
              border: Border.all(
                color:
                    emailError == null ? const Color(0x19000000) : Colors.red,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              onChanged: (value) {
                // Check email validity on input change
                final isValid = _validateEmail(value);
                setState(() {
                  emailError = isValid ? null : 'البريد الإلكتروني غير صحيح';
                });
              },
              decoration: const InputDecoration(
                hintText: 'example@mail.com',
                hintStyle: TextStyle(
                  color: Color(0xFF5E5E5E),
                  fontSize: 15,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.only(
                  left: 5,
                  top: -15,
                ),
              ),
            ),
          ),
          if (emailError != null)
            Padding(
              padding: const EdgeInsets.only(top: 5, right: 8),
              child: Text(
                emailError!,
                style: const TextStyle(
                  color: Colors.red,
                  fontSize: 12,
                ),
              ),
            ),
        ],
      ),
    );
  }

// Function to validate email format
  bool _validateEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{3,}$',
    );
    return emailRegex.hasMatch(email);
  }

// دالة إنشاء حقل كلمة السر
  Widget _buildPasswordField({
    required String label,
    required double top,
    required double left,
    required TextEditingController controller,
    bool obscureText = true,
    void Function(String)? onChanged,
    String? errorText,
    required VoidCallback onToggleVisibility,
  }) {
    return Positioned(
      top: top,
      left: left,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            ':$label',
            style: const TextStyle(
              color: Colors.black,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          Container(
            width: 340, 
            height: 35,
            decoration: BoxDecoration(
              color: const Color(0xE5FFFFFF),
              border: Border.all(
                color: errorText == null ? const Color(0x19000000) : Colors.red,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Stack(
              alignment: Alignment.centerRight,
              children: [
                TextField(
                  controller: controller,
                  obscureText: obscureText,
                  textAlign: TextAlign.right,
                  textAlignVertical: TextAlignVertical.center,
                  onChanged: onChanged,
                  decoration: const InputDecoration(
                    hintText: '********',
                    hintStyle: TextStyle(
                      color: Color(0xFF5E5E5E),
                      fontSize: 12,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.only(bottom: 10, right: 10),
                  ),
                ),
                Positioned(
                  left: 8,
                  child: GestureDetector(
                    onTap: onToggleVisibility,
                    child: Icon(
                      obscureText ? Icons.visibility : Icons.visibility_off,
                      color: const Color(0xFF5E5E5E),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (errorText != null)
            Padding(
              padding: const EdgeInsets.only(top: 5),
              child: Text(
                errorText,
                style: const TextStyle(
                  color: Colors.red,
                  fontSize: 12,
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// دالة للتحقق من صحة كلمة السر
  bool _validatePassword(String password) {
    final hasMinLength = password.length >= 8;
    final hasNumbers = RegExp(r'\d').hasMatch(password);
    return hasMinLength && hasNumbers;
  }

  /// واجهة بناء حقل كلمة السر مع تأكيد كلمة السر
  Widget _buildPasswordWithConfirm() {
    bool passwordObscure = true;
    bool confirmPasswordObscure = true;
    String? passwordError;
    String? confirmPasswordError;

    return StatefulBuilder(
      builder: (context, setState) => Stack(
        children: [
          _buildPasswordField(
            label: 'كلمة السر',
            top: 360,
            left: 30,
            controller: passwordController,
            obscureText: passwordObscure,
            errorText: passwordError,
            onChanged: (value) {
              setState(() {
                if (value.isEmpty) {
                  passwordError = 'يجب ملء الحقل';
                } else if (!_validatePassword(value)) {
                  passwordError =
                      'يجب أن تحتوي كلمة السر على الأقل 8 حروف وأرقام';
                } else {
                  passwordError = null;
                }
              });

              // التحقق من تطابق كلمة السر
              if (confirmPasswordController.text.isNotEmpty) {
                setState(() {
                  confirmPasswordError =
                      (confirmPasswordController.text != value)
                          ? 'كلمة السر غير متطابقة'
                          : null;
                });
              }
            },
            onToggleVisibility: () {
              setState(() {
                passwordObscure = !passwordObscure;
              });
            },
          ),

          // حقل تأكيد كلمة السر
          _buildPasswordField(
            label: 'تأكيد كلمة السر',
            top: 455,
            left: 30,
            controller: confirmPasswordController,
            obscureText: confirmPasswordObscure,
            errorText: confirmPasswordError,
            onChanged: (value) {
              setState(() {
                if (value.isEmpty) {
                  confirmPasswordError = 'يجب ملء الحقل';
                } else if (value != passwordController.text) {
                  confirmPasswordError = 'كلمة السر غير متطابقة';
                } else {
                  confirmPasswordError = null;
                }
              });
            },
            onToggleVisibility: () {
              setState(() {
                confirmPasswordObscure = !confirmPasswordObscure;
              });
            },
          ),
        ],
      ),
    );
  }

  // حقل رقم الجوال مع التحقق من البداية بـ +966
  Widget _buildPhoneNumberField({
    required TextEditingController controller, 
  }) {
    String? phoneError;

    return StatefulBuilder(
      builder: (context, setState) => Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const Text(
            ':رقم الجوال',
            style: TextStyle(
              color: Colors.black,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          Container(
            width: 340,
            height: 35,
            decoration: BoxDecoration(
              color: const Color(0xE5FFFFFF),
              border: Border.all(
                color:
                    phoneError == null ? const Color(0x19000000) : Colors.red,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: TextField(
              controller: controller, 
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                hintText: '+9665xxxxxxxx',
                hintStyle: TextStyle(
                  color: Color(0xFF5E5E5E),
                  fontSize: 15,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.only(left: 5, top: -15),
              ),
              onChanged: (value) {
                // التأكد من أن الرقم يبدأ بـ +966
                if (!value.startsWith("+9665")) {
                  controller.text = "+9665";
                  controller.selection =
                      TextSelection.collapsed(offset: controller.text.length);
                }
                setState(() {
                  if (value.length > 4 && value.substring(4).length != 9) {
                    phoneError =
                        '+رقم الجوال يجب أن يحتوي على 8 أرقام بعد 9665';
                  } else {
                    phoneError = null;
                  }
                });
              },
            ),
          ),
          if (phoneError != null)
            Padding(
              padding: const EdgeInsets.only(top: 5, right: 8),
              child: Text(
                phoneError!,
                style: const TextStyle(
                  color: Colors.red,
                  fontSize: 12,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
