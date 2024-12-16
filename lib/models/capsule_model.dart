import 'package:cloud_firestore/cloud_firestore.dart';

class Capsule {
  final String id;
  final String address;
  final List<String> amenities;
  final String area;
  final String beds;
  final int dailyRate;
  final String description;
  final int hourlyRate;
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

  // Существующий фабричный конструктор fromMap
  factory Capsule.fromMap(String id, Map<String, dynamic> data) {
    return Capsule(
      id: id,
      address: data['address'] ?? '',
      amenities: _parseList(data['amenities']),
      area: data['area'] ?? '',
      beds: data['beds'] ?? '',
      dailyRate: _toInt(data['dailyRate']),
      description: data['description'] ?? '',
      hourlyRate: _toInt(data['hourlyRate']),
      images: _parseList(data['images']),
      latitude: _toDouble(data['latitude']),
      longitude: _toDouble(data['longitude']),
      name: data['name'] ?? '',
      reviews: _parseList(data['reviews']),
    );
  }

  // Добавляем фабричный конструктор fromFirestore
  factory Capsule.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Capsule.fromMap(doc.id, data);
  }

  // Вспомогательные методы
  static int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  static List<String> _parseList(dynamic value) {
    if (value == null) return [];
    if (value is List) {
      return value.map((item) => item.toString()).toList();
    } else if (value is String) {
      return value.split(',').map((item) => item.trim()).toList();
    } else {
      return [];
    }
  }
}