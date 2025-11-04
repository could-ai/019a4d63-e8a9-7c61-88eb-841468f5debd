import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class DietTrackerScreen extends StatefulWidget {
  const DietTrackerScreen({super.key});

  @override
  State<DietTrackerScreen> createState() => _DietTrackerScreenState();
}

class _DietTrackerScreenState extends State<DietTrackerScreen> {
  List<Map<String, dynamic>> _dietEntries = [];
  final TextEditingController _mealController = TextEditingController();
  TimeOfDay? _selectedTime;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadDietEntries();
  }

  Future<void> _loadDietEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final entriesString = prefs.getStringList('diet_entries') ?? [];
    setState(() {
      _dietEntries = entriesString.map((entry) {
        final parts = entry.split('|');
        return {
          'meal': parts[0],
          'date': parts[1],
          'time': parts[2],
        };
      }).toList();
    });
  }

  Future<void> _saveDietEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final entriesString = _dietEntries.map((entry) =>
      '${entry['meal']}|${entry['date']}|${entry['time']}'
    ).toList();
    await prefs.setStringList('diet_entries', entriesString);
  }

  Future<void> _addDietEntry() async {
    if (_mealController.text.isEmpty || _selectedTime == null) return;

    final newEntry = {
      'meal': _mealController.text,
      'date': DateFormat('yyyy-MM-dd').format(_selectedDate),
      'time': _selectedTime!.format(context),
    };

    setState(() {
      _dietEntries.add(newEntry);
    });

    await _saveDietEntries();
    _mealController.clear();
    setState(() {
      _selectedTime = null;
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
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
        title: const Text('Diet Tracker'),
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
                      controller: _mealController,
                      decoration: const InputDecoration(
                        labelText: 'Meal Description',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Text('Date: ${DateFormat('MMM dd, yyyy').format(_selectedDate)}'),
                        ),
                        ElevatedButton(
                          onPressed: () => _selectDate(context),
                          child: const Text('Select Date'),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.pink),
                        ),
                      ],
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
                      onPressed: _addDietEntry,
                      child: const Text('Add Meal'),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.pink),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: _dietEntries.length,
                itemBuilder: (context, index) {
                  final entry = _dietEntries[index];
                  return Card(
                    child: ListTile(
                      title: Text(entry['meal']),
                      subtitle: Text('${entry['date']} at ${entry['time']}'),
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
