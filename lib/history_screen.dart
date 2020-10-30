import 'package:flutter/material.dart';
import 'package:getscanner/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:getscanner/process.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class History extends StatefulWidget {
  @override
  _HistoryState createState() => _HistoryState();
}

class _HistoryState extends State<History> {
  List<String> label;
  List value;
  @override
  void initState() {
    // TODO: implement initState
    label=[];
    value=[];
    super.initState();
  }
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
    body: StreamBuilder<QuerySnapshot>(

     stream: Firestore.instance.collection('items').snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot){
       if(!snapshot.hasData) {
         return Center(
           child: SpinKitDoubleBounce(
             color: Theme.of(context).primaryColor,
           )
         );
       }
       label.clear();
       value.clear();
       var items = snapshot.data.documents;
         print(items.length);
         for(int i=0; i<items.length;i ++){
           label.add(items[i].data["label"]);
           value.add(items[i].data["value"]);
           }
         return ScannedItems(labels: label,items: value);
         },
    ),
    );
  }
}
