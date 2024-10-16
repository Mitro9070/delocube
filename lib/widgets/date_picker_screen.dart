import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

class DatePickerScreen extends StatefulWidget {
  @override
  _DatePickerScreenState createState() => _DatePickerScreenState();
}

class _DatePickerScreenState extends State<DatePickerScreen> {
  DateTime? _startDate;
  DateTime? _endDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  RangeSelectionMode _rangeSelectionMode = RangeSelectionMode.toggledOn;
  DateTime _focusedDay = DateTime.now();

  void _onClear() {
    setState(() {
      _startDate = null;
      _endDate = null;
      _startTime = null;
      _endTime = null;
      _rangeSelectionMode = RangeSelectionMode.toggledOff;
    });
  }

  void _onApply() {
    if (_startDate != null && _endDate == null) {
      String formattedDate = DateFormat('dd MMMM', 'ru').format(_startDate!);
      String formattedStartTime = _startTime != null ? _startTime!.format(context) : '';
      String formattedEndTime = _endTime != null ? _endTime!.format(context) : '';
      String result = '$formattedDate ${formattedStartTime.isNotEmpty && formattedEndTime.isNotEmpty ? 'с $formattedStartTime до $formattedEndTime' : ''}';
      Navigator.of(context).pop(result);
    } else if (_startDate != null && _endDate != null) {
      String formattedStartDate = DateFormat('dd.MM.yyyy').format(_startDate!);
      String formattedEndDate = DateFormat('dd.MM.yyyy').format(_endDate!);
      String result = '$formattedStartDate - $formattedEndDate';
      Navigator.of(context).pop(result);
    }
  }

  Future<void> _selectTime(BuildContext context, bool isStart) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      helpText: isStart ? 'Выберите время начала бронирования' : 'Выберите время окончания бронирования',
      cancelText: 'Отменить',
      confirmText: 'Ок',
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
    }
  }

  void _selectTimeRange(BuildContext context) async {
    await _selectTime(context, true);
    await _selectTime(context, false);
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
                    _startDate != null && _endDate != null
                        ? '${DateFormat('d MMM', 'ru').format(_startDate!)} – ${DateFormat('d MMM', 'ru').format(_endDate!)}'
                        : (_startDate != null
                        ? DateFormat('d MMM', 'ru').format(_startDate!)
                        : ''),
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: Icon(Icons.access_time),
                    onPressed: _startDate != null && _endDate == null
                        ? () => _selectTimeRange(context)
                        : null,
                  ),
                ],
              ),
              Divider(),
              TableCalendar(
                locale: 'ru_RU',
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: _focusedDay,
                calendarFormat: _calendarFormat,
                rangeSelectionMode: _rangeSelectionMode,
                selectedDayPredicate: (day) => isSameDay(_startDate, day) || isSameDay(_endDate, day),
                rangeStartDay: _startDate,
                rangeEndDay: _endDate,
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _focusedDay = focusedDay;
                    if (_rangeSelectionMode == RangeSelectionMode.toggledOn) {
                      _startDate = selectedDay;
                      _endDate = null;
                      _rangeSelectionMode = RangeSelectionMode.toggledOff;
                    } else if (_rangeSelectionMode == RangeSelectionMode.toggledOff) {
                      _endDate = selectedDay;
                      _rangeSelectionMode = RangeSelectionMode.toggledOn;
                    }
                  });
                },
                onRangeSelected: (start, end, focusedDay) {
                  setState(() {
                    _focusedDay = focusedDay;
                    _startDate = start;
                    _endDate = end;
                  });
                },
                onFormatChanged: (format) {
                  if (_calendarFormat != format) {
                    setState(() {
                      _calendarFormat = format;
                    });
                  }
                },
                onPageChanged: (focusedDay) {
                  _focusedDay = focusedDay;
                },
              ),
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