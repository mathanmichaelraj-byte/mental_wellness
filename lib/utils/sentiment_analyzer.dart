class SentimentAnalyzer {
  static String analyze(String text) {
    final lowerText = text.toLowerCase();
    
    final negativeWords = ['sad', 'depressed', 'anxious', 'worried', 'stressed', 'tired', 
      'exhausted', 'hopeless', 'lonely', 'angry', 'frustrated', 'overwhelmed', 'scared',
      'afraid', 'terrible', 'awful', 'bad', 'hurt', 'pain', 'cry', 'crying'];
    
    final positiveWords = ['happy', 'good', 'great', 'excellent', 'wonderful', 'amazing',
      'excited', 'grateful', 'thankful', 'blessed', 'love', 'joy', 'peaceful', 'calm',
      'relaxed', 'better', 'improving'];
    
    int negativeCount = 0;
    int positiveCount = 0;
    
    for (var word in negativeWords) {
      if (lowerText.contains(word)) negativeCount++;
    }
    
    for (var word in positiveWords) {
      if (lowerText.contains(word)) positiveCount++;
    }
    
    if (negativeCount > positiveCount) return 'negative';
    if (positiveCount > negativeCount) return 'positive';
    return 'neutral';
  }
}
