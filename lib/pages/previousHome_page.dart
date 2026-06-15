import 'package:firebase_core/firebase_core.dart';
import 'package:jathwa1/pages/task_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
runApp(PrevioushomePage(name: '', avatar: ''));
}

class PrevioushomePage extends StatelessWidget {
 final String name;
  final String avatar;

  const PrevioushomePage({
    Key? key,
    
    required this.name,
    required this.avatar,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: true,
      builder:(_ ,child)=> MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
        ),
        home:  TaskManager(name:name, avatar: avatar,),
      ),
    );
  }
}

