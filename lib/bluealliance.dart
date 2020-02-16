import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'globals.dart';

Globals newGlobals = new Globals();


class Bluealliance extends StatefulWidget {
	@override
	_AboutState createState() => _AboutState();
}

class _AboutState extends State<Bluealliance> {

	Future<String> fetchSchedule() async {
		var matchresponse = await http.get(
			"https://www.thebluealliance.com/api/v3/event/2019pawch/matches/simple",
			headers: {
				"X-TBA-Auth-Key": "prLzMTfZitylzcN8Zwb64bTaUELuJW8G6AXnDebu20Oz0JF4hh8Voc9rhZFYArSz	"
			}
		);
		/*var teamresponse = await http.get(
			"https://www.thebluealliance.com/api/v3/event/2019pawch/teams/simple",
			headers: {
				"X-TBA-Auth-Key": "prLzMTfZitylzcN8Zwb64bTaUELuJW8G6AXnDebu20Oz0JF4hh8Voc9rhZFYArSz	"
			}
		);*/
		print(matchresponse.body);
		newGlobals.schedule = jsonDecode(matchresponse.body);
		//print(data[1-81]["alliances"]["blue"]["team_keys"]);
		//print(data[1-81]["alliances"]["red"]["team_keys"]);
		/*for(int i=0; i<= data.length-1; i++) {
			print(data[i]["alliances"]["blue"]["team_keys"]);
			print(data[i]["alliances"]["red"]["team_keys"]);
		}
		*/
	}

	@override
	Widget build(BuildContext context) {
		return new Scaffold(
			appBar: new AppBar(
					title: new Text("About"), backgroundColor: Colors.blue[900]),
			body: Center(
				child: Text("")
			),
			floatingActionButton: FloatingActionButton.extended(
				label: Text("Import Match Schedule"),
				onPressed: () => fetchSchedule(),
			),
		);
	}

}