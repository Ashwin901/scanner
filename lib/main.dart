import 'package:flutter/material.dart';
import 'scanner_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title:"Scanner" ,
      debugShowCheckedModeBanner: false,
      theme: Theme.of(context).copyWith(
       primaryColor: Color(0xff05dfd7),
        buttonColor: Color(0xff05dfd7),
      ),
      home: ScannerScreen(),
    );
  }
}
