class Capsule {
  final String id;
  final String address;
  final List<String> amenities;
  final String area;
  final String beds;
  final String dailyRate;
  final String description;
  final String hourlyRate;
  final List<String> images;
  final double latitude;
  final double longitude;
  final String name;
  final List<String> reviews;

  Capsule({
    required this.id,
    required this.address,
    required this.amenities,
    required this.area,
    required this.beds,
    required this.dailyRate,
    required this.description,
    required this.hourlyRate,
    required this.images,
    required this.latitude,
    required this.longitude,
    required this.name,
    required this.reviews,
  });

  factory Capsule.fromMap(String id, Map<String, dynamic> data) {
    return Capsule(
      id: id,
      address: data['address'] ?? '',
      amenities: data['amenities'] != null ? (data['amenities'] as String).split(',') : [],
      area: data['area'] ?? '',
      beds: data['beds'] ?? '',
      dailyRate: data['dailyRate'] ?? '',
      description: data['description'] ?? '',
      hourlyRate: data['hourlyRate'] ?? '',
      images: data['images'] != null ? (data['images'] as String).split(',') : [],
      latitude: double.tryParse(data['latitude'] ?? '') ?? 0.0,
      longitude: double.tryParse(data['longitude'] ?? '') ?? 0.0,
      name: data['name'] ?? '',
      reviews: data['reviews'] != null ? (data['reviews'] as String).split(',') : [],
    );
  }

  factory Capsule.fromFirestore(Map<String, dynamic> data, String id) {
    return Capsule(
      id: id,
      address: data['address'] ?? '',
      amenities: data['amenities'] != null ? (data['amenities'] as String).split(',') : [],
      area: data['area'] ?? '',
      beds: data['beds'] ?? '',
      dailyRate: data['dailyRate'] ?? '',
      description: data['description'] ?? '',
      hourlyRate: data['hourlyRate'] ?? '',
      images: data['images'] != null ? (data['images'] as String).split(',') : [],
      latitude: double.tryParse(data['latitude'] ?? '') ?? 0.0,
      longitude: double.tryParse(data['longitude'] ?? '') ?? 0.0,
      name: data['name'] ?? '',
      reviews: data['reviews'] != null ? (data['reviews'] as String).split(',') : [],
    );
  }
}