// quick_add_buttons.dart
import 'package:flutter/material.dart';

class QuickAddButtons extends StatelessWidget {
  final void Function(int) onFastLogWaterIntake; // Callback to log water intake

  const QuickAddButtons({required this.onFastLogWaterIntake, super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton(
          onPressed: () {
            onFastLogWaterIntake(50); // Add 50cl (1 unit)
          },
          child: Text(
            '1 (50cl)',
            style: TextStyle(color: Colors.lightBlue.shade300),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            onFastLogWaterIntake(100); // Add 100cl (2 units)
          },
          child: Text('2 (100cl)',
              style: TextStyle(color: Colors.lightBlue.shade300)),
        ),
        ElevatedButton(
          onPressed: () {
            onFastLogWaterIntake(150); // Add 150cl (3 units)
          },
          child: Text('3 (150cl)',
              style: TextStyle(color: Colors.lightBlue.shade300)),
        ),
      ],
    );
  }
}
