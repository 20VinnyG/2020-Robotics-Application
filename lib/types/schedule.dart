class Schedule {

  String _eventName;
	Map<int,_Match> _matches = {};
	_Match zeroMatch = _Match.zero();

	Schedule.importFromJson(List<dynamic> json, String eventName) {
		_eventName = eventName;
		json.forEach((matchDetails) {
			if (matchDetails['comp_level'] == 'qm') {
				_matches[matchDetails['match_number']] = _Match.importFromJson(matchDetails);
			}
		});
	}

	Schedule.fromJson (Map<String,dynamic> json) {
		_eventName = json['name'];
		json['matches'].forEach((matchObject) {
			_matches[matchObject['m']] = _Match.fromJson(matchObject['l']);
		});
	}

	_Match operator [] (int matchNumber) {
		if (_matches.containsKey(matchNumber)) {
			return _matches[matchNumber];
		}
		return zeroMatch;
	}

  Map<String,dynamic> toJson () {
		Map<String,dynamic> map = {};

    map['name'] = _eventName;
    map['matches'] = [];
		_matches.forEach((matchNumber,matchInfo) {
			map['matches'].add({
				'm': matchNumber,
				'l': matchInfo.toJson()
			});
		});

		return map;
  }

	String get eventName => _eventName;

}

class _Match {

	List<int> _teams = [];

	_Match.zero ();

	_Match.importFromJson (Map<String,dynamic> json) {
		json['alliances']['blue']['team_keys'].forEach((teamStr) {
			_teams.add(int.tryParse(teamStr.substring(3)) ?? 0);
		});
		json['alliances']['red']['team_keys'].forEach((teamStr) {
			_teams.add(int.tryParse(teamStr.substring(3)) ?? 0);
		});
	}

	int operator [] (int position) {
		return (position < 0 || position > _teams.length - 1) ? -1 : _teams[position];
	}

  List<dynamic> toJson () => List.from(_teams);

  _Match.fromJson (List<dynamic> json) {
    _teams = List.castFrom<dynamic,int>(json);
  }

}