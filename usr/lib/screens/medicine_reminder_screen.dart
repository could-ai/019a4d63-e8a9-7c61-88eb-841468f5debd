import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/notification_service.dart';
import 'package:intl/intl.dart';

class MedicineReminderScreen extends StatefulWidget {
  const MedicineReminderScreen({super.key});

  @override
  State<MedicineReminderScreen> createState() => _MedicineReminderScreenState();
}

class _MedicineReminderScreenState extends State<MedicineReminderScreen> {
  List<Map<String, dynamic>> _reminders = [];
  final TextEditingController _medicineController = TextEditingController();
  TimeOfDay? _selectedTime;

  @override
  void initState() {
    super.initState();
    _loadReminders();
  }

  Future<void> _loadReminders() async {
    final prefs = await SharedPreferences.getInstance();
    final remindersString = prefs.getStringList('medicine_reminders') ?? [];
    setState(() {
      _reminders = remindersString.map((reminder) {
        final parts = reminder.split('|');
        return {
          'medicine': parts[0],
          'time': parts[1],
          'id': int.parse(parts[2]),
        };
      }).toList();
    });
  }

  Future<void> _saveReminders() async {
    final prefs = await SharedPreferences.getInstance();
    final remindersString = _reminders.map((reminder) =>
      '${reminder['medicine']}|${reminder['time']}|${reminder['id']}'
    ).toList();
    await prefs.setStringList('medicine_reminders', remindersString);
  }

  Future<void> _addReminder() async {
    if (_medicineController.text.isEmpty || _selectedTime == null) return;

    final now = DateTime.now();
    final reminderTime = DateTime(
      now.year, now.month, now.day, _selectedTime!.hour, _selectedTime!.minute);

    final reminderId = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final newReminder = {
      'medicine': _medicineController.text,
      'time': _selectedTime!.format(context),
      'id': reminderId,
    };

    setState(() {
      _reminders.add(newReminder);
    });

    await _saveReminders();
    await NotificationService.scheduleNotification(
      id: reminderId,
      title: 'Medicine Reminder',
      body: 'Time to take ${_medicineController.text}',
      scheduledTime: reminderTime,
    );

    // Update dashboard
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('next_medicine_reminder', reminderTime.toIso8601String());

    _medicineController.clear();
    setState(() {
      _selectedTime = null;
    });
  }

  Future<void> _removeReminder(int index) async {
    final reminder = _reminders[index];
    await NotificationService.cancelNotification(reminder['id']);
    setState(() {
      _reminders.removeAt(index);
    });
    await _saveReminders();
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Medicine Reminders'),
        backgroundColor: Colors.pink,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    TextField(
                      controller: _medicineController,
                      decoration: const InputDecoration(
                        labelText: 'Medicine Name',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Text(_selectedTime == null
                            ? 'No time selected'
                            : 'Time: ${_selectedTime!.format(context)}'),
                        ),
                        ElevatedButton(
                          onPressed: () => _selectTime(context),
                          child: const Text('Select Time'),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.pink),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _addReminder,
                      child: const Text('Add Reminder'),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.pink),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: _reminders.length,
                itemBuilder: (context, index) {
                  final reminder = _reminders[index];
                  return Card(
                    child: ListTile(
                      title: Text(reminder['medicine']),
                      subtitle: Text('Time: ${reminder['time']}'),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _removeReminder(index),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
