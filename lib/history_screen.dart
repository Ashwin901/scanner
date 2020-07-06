import 'package:flutter/material.dart';
import 'package:getscanner/constants.dart';

class History extends StatefulWidget {
  @override
  _HistoryState createState() => _HistoryState();
}

class _HistoryState extends State<History> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
            color: Colors.black
        ),
        title: Text("History",
        style: scannerStyle,
        ),
      ),
    );
  }
}
