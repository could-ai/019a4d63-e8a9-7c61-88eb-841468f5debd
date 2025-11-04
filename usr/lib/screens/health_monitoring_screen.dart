import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

class HealthMonitoringScreen extends StatefulWidget {
  const HealthMonitoringScreen({super.key});

  @override
  State<HealthMonitoringScreen> createState() => _HealthMonitoringScreenState();
}

class _HealthMonitoringScreenState extends State<HealthMonitoringScreen> {
  List<Map<String, dynamic>> _healthData = [];
  final TextEditingController _bpSystolicController = TextEditingController();
  final TextEditingController _bpDiastolicController = TextEditingController();
  final TextEditingController _sugarController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadHealthData();
  }

  Future<void> _loadHealthData() async {
    final prefs = await SharedPreferences.getInstance();
    final dataString = prefs.getStringList('health_data') ?? [];
    setState(() {
      _healthData = dataString.map((data) {
        final parts = data.split('|');
        return {
          'date': parts[0],
          'bp_systolic': int.parse(parts[1]),
          'bp_diastolic': int.parse(parts[2]),
          'sugar': double.parse(parts[3]),
        };
      }).toList();
    });
  }

  Future<void> _saveHealthData() async {
    final prefs = await SharedPreferences.getInstance();
    final dataString = _healthData.map((data) =>
      '${data['date']}|${data['bp_systolic']}|${data['bp_diastolic']}|${data['sugar']}'
    ).toList();
    await prefs.setStringList('health_data', dataString);
  }

  Future<void> _addHealthEntry() async {
    if (_bpSystolicController.text.isEmpty || _bpDiastolicController.text.isEmpty || _sugarController.text.isEmpty) return;

    final now = DateTime.now();
    final newEntry = {
      'date': DateFormat('yyyy-MM-dd HH:mm').format(now),
      'bp_systolic': int.parse(_bpSystolicController.text),
      'bp_diastolic': int.parse(_bpDiastolicController.text),
      'sugar': double.parse(_sugarController.text),
    };

    setState(() {
      _healthData.add(newEntry);
    });

    await _saveHealthData();

    // Update latest data for dashboard
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('latest_bp_systolic', newEntry['bp_systolic'] as int);
    await prefs.setInt('latest_bp_diastolic', newEntry['bp_diastolic'] as int);
    await prefs.setDouble('latest_sugar', newEntry['sugar'] as double);
    await prefs.setString('latest_health_date', DateFormat('MMM dd, yyyy').format(now));

    _bpSystolicController.clear();
    _bpDiastolicController.clear();
    _sugarController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Health Monitoring'),
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
                    const Text(
                      'Add Health Data',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _bpSystolicController,
                            decoration: const InputDecoration(
                              labelText: 'Systolic BP',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextField(
                            controller: _bpDiastolicController,
                            decoration: const InputDecoration(
                              labelText: 'Diastolic BP',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _sugarController,
                      decoration: const InputDecoration(
                        labelText: 'Sugar Level (mg/dL)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _addHealthEntry,
                      child: const Text('Add Entry'),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.pink),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: _healthData.isEmpty
                ? const Center(child: Text('No health data recorded yet'))
                : ListView.builder(
                    itemCount: _healthData.length,
                    itemBuilder: (context, index) {
                      final data = _healthData[index];
                      return Card(
                        child: ListTile(
                          title: Text('Date: ${data['date']}'),
                          subtitle: Text(
                            'BP: ${data['bp_systolic']}/${data['bp_diastolic']} mmHg, Sugar: ${data['sugar']} mg/dL',
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
