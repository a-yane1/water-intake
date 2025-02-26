import 'package:flutter/material.dart';

class WaterIntakeDialog extends StatefulWidget {
  final Function(int) onLogWaterIntake; // Pass water intake back to HomePage

  const WaterIntakeDialog({required this.onLogWaterIntake, super.key});

  @override
  _WaterIntakeDialogState createState() => _WaterIntakeDialogState();
}

class _WaterIntakeDialogState extends State<WaterIntakeDialog> {
  final TextEditingController _controller =
      TextEditingController(); // Controller to get user input
  final _formKey = GlobalKey<FormState>(); // Form key for validation

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Log Water Intake'),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _controller,
          keyboardType:
              TextInputType.number, // Ensure only numbers can be input
          decoration: const InputDecoration(
            labelText: 'Enter water intake (in cl)', // Allow any cl value
            hintText: 'e.g. 20 for 20cl',
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter a number';
            }
            // Validate if input is a valid number and greater than 0
            if (int.tryParse(value) == null || int.parse(value) <= 0) {
              return 'Please enter a valid number greater than 0';
            }
            return null;
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(); // Close the dialog
          },
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            if (_formKey.currentState?.validate() ?? false) {
              // Get the number from the controller and log it
              int intakeInCl =
                  int.parse(_controller.text); // Get the input in centiliters
              widget.onLogWaterIntake(intakeInCl); // Pass the value to HomePage
              Navigator.of(context).pop(); // Close the dialog after logging
            }
          },
          child: const Text('Log'),
        ),
      ],
    );
  }
}
