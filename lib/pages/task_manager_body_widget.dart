import 'package:jathwa1/pages/child_page.dart';
import 'package:jathwa1/pages/colors.dart';
import 'package:jathwa1/pages/currentHome_page.dart';
import 'package:jathwa1/pages/custom_nav_bar.dart';
import 'package:jathwa1/pages/previousHome_page.dart';
import 'package:jathwa1/pages/previous_homework.dart';
import 'package:jathwa1/pages/profile_widget.dart';
import 'package:jathwa1/pages/switch_container.dart';
import 'package:jathwa1/pages/textutils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TaskManagerBodyWidget extends StatefulWidget {
  final String name;
  final String avatar;

  const TaskManagerBodyWidget({
    Key? key,
    required this.name,
    required this.avatar,
  }) : super(key: key);

  @override
  State<TaskManagerBodyWidget> createState() => _TaskManagerBodyWidgetState();
}

class _TaskManagerBodyWidgetState extends State<TaskManagerBodyWidget> {
  bool selected = false;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SingleChildScrollView(
          child: Column(
            children: [
              ProfileWidget(
                name: widget.name,
                avatar: widget.avatar,
              ),
              Container(
                padding: EdgeInsets.only(top: 8.h, right: 16.w, left: 16.w),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(22.r),
                        topRight: Radius.circular(22.r))),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding:
                          EdgeInsets.only(left: 8.w, right: 16.w, bottom: 8.h),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'الواجبات',
                            style: Textutils.title22,
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => Child(
                                      name: widget.name, avatar: widget.avatar, isEditing: false,),
                                ),
                              );
                            },
                            child: const Icon(Icons.arrow_forward_ios),
                          )
                        ],
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(bottom: 8.h),
                      padding: const EdgeInsets.all(8),
                      height: 40.h,
                      width: MediaQuery.of(context).size.width - 32.w,
                      decoration: BoxDecoration(
                          color: MyColors.lightgrey,
                          borderRadius: BorderRadius.circular(24.r)),
                      child: Row(
                        children: [
                          SwitchContainer(
                            color: selected ? Colors.white : Colors.transparent,
                            text: 'الحالية',
                            ontap: () {
                              setState(() {
                                selected = true;
                              });
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => WeeklyHomework(
                                    name: widget.name,
                                    avatar: widget.avatar, isEditing: false,
                                  ),
                                ),
                              );
                            },
                          ),
                          SwitchContainer(
                            color:
                                !selected ? Colors.white : Colors.transparent,
                            text: 'السابقه',
                            ontap: () {
                              setState(() {
                                selected = true;
                              });
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PrevioushomePage(
                                    name: widget.name,
                                    avatar: widget.avatar,
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    PreviousHomework(childID:widget.name,)
                  ],
                ),
              )
            ],
          ),
        ),
      
      ],
    );
  }
}
