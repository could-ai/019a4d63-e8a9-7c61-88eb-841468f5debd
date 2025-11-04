import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/notification_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String _nextReminder = 'No reminders set';
  Map<String, dynamic> _latestHealthData = {};

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Load next medicine reminder
    final nextReminderTime = prefs.getString('next_medicine_reminder');
    if (nextReminderTime != null) {
      final reminderDate = DateTime.parse(nextReminderTime);
      setState(() {
        _nextReminder = DateFormat('MMM dd, HH:mm').format(reminderDate);
      });
    }

    // Load latest health data
    final bpSystolic = prefs.getInt('latest_bp_systolic');
    final bpDiastolic = prefs.getInt('latest_bp_diastolic');
    final sugarLevel = prefs.getDouble('latest_sugar');
    final healthDate = prefs.getString('latest_health_date');

    setState(() {
      _latestHealthData = {
        'bp': bpSystolic != null && bpDiastolic != null ? '$bpSystolic/$bpDiastolic' : 'Not recorded',
        'sugar': sugarLevel?.toString() ?? 'Not recorded',
        'date': healthDate ?? 'N/A',
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pregnancy Care Dashboard'),
        backgroundColor: Colors.pink,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Welcome to Pregnancy Care',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Next Medicine Reminder',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(_nextReminder),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Latest Health Data',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text('Blood Pressure: ${_latestHealthData['bp']}'),
                    Text('Sugar Level: ${_latestHealthData['sugar']} mg/dL'),
                    Text('Recorded: ${_latestHealthData['date']}'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Quick Actions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () => Navigator.pushNamed(context, '/medicine'),
                  icon: const Icon(Icons.medication),
                  label: const Text('Medicine'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.pink),
                ),
                ElevatedButton.icon(
                  onPressed: () => Navigator.pushNamed(context, '/diet'),
                  icon: const Icon(Icons.restaurant),
                  label: const Text('Diet'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.pink),
                ),
                ElevatedButton.icon(
                  onPressed: () => Navigator.pushNamed(context, '/health'),
                  icon: const Icon(Icons.monitor_heart),
                  label: const Text('Health'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.pink),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
