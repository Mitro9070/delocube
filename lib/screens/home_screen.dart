import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'search_screen.dart'; // Импортируем экран поиска
import 'capsule_list_screen.dart'; // Импортируем экран списка капсул
import '../widgets/menu_drawer.dart'; // Импортируем виджет бокового меню
import '../widgets/top_search_bar.dart'; // Импортируем верхнюю панель
import '../widgets/bottom_navigation_bar.dart'; // Импортируем нижнюю панель
import '../models/capsule_model.dart'; // Импортируем модель капсулы

class HomeScreen extends StatefulWidget {
  static const routeName = '/home';

  final LatLng? targetLocation;

  HomeScreen({this.targetLocation});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late GoogleMapController _mapController;
  Location _location = Location();
  LatLng _currentPosition = LatLng(0, 0);
  List<Map<String, dynamic>> _regions = [];
  final TextEditingController _searchController = TextEditingController();
  final List<String> _selectedLocations = [];
  List<Capsule> _capsules = [];
  bool _isLoading = false;
  BitmapDescriptor? _customIcon;

  @override
  void initState() {
    super.initState();
    _initializeFirebase();
    _loadCustomIcon();
    _loadRegions();
    _getCurrentLocation();
    _loadCapsules();
  }

  Future<void> _initializeFirebase() async {
    await Firebase.initializeApp();
  }

  Future<void> _loadCustomIcon() async {
    _customIcon = await BitmapDescriptor.fromAssetImage(
      ImageConfiguration(size: Size(48, 48)),
      'lib/assets/map32.png',
    );
  }

  Future<void> _loadRegions() async {
    try {
      final String response = await rootBundle.loadString('lib/assets/regions.json');
      final data = await json.decode(response);
      setState(() {
        _regions = List<Map<String, dynamic>>.from(data['regions']);
      });
      print('Regions loaded: $_regions');
    } catch (e) {
      print('Error loading regions: $e');
    }
  }

  void _getCurrentLocation() async {
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;

    _serviceEnabled = await _location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await _location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await _location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await _location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    var locationData = await _location.getLocation();
    setState(() {
      _currentPosition = LatLng(locationData.latitude!, locationData.longitude!);
    });
    _mapController.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: _currentPosition, zoom: 15),
      ),
    );

    if (widget.targetLocation != null) {
      _mapController.animateCamera(
        CameraUpdate.newLatLngBounds(
          LatLngBounds(
            southwest: LatLng(widget.targetLocation!.latitude - 0.1, widget.targetLocation!.longitude - 0.1),
            northeast: LatLng(widget.targetLocation!.latitude + 0.1, widget.targetLocation!.longitude + 0.1),
          ),
          10,
        ),
      );
    }
  }

  Future<void> _loadCapsules() async {
    setState(() {
      _isLoading = true;
    });

    // Обновите URL базы данных на правильный
    DatabaseReference capsulesRef = FirebaseDatabase.instance.refFromURL('https://delocube-6ecbc-default-rtdb.asia-southeast1.firebasedatabase.app').child('Capsules');
    DatabaseEvent event = await capsulesRef.once();
    final data = event.snapshot.value as Map<dynamic, dynamic>?;

    if (data != null) {
      List<Capsule> capsules = [];
      data.forEach((key, value) {
        capsules.add(Capsule.fromMap(key, Map<String, dynamic>.from(value)));
      });
      setState(() {
        _capsules = capsules;
        print('Capsules loaded: $_capsules');
      });
    } else {
      print('No capsules found in the database.');
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _searchRegion(String query) {
    final List<Map<String, dynamic>> matches = [];
    for (var region in _regions) {
      if (region['name'].toLowerCase().startsWith(query.toLowerCase())) {
        matches.add(region);
      }
    }

    if (matches.isNotEmpty) {
      final region = matches.first;
      LatLng targetLocation = LatLng(region['latitude'], region['longitude']);
      _mapController.animateCamera(
        CameraUpdate.newLatLngBounds(
          LatLngBounds(
            southwest: LatLng(targetLocation.latitude - 0.1, targetLocation.longitude - 0.1),
            northeast: LatLng(targetLocation.latitude + 0.1, targetLocation.longitude + 0.1),
          ),
          10,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TopSearchBar(
          searchController: _searchController,
          onSearch: (query) => _searchRegion(query),
          regions: _regions,
        ),
        backgroundColor: Colors.blue,
      ),
      drawer: MenuDrawer(), // Используем виджет бокового меню
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: (controller) {
              _mapController = controller;
              _getCurrentLocation();
            },
            initialCameraPosition: CameraPosition(
              target: _currentPosition,
              zoom: 15,
            ),
            markers: _capsules.map((capsule) {
              print('Adding marker for capsule: ${capsule.name} at ${capsule.latitude}, ${capsule.longitude}');
              return Marker(
                markerId: MarkerId(capsule.id),
                position: LatLng(capsule.latitude, capsule.longitude),
                icon: _customIcon ?? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
                infoWindow: InfoWindow(
                  title: capsule.name,
                  snippet: capsule.address,
                ),
              );
            }).toSet(),
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
          ),
          if (_isLoading)
            Center(child: CircularProgressIndicator()),
          Align(
            alignment: Alignment.bottomCenter,
            child: BottomNavBar(
              currentIndex: 0,
              onTap: (index) {
                if (index == 1) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => CapsuleListScreen()),
                  );
                }
                // Добавьте логику для обработки нажатий на элементы нижней панели
              },
            ),
          ),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 56.0), // 3 пикселя выше нижней панели
        child: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => CapsuleListScreen()),
            );
          },
          child: Icon(Icons.list),
          backgroundColor: Colors.blue,
        ),
      ),
    );
  }
}