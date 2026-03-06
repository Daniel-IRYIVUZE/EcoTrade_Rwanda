class LocationModel {
	final double latitude;
	final double longitude;
	final String? address;

	const LocationModel({
		required this.latitude,
		required this.longitude,
		this.address,
	});

	Map<String, dynamic> toJson() => {
		'latitude': latitude,
		'longitude': longitude,
		'address': address,
	};

	factory LocationModel.fromJson(Map<String, dynamic> json) => LocationModel(
		latitude: (json['latitude'] as num).toDouble(),
		longitude: (json['longitude'] as num).toDouble(),
		address: json['address'] as String?,
	);
}
