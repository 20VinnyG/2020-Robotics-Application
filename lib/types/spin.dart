class Spin {

	int positionControl = 0;
	int rotationControl = 0;

	Spin ();

	Spin.fromJson (Map<String,dynamic> json) :
		positionControl = json['pc'],
		rotationControl = json['rc'];

	Map<String,dynamic> toJson () => {
		'pc': positionControl,
		'rc': rotationControl
	};

}