import 'package:jathwa1/pages/textutils.dart';
import 'package:flutter/material.dart';


class SwitchContainer extends StatelessWidget {
  final String text;
  final Function()? ontap;
  final Color color;
  const SwitchContainer({
    super.key,  required this.text,
    required this.ontap,
    required this.color
  });
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: ontap,
      child: Container(
        alignment: Alignment.center,
        width: (MediaQuery.of(context).size.width - 50)/2 -8,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16)
      
        ),
        child: Text(text,style: Textutils.title18,),
      ),
    );
  }
}