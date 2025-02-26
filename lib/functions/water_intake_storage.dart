import 'dart:convert';

import 'package:my_water_intake/functions/water_intake.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WaterIntakeStorage {
  // Save water intake logs to SharedPreferences
  Future<void> saveWaterIntake(List<WaterIntake> intakeLogs) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> intakeLogsString =
        intakeLogs.map((log) => json.encode(log.toJson())).toList();
    await prefs.setStringList('waterIntakeLogs', intakeLogsString);
  }

  // Load water intake logs from SharedPreferences
  Future<List<WaterIntake>> loadWaterIntake() async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? intakeLogsString = prefs.getStringList('waterIntakeLogs');
    if (intakeLogsString != null) {
      return intakeLogsString
          .map((logString) => WaterIntake.fromJson(json.decode(logString)))
          .toList();
    }
    return [];
  }

  // Load water intake logs for a specific week
  Future<List<WaterIntake>> loadWeeklyStats(DateTime weekStart) async {
    List<WaterIntake> allLogs = await loadWaterIntake();
    List<WaterIntake> weeklyLogs = [];

    // Define the end of the week (7 days after the start)
    DateTime weekEnd = weekStart.add(const Duration(days: 6));

    for (var log in allLogs) {
      // Check if the log's timestamp is within the week range
      if (log.timestamp.isAfter(weekStart.subtract(const Duration(days: 1))) &&
          log.timestamp.isBefore(weekEnd.add(const Duration(days: 1)))) {
        weeklyLogs.add(log);
      }
    }
    return weeklyLogs;
  }
}
