import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:jathwa1/pages/register_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ForgotPasswordPage(),
    );
  }
}

class ForgotPasswordPage extends StatefulWidget {
  @override
  _ForgotPasswordPageState createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController emailController = TextEditingController();
  String? emailError;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // الخلفية
          Container(
            width: double.infinity,
            height: double.infinity,
            child: Image.asset(
              'images/Background.png',
              fit: BoxFit.cover,
            ),
          ),

          // المحتوى
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              width: 350,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white60,
                borderRadius: BorderRadius.circular(50),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'نسيت كلمة السر؟',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 28),
                  const Text(
                    ': الإيميل',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: emailController,
                    decoration: InputDecoration(
                      hintText: '******@*******.com',
                      hintStyle: const TextStyle(
                        color: Colors.black54,
                        fontSize: 14,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                          color: Colors.grey,
                          width: 1.5,
                        ),
                      ),
                      errorText: emailError, // لإظهار رسالة الخطأ
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 20),
                  Align(
                    alignment: Alignment.center,
                    child: ElevatedButton(
                      onPressed: () async {
                        setState(() {
                          emailError = emailController.text.isEmpty
                              ? 'يجب ملء حقل البريد الإلكتروني'
                              : null;
                        });

                        if (emailError == null) {
                          try {
                            await FirebaseAuth.instance.sendPasswordResetEmail(
                              email: emailController.text,
                            );
                            AwesomeDialog(
                              context: context,
                              dialogType: DialogType.success,
                              title: 'تم إرسال رابط إعادة تعيين كلمة المرور',
                              desc:
                                  'يرجى التحقق من بريدك الإلكتروني لإعادة تعيين كلمة المرور',
                              btnOkOnPress: () {},
                            ).show();
                          } catch (e) {
                            AwesomeDialog(
                              context: context,
                              dialogType: DialogType.error,
                              title: 'خطأ',
                              desc:
                                  'تعذر إرسال البريد الإلكتروني. تأكد من صحة البريد الإلكتروني.',
                              btnOkOnPress: () {},
                            ).show();
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.lightGreen,
                        minimumSize: const Size(290, 45),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: const Text(
                        'إرسال',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Align(
                    alignment: Alignment.center,
                    child: TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const RegisterForm()),
                        );
                      },
                      child: const Text.rich(
                        TextSpan(
                          text: 'ليس لديك حساب؟ ',
                          style: TextStyle(
                            color: Colors.black54,
                            fontWeight: FontWeight.bold,
                          ),
                          children: [
                            TextSpan(
                              text: 'إنشاء حساب',
                              style: TextStyle(
                                color: Colors.lightGreen,
                                fontWeight: FontWeight.bold,
                              ),
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
}
