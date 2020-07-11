import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:getscanner/history_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'constants.dart';
import 'process.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ScannerScreen extends StatefulWidget {
  @override
  _ScannerScreenState createState() => _ScannerScreenState();
}

final fireStore = Firestore.instance;

class _ScannerScreenState extends State<ScannerScreen> {
  TextRecognizer textRecognizer;
  VisionText visionText;
  RegExp urlExp;
  RegExp phoneExp;
  List<String> label;
  List value;

  @override
  void initState() {
    textRecognizer = FirebaseVision.instance.textRecognizer();
    urlExp = RegExp(
        r"^(https?:\/\/)?([\da-z\.-]+)\.([a-z\.]{2,6})([\/\w \.-]*)*\/?$",
        caseSensitive: false);
    phoneExp =
        RegExp(r"^(\+91[\-\s]?)?[0]?(91)?[789]\d{9}$", caseSensitive: false);
    label = [];
    value=[];
    super.initState();
  }

//  This function accepts the image and scans it and separates url,phoneNumber and other types of text.
  void getData() async {
    label.clear();
    value.clear();
    var imageFile = await ImagePicker.pickImage(source: ImageSource.camera);
    FirebaseVisionImage visionImage = FirebaseVisionImage.fromFile(imageFile);
    VisionText visionText1 = await textRecognizer.processImage(visionImage);
    for (int i = 0; i < visionText1.blocks.length; i++) {
      setState(() {
        if (urlExp.hasMatch(visionText1.blocks[i].text.toLowerCase())) {
          label.add("URL :");
        } else if (phoneExp.hasMatch(visionText1.blocks[i].text)) {
          label.add("Phone Number :");
        } else {
          label.add("Other :");
        }
       value.add(visionText1.blocks[i].text);
      });
    }
 storeData(value,label);
  }

  void storeData(List value, List label){
    for(int i=0;i<value.length;i++){
      if(label[i] == "URL :" || label[i] == "Phone Number :"){
        fireStore.collection("items").add({
          "label":label[i],
          "value":value[i]
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          iconTheme: IconThemeData(color: Colors.black),
          title: Text(
            'Scanner',
            style: scannerStyle,
          ),
        ),
        drawer: Drawer(
          child: ListView(
            children: <Widget>[
              DrawerHeader(
                child: Center(
                    child: Text(
                  "Scanner",
                  style: scannerStyle.copyWith(fontSize: 20),
                )),
                decoration: BoxDecoration(
                    gradient: LinearGradient(colors: <Color>[
                  Theme.of(context).primaryColor,
                  Color(0xffa3f7bf)
                ])),
              ),
              DrawerItem(title: "History",
              navigate: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return History();
                }));
              },
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
            backgroundColor: Theme.of(context).primaryColor,
            child: Icon(
              Icons.camera_alt,
              color: Colors.black,
            ),
            onPressed: getData),
        body: value.length == 0
            ? Center(
                child: Text(
                  "Select a picture",
                  style: scannerStyle,
                ),
              )
            : ScannedItems(items: value, labels: label));
  }
}

class DrawerItem extends StatelessWidget {
  final title;
  final Function navigate;
  DrawerItem({this.title,this.navigate});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 10.0),
      child: InkWell(
        onTap: navigate,
        child: Padding(
          padding: EdgeInsets.fromLTRB(8.0, 0, 8.0, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Icon(Icons.history),
                  SizedBox(
                    width: 8.0,
                  ),
                  Text(
                    title,
                    style: scannerStyle.copyWith(fontSize: 20),
                  )
                ],
              ),
              Icon(Icons.arrow_right)
            ],
          ),
        ),
        splashColor: Theme.of(context).primaryColor,
      ),
    );
  }
}
