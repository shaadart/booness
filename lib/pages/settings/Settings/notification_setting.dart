import 'package:flutter/material.dart';

class TimePickerScreen extends StatefulWidget {
  const TimePickerScreen({super.key});

  @override
  _TimePickerScreenState createState() => _TimePickerScreenState();
}

class _TimePickerScreenState extends State<TimePickerScreen> {
  TimeOfDay _selectedTime = TimeOfDay.now();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _showEmbeddedTimePicker());
  }

  void _showEmbeddedTimePicker() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return TimePickerWidget(
          initialTime: _selectedTime,
          onTimeChanged: (newTime) {
            setState(() {
              _selectedTime = newTime;
            });
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Time Picker Demo'),
      ),
      body: Center(
        child: Text(
          'Selected time: ${_selectedTime.format(context)}',
          style: const TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}

class TimePickerWidget extends StatefulWidget {
  final TimeOfDay initialTime;
  final ValueChanged<TimeOfDay> onTimeChanged;

  const TimePickerWidget({super.key, required this.initialTime, required this.onTimeChanged});

  @override
  _TimePickerWidgetState createState() => _TimePickerWidgetState();
}

class _TimePickerWidgetState extends State<TimePickerWidget> {
  late TimeOfDay _selectedTime;

  @override
  void initState() {
    super.initState();
    _selectedTime = widget.initialTime;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TimePickerSpinner(
            time: TimeOfDay(hour: _selectedTime.hour, minute: _selectedTime.minute),
            is24HourMode: false,
            normalTextStyle: const TextStyle(fontSize: 24, color: Colors.black),
            highlightedTextStyle: const TextStyle(fontSize: 24, color: Colors.blue),
            spacing: 50,
            itemHeight: 50,
            isForce2Digits: true,
            onTimeChange: (newTime) {
              setState(() {
                _selectedTime = newTime;
              });
              widget.onTimeChanged(newTime);
            },
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }
}

class TimePickerSpinner extends StatelessWidget {
  final TimeOfDay time;
  final bool is24HourMode;
  final TextStyle normalTextStyle;
  final TextStyle highlightedTextStyle;
  final double spacing;
  final double itemHeight;
  final bool isForce2Digits;
  final ValueChanged<TimeOfDay> onTimeChange;

  const TimePickerSpinner({super.key, 
    required this.time,
    this.is24HourMode = true,
    required this.normalTextStyle,
    required this.highlightedTextStyle,
    this.spacing = 40.0,
    this.itemHeight = 30.0,
    this.isForce2Digits = true,
    required this.onTimeChange,
  });

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        Text(
          'Time Picker Spinner',
          style: TextStyle(fontSize: 24),
        ),
        // Add your custom time picker spinner implementation here.
        // This is just a placeholder widget.
        Placeholder(
          fallbackHeight: 150,
        ),
      ],
    );
  }
}
