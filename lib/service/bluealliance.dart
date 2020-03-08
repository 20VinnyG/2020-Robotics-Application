import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';

import 'package:scoutmobile2020/types/schedule.dart';

class Bluealliance {

	static Future<Schedule> promptForSchedule (BuildContext scaffoldContext) async {
		String eventCode = await _promptForEventId(scaffoldContext);

		if (eventCode != null && eventCode.isNotEmpty) {
			http.Response matchResponse = await http.get(
				'https://www.thebluealliance.com/api/v3/event/${eventCode}/matches/simple',
				headers: { 'X-TBA-Auth-Key': 'prLzMTfZitylzcN8Zwb64bTaUELuJW8G6AXnDebu20Oz0JF4hh8Voc9rhZFYArSz' }
			);

			if (matchResponse.statusCode == 200) {
				dynamic json = jsonDecode(matchResponse.body);
				Schedule schedule = (json.isNotEmpty) ? Schedule.fromJson(json) : null;
				Scaffold.of(scaffoldContext).showSnackBar(SnackBar(content: Text(schedule != null ? 'Loaded Schedule' : 'Failed to parse schedule'), duration: Duration(seconds: 3)));
				return schedule;
			} else {
				Scaffold.of(scaffoldContext).showSnackBar(SnackBar(content: Text('Failed to load schedule ($eventCode) -- HTTP: ' + matchResponse.statusCode.toString()), duration: Duration(seconds: 3)));
			}
		}

		return null;
	}

	static Future<String> _promptForEventId (BuildContext context) async {
		String eventCode;

		return await showDialog(
			context: context,
			builder: (context) {
				return StatefulBuilder(
					builder: (context, setState) {
					return AlertDialog(
							title: Text("Import Match Schedule"),
							content: Column(
								children: <Widget>[
									TextFormField(
										initialValue: eventCode,
										decoration: const InputDecoration(labelText: 'Enter event code'),
										onChanged: (input) { setState(() { eventCode = input; }); },
										onSaved: (input) { setState(() { eventCode = input; }); },
									),
									Row(
										children: <Widget>[
											RaisedButton(
												child: Text('Cancel'),
												onPressed: () { Navigator.pop(context, null); }
											),
											Container(width: 5.0),
											RaisedButton(
												child: Text('Import'),
												onPressed: () { Navigator.pop(context, eventCode); }
											),
										],
										mainAxisAlignment: MainAxisAlignment.center,
										mainAxisSize: MainAxisSize.min,
									)
								],
								mainAxisAlignment: MainAxisAlignment.center,
								mainAxisSize: MainAxisSize.min,
							));
				});
			});
	}

}