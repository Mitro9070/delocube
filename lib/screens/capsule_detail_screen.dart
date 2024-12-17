import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import '../utils/cost_calculation.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../models/capsule_model.dart';
import '../widgets/date_picker_screen.dart';
import '../widgets/guest_picker_screen.dart';
import 'package:intl/intl.dart';

class CapsuleDetailScreen extends StatefulWidget {
  final Capsule capsule;

  CapsuleDetailScreen({required this.capsule});

  @override
  _CapsuleDetailScreenState createState() => _CapsuleDetailScreenState();
}

class _CapsuleDetailScreenState extends State<CapsuleDetailScreen> {
  int _current = 0;
  bool _isLoading = true;
  BitmapDescriptor? customIcon;
  int _loadedImages = 0;

  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _guestsController = TextEditingController();
  final TextEditingController _hoursController = TextEditingController();
  String _cost = '';
  bool _isSingleDateSelected = false;

  @override
  void initState() {
    super.initState();
    _loadCustomIcon();

    _hoursController.addListener(() {
      setState(() {
        _cost = CostCalculation.calculateCost(
          dateText: _dateController.text,
          capsule: widget.capsule,
        );
      });
    });
  }

  Future<void> _loadCustomIcon() async {
    customIcon = await BitmapDescriptor.fromAssetImage(
      ImageConfiguration(size: Size(32, 32)),
      'lib/assets/map32.png',
    );
    setState(() {});
  }

