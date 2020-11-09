import 'package:flutter/material.dart';

class AlertDialogDemo extends StatelessWidget {
  // Global Key of Scaffold
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(title: Text("AlertDialog Demo")),
      body: Center(
          child: RaisedButton(
            child: Text("Show AlertDialog"),
            onPressed: () {
              showAlertDialog(context);
            },
          )),
    );
  }

  void showAlertDialog(BuildContext context) async {
    String result = await showDialog(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('AlertDialog Demo'),
          content: Text("Select button you want"),
          actions: <Widget>[
            FlatButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.pop(context, "OK");
              },
            ),
            FlatButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.pop(context, "Cancel");
              },
            ),
          ],
        );
      },
    );
  }

}