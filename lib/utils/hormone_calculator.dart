class HormoneLevel {
  final double serotonin;
  final double dopamine;
  final double oxytocin;

  HormoneLevel({
    required this.serotonin,
    required this.dopamine,
    required this.oxytocin,
  });

  String getSerotoninLevel() => _categorize(serotonin);
  String getDopamineLevel() => _categorize(dopamine);
  String getOxytocinLevel() => _categorize(oxytocin);

  String _categorize(double value) {
    if (value < 40) return 'Low';
    if (value <= 70) return 'Normal';
    return 'High';
  }
}

class HormoneCalculator {
  static HormoneLevel calculate(int moodScore) {
    final serotonin = (moodScore / 10) * 100;
    final dopamine = ((moodScore + 2) / 12) * 100;
    final oxytocin = ((moodScore + 1) / 11) * 100;

    return HormoneLevel(
      serotonin: serotonin.clamp(0, 100),
      dopamine: dopamine.clamp(0, 100),
      oxytocin: oxytocin.clamp(0, 100),
    );
  }

  static List<String> getSuggestions(HormoneLevel levels) {
    List<String> suggestions = [];

    if (levels.serotonin < 40) {
      suggestions.add('Consider outdoor activities for mood stability');
    }
    if (levels.dopamine < 40) {
      suggestions.add('Engage in activities you enjoy to boost motivation');
    }
    if (levels.oxytocin < 40) {
      suggestions.add('Connect with supportive people or calming environments');
    }

    if (suggestions.isEmpty) {
      suggestions.add('You\'re doing well! Keep up your routine');
    }

    return suggestions;
  }
}
