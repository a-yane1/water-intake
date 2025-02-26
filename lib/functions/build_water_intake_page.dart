import 'package:flutter/material.dart';

class WaterIntakePage extends StatelessWidget {
  final int totalWaterIntake;
  final List<String> intakeLogs;
  final Function(int) onFastLogWaterIntake;
  final Function(int) onDelete;

  const WaterIntakePage({
    super.key,
    required this.totalWaterIntake,
    required this.intakeLogs,
    required this.onFastLogWaterIntake,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('Total Water Intake: $totalWaterIntake cl'),
        ElevatedButton(
          onPressed: () => onFastLogWaterIntake(100),
          child: const Text('Add 100cl'),
        ),
        ListView.builder(
          shrinkWrap: true,
          itemCount: intakeLogs.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(intakeLogs[index]),
              trailing: IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () => onDelete(50), // Example
              ),
            );
          },
        ),
      ],
    );
  }
}
