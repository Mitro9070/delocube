import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

class StorytellingScreen extends StatefulWidget {
  @override
  _StorytellingScreenState createState() => _StorytellingScreenState();
}

class _StorytellingScreenState extends State<StorytellingScreen> {
  final List<String> images = [
    'lib/assets/Slider/Frame1.png',
    'lib/assets/Slider/Frame2.png',
    'lib/assets/Slider/Frame3.png',
    'lib/assets/Slider/Frame4.png',
    'lib/assets/Slider/Frame5.png',
  ];

  int _currentSlide = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CarouselSlider(
              options: CarouselOptions(
                height: 373,
                autoPlay: true,
                autoPlayInterval: Duration(seconds: 3),
                onPageChanged: (index, reason) {
                  setState(() {
                    _currentSlide = index;
                  });
                  if (index == images.length - 1) {
                    Navigator.pushReplacementNamed(context, '/welcome');
                  }
                },
              ),
              items: images.map((image) {
                return Builder(
                  builder: (BuildContext context) {
                    return Image.asset(image, fit: BoxFit.cover);
                  },
                );
              }).toList(),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: images.map((url) {
                int index = images.indexOf(url);
                return Container(
                  width: 8.0,
                  height: 8.0,
                  margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 2.0),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentSlide == index
                        ? Color.fromRGBO(0, 255, 0, 0.9)
                        : Color.fromRGBO(0, 0, 0, 0.4),
                  ),
                );
              }).toList(),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/welcome');
              },
              child: Text('Пропустить'),
            ),
          ],
        ),
      ),
    );
  }
}