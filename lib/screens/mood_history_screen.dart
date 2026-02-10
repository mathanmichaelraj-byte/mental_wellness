import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/mood_entry.dart';
import '../services/database_service.dart';

class MoodHistoryScreen extends StatefulWidget {
  const MoodHistoryScreen({super.key});

  @override
  State<MoodHistoryScreen> createState() => _MoodHistoryScreenState();
}

class _MoodHistoryScreenState extends State<MoodHistoryScreen> {
  List<MoodEntry> _entries = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadEntries();
  }

  Future<void> _loadEntries() async {
    final entries = await DatabaseService.instance.getMoodEntries(limit: 30);
    setState(() {
      _entries = entries;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mood History')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _entries.isEmpty
              ? const Center(child: Text('No mood entries yet'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _entries.length,
                  itemBuilder: (context, index) {
                    final entry = _entries[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: _getMoodColor(entry.moodScore),
                          child: Text(
                            entry.moodScore.toString(),
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                        title: Text(DateFormat('MMM dd, yyyy - hh:mm a').format(entry.timestamp)),
                        subtitle: entry.notes != null ? Text(entry.notes!) : null,
                        trailing: _getMoodEmoji(entry.moodScore),
                      ),
                    );
                  },
                ),
    );
  }

  Color _getMoodColor(int score) {
    if (score <= 3) return Colors.red;
    if (score <= 5) return Colors.orange;
    if (score <= 7) return Colors.yellow;
    return Colors.green;
  }

  Widget _getMoodEmoji(int score) {
    String emoji;
    if (score <= 3) {
      emoji = '😢';
    } else if (score <= 5){ 
      emoji = '😐';
    }else if (score <= 7){ 
      emoji = '🙂';
    }else{
      emoji = '😊';
    }
    
    return Text(emoji, style: const TextStyle(fontSize: 24));
  }
}
