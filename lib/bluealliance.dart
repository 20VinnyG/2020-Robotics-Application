import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:async';

class Bluealliance extends StatefulWidget {
	List schedule;
	@override
	_AboutState createState() => _AboutState();
	Bluealliance({this.schedule});
}

class _AboutState extends State<Bluealliance> {

	String eventcode;

	Future<String> fetchSchedule() async {
		var matchresponse = await http.get(
			"https://www.thebluealliance.com/api/v3/event/2019pawch/matches/simple",
			headers: {
				"X-TBA-Auth-Key": "prLzMTfZitylzcN8Zwb64bTaUELuJW8G6AXnDebu20Oz0JF4hh8Voc9rhZFYArSz	"
			}
		);
		widget.schedule = jsonDecode(matchresponse.body);
		print(widget.schedule);
		/*var teamresponse = await http.get(
			"https://www.thebluealliance.com/api/v3/event/2019pawch/teams/simple",
			headers: {
				"X-TBA-Auth-Key": "prLzMTfZitylzcN8Zwb64bTaUELuJW8G6AXnDebu20Oz0JF4hh8Voc9rhZFYArSz	"
			}
		);*/
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
				child:
				TextFormField(
					initialValue: eventcode,
					decoration: const InputDecoration(labelText: 'Enter event code'),
					validator: (input) => input.isEmpty ? 'Not a valid input' : null,
					onChanged: (input) {
						setState(() {
							input = eventcode;
						});
					},
				),
			),
			floatingActionButton: FloatingActionButton.extended(
				label: Text("Import Match Schedule"),
				onPressed: () => fetchSchedule(),
			),
		);
	}

}

