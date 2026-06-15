
import 'package:jathwa1/pages/homeTwo_page.dart';
import 'package:jathwa1/pages/profile_page.dart';
import 'package:flutter/material.dart';




class CustomNavBar extends StatelessWidget {
  const CustomNavBar({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return
     Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        width: 172,
        height: 55,
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 34, 166, 215),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

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
            const SizedBox(width: 20),

            IconButton(
              icon: const Icon(
                Icons.grid_view_rounded,
                size: 40,
                color: Color.fromARGB(255, 183, 224, 255),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const homeTwo()),
                );
              },
            ),
            
          ],
        ),
      ),
    );
  
   
  }
}

