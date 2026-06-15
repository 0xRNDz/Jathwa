import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:jathwa1/pages/ResetPass_page.dart';
import 'package:jathwa1/pages/homeTwo_page.dart';
import 'package:jathwa1/pages/register_page.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(LoginPage());
}

class LoginPage extends StatefulWidget {
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  String? emailError;
  String? passwordError;

  bool _validateEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            child: Image.asset(
              'assets/images/Background.jpg',
              fit: BoxFit.cover,
            ),
          ),
          // محتوى تسجيل الدخول
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              width: 350,
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white60,
                borderRadius: BorderRadius.circular(50),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'مرحبًا بعودتك',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 28),
                  _buildEmailField(),
                  SizedBox(height: 20),
                  _buildPasswordField(),
                  SizedBox(height: 7),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton(
                      onPressed: () {
                       Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => ForgotPasswordPage()),
                              );
                      },
                      child: Text(
                        'نسيت كلمة السر؟',
                        style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: ElevatedButton(
                      onPressed: () async {
                        setState(() {
                          emailError = _validateEmail(emailController.text)
                              ? null
                              : 'يرجى إدخال إيميل صالح.';
                          passwordError = passwordController.text.isNotEmpty
                              ? null
                              : 'يجب ملء حقل كلمة السر.';
                        });

                        if (emailError == null && passwordError == null) {
                          try {
                              final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
                              email: emailController.text,
                              password: passwordController.text,
                            );
                         
                            if (credential.user!.emailVerified) {
                               Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => homeTwo()),
                              );
                              
                            } else {
                           AwesomeDialog(
                                context: context,
                                dialogType: DialogType.warning,
                                title: 'لم يتم التحقق من البريد الإلكتروني',
                                desc: 'يرجى التحقق من بريدك الإلكتروني قبل تسجيل الدخول.',
                                btnOkOnPress: () {},
                              ).show();
                            }
                          } on FirebaseAuthException {
                            AwesomeDialog(
                              context: context,
                              dialogType: DialogType.error,
                              title: 'حدث خطأ أثناء تسجيل الدخول',
                              desc: 'تأكد من ادخال البيانات بشكل صحيح',
                              btnOkOnPress: () {},
                            ).show();
                          } catch (e) {
                            print('خطأ: $e');
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.lightGreen,
                        minimumSize: Size(290, 45),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: Text(
                        'تسجيل الدخول',
                        style: TextStyle(fontSize: 18, color: Colors.black, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Align(
                    alignment: Alignment.center,
                    child: TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => RegisterForm()),
                        );
                      },
                      child: Text.rich(
                        TextSpan(
                          text: 'ليس لديك حساب؟ ',
                          style: TextStyle(color: Colors.black54, fontWeight: FontWeight.bold),
                          children: [
                            TextSpan(
                              text: 'إنشاء حساب',
                              style: TextStyle(color: Colors.lightGreen, fontWeight: FontWeight.bold),
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
      ),
    );
  }

  Widget _buildEmailField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          ': الإيميل',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        TextField(
          controller: emailController,
          decoration: InputDecoration(
            hintText: 'example@mail.com',
            filled: true,
            fillColor: Colors.white,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey, width: 1.5),
            ),
          ),
        ),
        if (emailError != null)
          Padding(
            padding: const EdgeInsets.only(top: 5),
            child: Text(
              emailError!,
              style: TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
      ],
    );
  }

  Widget _buildPasswordField() {
    bool passwordObscure = true;

    return StatefulBuilder(
      builder: (context, setState) => Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            ': كلمة السر',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: passwordError == null ? Colors.grey : Colors.red,
                width: 1.5,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: TextField(
              controller: passwordController,
              obscureText: passwordObscure,
              onChanged: (value) {
                setState(() {
                  passwordError = value.isNotEmpty ? null : 'يجب ملء حقل كلمة السر.';
                });
              },
              decoration: InputDecoration(
                hintText: '********',
                filled: true,
                fillColor: Colors.white,
                border: InputBorder.none,
                suffixIcon: IconButton(
                  icon: Icon(
                    passwordObscure ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      passwordObscure = !passwordObscure;
                    });
                  },
                ),
              ),
            ),
          ),
          if (passwordError != null)
            Padding(
              padding: const EdgeInsets.only(top: 5),
              child: Text(
                passwordError!,
                style: TextStyle(color: Colors.red, fontSize: 12),
              ),
            ),
        ],
      ),
    );
  }
}
