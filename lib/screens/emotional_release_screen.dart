import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/emotional_note.dart';
import '../services/database_service.dart';
import '../utils/sentiment_analyzer.dart';

class EmotionalReleaseScreen extends StatefulWidget {
  const EmotionalReleaseScreen({super.key});

  @override
  State<EmotionalReleaseScreen> createState() => _EmotionalReleaseScreenState();
}

class _EmotionalReleaseScreenState extends State<EmotionalReleaseScreen> {
  final TextEditingController _controller = TextEditingController();
  List<EmotionalNote> _notes = [];
  int _expiryHours = 24;

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadNotes() async {
    await DatabaseService.instance.deleteExpiredNotes();
    final notes = await DatabaseService.instance.getActiveEmotionalNotes();
    setState(() => _notes = notes);
  }

  Future<void> _saveNote() async {
    if (_controller.text.isEmpty) return;

    final sentiment = SentimentAnalyzer.analyze(_controller.text);
    
    final note = EmotionalNote(
      content: _controller.text,
      createdAt: DateTime.now(),
      expiresAt: DateTime.now().add(Duration(hours: _expiryHours)),
      sentiment: sentiment,
    );

    await DatabaseService.instance.insertEmotionalNote(note);
    _controller.clear();
    _loadNotes();
  }

  Future<void> _deleteNote(int id) async {
    await DatabaseService.instance.deleteEmotionalNote(id);
    _loadNotes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Emotional Release')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Express your feelings safely',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Your notes will auto-delete after the selected time',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _controller,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    hintText: 'Write your thoughts here...',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Text('Auto-delete after: '),
                    DropdownButton<int>(
                      value: _expiryHours,
                      items: [1, 6, 12, 24, 48].map((h) {
                        return DropdownMenuItem(
                          value: h,
                          child: Text('$h hours'),
                        );
                      }).toList(),
                      onChanged: (value) => setState(() => _expiryHours = value!),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: _saveNote,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 45),
                  ),
                  child: const Text('Save Note'),
                ),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: _notes.isEmpty
                ? const Center(child: Text('No active notes'))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _notes.length,
                    itemBuilder: (context, index) {
                      final note = _notes[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(note.content),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Expires: ${DateFormat('MMM dd, hh:mm a').format(note.expiresAt)}',
                                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, size: 20),
                                    onPressed: () => _deleteNote(note.id!),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
