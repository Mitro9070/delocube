

import 'package:intl/intl.dart';
import '../models/capsule_model.dart';

class CostCalculation {
  static String calculateCost({
    required String dateText,
    required Capsule capsule,
  }) {
    if (dateText.isEmpty) return '';

    try {
      print('Date Text: $dateText');

      // Проверяем, является ли это диапазоном дат
      if (dateText.contains(' - ')) {
        // Обработка посуточного тарифа
        return _calculateDailyCost(dateText, capsule);
      } else if (dateText.contains('с') && dateText.contains('до')) {
        // Обработка почасового тарифа
        return _calculateHourlyCost(dateText, capsule);
      } else {
        // Формат даты не распознан
        return 'Пожалуйста, выберите корректные даты или время';
      }
    } catch (e) {
      print('Error in calculateCost: $e');
      return 'Ошибка расчета стоимости';
    }
  }

  static String _calculateDailyCost(String dateText, Capsule capsule) {
    try {
      final dateRange = dateText.split(' - ');
      final startDateString = dateRange[0].trim();
      final endDateString = dateRange[1].trim();

      DateTime startDate;
      DateTime endDate;
      final currentYear = DateTime.now().year;

      // Попытка парсить в формате 'dd.MM.yyyy'
      try {
        startDate = DateFormat('dd.MM.yyyy', 'ru').parse(startDateString);
        endDate = DateFormat('dd.MM.yyyy', 'ru').parse(endDateString);
      } catch (_) {
        // Если не удалось, пытаемся парсить в формате 'd MMMM'
        startDate = DateFormat('d MMMM', 'ru').parse(startDateString);
        endDate = DateFormat('d MMMM', 'ru').parse(endDateString);

        // Добавляем текущий год
        startDate = DateTime(currentYear, startDate.month, startDate.day);
        endDate = DateTime(currentYear, endDate.month, endDate.day);
      }

      final duration = endDate.difference(startDate).inDays;
      if (duration <= 0) return 'Дата окончания должна быть позже даты начала.';

      int dailyRate = capsule.dailyRate;
      int cost = dailyRate * duration;
      String rate = '$dailyRate руб./сутки';

      print('Start Date: $startDate');
      print('End Date: $endDate');
      print('Duration: $duration');

      return '$cost руб. / $duration суток, $rate';
    } catch (e) {
      print('Error in _calculateDailyCost: $e');
      return 'Ошибка расчета посуточной стоимости';
    }
  }

  static String _calculateHourlyCost(String dateText, Capsule capsule) {
    try {
      final parts = dateText.split(' с ');
      if (parts.length < 2) return 'Недостаточно данных для расчета стоимости.';

      final datePart = parts[0].trim();
      final timeRange = parts[1].trim();

      DateTime date;
      final currentYear = DateTime.now().year;

      // Попытка парсить в формате 'dd.MM.yyyy'
      try {
        date = DateFormat('dd.MM.yyyy', 'ru').parse(datePart);
      } catch (_) {
        // Если не удалось, пытаемся парсить в формате 'd MMMM'
        date = DateFormat('d MMMM', 'ru').parse(datePart);
        // Добавляем текущий год
        date = DateTime(currentYear, date.month, date.day);
      }

      final timeParts = timeRange.split(' до ');
      if (timeParts.length < 2) return 'Недостаточно данных для расчета стоимости.';

      var startTimeStr = timeParts[0].trim();
      var endTimeStr = timeParts[1].trim();

      print('Start Time String: $startTimeStr');
      print('End Time String: $endTimeStr');

      // Парсим время
      final startTime = DateFormat('HH:mm', 'ru').parse(startTimeStr);
      final endTime = DateFormat('HH:mm', 'ru').parse(endTimeStr);

      final fullStartDateTime = DateTime(
          date.year, date.month, date.day, startTime.hour, startTime.minute);
      final fullEndDateTime = DateTime(
          date.year, date.month, date.day, endTime.hour, endTime.minute);

      final durationInMinutes =
          fullEndDateTime.difference(fullStartDateTime).inMinutes;
      if (durationInMinutes <= 0)
        return 'Время окончания должно быть позже времени начала.';

      // Рассчитываем длительность в часах с учетом минут
      final durationInHours = durationInMinutes / 60;

      int hourlyRate = capsule.hourlyRate;
      int cost = (hourlyRate * durationInHours).ceil(); // Округляем в большую сторону
      String rate = '$hourlyRate руб./час';

      String formattedDuration = durationInHours.toStringAsFixed(1);

      return '$cost руб. / $formattedDuration час${_getHourSuffix(durationInHours)}, $rate';
    } catch (e) {
      print('Error in _calculateHourlyCost: $e');
      return 'Ошибка расчета почасовой стоимости';
    }
  }

  static String _getHourSuffix(double hours) {
    int h = hours.round();

    if (h % 10 == 1 && h % 100 != 11) {
      return '';
    } else if (h % 10 >= 2 && h % 10 <= 4 && (h % 100 < 10 || h % 100 >= 20)) {
      return 'а';
    } else {
      return 'ов';
    }
  }
}