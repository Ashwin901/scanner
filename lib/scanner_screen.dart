import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'constants.dart';
import 'process.dart';

class ScannerScreen extends StatefulWidget {
  @override
  _ScannerScreenState createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  TextRecognizer textRecognizer;
  VisionText visionText;
  RegExp urlExp;
  RegExp phoneExp;
  List<String> label;

  @override
  void initState() {
    textRecognizer = FirebaseVision.instance.textRecognizer();
    urlExp = RegExp(
        r"^(https?:\/\/)?([\da-z\.-]+)\.([a-z\.]{2,6})([\/\w \.-]*)*\/?$",
        caseSensitive: false);
    phoneExp =
        RegExp(r"^(\+91[\-\s]?)?[0]?(91)?[789]\d{9}$", caseSensitive: false);
    label = [];
    super.initState();
  }

//  This function accepts the image and scans it and separates url,phoneNumber and other types of text.
  void getData() async {
    label.clear();
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
      });
    }
    if (mounted) {
      setState(() {
        visionText = visionText1;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Center(
              child: Text(
            'Scanner',
            style: scannerStyle,
          )),
        ),
        floatingActionButton: FloatingActionButton(
            backgroundColor: Theme.of(context).primaryColor,
            child: Icon(
              Icons.camera_alt,
              color: Colors.black,
            ),
            onPressed: getData),
        body: visionText == null
            ? Center(
                child: Text(
                  "Select a picture",
                  style: scannerStyle,
                ),
              )
            : ScannedItems(items: visionText,labels: label)
    );
  }
}
