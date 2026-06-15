import 'package:jathwa1/pages/colors.dart';
import 'package:jathwa1/pages/task_manager_body_widget.dart';
import 'package:flutter/material.dart';


class TaskManager extends StatefulWidget {
  final String name;
  final String avatar;

  const TaskManager({
    Key? key,
    
    required this.name,
    required this.avatar,
  }) : super(key: key);
  @override
  State<TaskManager> createState() => _TaskManagerState();
}

class _TaskManagerState extends State<TaskManager> {
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child:  Scaffold(
        backgroundColor: MyColors.appbarColor,
        body: TaskManagerBodyWidget(name:widget.name, avatar: widget.avatar,),
      ),
    );
  }
}

