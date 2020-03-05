import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'package:scoutmobile2020/scan.dart';
import 'scoutmode.dart';

class Homepage extends StatefulWidget {
  @override
  _HomepageState createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  List schedule = new List();
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
            title: new Text("FRC 1640 Scouting App"),
            backgroundColor: Colors.blue[900]),
        body: new Container(
          child: new Center(
            child: new Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                RaisedButton(
                    child: Text('Scout Mode'),
                    color: Colors.yellow,
                    onPressed: () {
                      Navigator.push(
                          context,
                          new MaterialPageRoute(
                              builder: (context) => ScoutMode(schedule: schedule)));
                    }),
                RaisedButton(
                    child: Text('Scan Mode'),
                    color: Colors.yellow,
                    onPressed: () {
                      Navigator.push(
                          context,
                          new MaterialPageRoute(
                              builder: (context) => ScanMode()));
                    }),
                RaisedButton(
                    child: Text('Import Match Schedule'),
                    color: Colors.yellow,
                    onPressed: () {
                      showDialog(
                          context: context,
                          builder: (context) {
                            return StatefulBuilder(
                                builder: (context, setState) {
                              return AlertDialog(
                                  title: Text("Import Match Schedule"),
                                  content: Column(
                                    children: <Widget>[
                                      /*TextFormField(
                                        initialValue: eventcode,
                                        decoration: const InputDecoration(
                                            labelText: 'Enter event code'),
                                        validator: (input) => input.isEmpty
                                            ? 'Not a valid input'
                                            : null,
                                        onChanged: (input) {
                                          setState(() {
                                            input = eventcode;
                                          });
                                        },
                                      ),
                                      */
                                      RaisedButton(
                                          child: Text('Import Match Schedule'),
                                          onPressed: () {
                                            fetchSchedule();
                                          })
                                    ],
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.min,
                                  ));
                            });
                          });
                    }),
                RaisedButton(
                    child: Text('Test'),
                    color: Colors.yellow,
                    onPressed: () {
                      print(schedule);
                    }),
              ],
            ),
          ),
        ));
  }

  Future<String> fetchSchedule() async {
    var matchresponse = await http.get(
        "https://www.thebluealliance.com/api/v3/event/2019pawch/matches/simple",
        headers: {
          "X-TBA-Auth-Key":
              "prLzMTfZitylzcN8Zwb64bTaUELuJW8G6AXnDebu20Oz0JF4hh8Voc9rhZFYArSz"
        });
    schedule = jsonDecode(matchresponse.body);
    print(schedule);
  }
}
