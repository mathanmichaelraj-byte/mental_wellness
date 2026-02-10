import 'package:flutter/material.dart';
import '../services/emotional_inference_service.dart';
import '../services/database_service.dart';
import '../models/behavior_pattern.dart';
import '../models/emotional_confidence.dart';

class MoodHistoryScreen extends StatefulWidget {
  const MoodHistoryScreen({super.key});

  @override
  State<MoodHistoryScreen> createState() => _MoodHistoryScreenState();
}

class _MoodHistoryScreenState extends State<MoodHistoryScreen> {
  EmotionalState? _currentState;
  EmotionalConfidence? _confidence;
  List<BehaviorPattern> _patterns = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    
    final state = await EmotionalInferenceService.instance.inferEmotionalState();
    final confidence = await EmotionalInferenceService.instance.calculateConfidence();
    final patterns = await DatabaseService.instance.getRecentBehaviorPatterns(days: 7);
    
    setState(() {
      _currentState = state;
      _confidence = confidence;
      _patterns = patterns;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Emotional Analysis'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCurrentStateCard(),
                  const SizedBox(height: 20),
                  _buildConfidenceCard(),
                  const SizedBox(height: 20),
                  _buildMetricsCard(),
                  const SizedBox(height: 20),
                  _buildPatternsCard(),
                ],
              ),
            ),
    );
  }

  Widget _buildCurrentStateCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Current Emotional State',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              _currentState != null
                  ? EmotionalInferenceService.instance.getStateDescription(_currentState!)
                  : 'Analyzing...',
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConfidenceCard() {
    if (_confidence == null) return const SizedBox();
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Confidence Level',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getConfidenceColor(_confidence!.level),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _confidence!.level.name.toUpperCase(),
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: _confidence!.score,
              backgroundColor: Colors.grey.shade200,
              color: _getConfidenceColor(_confidence!.level),
            ),
            const SizedBox(height: 8),
            Text(
              'Score: ${(_confidence!.score * 100).toStringAsFixed(0)}% | Signals: ${_confidence!.signalCount}',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 12),
            const Text(
              'Detected Signals:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ..._confidence!.signals.map((signal) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle, size: 16, color: Colors.green),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          signal.replaceAll('_', ' ').toUpperCase(),
                          style: const TextStyle(fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricsCard() {
    if (_patterns.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(Icons.analytics_outlined, size: 48, color: Colors.grey[400]),
              const SizedBox(height: 12),
              Text(
                'Not enough data yet',
                style: TextStyle(color: Colors.grey[600]),
              ),
              const SizedBox(height: 8),
              Text(
                'Use the app for a few days to see your patterns',
                style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    int totalOpens = 0;
    int lateNightCount = 0;
    int totalScreenTime = 0;

    for (var pattern in _patterns) {
      totalOpens += pattern.appOpenCount;
      if (pattern.timeOfDay == 'late_night') lateNightCount++;
      totalScreenTime += pattern.screenTimeSeconds;
    }

    double avgOpens = totalOpens / _patterns.length;
    double lateNightPercent = (lateNightCount / _patterns.length) * 100;
    int avgScreenTime = totalScreenTime ~/ _patterns.length;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Behavioral Metrics (Last 7 Days)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildMetricRow('Average Daily Opens', avgOpens.toStringAsFixed(1)),
            _buildMetricRow('Late Night Usage', '${lateNightPercent.toStringAsFixed(0)}%'),
            _buildMetricRow('Avg Session Time', '${avgScreenTime}s'),
            _buildMetricRow('Total Patterns', _patterns.length.toString()),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[700])),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildPatternsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'How We Calculate',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildCalculationStep('Track app usage patterns automatically'),
            _buildCalculationStep('Analyze time-of-day and frequency'),
            _buildCalculationStep('Calculate confidence from multiple signals'),
            _buildCalculationStep('Infer emotional state from patterns'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'All analysis is done locally on your device. No data is sent anywhere.',
                style: TextStyle(fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalculationStep(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(Icons.arrow_right, color: Colors.blue[400]),
          const SizedBox(width: 8),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }

  Color _getConfidenceColor(ConfidenceLevel level) {
    switch (level) {
      case ConfidenceLevel.low:
        return Colors.grey;
      case ConfidenceLevel.medium:
        return Colors.blue;
      case ConfidenceLevel.high:
        return Colors.orange;
    }
  }
}
