import 'package:flutter/material.dart';
import 'constants.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:contacts_service/contacts_service.dart';



class ScannedItems extends StatefulWidget {
  final items,labels;
  ScannedItems({this.items,this.labels});
  @override
  _ScannedItemsState createState() => _ScannedItemsState();
}

class _ScannedItemsState extends State<ScannedItems> {
  TextEditingController  fName;
  TextEditingController sName;
  TextEditingController pNumber;
  Permission permission;
  Contact contact;
  List value;
  @override
  void initState() {
    // TODO: implement initState
    fName = TextEditingController();
    sName = TextEditingController();
    pNumber = TextEditingController();
    permission = Permission.contacts;
    value=[];
    super.initState();
  }

//  This function checks the type of text and specifies what function it has to perform.
  void labelFunction(String label, String value) {
    switch (label) {
      case "URL :":
        launchURL(value);
        break;
      case "Phone Number :":
        addContacts(value);
        break;
      case "Other :":
        showDialog(
            context: context,
            builder: (context) => AlertDialog(
              content: Text(
                "No function available",
                style: scannerStyle,
              ),
              actions: <Widget>[
                RaisedButton(
                  color: Theme.of(context).primaryColor,
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    "Ok",
                    style: scannerStyle,
                  ),
                )
              ],
            ));
        break;
    }
  }

  //This function accepts the url and launches it.
  void launchURL(String scannedUrl) async {
    var url = scannedUrl;
    if (await canLaunch(url)) {
      await launch(url, forceWebView: true);
    } else {
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
            content: Text(
              "Invalid URL",
              style: scannerStyle,
            ),
            actions: <Widget>[
              RaisedButton(
                color: Theme.of(context).primaryColor,
                child: Text(
                  "OK",
                  style: scannerStyle,
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              )
            ],
          ));
      throw 'Could not launch $url';
    }
  }

  //This function saves the contact.
  void addContacts(String phoneNumber) async {
    pNumber.text = phoneNumber;
    var res = await permission.request();
    if (res.isGranted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(
            "Add Contact",
            style: scannerStyle,
          ),
          content: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              TextField(
                style: scannerStyle,
                controller: fName,
                autofocus: true,
                decoration: InputDecoration(labelText: "First Name"),
              ),
              TextField(
                style: scannerStyle,
                controller: sName,
                decoration: InputDecoration(labelText: "Last Name"),
              ),
              TextField(
                controller: pNumber,
                style: scannerStyle,
                decoration: InputDecoration(labelText: "Phone Number"),
              )
            ],
          ),
          actions: <Widget>[
            RaisedButton(
              color: Theme.of(context).primaryColor,
              onPressed: () async {
                if (fName.text.isNotEmpty || sName.text.isNotEmpty) {
                  setState(() {
                    contact = Contact(
                        givenName: fName.text,
                        familyName: sName.text,
                        phones: [Item(value: phoneNumber)]);
                  });
                  await ContactsService.addContact(contact);
                }
                Navigator.pop(context);
//                 To inform the user that the contact has been added.
                showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      content: Text(
                        "Contact added",
                        style: scannerStyle,
                      ),
                      actions: <Widget>[
                        RaisedButton(
                          color: Theme.of(context).primaryColor,
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text(
                            "Ok",
                            style: scannerStyle,
                          ),
                        )
                      ],
                    ));
              },
              child: Text(
                "Add",
                style: scannerStyle,
              ),
            )
          ],
        ),
      );
    }
  }

  //This is the format in which the text will be displayed.
  @override
  Widget build(BuildContext context) {
    final items = widget.items;
    final label = widget.labels;
    return  Container(
      child: items.length==0 ? CircularProgressIndicator(
        backgroundColor: Theme.of(context).primaryColor,
      ) :ListView.builder(
          shrinkWrap: true,
          itemCount: items.length,
          itemBuilder: (context, index) {
            return GestureDetector(
                child: Card(
                  child: ListTile(
                    leading: Text(
                      label[index],
                      style: scannerStyle,
                    ),
                    title: Text(
//                      visionText.blocks[index].text,
                      items[index],
                      style: scannerStyle,
                    ),
                  ),
                ),
                onTap: () {
                  labelFunction(
                      label[index], items[index]);
                });
          }),
    );
  }
}
