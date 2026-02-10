import 'package:flutter/material.dart';
import '../services/audio_service.dart';

class CalmAudioScreen extends StatefulWidget {
  const CalmAudioScreen({super.key});

  @override
  State<CalmAudioScreen> createState() => _CalmAudioScreenState();
}

class _CalmAudioScreenState extends State<CalmAudioScreen> {
  bool _isPlaying = false;
  String _currentTrack = '';

  @override
  void dispose() {
    AudioService.instance.stop();
    super.dispose();
  }

  Future<void> _playTrack(String track, Future<void> Function() playFunction) async {
    await AudioService.instance.stop();
    await playFunction();
    setState(() {
      _isPlaying = true;
      _currentTrack = track;
    });
  }

  Future<void> _pause() async {
    await AudioService.instance.pause();
    setState(() => _isPlaying = false);
  }

  Future<void> _stop() async {
    await AudioService.instance.stop();
    setState(() {
      _isPlaying = false;
      _currentTrack = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Calm Audio')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (_currentTrack.isNotEmpty)
              Card(
                color: Colors.blue.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text(
                        'Now Playing: $_currentTrack',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
                            iconSize: 48,
                            onPressed: _isPlaying ? _pause : () => _playTrack(_currentTrack, AudioService.instance.playCalm),
                          ),
                          IconButton(
                            icon: const Icon(Icons.stop),
                            iconSize: 48,
                            onPressed: _stop,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 24),
            const Text(
              'Choose a calming track',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                children: [
                  _buildTrackCard(
                    'Calm Meditation',
                    'Peaceful meditation sounds',
                    Icons.self_improvement,
                    Colors.blue,
                    () => _playTrack('Calm Meditation', AudioService.instance.playCalm),
                  ),
                  _buildTrackCard(
                    'Breathing Guide',
                    'Guided breathing exercise',
                    Icons.air,
                    Colors.teal,
                    () => _playTrack('Breathing Guide', AudioService.instance.playBreathing),
                  ),
                  _buildTrackCard(
                    'Nature Sounds',
                    'Relaxing nature ambience',
                    Icons.nature,
                    Colors.green,
                    () => _playTrack('Nature Sounds', AudioService.instance.playNature),
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(8),
              child: Text(
                'Note: Add audio files to assets/audio/ folder\n(calm.mp3, breathing.mp3, nature.mp3)',
                style: TextStyle(fontSize: 12, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrackCard(String title, String subtitle, IconData icon, Color color, VoidCallback onTap) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color,
          child: Icon(icon, color: Colors.white),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.play_circle_outline),
        onTap: onTap,
      ),
    );
  }
}
