import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import '../widgets/top_search_bar.dart';
import '../widgets/bottom_navigation_bar.dart';
import '../models/capsule_model.dart';
import 'home_screen.dart'; // Импортируем экран карты

class CapsuleListScreen extends StatefulWidget {
  @override
  _CapsuleListScreenState createState() => _CapsuleListScreenState();
}

class _CapsuleListScreenState extends State<CapsuleListScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _regions = [];
  List<Capsule> _capsules = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadRegions();
    _loadCapsules();
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

  Future<void> _loadCapsules() async {
    setState(() {
      _isLoading = true;
    });

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
      // Implement search logic if needed
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
      body: Stack(
        children: [
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : ListView.builder(
            itemCount: _capsules.length,
            itemBuilder: (context, index) {
              final capsule = _capsules[index];
              return Container(
                margin: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 4.5,
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.network(
                            capsule.images.isNotEmpty ? capsule.images[0] : '',
                            width: 100, // Увеличено на 5 пикселей
                            height: 100, // Увеличено на 5 пикселей
                            fit: BoxFit.cover,
                          ),
                        ),
                        SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              capsule.name,
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              capsule.address,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w300,
                                color: Colors.grey,
                              ),
                            ),
                            SizedBox(height: 8),
                            GestureDetector(
                              onTap: () {
                                // Implement booking logic
                              },
                              child: Row(
                                children: [
                                  Text(
                                    'Забронировать',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.black,
                                    ),
                                  ),
                                  SizedBox(width: 4),
                                  Icon(
                                    Icons.arrow_forward_ios,
                                    size: 9,
                                    color: Colors.black,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Positioned(
                      top: 1,
                      right: 1,
                      child: IconButton(
                        icon: Icon(Icons.favorite_border),
                        onPressed: () {
                          // Implement favorite logic
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: BottomNavBar(
              currentIndex: 1,
              onTap: (index) {
                if (index == 0) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => HomeScreen()),
                  );
                }
                // Implement navigation logic
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
              MaterialPageRoute(builder: (context) => HomeScreen()),
            );
          },
          child: Icon(Icons.map),
          backgroundColor: Colors.blue,
        ),
      ),
    );
  }
}