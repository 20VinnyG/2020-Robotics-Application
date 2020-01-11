import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
//import 'package:qr_flutter/qr_flutter.dart';
import 'match.dart';

class ScoutMode extends StatefulWidget {
  @override
  _ScoutModeState createState() => _ScoutModeState();
}

class _ScoutModeState extends State<ScoutMode> {
  Match newMatch = new Match();
  final formKey = GlobalKey<FormState>();

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
                    key: formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextFormField(
                          decoration: const InputDecoration(
                            hintText: 'Enter your initials',
                          ),
                          validator: (input) => input.isEmpty ? 'Not a valid input' : null,
                          onSaved: (input) => newMatch.initials = input, 
                        ),
                        TextFormField(
                          decoration: const InputDecoration(
                            hintText: 'Enter the match number',
                          ),
                          validator: (input) => input.isEmpty ? 'Not a valid input' : null,
                          onSaved: (input) => newMatch.matchNumber = input, 
                        ),
                        TextFormField(
                          decoration: const InputDecoration(
                            hintText: 'Enter the team number',
                          ),
                          validator: (input) => input.isEmpty ? 'Not a valid input' : null,
                          onSaved: (input) => newMatch.teamNumber = input, 
                        ),
                        Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 16.0, horizontal: 16.0),
                            child: RaisedButton(
                              onPressed: _submit,
                            ))
                      ],
                    )))));
  }

  void _submit(){
  if(formKey.currentState.validate()) {
    formKey.currentState.save();
    print(newMatch.initials);
    print(newMatch.teamNumber);
    print(newMatch.matchNumber);
    var payload = {
      'initials': newMatch.initials,
      'teamnumber': newMatch.teamNumber,
      'matchnumber': newMatch.matchNumber,
    };
    print(payload);
    showDialog(context: context, builder: (context) {
    return AlertDialog(
      title: Text("Generated QR"),
      content: QrImage(
        data: payload.toString(),
      )
    );
    });
  }
}
}

