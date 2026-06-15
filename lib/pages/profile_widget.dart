import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:jathwa1/pages/addChild_page.dart';
import 'package:jathwa1/pages/textutils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProfileWidget extends StatefulWidget {
  final String name;
  final String avatar;

  const ProfileWidget({
    Key? key,
   
    required this.name,
    required this.avatar,
  }) : super(key: key);

  

  @override
  State<ProfileWidget> createState() => _ProfileWidgetState();
}

class _ProfileWidgetState extends State<ProfileWidget> {
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
    return SizedBox(
      height: 130.h,
      child: Padding(
        padding:  EdgeInsets.only(top: 50.h,right: 20.w,bottom: 10.h),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            CircleAvatar(
              radius: 25.r,
             backgroundImage: AssetImage(widget.avatar),
              child: Transform.translate(
                offset: Offset(18.w, 18.h),
                child: GestureDetector(
                  onTap: () {
                     fetchChildData(widget.name);
                  },
                  child: CircleAvatar(
                    radius: 8.r,
                    backgroundColor: Colors.white,
                    child: const Icon(Icons.edit,size: 16,),
                  ),
                ),
              ),
            ),
            SizedBox(width: 10.w,),
            Transform.translate(
              offset:const Offset(0, -10),
              child: Text(widget.name,style: Textutils.titlebold30))
          ],
        ),
      ),
      );
  }
}