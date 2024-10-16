import 'package:flutter/material.dart';
import '../models/capsule_model.dart';
import '../screens/feedback_screen.dart';

class CapsuleDetailScreen extends StatelessWidget {
  final Capsule capsule;

  CapsuleDetailScreen({required this.capsule});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(capsule.name),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                capsule.name,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                capsule.description,
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 10),
              Text(
                'Цена: ${capsule.dailyRate} рублей',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                'Отзывы:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              ...capsule.reviews.map((review) => Text('- $review')).toList(),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  // Логика бронирования капсулы
                },
                child: Text('Забронировать'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    '/feedback',
                    arguments: capsule,
                  );
                },
                child: Text('Завершить бронирование и оставить отзыв'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}