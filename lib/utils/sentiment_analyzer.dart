class SentimentAnalyzer {
  // Weighted sentiment words (word: weight)
  static const Map<String, double> _negativeWords = {
    'depressed': 3.0, 'suicidal': 3.0, 'hopeless': 3.0, 'worthless': 3.0,
    'anxious': 2.5, 'overwhelmed': 2.5, 'terrified': 2.5, 'devastated': 2.5,
    'stressed': 2.0, 'worried': 2.0, 'scared': 2.0, 'angry': 2.0, 'frustrated': 2.0,
    'sad': 1.5, 'lonely': 1.5, 'tired': 1.5, 'exhausted': 1.5, 'hurt': 1.5,
    'bad': 1.0, 'upset': 1.0, 'down': 1.0, 'unhappy': 1.0, 'difficult': 1.0,
    'fucked': 3.0, 'screwed': 2.5, 'messed up': 2.0, 'destroyed': 3.0,
    'cooked': 2.0, 'broken': 2.5, 'ruined': 3.0, 'sucked': 2.0, 'horrible': 3.0,
  };

  static const Map<String, double> _positiveWords = {
    'amazing': 3.0, 'wonderful': 3.0, 'excellent': 3.0, 'fantastic': 3.0,
    'great': 2.5, 'excited': 2.5, 'grateful': 2.5, 'blessed': 2.5,
    'happy': 2.0, 'good': 2.0, 'love': 2.0, 'joy': 2.0, 'peaceful': 2.0,
    'calm': 1.5, 'relaxed': 1.5, 'better': 1.5, 'improving': 1.5, 'hopeful': 1.5,
    'okay': 1.0, 'fine': 1.0, 'alright': 1.0, 'decent': 1.0,
  };

  // Negation words that flip sentiment
  static const List<String> _negations = [
    'not', 'no', 'never', 'neither', 'nobody', 'nothing', 'nowhere',
    'hardly', 'barely', 'scarcely', "don't", "doesn't", "didn't", "won't",
    "wouldn't", "shouldn't", "can't", "cannot"
  ];

  // Intensifiers that amplify sentiment
  static const Map<String, double> _intensifiers = {
    'very': 1.5, 'extremely': 2.0, 'really': 1.5, 'so': 1.5, 'incredibly': 2.0,
    'absolutely': 2.0, 'completely': 1.8, 'totally': 1.8, 'utterly': 2.0,
  };

  static String analyze(String text) {
    return analyzeDetailed(text)['sentiment'] as String;
  }

  static Map<String, dynamic> analyzeDetailed(String text) {
    if (text.trim().isEmpty) {
      return {'sentiment': 'neutral', 'score': 0.0, 'confidence': 0.0};
    }

    final words = text.toLowerCase().split(RegExp(r'\s+'));
    double score = 0.0;
    int wordCount = 0;
    
    for (int i = 0; i < words.length; i++) {
      final word = words[i].replaceAll(RegExp(r"[^a-z']"), '');
      if (word.isEmpty) continue;
      wordCount++;
      
      double multiplier = 1.0;
      if (i > 0) {
        final prevWord = words[i - 1].replaceAll(RegExp(r"[^a-z']"), '');
        multiplier = _intensifiers[prevWord] ?? 1.0;
      }
      
      bool isNegated = false;
      for (int j = 1; j <= 3 && i - j >= 0; j++) {
        final prevWord = words[i - j].replaceAll(RegExp(r"[^a-z']"), '');
        if (_negations.contains(prevWord)) {
          isNegated = true;
          break;
        }
      }
      
      if (_positiveWords.containsKey(word)) {
        double value = _positiveWords[word]! * multiplier;
        score += isNegated ? -value : value;
      } else if (_negativeWords.containsKey(word)) {
        double value = _negativeWords[word]! * multiplier;
        score += isNegated ? value : -value;
      }
    }
    
    final lowerText = text.toLowerCase();
    if (lowerText.contains('want to die') || lowerText.contains('end it all')) score -= 5.0;
    if (lowerText.contains('getting better') || lowerText.contains('feeling better')) score += 3.0;
    if (lowerText.contains('can\'t take') || lowerText.contains('give up')) score -= 3.0;
    if (lowerText.contains('thank') || lowerText.contains('appreciate')) score += 2.0;
    
    final exclamations = '!'.allMatches(text).length;
    final questions = '?'.allMatches(text).length;
    if (exclamations > 2) score = score.abs() * (score > 0 ? 1.3 : 1.2);
    if (questions > 2) score -= 0.5;
    
    double confidence = (score.abs() / (wordCount > 0 ? wordCount : 1)).clamp(0.0, 1.0);
    
    String sentiment;
    if (score < 0) {
      sentiment = 'negative';
    } else if (score > 2.0) {
      sentiment = 'positive';
    } else {
      sentiment = 'neutral';
    }
    
    return {
      'sentiment': sentiment,
      'score': score,
      'confidence': confidence,
    };
  }
}
