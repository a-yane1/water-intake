import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../functions/water_intake.dart';

class WaterIntakeListView extends StatefulWidget {
  final List<WaterIntake> intakeLogs;
  final Function(WaterIntake) onDelete; // Callback to handle deletion
  final DateTime selectedDate; // Date to filter intake logs

  const WaterIntakeListView({
    super.key,
    required this.intakeLogs,
    required this.onDelete,
    required this.selectedDate,
  });

  @override
  _WaterIntakeListViewState createState() => _WaterIntakeListViewState();
}

class _WaterIntakeListViewState extends State<WaterIntakeListView> {
  List<WaterIntake> filteredLogs = [];

  @override
  void initState() {
    super.initState();
    _filterLogs();
  }

  @override
  void didUpdateWidget(covariant WaterIntakeListView oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If the intake logs or selected date has changed, filter the logs again
    if (widget.intakeLogs != oldWidget.intakeLogs ||
        widget.selectedDate != oldWidget.selectedDate) {
      _filterLogs();
    }
  }

  // Function to filter the logs based on the selected date
  void _filterLogs() {
    setState(() {
      filteredLogs = widget.intakeLogs.where((log) {
        return log.timestamp.year == widget.selectedDate.year &&
            log.timestamp.month == widget.selectedDate.month &&
            log.timestamp.day == widget.selectedDate.day;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;

    return Expanded(
      child: filteredLogs.isNotEmpty
          ? ListView.builder(
              itemCount: filteredLogs.length,
              itemBuilder: (context, index) {
                return Dismissible(
                  key: Key(filteredLogs[index].id), // Use the unique ID for key
                  direction: DismissDirection.endToStart,
                  onDismissed: (direction) {
                    // Use the callback to update the parent state with the water intake object
                    widget.onDelete(filteredLogs[index]);

                    // Show a snackbar for confirmation
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Water intake log removed")),
                    );
                  },
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: EdgeInsets.only(right: height * .02),
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                  ),
                  child: Column(
                    children: [
                      ListTile(
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${filteredLogs[index].amount} cl',
                              style: TextStyle(
                                fontSize: height * 0.023,
                                fontWeight: FontWeight.w600,
                                color: Colors.blueGrey.shade600,
                              ),
                            ),
                            Text(
                              DateFormat('HH:mm')
                                  .format(filteredLogs[index].timestamp),
                              style: TextStyle(
                                fontSize: height * .015,
                                color: Colors.blueGrey,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Divider(
                        color: Colors.lightBlue.shade50,
                      ),
                    ],
                  ),
                );
              },
            )
          : Center(
              child: Text(
                'No logs for the selected date',
                style: TextStyle(
                  fontSize: height * 0.02,
                  color: Colors.grey,
                ),
              ),
            ),
    );
  }
}
