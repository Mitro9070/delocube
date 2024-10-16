import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'search_screen.dart'; // Импортируем экран поиска
import '../widgets/menu_drawer.dart'; // Импортируем виджет бокового меню
import '../models/capsule_model.dart'; // Импортируем модель капсулы

class HomeScreen extends StatefulWidget {
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

  @override
  void initState() {
    super.initState();
    _initializeFirebase();
    _loadRegions();
    _getCurrentLocation();
    _loadCapsules();
  }

  Future<void> _initializeFirebase() async {
    await Firebase.initializeApp();
  }

  Future<void> _loadRegions() async {
    try {
      final String response = await rootBundle.loadString('assets/regions.json');
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

  void _loadCapsules() async {
    DatabaseReference capsulesRef = FirebaseDatabase.instance.ref().child('Capsules');
    capsulesRef.once().then((DatabaseEvent event) {
      List<Capsule> capsules = [];
      Map<String, dynamic> data = Map<String, dynamic>.from(event.snapshot.value as Map);
      data.forEach((key, value) {
        capsules.add(Capsule.fromMap(key, Map<String, dynamic>.from(value)));
      });
      setState(() {
        _capsules = capsules;
        print('Capsules loaded: $_capsules');
      });
    }).catchError((error) {
      print('Error loading capsules: $error');
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
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Autocomplete<String>(
                optionsBuilder: (TextEditingValue textEditingValue) {
                  if (textEditingValue.text.isEmpty) {
                    return const Iterable<String>.empty();
                  }
                  return _regions.map((region) => region['name'] as String).where((String option) {
                    return option.toLowerCase().startsWith(textEditingValue.text.toLowerCase());
                  });
                },
                onSelected: (String selection) {
                  setState(() {
                    _selectedLocations.add(selection);
                    _searchController.text = _selectedLocations.join(', ');
                    _searchRegion(selection);
                  });
                },
                fieldViewBuilder: (BuildContext context, TextEditingController textEditingController, FocusNode focusNode, VoidCallback onFieldSubmitted) {
                  return TextField(
                    controller: textEditingController,
                    focusNode: focusNode,
                    decoration: InputDecoration(
                      hintText: 'Куда?',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                    ),
                  );
                },
              ),
            ),
            IconButton(
              icon: Icon(Icons.settings),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SearchScreen()),
                );
              },
            ),
          ],
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
                icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
                infoWindow: InfoWindow(
                  title: capsule.name,
                  snippet: capsule.address,
                ),
              );
            }).toSet(),
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: BottomNavigationBar(
              items: [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  label: 'Поиск',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.favorite),
                  label: 'Избранное',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.chat),
                  label: 'Связаться',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person),
                  label: 'Профиль',
                ),
              ],
              type: BottomNavigationBarType.fixed,
              onTap: (index) {
                // Добавьте логику для обработки нажатий на элементы нижней панели
              },
            ),
          ),
        ],
      ),
    );
  }
}