  void _onImageLoaded() {
    _loadedImages++;
    if (_loadedImages == widget.capsule.images.length) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          _isLoading = false;
        });
      });
    }
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
        _cost = CostCalculation.calculateCost(
          dateText: _dateController.text,
          capsule: widget.capsule,
        );
        print('Selected Dates: $selectedDates');
        print('Calculated Cost: $_cost');
      });
    }
  }

  void _selectTime(BuildContext context) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            alwaysUse24HourFormat: true, // Принудительно 24-часовой формат
          ),
          child: Localizations.override(
            context: context,
            locale: const Locale('ru', 'RU'), // Установка русской локали
            child: child,
          ),
        );
      },
    );

    if (pickedTime != null) {
      final now = DateTime.now();
      final DateTime fullTime = DateTime(now.year, now.month, now.day, pickedTime.hour, pickedTime.minute);
      final String formattedTime = DateFormat('HH:mm', 'ru').format(fullTime);
      // Используйте formattedTime по необходимости
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            // Выравниваем элементы по левому краю
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Stack(
                children: [
                  CarouselSlider(
                    options: CarouselOptions(
                      height: 230,
                      enlargeCenterPage: true,
                      enableInfiniteScroll: false,
                      aspectRatio: 16 / 9,
                      viewportFraction: 0.994,
                      onPageChanged: (index, reason) {
                        setState(() {
                          _current = index;
                        });
                      },
                    ),
                    items: widget.capsule.images.map((image) {
                      return Builder(
                        builder: (BuildContext context) {
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.network(
                              image,
                              width: MediaQuery.of(context).size.width,
                              fit: BoxFit.cover,
                              loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                                if (loadingProgress == null) {
                                  _onImageLoaded();
                                  return child;
                                } else {
                                  return Center(
                                    child: CircularProgressIndicator(),
                                  );
                                }
                              },
                            ),
                          );
                        },
                      );
                    }).toList(),
                  ),
                  if (_isLoading)
                    Positioned.fill(
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                ],
              ),
              SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: widget.capsule.images.map((url) {
                  int index = widget.capsule.images.indexOf(url);
                  return Container(
                    width: 8.0,
                    height: 8.0,
                    margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 2.0),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _current == index
                          ? Color.fromRGBO(0, 0, 0, 0.9)
                          : Color.fromRGBO(0, 0, 0, 0.4),
                    ),
                  );
                }).toList(),
              ),
              SizedBox(height: 16),
              Text(
                widget.capsule.name,
                style: TextStyle(
                  fontFamily: 'Rubik',
                  fontSize: 24,
                  fontWeight: FontWeight.w400,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 4),
              Text(
                widget.capsule.address,
                style: TextStyle(
                  fontFamily: 'Rubik',
                  fontSize: 12,
                  fontWeight: FontWeight.w300,
                  color: Color(0xFF6C6C6C),
                ),
              ),
              SizedBox(height: 16),
              Text(
                '${widget.capsule.area} кв.м., спальных мест - ${widget.capsule.beds}',
                style: TextStyle(
                  fontFamily: 'Rubik',
                  fontSize: 11,
                  fontWeight: FontWeight.w300,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _dateController,
                readOnly: true,
                onTap: _openDatePicker,
                decoration: InputDecoration(
                  labelText: 'Когда',
                  hintText: 'Указать даты',
                  filled: true,
                  fillColor: Color(0xFFF8F9FB),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(9),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
                ),
              ),
              if (_isSingleDateSelected) ...[
                SizedBox(height: 16),
                TextField(
                  controller: _hoursController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Часы',
                    hintText: 'Указать количество часов',
                    filled: true,
                    fillColor: Color(0xFFF8F9FB),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(9),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
                  ),
                ),
              ],
              SizedBox(height: 16),
              TextField(
                controller: _guestsController,
                readOnly: true,
                onTap: _openGuestPicker,
                decoration: InputDecoration(
                  labelText: 'Кто',
                  hintText: 'Добавить гостей',
                  filled: true,
                  fillColor: Color(0xFFF8F9FB),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(9),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
                ),
              ),
              if (_cost.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Text(
                    _cost,
                    key: Key('cost_text'),
                    style: TextStyle(
                      fontFamily: 'Rubik',
                      fontSize: 20,
                      fontWeight: FontWeight.w300,
                      color: _cost.contains('Пожалуйста') ? Colors.red : Colors.black,
                    ),
                  ),
                ),
              SizedBox(height: 16),
              Row(
                children: [
                  ElevatedButton(
                    onPressed: () {},
                    child: Text('Получить 285 бонусов'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFF8F9FB),
                      foregroundColor: Colors.black,
                      padding: EdgeInsets.symmetric(horizontal: 17),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                        side: BorderSide(color: Colors.black, width: 0.5),
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {},
                    child: Text('Нечего списать'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFF8F9FB),
                      foregroundColor: Colors.black,
                      padding: EdgeInsets.symmetric(horizontal: 17),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              TextButton(
                onPressed: () {},
                child: Text('Промокод >'),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.black,
                  textStyle: TextStyle(
                    fontFamily: 'Rubik',
                    fontSize: 13,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ),
              SizedBox(height: 16),
              TextButton(
                onPressed: () {},
                child: Text('Договор аренды Делокуб >'),
                style: TextButton.styleFrom(
                  foregroundColor: Color(0xFF6C6C6C),
                  textStyle: TextStyle(
                    fontFamily: 'Rubik',
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              SizedBox(height: 8),
              TextButton(
                onPressed: () {},
                child: Text('Что такое бонусы?'),
                style: TextButton.styleFrom(
                  foregroundColor: Color(0xFF447FFF),
                  textStyle: TextStyle(
                    fontFamily: 'Rubik',
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Расположение',
                style: TextStyle(
                  fontFamily: 'Rubik',
                  fontSize: 20,
                  fontWeight: FontWeight.w400,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 8),
              Container(
                width: MediaQuery.of(context).size.width - 6,
                height: 180,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: customIcon == null
                    ? Center(child: CircularProgressIndicator())
                    : ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: LatLng(widget.capsule.latitude, widget.capsule.longitude),
                      zoom: 14,
                    ),
                    markers: {
                      Marker(
                        markerId: MarkerId('capsule_location'),
                        position: LatLng(widget.capsule.latitude, widget.capsule.longitude),
                        icon: customIcon!,
                      ),
                    },
                  ),
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Основные удобства номера',
                style: TextStyle(
                  fontFamily: 'Rubik',
                  fontSize: 20,
                  fontWeight: FontWeight.w400,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Беспроводной интернет Wi-Fi\nКондиционер\nПолотенца\nФен\nТелевизор',
                style: TextStyle(
                  fontFamily: 'Rubik',
                  fontSize: 14,
                  fontWeight: FontWeight.w300,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {},
                child: Text('Все удобства'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFF8F9FB),
                  foregroundColor: Colors.black,
                  padding: EdgeInsets.symmetric(horizontal: 33, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: BorderSide(color: Color(0xFF6C6C6C), width: 1),
                  ),
                ),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {},
                child: Text('ЗАБРОНИРОВАТЬ'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 12),
                  textStyle: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}