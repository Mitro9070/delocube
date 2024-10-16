import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:convert';
import 'home_screen.dart';
import '../widgets/date_picker_screen.dart';
import '../widgets/guest_picker_screen.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _priceFromController = TextEditingController();
  final TextEditingController _priceToController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _guestsController = TextEditingController();
  final List<String> _selectedLocations = [];
  List<Map<String, dynamic>> _regions = [];

  @override
  void initState() {
    super.initState();
    _loadRegions();
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

  void _clearFields() {
    _locationController.clear();
    _priceFromController.clear();
    _priceToController.clear();
    _dateController.clear();
    _guestsController.clear();
    _selectedLocations.clear();
    setState(() {});
  }

  void _openDatePicker() async {
    final selectedDates = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return DatePickerScreen();
      },
    );

    if (selectedDates != null) {
      setState(() {
        _dateController.text = selectedDates;
      });
    }
  }

  void _openGuestPicker() async {
    final selectedGuests = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return GuestPickerScreen();
      },
    );

    if (selectedGuests != null) {
      setState(() {
        _guestsController.text = selectedGuests;
      });
    }
  }

  void _search() {
    // Получаем координаты центра выбранного региона или города
    LatLng? targetLocation;
    for (String location in _selectedLocations) {
      final region = _regions.firstWhere((region) => region['name'] == location, orElse: () => {});
      if (region.isNotEmpty) {
        targetLocation = LatLng(region['latitude'], region['longitude']);
        break;
      }
    }

    if (targetLocation != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomeScreen(
            targetLocation: targetLocation,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: 24), // Отступ сверху
            Autocomplete<String>(
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
                  _locationController.text = _selectedLocations.join(', ');
                });
              },
              fieldViewBuilder: (BuildContext context, TextEditingController textEditingController, FocusNode focusNode, VoidCallback onFieldSubmitted) {
                return TextField(
                  controller: textEditingController,
                  focusNode: focusNode,
                  decoration: InputDecoration(
                    labelText: 'Где искать',
                    hintText: 'Введите регион',
                    filled: true,
                    fillColor: Color(0xFFF5F5F5),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
                  ),
                );
              },
            ),
            SizedBox(height: 24), // Увеличенный отступ
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _priceFromController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      TextInputFormatter.withFunction((oldValue, newValue) {
                        return newValue.copyWith(
                          text: newValue.text + ' руб.',
                        );
                      }),
                    ],
                    decoration: InputDecoration(
                      labelText: 'Цена',
                      hintText: 'от',
                      filled: true,
                      fillColor: Color(0xFFF5F5F5),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _priceToController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      TextInputFormatter.withFunction((oldValue, newValue) {
                        return newValue.copyWith(
                          text: newValue.text + ' руб.',
                        );
                      }),
                    ],
                    decoration: InputDecoration(
                      hintText: 'до',
                      filled: true,
                      fillColor: Color(0xFFF5F5F5),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 24), // Увеличенный отступ
            TextField(
              controller: _dateController,
              readOnly: true,
              onTap: _openDatePicker,
              decoration: InputDecoration(
                labelText: 'Когда',
                hintText: 'Указать даты',
                filled: true,
                fillColor: Color(0xFFF5F5F5),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
              ),
            ),
            SizedBox(height: 24), // Увеличенный отступ
            TextField(
              controller: _guestsController,
              readOnly: true,
              onTap: _openGuestPicker,
              decoration: InputDecoration(
                labelText: 'Кто',
                hintText: 'Добавить гостей',
                filled: true,
                fillColor: Color(0xFFF5F5F5),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
              ),
            ),
            SizedBox(height: 24), // Увеличенный отступ
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: _clearFields,
                  child: Text(
                    'Очистить всё',
                    style: TextStyle(color: Colors.black, fontSize: 16),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _search,
                  icon: Icon(Icons.search, color: Colors.white),
                  label: Text('Искать'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    textStyle: TextStyle(fontSize: 16),
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Поиск',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Избранное',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.message),
            label: 'Связаться',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Профиль',
          ),
        ],
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.black,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}