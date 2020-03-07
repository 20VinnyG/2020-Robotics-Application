class Spin {

	bool positionControl = false;
	bool colorControl = false;

	Spin ();

	Spin.fromJson (Map<String,dynamic> json) :
		positionControl = json['pc'] != 0,
		colorControl = json['cc'] != 0;

	Map<String,dynamic> toJson () => {
		'pc': positionControl ? 1 : 0,
		'cc': colorControl ? 1 : 0
	};

}