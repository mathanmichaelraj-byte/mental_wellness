import 'package:flutter/material.dart';
import '../models/mood_entry.dart';
import '../services/database_service.dart';
import '../services/notification_service.dart';
import '../utils/hormone_calculator.dart';

class MoodTrackingScreen extends StatefulWidget {
  const MoodTrackingScreen({super.key});

  @override
  State<MoodTrackingScreen> createState() => _MoodTrackingScreenState();
}

class _MoodTrackingScreenState extends State<MoodTrackingScreen> {
  int _moodScore = 5;
  final TextEditingController _notesController = TextEditingController();
  HormoneLevel? _hormoneLevel;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  void _updateHormoneLevel() {
    setState(() {
      _hormoneLevel = HormoneCalculator.calculate(_moodScore);
    });
  }

  Future<void> _saveMood() async {
    final entry = MoodEntry(
      moodScore: _moodScore,
      notes: _notesController.text.isEmpty ? null : _notesController.text,
      timestamp: DateTime.now(),
    );

    await DatabaseService.instance.insertMoodEntry(entry);
    await NotificationService.instance.showInstantNotification(
      'Mood Saved',
      'Your mood has been recorded. Keep taking care of yourself!',
    );

    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Track Your Mood')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'How are you feeling?',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Rate your mood from 1 (low) to 10 (high)',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            Center(
              child: Text(
                _moodScore.toString(),
                style: const TextStyle(fontSize: 64, fontWeight: FontWeight.bold, color: Colors.blue),
              ),
            ),
            Slider(
              value: _moodScore.toDouble(),
              min: 1,
              max: 10,
              divisions: 9,
              label: _moodScore.toString(),
              onChanged: (value) {
                setState(() => _moodScore = value.toInt());
                _updateHormoneLevel();
              },
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _notesController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Notes (optional)',
                hintText: 'Add any thoughts or context...',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            if (_hormoneLevel != null) ...[
              const Text(
                'Emotional Indicators',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              _buildHormoneCard('Serotonin', _hormoneLevel!.serotonin, _hormoneLevel!.getSerotoninLevel()),
              _buildHormoneCard('Dopamine', _hormoneLevel!.dopamine, _hormoneLevel!.getDopamineLevel()),
              _buildHormoneCard('Oxytocin', _hormoneLevel!.oxytocin, _hormoneLevel!.getOxytocinLevel()),
              const SizedBox(height: 16),
              const Text(
                'Suggestions:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ...HormoneCalculator.getSuggestions(_hormoneLevel!).map(
                (s) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text('• $s'),
                ),
              ),
            ],
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _saveMood,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text('Save Mood'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHormoneCard(String name, double value, String level) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
            Text('${value.toStringAsFixed(1)}% - $level'),
          ],
        ),
      ),
    );
  }
}
