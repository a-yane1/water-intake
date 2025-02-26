import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:my_water_intake/functions/water_intake_storage.dart';
import 'package:my_water_intake/functions/water_intake.dart';

class StatsPage extends StatefulWidget {
  final DateTime selectedDate;

  const StatsPage({
    required this.selectedDate,
    super.key,
  });

  @override
  // ignore: library_private_types_in_public_api
  _StatsPageState createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  late double totalWeeklyIntake;
  late Map<String, int> dailyIntake;
  late WaterIntakeStorage waterIntakeStorage;

  @override
  void initState() {
    super.initState();
    waterIntakeStorage = WaterIntakeStorage();
    dailyIntake = {};
    totalWeeklyIntake = 0;
    _loadWeeklyIntake(widget.selectedDate);
  }

  Future<void> _loadWeeklyIntake(DateTime selectedDate) async {
    List<WaterIntake> waterIntakes = await waterIntakeStorage.loadWaterIntake();

    DateTime startOfWeek =
        selectedDate.subtract(Duration(days: selectedDate.weekday % 7));
    DateTime endOfWeek = startOfWeek.add(const Duration(days: 6));

    double weeklyTotal = 0;
    Map<String, int> newDailyIntake = {};

    for (var intake in waterIntakes) {
      if (intake.timestamp
              .isAfter(startOfWeek.subtract(const Duration(days: 1))) &&
          intake.timestamp.isBefore(endOfWeek.add(const Duration(days: 1)))) {
        weeklyTotal += intake.amount.toDouble();
        String dayKey = DateFormat('yyyy-MM-dd').format(intake.timestamp);
        newDailyIntake[dayKey] = (newDailyIntake[dayKey] ?? 0) + intake.amount;
      }
    }

    setState(() {
      totalWeeklyIntake = weeklyTotal;
      dailyIntake = newDailyIntake;
    });
  }

  @override
  void didUpdateWidget(covariant StatsPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedDate != oldWidget.selectedDate) {
      // Reload the data when selectedDate changes
      _loadWeeklyIntake(widget.selectedDate);
    }
  }

  @override
  Widget build(BuildContext context) {
    double maxY = _calculateMaxY();
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    DateTime startOfWeek = widget.selectedDate
        .subtract(Duration(days: widget.selectedDate.weekday % 7));
    DateTime endOfWeek = startOfWeek.add(const Duration(days: 6));

    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.all(height * .02),
        child: Column(
          children: [
            // Display the week range
            Text(
              "Stats for the week: ${DateFormat('MMM dd').format(startOfWeek)} - ${DateFormat('MMM dd').format(endOfWeek)}",
              style: TextStyle(
                  fontSize: height * .02, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: height * .02),
            // Weekly total
            Card(
              color: Colors.lightBlue.shade50,
              elevation: height * .01,
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: width * .02,
                  vertical: height * .015,
                ),
                child: Text(
                  'Total Intake for the Week: ${(totalWeeklyIntake / 100).toStringAsFixed(2)}L',
                  style: TextStyle(
                      fontSize: height * .02, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            SizedBox(height: height * .03),
            // Chart area
            SizedBox(
              height: height * .6,
              child: BarChart(
                BarChartData(
                  barGroups: _createBarGroups(),
                  borderData: FlBorderData(
                    show: true,
                    border: Border(
                      left: BorderSide(
                          color: Colors.lightBlue.shade400,
                          width: width * .005),
                      bottom: BorderSide(
                          color: Colors.lightBlue.shade400,
                          width: width * .005),
                      right: BorderSide.none,
                      top: BorderSide.none,
                    ),
                  ),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) =>
                            _leftTitles(value, meta, maxY),
                        reservedSize: height * .07,
                      ),
                    ),
                    rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: _bottomTitles,
                        reservedSize: height * .05,
                      ),
                    ),
                  ),
                  gridData: const FlGridData(
                    show: true,
                    drawVerticalLine: false,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  double _calculateMaxY() {
    if (dailyIntake.isEmpty) {
      return 1000; // Default minimum if no data is available
    }
    double maxValue =
        dailyIntake.values.reduce((a, b) => a > b ? a : b).toDouble();
    return maxValue + 500.0; // Slightly higher to allow space for titles
  }

  List<BarChartGroupData> _createBarGroups() {
    List<BarChartGroupData> barGroups = [];
    DateTime startOfWeek = widget.selectedDate
        .subtract(Duration(days: widget.selectedDate.weekday % 7));

    for (int i = 0; i < 7; i++) {
      DateTime day = startOfWeek.add(Duration(days: i));
      String dayKey = DateFormat('yyyy-MM-dd').format(day);
      int intake = dailyIntake[dayKey] ?? 0;
      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: intake.toDouble(),
              color: Colors.lightBlue.shade300,
              borderRadius: BorderRadius.circular(
                  MediaQuery.of(context).size.width * .01),
              width: MediaQuery.of(context).size.width * .07,
            ),
          ],
        ),
      );
    }

    return barGroups;
  }

  Widget _bottomTitles(double value, TitleMeta meta) {
    DateTime startOfWeek = widget.selectedDate
        .subtract(Duration(days: widget.selectedDate.weekday % 7));
    DateTime day = startOfWeek.add(Duration(days: value.toInt()));
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Text(DateFormat('E').format(day)),
    );
  }

  Widget _leftTitles(double value, TitleMeta meta, double maxY) {
    // Determine the increment size based on maxY
    double increment =
        (maxY >= 300) ? 100 : 50; // Choose 100 for values >= 300, else 50

    // Only display labels at multiples of the increment size
    if (value % increment == 0) {
      return Padding(
        padding: const EdgeInsets.only(left: 8.0),
        child:
            Text('${(value / 1000).toStringAsFixed(1)}L'), // Convert to liters
      );
    }

    return const SizedBox.shrink(); // Empty widget for non-title values
  }
}
