import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class WaterIntakeCard extends StatelessWidget {
  final double height;
  final double width;
  final int totalWaterIntake;
  final DateTime selectedDate; // Add selectedDate to the widget

  const WaterIntakeCard({
    super.key,
    required this.height,
    required this.width,
    required this.totalWaterIntake,
    required this.selectedDate, // Include selectedDate in the constructor
  });

  @override
  Widget build(BuildContext context) {
    // Get the current date (today)
    DateTime today = DateTime.now();

    // Check if the selected date is today
    bool isToday = today.year == selectedDate.year &&
        today.month == selectedDate.month &&
        today.day == selectedDate.day;

    // Check if the selected date is yesterday
    bool isYesterday = today.subtract(const Duration(days: 1)).year ==
            selectedDate.year &&
        today.subtract(const Duration(days: 1)).month == selectedDate.month &&
        today.subtract(const Duration(days: 1)).day == selectedDate.day;

    // Determine the text to display for the date
    String dateLabel;
    if (isToday) {
      dateLabel = 'Today';
    } else if (isYesterday) {
      dateLabel = 'Yesterday';
    } else {
      dateLabel = DateFormat('dd/MM/yyyy').format(
          selectedDate); // Show the actual date if it's not today or yesterday
    }

    return Column(
      children: [
        Card(
          elevation: height * .005,
          color: Colors.lightBlue.shade50,
          child: Padding(
            padding: EdgeInsets.symmetric(
                horizontal: width * .03, vertical: height * .01),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  // Show Today, Yesterday, or formatted date
                  dateLabel,
                  style: TextStyle(
                      fontSize: height * .025,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueGrey),
                ),
                Text(
                  // Show the total water intake for the selected day
                  '${(totalWaterIntake / 100).toStringAsFixed(2)}L',
                  style: TextStyle(
                      fontSize: height * .022, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
