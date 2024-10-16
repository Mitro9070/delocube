import 'package:flutter/material.dart';

class GuestPickerScreen extends StatefulWidget {
  @override
  _GuestPickerScreenState createState() => _GuestPickerScreenState();
}

class _GuestPickerScreenState extends State<GuestPickerScreen> {
  int _adults = 1;
  int _children = 0;
  int _infants = 0;

  void _onClear() {
    setState(() {
      _adults = 1;
      _children = 0;
      _infants = 0;
    });
  }

  void _onApply() {
    String result = 'Взрослые - $_adults, Дети - $_children, Младенцы - $_infants';
    Navigator.of(context).pop(result);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.5), // Эффект затемнения экрана
      body: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          padding: EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  Text(
                    'Гости',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(width: 48), // Для выравнивания заголовка по центру
                ],
              ),
              Divider(),
              Text(
                'Жилье рассчитано максимум на 3 гостя (не считая младенцев)',
                style: TextStyle(fontSize: 14, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16),
              GuestCounter(
                label: 'Взрослые',
                subLabel: 'от 13 лет',
                initialValue: _adults,
                onChanged: (value) {
                  setState(() {
                    _adults = value;
                  });
                },
              ),
              GuestCounter(
                label: 'Дети',
                subLabel: 'Возраст: 2–12',
                initialValue: _children,
                onChanged: (value) {
                  setState(() {
                    _children = value;
                  });
                },
              ),
              GuestCounter(
                label: 'Младенцы',
                subLabel: 'Младше 2',
                initialValue: _infants,
                onChanged: (value) {
                  setState(() {
                    _infants = value;
                  });
                },
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: _onClear,
                    child: Text(
                      'Очистить',
                      style: TextStyle(color: Colors.black, fontSize: 16),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _onApply,
                    child: Text('Применить'),
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
      ),
    );
  }
}

class GuestCounter extends StatelessWidget {
  final String label;
  final String subLabel;
  final int initialValue;
  final ValueChanged<int> onChanged;

  GuestCounter({
    required this.label,
    required this.subLabel,
    required this.initialValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    int _count = initialValue;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: 16)),
              Text(subLabel, style: TextStyle(fontSize: 14, color: Colors.grey)),
            ],
          ),
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.remove_circle_outline),
                onPressed: () {
                  if (_count > 0) {
                    _count--;
                    onChanged(_count);
                  }
                },
              ),
              Text('$_count', style: TextStyle(fontSize: 16)),
              IconButton(
                icon: Icon(Icons.add_circle_outline),
                onPressed: () {
                  _count++;
                  onChanged(_count);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}