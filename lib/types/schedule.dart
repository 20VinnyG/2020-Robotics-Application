class Schedule {

	Map<int,_Match> _matches = {};
	_Match zeroMatch = _Match.zero();

	Schedule.fromJson(List<dynamic> json) {
		json.forEach((matchDetails) {
			if (matchDetails['comp_level'] == 'qm') {
				_matches[matchDetails['match_number']] = _Match.fromJson(matchDetails);
			}
		});
	}

	_Match operator [] (int matchNumber) {
		if (_matches.containsKey(matchNumber)) {
			return _matches[matchNumber];
		}
		return zeroMatch;
	}

}

class _Match {

	List<int> _teams = [];

	_Match.zero ();

	_Match.fromJson (Map<String,dynamic> json) {
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
	
}