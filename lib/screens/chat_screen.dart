import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firestore_service.dart';
import '../models/capsule_model.dart';
import '../screens/capsule_detail_screen.dart';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final FirestoreService _firestoreService = FirestoreService();
  final List<String> _messages = [];

  void _sendMessage() async {
    final message = _controller.text;
    _controller.clear();

    setState(() {
      _messages.add('Вы: $message');
    });

    // Пример простой логики бота
    if (message.toLowerCase().contains('найди капсулу')) {
      final capsules = await _firestoreService.getCapsules();
      final capsule = capsules.first; // Пример: выбираем первую капсулу

      setState(() {
        _messages.add('Бот: Найдена капсула "${capsule.name}"');
      });

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CapsuleDetailScreen(capsule: capsule),
        ),
      );
    } else {
      setState(() {
        _messages.add('Бот: Не понял ваш запрос.');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Чат с ботом'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_messages[index]),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Введите сообщение',
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}