import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'match.dart';

class ScoutMode extends StatefulWidget {

  @override
  _ScoutModeState createState() => _ScoutModeState();
}

class _ScoutModeState extends State<ScoutMode> {

  final _match = Match();
  final _formKey = GlobalKey<FormState>();


  createQR(BuildContext context){
    return showDialog(context: context,builder: (context) {
      return AlertDialog(
        title: Text("Generated QR"),
        content: QrImage(
          data: "sts",
        ),
      );
    } );
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
          title: new Text("Scout Mode"), backgroundColor: Colors.blue[900]),
      body: new Container(
        padding: 
          const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
        child: Builder(
          builder: (context) => Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
              decoration: const InputDecoration(
                hintText: 'Enter your initials',
              ),
              validator: (value) {
                if (value.isEmpty){
                  return 'Please enter your initials';
                }
              },
              onSaved: (val) => setState(() => _match.initials = val),
            ),
            TextFormField(
              decoration: const InputDecoration(
                hintText: 'Enter the match number',
              ),
              validator: (value) {
                if (value.isEmpty){
                  return 'Please enter the match number';
                }
              },
              onSaved: (val) => setState(() => _match.teamNumber = val),
            ),
            TextFormField(
              decoration: const InputDecoration(
                hintText: 'Enter the team number',
              ),
              validator: (value) {
                if (value.isEmpty){
                  return 'Please enter the team number';
                }
              },
              onSaved: (val) => setState(() => _match.matchNumber = val),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                vertical: 16.0, horizontal: 16.0
              ),
              child: RaisedButton(onPressed: () {
                final form = _formKey.currentState;
                if (form.validate()) {
                  form.save();
                  createQR(context);
                }
              },)
            )
              ],
            )
          )
        )
      )
    );
  }
}