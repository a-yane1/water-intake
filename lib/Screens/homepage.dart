import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../functions/water_intake.dart';
import '../functions/water_intake_dialog.dart';
import '../functions/water_intake_storage.dart';
import '../widgets/water_intake_card.dart';
import '../widgets/water_intake_listview.dart';
import '../widgets/quick_add_buttons.dart';
import 'stats_screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int totalWaterIntake = 0;
  List<WaterIntake> intakeLogs = [];
  Map<String, int> dailyIntake = {};
  Map<String, Map<String, int>> weeklyIntake = {};
  int _selectedIndex = 0;
  DateTime _selectedDate = DateTime.now();
  final WaterIntakeStorage storage = WaterIntakeStorage();

  @override
  void initState() {
    super.initState();
    _loadWaterIntakes(); // Load intake data from SharedPreferences
  }

  // Load water intake logs from shared preferences
  Future<void> _loadWaterIntakes() async {
    List<WaterIntake> logs =
        await storage.loadWaterIntake(); // Load from SharedPreferences
    setState(() {
      intakeLogs = logs;
      totalWaterIntake = logs.fold(
          0, (sum, intake) => sum + intake.amount); // Calculate total intake
      _updateDailyIntake(); // Update the daily intake map
    });
  }

  // Update the daily intake map based on the loaded logs
  void _updateDailyIntake() {
    dailyIntake.clear(); // Clear current daily intake
    for (var log in intakeLogs) {
      String day = DateFormat('yyyy-MM-dd').format(log.timestamp);
      dailyIntake[day] = (dailyIntake[day] ?? 0) + log.amount;
    }
  }

  // Save water intake logs whenever the logs are updated
  Future<void> _saveWaterIntakes() async {
    await storage
        .saveWaterIntake(intakeLogs); // Save the logs in SharedPreferences
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      _buildWaterIntakePage(context),
      StatsPage(selectedDate: _selectedDate),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Daily Water Intake',
            style:
                TextStyle(color: Colors.blueGrey, fontWeight: FontWeight.w500)),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today, color: Colors.blueGrey),
            onPressed: () {
              _selectDate(context);
            },
          ),
        ],
      ),
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: [
          BottomNavigationBarItem(
            icon: Icon(
              Icons.local_drink,
              color: Colors.blue.shade500,
            ),
            label: 'Intake',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.bar_chart,
              color: Colors.blue.shade500,
            ),
            label: 'Stats',
          ),
        ],
      ),
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton(
              backgroundColor: Colors.lightBlue.shade50,
              onPressed: () {
                _showAlertDialog(context);
              },
              child: const Icon(
                Icons.add,
                color: Colors.blueGrey,
              ),
            )
          : null,
    );
  }

  void _showAlertDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return WaterIntakeDialog(onLogWaterIntake: _logWaterIntake);
      },
    );
  }

  void _logWaterIntake(int cl) {
    if (cl > 0) {
      setState(() {
        totalWaterIntake += cl; // Directly use the value of cl

        String day = DateFormat('yyyy-MM-dd').format(_selectedDate);

        intakeLogs.add(WaterIntake(
          id: DateTime.now().toString(),
          amount: cl, // Use the cl value directly
          timestamp: _selectedDate,
        ));

        dailyIntake[day] = (dailyIntake[day] ?? 0) + cl; // Update with cl
      });

      // Save the updated data
      _saveWaterIntakes();
    }
  }

  void _fastLogWaterIntake(int cl) {
    _logWaterIntake(cl); // Use cl directly
  }

  Widget _buildWaterIntakePage(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    // Filter the intake for the selected date
    String selectedDayKey = DateFormat('yyyy-MM-dd').format(_selectedDate);
    int intakeForSelectedDay = dailyIntake[selectedDayKey] ?? 0;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          WaterIntakeCard(
              height: height,
              width: width,
              totalWaterIntake: intakeForSelectedDay,
              selectedDate: _selectedDate),
          SizedBox(height: height * .02),
          QuickAddButtons(onFastLogWaterIntake: _fastLogWaterIntake),
          SizedBox(height: height * .02),
          WaterIntakeListView(
            intakeLogs: _getLogsForSelectedDate(),
            onDelete: _removeWaterIntake,
            selectedDate: _selectedDate,
          ),
        ],
      ),
    );
  }

  List<WaterIntake> _getLogsForSelectedDate() {
    String selectedDayKey = DateFormat('yyyy-MM-dd').format(_selectedDate);

    return intakeLogs.where((log) {
      String logDayKey = DateFormat('yyyy-MM-dd').format(log.timestamp);
      return logDayKey == selectedDayKey;
    }).toList();
  }

  void _removeWaterIntake(WaterIntake intake) {
    setState(() {
      // Remove from the list of logs
      intakeLogs.removeWhere((log) => log.id == intake.id);

      // Update the daily intake map
      String day = DateFormat('yyyy-MM-dd').format(intake.timestamp);
      dailyIntake[day] = (dailyIntake[day] ?? 0) - intake.amount;

      if (dailyIntake[day]! <= 0) dailyIntake.remove(day);

      // Recalculate the total water intake
      totalWaterIntake =
          intakeLogs.fold(0, (sum, intake) => sum + intake.amount);
    });

    // Save the updated intake logs to shared preferences
    _saveWaterIntakes();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked; // Update the selected date
      });
    }
  }
}
